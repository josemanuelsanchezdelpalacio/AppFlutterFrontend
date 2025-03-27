import 'package:flutter/material.dart';
import 'package:flutter_proyecto_app/data/transaccion.dart';
import 'package:flutter_proyecto_app/services/metas_ahorro_service.dart';
import 'package:flutter_proyecto_app/services/presupuestos_service.dart';
import 'package:flutter_proyecto_app/theme/app_theme.dart';

class AsignacionTransaccionScreen extends StatefulWidget {
  final int idUsuario;
  final TipoTransacciones tipoTransaccion;
  final String categoria;

  const AsignacionTransaccionScreen({
    Key? key,
    required this.idUsuario,
    required this.tipoTransaccion,
    required this.categoria,
  }) : super(key: key);

  @override
  _AsignacionTransaccionScreenState createState() => _AsignacionTransaccionScreenState();
}

class _AsignacionTransaccionScreenState extends State<AsignacionTransaccionScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  List<Map<String, dynamic>> _presupuestos = [];
  List<Map<String, dynamic>> _metas = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _cargarDatos();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _cargarDatos() async {
    setState(() {
      _isLoading = true;
    });

    try {
      if (widget.tipoTransaccion == TipoTransacciones.GASTO) {
        final presupuestos = await PresupuestosService().obtenerPresupuestos(widget.idUsuario);
        final fechaActual = DateTime.now();
        
        _presupuestos = presupuestos.where((presupuesto) {
          return presupuesto.categoria == widget.categoria &&
              !fechaActual.isBefore(presupuesto.fechaInicio) &&
              !fechaActual.isAfter(presupuesto.fechaFin);
        }).map((p) => {
          'id': p.id,
          'nombre': p.categoria,
          'cantidad': p.cantidad,
          'restante': p.cantidadRestante,
        }).toList();
      } else {
        final metas = await MetasAhorroService().obtenerMetasAhorro(widget.idUsuario);
        
        _metas = metas.where((meta) {
          return meta.categoria == widget.categoria && !meta.completada;
        }).map((m) => {
          'id': m.id,
          'nombre': m.nombre,
          'objetivo': m.cantidadObjetivo,
          'actual': m.cantidadActual,
          'porcentaje': (m.cantidadActual / m.cantidadObjetivo * 100),
        }).toList();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar datos: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Asignar transacción'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Presupuestos', icon: Icon(Icons.account_balance_wallet)),
            Tab(text: 'Metas', icon: Icon(Icons.savings)),
          ],
          labelColor: AppTheme.naranja,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppTheme.naranja,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Pestaña de Presupuestos
          _buildPresupuestosTab(),
          
          // Pestaña de Metas
          _buildMetasTab(),
        ],
      ),
    );
  }

  Widget _buildPresupuestosTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.naranja));
    }

    if (widget.tipoTransaccion != TipoTransacciones.GASTO) {
      return const Center(
        child: Text(
          'Solo puedes asignar gastos a presupuestos',
          style: TextStyle(color: AppTheme.blanco, fontSize: 16),
        ),
      );
    }

    if (_presupuestos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.account_balance_wallet, size: 50, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'No hay presupuestos disponibles para la categoría ${widget.categoria}',
              style: const TextStyle(color: Colors.grey, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _presupuestos.length,
      itemBuilder: (context, index) {
        final presupuesto = _presupuestos[index];
        return Card(
          color: AppTheme.gris,
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            title: Text(
              presupuesto['nombre'],
              style: const TextStyle(color: AppTheme.blanco),
            ),
            subtitle: Text(
              '${presupuesto['restante'].toStringAsFixed(2)}/${presupuesto['cantidad'].toStringAsFixed(2)} restantes',
              style: TextStyle(
                color: presupuesto['restante'] > 0 ? Colors.green : Colors.red,
              ),
            ),
            trailing: Icon(
              Icons.arrow_forward_ios,
              color: AppTheme.naranja,
              size: 16,
            ),
            onTap: () {
              Navigator.pop(context, {
                'tipo': 'presupuesto',
                'id': presupuesto['id'],
              });
            },
          ),
        );
      },
    );
  }

  Widget _buildMetasTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.naranja));
    }

    if (widget.tipoTransaccion != TipoTransacciones.INGRESO) {
      return const Center(
        child: Text(
          'Solo puedes asignar ingresos a metas',
          style: TextStyle(color: AppTheme.blanco, fontSize: 16),
        ),
      );
    }

    if (_metas.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.savings, size: 50, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'No hay metas disponibles para la categoría ${widget.categoria}',
              style: const TextStyle(color: Colors.grey, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _metas.length,
      itemBuilder: (context, index) {
        final meta = _metas[index];
        return Card(
          color: AppTheme.gris,
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            title: Text(
              meta['nombre'],
              style: const TextStyle(color: AppTheme.blanco),
            ),
            subtitle: Text(
              '${meta['actual'].toStringAsFixed(2)}/${meta['objetivo'].toStringAsFixed(2)} (${meta['porcentaje'].toStringAsFixed(0)}%)',
              style: TextStyle(
                color: meta['actual'] >= meta['objetivo'] ? Colors.green : AppTheme.naranja,
              ),
            ),
            trailing: Icon(
              Icons.arrow_forward_ios,
              color: AppTheme.naranja,
              size: 16,
            ),
            onTap: () {
              Navigator.pop(context, {
                'tipo': 'meta',
                'id': meta['id'],
              });
            },
          ),
        );
      },
    );
  }
}


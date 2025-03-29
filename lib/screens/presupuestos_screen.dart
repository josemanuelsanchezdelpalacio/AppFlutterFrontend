import 'package:flutter/material.dart';
import 'package:flutter_proyecto_app/components/barra_inferior_secciones.dart';
import 'package:flutter_proyecto_app/components/filtro_elementos.dart';
import 'package:flutter_proyecto_app/components/menu_desplegable.dart';
import 'package:flutter_proyecto_app/data/presupuesto.dart';
import 'package:flutter_proyecto_app/models/presupuestos_viewmodel.dart';
import 'package:flutter_proyecto_app/screens/add_presupuestos_screen.dart';
import 'package:flutter_proyecto_app/theme/app_theme.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class PresupuestosScreen extends StatefulWidget {
  final int idUsuario;

  const PresupuestosScreen({super.key, required this.idUsuario});

  @override
  State<PresupuestosScreen> createState() => _PresupuestosScreenState();
}

class _PresupuestosScreenState extends State<PresupuestosScreen> {
  late PresupuestosViewModel _viewModel;
  bool _isSelectionMode = false;
  Set<int> _selectedPresupuestos = {};

  @override
  void initState() {
    super.initState();
    _viewModel = PresupuestosViewModel(widget.idUsuario);
    _viewModel.addListener(_actualizarVista);
    _viewModel.cargarPresupuestos();
  }

  @override
  void dispose() {
    _viewModel.removeListener(_actualizarVista);
    _viewModel.dispose();
    super.dispose();
  }

  void _actualizarVista() {
    if (mounted) setState(() {});
  }

  void _navegarA({Presupuesto? presupuestoParaEditar}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddPresupuestoScreen(
          idUsuario: widget.idUsuario,
          presupuestoParaEditar: presupuestoParaEditar,
        ),
      ),
    ).then((_) => _viewModel.cargarPresupuestos());
  }

  void _gestionarSeleccion(
      {bool? toggleMode, int? presupuestoId, bool? selectAll}) {
    setState(() {
      if (toggleMode != null) {
        _isSelectionMode = toggleMode;
        if (!_isSelectionMode) _selectedPresupuestos.clear();
      }

      if (presupuestoId != null) {
        if (_selectedPresupuestos.contains(presupuestoId)) {
          _selectedPresupuestos.remove(presupuestoId);
        } else {
          _selectedPresupuestos.add(presupuestoId);
        }
        if (_selectedPresupuestos.isEmpty && _isSelectionMode) {
          _isSelectionMode = false;
        }
      }

      if (selectAll != null) {
        if (_selectedPresupuestos.length ==
            _viewModel.presupuestosFiltrados.length) {
          _selectedPresupuestos.clear();
          _isSelectionMode = false;
        } else {
          _selectedPresupuestos =
              _viewModel.presupuestosFiltrados.map((p) => p.id!).toSet();
        }
      }
    });
  }

  void _confirmarEliminar(List<Presupuesto> presupuestos) {
    final bool esSingular = presupuestos.length == 1;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.gris,
        title: Text(esSingular
            ? 'Confirmar eliminación'
            : 'Confirmar eliminación múltiple'),
        content: Text(esSingular
            ? '¿Estás seguro de eliminar el presupuesto "${presupuestos.first.categoria}"?'
            : '¿Estás seguro de eliminar ${presupuestos.length} presupuestos?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar',
                style: TextStyle(color: AppTheme.blanco)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _eliminarPresupuestos(presupuestos);
            },
            child: const Text('Eliminar',
                style: TextStyle(color: AppTheme.naranja)),
          ),
        ],
      ),
    );
  }

  Future<void> _eliminarPresupuestos(List<Presupuesto> presupuestos) async {
    try {
      for (var presupuesto in presupuestos) {
        await _viewModel.eliminarPresupuesto(presupuesto.id!);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(presupuestos.length == 1
                ? 'Presupuesto eliminado con éxito'
                : '${presupuestos.length} presupuestos eliminados con éxito'),
            backgroundColor: Colors.green,
          ),
        );
      }

      _gestionarSeleccion(toggleMode: false);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al eliminar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _mostrarOpcionesPresupuesto(Presupuesto presupuesto) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.gris,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              presupuesto.categoria,
              style: const TextStyle(
                color: AppTheme.blanco,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '${presupuesto.cantidadGastada.toStringAsFixed(2)} € / ${presupuesto.cantidad.toStringAsFixed(2)} €',
              style: TextStyle(
                color: _viewModel.estaCompletado(presupuesto)
                    ? Colors.red
                    : AppTheme.naranja,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.edit, color: AppTheme.naranja),
              title: const Text('Editar presupuesto',
                  style: TextStyle(color: AppTheme.blanco)),
              onTap: () {
                Navigator.pop(context);
                _navegarA(presupuestoParaEditar: presupuesto);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Eliminar presupuesto',
                  style: TextStyle(color: AppTheme.blanco)),
              onTap: () {
                Navigator.pop(context);
                _confirmarEliminar([presupuesto]);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoCard(String title, String value, IconData icon,
      {Color color = AppTheme.naranja}) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        Text(title, style: const TextStyle(fontSize: 14)),
      ],
    );
  }

  Widget _infoRow(String label, String value, [Color? valueColor]) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(color: AppTheme.blanco, fontSize: 14)),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: valueColor ?? AppTheme.blanco,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.account_balance_wallet,
              size: 70, color: Colors.grey),
          const SizedBox(height: 20),
          const Text('No hay presupuestos',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          const Text(
            'Añade tu primer presupuesto pulsando el botón +',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: () => _navegarA(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.naranja,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            icon: const Icon(Icons.add, color: Colors.black),
            label: const Text(
              'NUEVO PRESUPUESTO',
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsView() {
    String mensajeFiltro = '';

    if (_viewModel.filtroActual != null && _viewModel.mesFiltro != null) {
      mensajeFiltro =
          'No hay presupuestos con el filtro: ${_viewModel.filtroActual} en ${DateFormat('MMMM yyyy', 'es').format(_viewModel.mesFiltro!)}';
    } else if (_viewModel.filtroActual != null) {
      mensajeFiltro =
          'No hay presupuestos con el filtro: ${_viewModel.filtroActual}';
    } else if (_viewModel.mesFiltro != null) {
      mensajeFiltro =
          'No hay presupuestos para el mes: ${DateFormat('MMMM yyyy', 'es').format(_viewModel.mesFiltro!)}';
    } else {
      mensajeFiltro = 'No hay presupuestos con los filtros seleccionados';
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.filter_list_off, size: 70, color: Colors.grey),
          const SizedBox(height: 20),
          Text(
            mensajeFiltro,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          TextButton.icon(
            onPressed: () {
              _viewModel.setFiltro(null);
              _viewModel.setMesFiltro(null);
            },
            icon: const Icon(Icons.filter_alt_off),
            label: const Text('Quitar filtros'),
            style: TextButton.styleFrom(foregroundColor: AppTheme.naranja),
          ),
        ],
      ),
    );
  }

  Widget _buildResumenCard() {
    return Card(
      color: AppTheme.gris,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Resumen de presupuestos',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _infoCard('Total', _viewModel.presupuestos.length.toString(),
                    Icons.list_alt),
                _infoCard(
                  'Superados',
                  _viewModel.presupuestosCompletados.toString(),
                  Icons.warning,
                  color: Colors.red,
                ),
                _infoCard(
                  'En curso',
                  _viewModel.presupuestosEnCurso.toString(),
                  Icons.check_circle,
                  color: Colors.green,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPresupuestoCard(Presupuesto presupuesto) {
    double progreso = _viewModel.calcularProgreso(presupuesto);
    bool estaCompletado = _viewModel.estaCompletado(presupuesto);
    bool estaVencido = _viewModel.estaVencido(presupuesto);
    bool isSelected = presupuesto.id != null &&
        _selectedPresupuestos.contains(presupuesto.id!);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: isSelected ? AppTheme.naranja.withOpacity(0.3) : AppTheme.gris,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected
              ? AppTheme.naranja
              : estaCompletado
                  ? Colors.green
                  : estaVencido
                      ? Colors.orange
                      : Colors.transparent,
          width: isSelected || estaCompletado || estaVencido ? 1.5 : 0,
        ),
      ),
      child: InkWell(
        onTap: _isSelectionMode
            ? () => _gestionarSeleccion(presupuestoId: presupuesto.id!)
            : () => _mostrarOpcionesPresupuesto(presupuesto),
        onLongPress: !_isSelectionMode
            ? () {
                _gestionarSeleccion(toggleMode: true);
                _gestionarSeleccion(presupuestoId: presupuesto.id!);
              }
            : null,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (_isSelectionMode)
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Icon(
                        isSelected ? Icons.check_circle : Icons.circle_outlined,
                        color: isSelected ? AppTheme.naranja : null,
                      ),
                    ),
                  Icon(
                    _viewModel.obtenerIconoCategoria(presupuesto.categoria),
                    color: AppTheme.naranja,
                    size: 28,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      presupuesto.categoria,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  if (!_isSelectionMode) ...[
                    if (estaCompletado)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Superado',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold),
                        ),
                      )
                    else if (estaVencido)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Vencido',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    const Icon(Icons.chevron_right, color: Colors.grey),
                  ],
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  CircularPercentIndicator(
                    radius: 35.0,
                    lineWidth: 8.0,
                    percent: progreso > 1.0 ? 1.0 : progreso,
                    center: Text(
                      '${(progreso * 100).toInt()}%',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14.0),
                    ),
                    progressColor: estaCompletado
                        ? Colors.green
                        : estaVencido
                            ? Colors.orange
                            : AppTheme.naranja,
                    backgroundColor: AppTheme.colorFondo,
                    circularStrokeCap: CircularStrokeCap.round,
                    animation: true,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _infoRow('Límite:',
                            '${presupuesto.cantidad.toStringAsFixed(2)} €'),
                        const SizedBox(height: 4),
                        _infoRow(
                          'Gastado:',
                          '${presupuesto.cantidadGastada.toStringAsFixed(2)} €',
                          estaCompletado ? Colors.green : null,
                        ),
                        const SizedBox(height: 4),
                        _infoRow(
                          'Restante:',
                          '${(presupuesto.cantidad - presupuesto.cantidadGastada).toStringAsFixed(2)} €',
                          estaCompletado ? Colors.green : null,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.calendar_today,
                      size: 14, color: AppTheme.blanco),
                  const SizedBox(width: 4),
                  Text(
                    'Periodo: ${DateFormat('dd/MM/yyyy').format(presupuesto.fechaInicio)} - ${DateFormat('dd/MM/yyyy').format(presupuesto.fechaFin)}',
                    style: TextStyle(
                      color: estaVencido ? Colors.orange : AppTheme.blanco,
                      fontWeight:
                          estaVencido ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.timer_outlined,
                      size: 14, color: AppTheme.blanco),
                  const SizedBox(width: 4),
                  Text(
                    _viewModel.obtenerTextoTiempoRestante(presupuesto),
                    style: TextStyle(
                      color: _viewModel.diasRestantes(presupuesto) < 7
                          ? Colors.orange
                          : AppTheme.blanco,
                      fontWeight: _viewModel.diasRestantes(presupuesto) < 7
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPresupuestosList() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          FiltroElementos(
            filtroActual: _viewModel.filtroActual,
            onFilterChanged: (filtro) => _viewModel.setFiltro(filtro),
            filtros: _viewModel.filtros,
            fechaFiltro: null,
            onFechaChanged: (fecha) {},
            mesFiltro: _viewModel.mesFiltro,
            onMesChanged: _viewModel.setMesFiltro,
            mesesDisponibles: _viewModel.mesesFiltro,
          ),
          if (!_isSelectionMode) _buildResumenCard(),
          if (!_isSelectionMode) const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: _viewModel.presupuestosFiltrados.length,
              itemBuilder: (context, index) => _buildPresupuestoCard(
                  _viewModel.presupuestosFiltrados[index]),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSelectionMode
            ? Text('${_selectedPresupuestos.length} seleccionados')
            : const Text('Mis presupuestos',
                style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: _isSelectionMode
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => _gestionarSeleccion(toggleMode: false),
              )
            : null,
        actions: [
          if (_isSelectionMode) ...[
            IconButton(
              icon: const Icon(Icons.select_all),
              tooltip: 'Seleccionar todo',
              onPressed: () => _gestionarSeleccion(selectAll: true),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              tooltip: 'Eliminar seleccionados',
              onPressed: _selectedPresupuestos.isNotEmpty
                  ? () {
                      List<Presupuesto> presupuestosParaEliminar = _viewModel
                          .presupuestos
                          .where((p) =>
                              p.id != null &&
                              _selectedPresupuestos.contains(p.id!))
                          .toList();
                      _confirmarEliminar(presupuestosParaEliminar);
                    }
                  : null,
            ),
          ] else if (_viewModel.presupuestos.isNotEmpty) ...[
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              tooltip: 'Selección múltiple',
              onPressed: () => _gestionarSeleccion(toggleMode: true),
            ),
          ],
        ],
      ),
      drawer: !_isSelectionMode
          ? MenuDesplegable(idUsuario: widget.idUsuario)
          : null,
      body: _viewModel.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.naranja))
          : _viewModel.errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          color: Colors.red, size: 48),
                      const SizedBox(height: 16),
                      Text(
                        _viewModel.errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _viewModel.cargarPresupuestos,
                        style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.naranja),
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                )
              : _viewModel.presupuestos.isEmpty
                  ? _buildEmptyState()
                  : _viewModel.presupuestosFiltrados.isEmpty
                      ? _buildNoResultsView()
                      : _buildPresupuestosList(),
      floatingActionButton:
          _viewModel.presupuestos.isNotEmpty && !_isSelectionMode
              ? FloatingActionButton(
                  onPressed: () => _navegarA(),
                  backgroundColor: AppTheme.naranja,
                  child: const Icon(Icons.add, color: Colors.black),
                )
              : null,
      bottomNavigationBar: BarraInferiorSecciones(
        idUsuario: widget.idUsuario,
        indexActual: 3,
      ),
    );
  }
}


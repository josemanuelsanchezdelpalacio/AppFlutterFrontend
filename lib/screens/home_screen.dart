import 'package:flutter/material.dart';
import 'package:flutter_proyecto_app/components/barra_inferior_secciones.dart';
import 'package:flutter_proyecto_app/components/menu_desplegable.dart';
import 'package:flutter_proyecto_app/data/metas_ahorro.dart';
import 'package:flutter_proyecto_app/data/presupuesto.dart';
import 'package:flutter_proyecto_app/data/transaccion.dart';
import 'package:flutter_proyecto_app/models/home_viewmodel.dart';
import 'package:flutter_proyecto_app/screens/auth_screens/login_screen.dart';
import 'package:flutter_proyecto_app/services/auth_service.dart';
import 'package:flutter_proyecto_app/theme/app_theme.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/percent_indicator.dart';

class HomeScreen extends StatefulWidget {
  final int idUsuario;

  const HomeScreen({super.key, required this.idUsuario});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late HomeViewModel _viewModel;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _viewModel = HomeViewModel(widget.idUsuario);
    _viewModel.cargarDatos();
    _viewModel.addListener(_actualizarEstado);
  }

  @override
  void dispose() {
    _viewModel.removeListener(_actualizarEstado);
    _viewModel.dispose();
    super.dispose();
  }

  void _actualizarEstado() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _mostrarDialogoConfirmacion() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppTheme.gris,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            '¿Cerrar sesión?',
            style: TextStyle(
              color: AppTheme.blanco,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            '¿Estás seguro que deseas cerrar tu sesión?',
            style: TextStyle(
              color: AppTheme.blanco,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'Cancelar',
                style: TextStyle(
                  color: AppTheme.blanco,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text(
                'Cerrar sesión',
                style: TextStyle(
                  color: AppTheme.naranja,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                _cerrarSesion();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _cerrarSesion() async {
    try {
      await _authService.cerrarSesion();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cerrar sesión: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.colorFondo,
      appBar: AppBar(
        backgroundColor: AppTheme.colorFondo,
        elevation: 0,
        title: const Text(
          'Resumen financiero',
          style: TextStyle(
            color: AppTheme.blanco,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.logout,
              color: Colors.white,
            ),
            tooltip: 'Cerrar sesion',
            onPressed: _mostrarDialogoConfirmacion,
          ),
        ],
      ),
      drawer: MenuDesplegable(idUsuario: widget.idUsuario),
      body: _viewModel.isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppTheme.naranja,
                strokeWidth: 4,
              ),
            )
          : _viewModel.errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 50,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _viewModel.errorMessage,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _viewModel.cargarDatos,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.naranja,
                        ),
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                )
              : _buildBody(),
      bottomNavigationBar: BarraInferiorSecciones(
        idUsuario: widget.idUsuario,
        indexActual: 0,
      ),
    );
  }

  Widget _buildBody() {
    return RefreshIndicator(
      onRefresh: _viewModel.cargarDatos,
      color: AppTheme.naranja,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDateSelector(),
              _buildResumenMensual(),
              const SizedBox(height: 24),
              _buildSectionHeader('Ultimas transacciones', Icons.receipt_long),
              _buildUltimasTransacciones(),
              const SizedBox(height: 24),
              _buildSectionHeader(
                  'Presupuestos activos', Icons.account_balance_wallet),
              _buildPresupuestosActivos(),
              const SizedBox(height: 24),
              _buildSectionHeader('Metas de ahorro', Icons.savings),
              _buildMetasAhorro(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: AppTheme.blanco),
            onPressed: _viewModel.cambiarMesAnterior,
          ),
          GestureDetector(
            onTap: _viewModel.cambiarMesActual,
            child: Text(
              DateFormat('MMMM yyyy', 'es_ES').format(_viewModel.fechaInicio),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.blanco,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios, color: AppTheme.blanco),
            onPressed: _viewModel.cambiarMesSiguiente,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppTheme.naranja.withOpacity(0.3),
            width: 2,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.blanco,
            ),
          ),
          Icon(icon, color: AppTheme.naranja, size: 24),
        ],
      ),
    );
  }

  Widget _buildResumenMensual() {
    final formatoMoneda = NumberFormat.currency(locale: 'es_MX', symbol: '\$');

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8, top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            formatoMoneda.format(_viewModel.balanceTotal),
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: _viewModel.balanceTotal >= 0 ? Colors.green : Colors.red,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildFinancialCard(
                  'Ingresos',
                  formatoMoneda.format(_viewModel.ingresosTotal),
                  Icons.arrow_upward,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildFinancialCard(
                  'Gastos',
                  formatoMoneda.format(_viewModel.gastosTotal),
                  Icons.arrow_downward,
                  Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialCard(
      String title, String amount, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: AppTheme.gris,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.blanco.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  amount,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.blanco,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUltimasTransacciones() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.gris.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: _viewModel.ultimasTransacciones.isEmpty
          ? const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(
                child: Text(
                  'No hay transacciones para este período',
                  style: TextStyle(color: AppTheme.blanco),
                ),
              ),
            )
          : ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _viewModel.ultimasTransacciones.length,
              separatorBuilder: (context, index) => const Divider(
                color: AppTheme.gris,
                height: 1,
              ),
              itemBuilder: (context, index) {
                return _buildTransaccionItem(
                    _viewModel.ultimasTransacciones[index]);
              },
            ),
    );
  }

  Widget _buildTransaccionItem(Transaccion transaccion) {
    final formatoMoneda = NumberFormat.currency(locale: 'es_MX', symbol: '\$');
    final bool esIngreso =
        transaccion.tipoTransaccion == TipoTransacciones.INGRESO;
    final Color colorMonto = esIngreso ? Colors.green : Colors.red;
    final IconData icono =
        esIngreso ? Icons.arrow_upward : Icons.arrow_downward;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorMonto.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icono, color: colorMonto, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaccion.descripcion,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.blanco,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  transaccion.categoria,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.blanco.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                esIngreso
                    ? '+ ${formatoMoneda.format(transaccion.cantidad)}'
                    : '- ${formatoMoneda.format(transaccion.cantidad)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: colorMonto,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                DateFormat('dd/MM/yyyy').format(transaccion.fechaTransaccion),
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.blanco.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPresupuestosActivos() {
    return Container(
      height: 140,
      decoration: BoxDecoration(
        color: AppTheme.gris.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: _viewModel.presupuestos.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'No hay presupuestos activos',
                  style: TextStyle(color: AppTheme.blanco),
                ),
              ),
            )
          : ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _viewModel.presupuestos.length,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              itemBuilder: (context, index) =>
                  _buildPresupuestoItem(_viewModel.presupuestos[index]),
            ),
    );
  }

  Widget _buildPresupuestoItem(Presupuesto presupuesto) {
    final formatoMoneda = NumberFormat.currency(locale: 'es_MX', symbol: '\$');
    final double gastado = presupuesto.cantidadGastada;
    final double porcentaje = gastado / presupuesto.cantidad;

    return Container(
      width: 160,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.gris,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            presupuesto.categoria,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppTheme.blanco,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          LinearPercentIndicator(
            lineHeight: 10,
            percent: porcentaje > 1 ? 1 : (porcentaje < 0 ? 0 : porcentaje),
            progressColor: porcentaje > 0.9 ? Colors.red : AppTheme.naranja,
            backgroundColor: AppTheme.blanco.withOpacity(0.2),
            barRadius: const Radius.circular(5),
            padding: EdgeInsets.zero,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${(porcentaje * 100).toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.blanco.withOpacity(0.7),
                ),
              ),
              Text(
                formatoMoneda.format(gastado),
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.blanco,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'de ${formatoMoneda.format(presupuesto.cantidad)}',
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.blanco.withOpacity(0.7),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildMetasAhorro() {
    return Container(
      height: 140,
      decoration: BoxDecoration(
        color: AppTheme.gris.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: _viewModel.metasAhorro.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'No hay metas de ahorro activas',
                  style: TextStyle(color: AppTheme.blanco),
                ),
              ),
            )
          : ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _viewModel.metasAhorro.length,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              itemBuilder: (context, index) =>
                  _buildMetaAhorroItem(_viewModel.metasAhorro[index]),
            ),
    );
  }

  Widget _buildMetaAhorroItem(MetaAhorro meta) {
    final formatoMoneda = NumberFormat.currency(locale: 'es_MX', symbol: '\$');
    final double porcentaje = meta.cantidadActual / meta.cantidadObjetivo;
    final DateTime hoy = DateTime.now();
    final bool fechaVencida = meta.fechaObjetivo.isBefore(hoy);

    // Asegurarnos de que el porcentaje esté entre 0 y 1
    final double porcentajeAjustado = porcentaje.clamp(0.0, 1.0);

    return Container(
      width: 160,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.gris,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            meta.nombre,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppTheme.blanco,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          LinearPercentIndicator(
            lineHeight: 10,
            percent: porcentajeAjustado,
            progressColor: fechaVencida ? Colors.red : Colors.green,
            backgroundColor: AppTheme.blanco.withOpacity(0.2),
            barRadius: const Radius.circular(5),
            padding: EdgeInsets.zero,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${(porcentajeAjustado * 100).toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.blanco.withOpacity(0.7),
                ),
              ),
              Text(
                formatoMoneda.format(meta.cantidadActual),
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.blanco,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'de ${formatoMoneda.format(meta.cantidadObjetivo)}',
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.blanco.withOpacity(0.7),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}


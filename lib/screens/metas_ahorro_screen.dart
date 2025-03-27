import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:flutter_proyecto_app/components/barra_inferior_secciones.dart';
=======
import 'package:flutter_proyecto_app/components/custom_bottom_app_bar.dart';
>>>>>>> 8f1d397338e300a443102a7f54c5ce411ddd3503
import 'package:flutter_proyecto_app/components/filtro_elementos.dart';
import 'package:flutter_proyecto_app/components/menu_desplegable.dart';
import 'package:flutter_proyecto_app/data/metas_ahorro.dart';
import 'package:flutter_proyecto_app/models/metas_ahorro_viewmodel.dart';
import 'package:flutter_proyecto_app/screens/add_metas_ahorro_screen.dart';
import 'package:flutter_proyecto_app/theme/app_theme.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class MetasAhorroScreen extends StatefulWidget {
  final int idUsuario;

  const MetasAhorroScreen({super.key, required this.idUsuario});

  @override
  State<MetasAhorroScreen> createState() => _MetasAhorroScreenState();
}

class _MetasAhorroScreenState extends State<MetasAhorroScreen> {
  late MetasAhorroViewModel _viewModel;
  bool _isSelectionMode = false;
  Set<int> _selectedMetas = {};

  @override
  void initState() {
    super.initState();
    _viewModel = MetasAhorroViewModel(widget.idUsuario);
    _viewModel.addListener(_actualizarVista);
    _viewModel.cargarMetasAhorro();
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

<<<<<<< HEAD
  // Método para entrar/salir del modo selección
  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      _selectedMetas.clear();
    });
  }

  // Método para gestionar la selección de una meta
  void _toggleMetaSelection(int metaId) {
    setState(() {
      if (_selectedMetas.contains(metaId)) {
        _selectedMetas.remove(metaId);
        // Si no quedan metas seleccionadas, salir del modo selección
        if (_selectedMetas.isEmpty && _isSelectionMode) {
          _isSelectionMode = false;
        }
      } else {
        _selectedMetas.add(metaId);
      }
    });
  }

  // Método para seleccionar o deseleccionar todas las metas
  void _toggleSelectAll() {
    setState(() {
      if (_selectedMetas.length == _viewModel.metasFiltradas.length) {
        // Si todas están seleccionadas, deseleccionar todas
        _selectedMetas.clear();
        _isSelectionMode = false;
      } else {
        // Seleccionar todas las metas filtradas
        _selectedMetas = _viewModel.metasFiltradas
            .where((meta) => meta.id != null)
            .map((meta) => meta.id!)
            .toSet();
      }
    });
  }

=======
>>>>>>> 8f1d397338e300a443102a7f54c5ce411ddd3503
  // Método combinado para manejar navegación
  void _navegarA({MetaAhorro? metaParaEditar}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddMetasAhorroScreen(
          idUsuario: widget.idUsuario,
          metaAhorroParaEditar: metaParaEditar,
        ),
      ),
    ).then((_) => _viewModel.cargarMetasAhorro());
  }

<<<<<<< HEAD
  // Método para mostrar el diálogo de confirmación de eliminación
  void _mostrarDialogoConfirmacionEliminacion(List<MetaAhorro> metas) {
=======
  // Método combinado para manejo de selección
  void _gestionarSeleccion(
      {int? metaId, bool toggleMode = false, bool selectAll = false}) {
    setState(() {
      if (toggleMode) {
        _isSelectionMode = !_isSelectionMode;
        _selectedMetas.clear();
      }

      if (metaId != null) {
        if (_selectedMetas.contains(metaId)) {
          _selectedMetas.remove(metaId);
        } else {
          _selectedMetas.add(metaId);
        }
      }

      if (selectAll) {
        if (_selectedMetas.length == _viewModel.metasFiltradas.length) {
          _selectedMetas.clear();
          _isSelectionMode = false;
        } else {
          _selectedMetas =
              _viewModel.metasFiltradas.map((meta) => meta.id!).toSet();
        }
      }

      // Si no hay elementos seleccionados, salir del modo selección
      if (_selectedMetas.isEmpty && _isSelectionMode) {
        _isSelectionMode = false;
      }
    });
  }

  // Método combinado para eliminación
  void _gestionarEliminacion(List<MetaAhorro> metas) {
>>>>>>> 8f1d397338e300a443102a7f54c5ce411ddd3503
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.gris,
        title: Text(metas.length == 1
            ? 'Confirmar eliminación'
            : 'Confirmar eliminación múltiple'),
        content: Text(metas.length == 1
            ? '¿Estás seguro de eliminar la meta "${metas.first.nombre}"?'
            : '¿Estás seguro de eliminar ${metas.length} metas de ahorro?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar',
                style: TextStyle(color: AppTheme.blanco)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _eliminarMetas(metas);
            },
            child: const Text('Eliminar',
                style: TextStyle(color: AppTheme.naranja)),
          ),
        ],
      ),
    );
  }

<<<<<<< HEAD
  // Método para eliminar las metas seleccionadas
=======
>>>>>>> 8f1d397338e300a443102a7f54c5ce411ddd3503
  Future<void> _eliminarMetas(List<MetaAhorro> metas) async {
    try {
      for (var meta in metas) {
        await _viewModel.eliminarMetaAhorro(meta.id!);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(metas.length == 1
                ? 'Meta de ahorro eliminada con éxito'
                : '${metas.length} metas de ahorro eliminadas con éxito'),
            backgroundColor: Colors.green,
          ),
        );
      }

      setState(() {
        _isSelectionMode = false;
        _selectedMetas.clear();
      });
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

<<<<<<< HEAD
  // Método para mostrar opciones de una meta individual
=======
>>>>>>> 8f1d397338e300a443102a7f54c5ce411ddd3503
  void _mostrarOpcionesMeta(MetaAhorro meta) {
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
              meta.nombre,
              style: const TextStyle(
                color: AppTheme.blanco,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '${meta.cantidadActual.toStringAsFixed(2)} € / ${meta.cantidadObjetivo.toStringAsFixed(2)} €',
              style: TextStyle(
                color: _viewModel.calcularProgreso(meta) >= 1.0
                    ? Colors.green
                    : AppTheme.naranja,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.edit, color: AppTheme.naranja),
              title: const Text('Editar meta',
                  style: TextStyle(color: AppTheme.blanco)),
              onTap: () {
                Navigator.pop(context);
                _navegarA(metaParaEditar: meta);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Eliminar meta',
                  style: TextStyle(color: AppTheme.blanco)),
              onTap: () {
                Navigator.pop(context);
<<<<<<< HEAD
                _mostrarDialogoConfirmacionEliminacion([meta]);
=======
                _gestionarEliminacion([meta]);
>>>>>>> 8f1d397338e300a443102a7f54c5ce411ddd3503
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSelectionMode
            ? Text('${_selectedMetas.length} seleccionadas')
            : const Text('Mis metas de ahorro',
                style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: _isSelectionMode
            ? IconButton(
                icon: const Icon(Icons.close),
<<<<<<< HEAD
                onPressed: _toggleSelectionMode,
=======
                onPressed: () => _gestionarSeleccion(toggleMode: true),
>>>>>>> 8f1d397338e300a443102a7f54c5ce411ddd3503
              )
            : null,
        actions: _buildAppBarActions(),
      ),
      drawer: !_isSelectionMode
          ? MenuDesplegable(idUsuario: widget.idUsuario)
          : null,
      body: _buildBody(),
      floatingActionButton:
          _viewModel.metasAhorro.isNotEmpty && !_isSelectionMode
              ? FloatingActionButton(
                  onPressed: () => _navegarA(),
                  backgroundColor: AppTheme.naranja,
                  child: const Icon(Icons.add, color: Colors.black),
                )
              : null,
<<<<<<< HEAD
      bottomNavigationBar: BarraInferiorSecciones(
        idUsuario: widget.idUsuario,
        indexActual: 2,
=======
      bottomNavigationBar: CustomBottomNavBar(
        idUsuario: widget.idUsuario,
        currentIndex: 2,
>>>>>>> 8f1d397338e300a443102a7f54c5ce411ddd3503
      ),
    );
  }

  List<Widget> _buildAppBarActions() {
    if (_isSelectionMode) {
      return [
        IconButton(
          icon: const Icon(Icons.select_all),
          tooltip: 'Seleccionar todo',
<<<<<<< HEAD
          onPressed: _toggleSelectAll,
=======
          onPressed: () => _gestionarSeleccion(selectAll: true),
>>>>>>> 8f1d397338e300a443102a7f54c5ce411ddd3503
        ),
        IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          tooltip: 'Eliminar seleccionadas',
          onPressed: _selectedMetas.isNotEmpty
              ? () {
                  List<MetaAhorro> metasParaEliminar = _viewModel.metasAhorro
                      .where((meta) =>
                          meta.id != null && _selectedMetas.contains(meta.id!))
                      .toList();
<<<<<<< HEAD
                  _mostrarDialogoConfirmacionEliminacion(metasParaEliminar);
=======
                  _gestionarEliminacion(metasParaEliminar);
>>>>>>> 8f1d397338e300a443102a7f54c5ce411ddd3503
                }
              : null,
        ),
      ];
    } else if (_viewModel.metasAhorro.isNotEmpty) {
      return [
        IconButton(
          icon: const Icon(Icons.delete_sweep),
          tooltip: 'Selección múltiple',
<<<<<<< HEAD
          onPressed: _toggleSelectionMode,
=======
          onPressed: () => _gestionarSeleccion(toggleMode: true),
>>>>>>> 8f1d397338e300a443102a7f54c5ce411ddd3503
        ),
      ];
    }
    return [];
  }

  Widget _buildBody() {
    if (_viewModel.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.naranja),
      );
    }

    if (_viewModel.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              _viewModel.errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _viewModel.cargarMetasAhorro,
              style:
                  ElevatedButton.styleFrom(backgroundColor: AppTheme.naranja),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (_viewModel.metasAhorro.isEmpty) {
      return _buildEmptyState();
    }

    if (_viewModel.metasFiltradas.isEmpty) {
      return _buildNoResultsView();
    }

    return _buildMetasList();
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.savings, size: 70, color: Colors.grey),
          const SizedBox(height: 20),
          const Text(
            'No hay metas de ahorro',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text(
            'Añade tu primera meta pulsando el botón +',
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
              'NUEVA META',
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.filter_list_off, size: 70, color: Colors.grey),
          const SizedBox(height: 20),
          Text(
            _viewModel.mesFiltro != null
                ? _viewModel.filtroActual != null
                    ? 'No hay metas en ${DateFormat('MMMM yyyy', 'es').format(_viewModel.mesFiltro!)} con el filtro: ${_viewModel.filtroActual}'
                    : 'No hay metas en ${DateFormat('MMMM yyyy', 'es').format(_viewModel.mesFiltro!)}'
                : 'No hay metas con el filtro: ${_viewModel.filtroActual}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_viewModel.filtroActual != null)
                TextButton.icon(
                  onPressed: () => _viewModel.cambiarFiltro(null),
                  icon: const Icon(Icons.filter_alt_off),
                  label: const Text('Quitar filtro estado'),
                  style:
                      TextButton.styleFrom(foregroundColor: AppTheme.naranja),
                ),
              if (_viewModel.mesFiltro != null)
                TextButton.icon(
                  onPressed: () => _viewModel.cambiarMesFiltro(null),
                  icon: const Icon(Icons.calendar_month_outlined),
                  label: const Text('Quitar filtro mes'),
                  style:
                      TextButton.styleFrom(foregroundColor: AppTheme.naranja),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetasList() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          FiltroElementos(
            filtroActual: _viewModel.filtroActual,
            onFilterChanged: (filtro) => _viewModel.cambiarFiltro(filtro),
            filtros: _viewModel.filtros,
            // Pasar el mes de filtro
            mesFiltro: _viewModel.mesFiltro,
            onMesChanged: _viewModel.cambiarMesFiltro,
            mesesDisponibles: _viewModel.mesesDisponibles,
            // Pasar un valor nulo para fechaFiltro y una función vacía para onFechaChanged
            fechaFiltro: null,
            onFechaChanged:
                (_) {}, // función vacía que cumple con la firma requerida
          ),
          if (!_isSelectionMode) _buildResumenCard(),
          if (!_isSelectionMode) const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: _viewModel.metasFiltradas.length,
              itemBuilder: (context, index) =>
                  _buildMetaCard(_viewModel.metasFiltradas[index]),
            ),
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
              'Resumen de Metas',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildInfoCard(
                  'Total',
                  _viewModel.metasAhorro.length.toString(),
                  Icons.list_alt,
                ),
                _buildInfoCard(
                  'Completadas',
                  _viewModel.metasCompletadas.toString(),
                  Icons.check_circle,
                  color: Colors.green,
                ),
                _buildInfoCard(
                  'Pendientes',
                  _viewModel.metasPendientes.toString(),
                  Icons.pending_actions,
                  color: AppTheme.naranja,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon,
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

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildMetaCard(MetaAhorro meta) {
    double progreso = _viewModel.calcularProgreso(meta);
    bool estaVencida = _viewModel.estaVencida(meta);
    bool isSelected = meta.id != null && _selectedMetas.contains(meta.id!);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: isSelected ? AppTheme.naranja.withOpacity(0.3) : AppTheme.gris,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected
              ? AppTheme.naranja
              : meta.completada
                  ? Colors.green
                  : estaVencida
                      ? Colors.red
                      : Colors.transparent,
          width: isSelected || meta.completada || estaVencida ? 1.5 : 0,
        ),
      ),
      child: InkWell(
        onTap: _isSelectionMode
<<<<<<< HEAD
            ? () => meta.id != null ? _toggleMetaSelection(meta.id!) : null
            : () => _mostrarOpcionesMeta(meta),
        onLongPress: !_isSelectionMode && meta.id != null
            ? () {
                _toggleSelectionMode();
                _toggleMetaSelection(meta.id!);
=======
            ? () => _gestionarSeleccion(metaId: meta.id!)
            : () => _mostrarOpcionesMeta(meta),
        onLongPress: !_isSelectionMode
            ? () {
                _gestionarSeleccion(toggleMode: true);
                _gestionarSeleccion(metaId: meta.id!);
>>>>>>> 8f1d397338e300a443102a7f54c5ce411ddd3503
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
                    _viewModel.obtenerIconoCategoria(meta.nombre),
                    color: AppTheme.naranja,
                    size: 28,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      meta.nombre,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  if (!_isSelectionMode) ...[
                    if (meta.completada)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Completada',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    else if (estaVencida)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Vencida',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
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
<<<<<<< HEAD
                    percent: progreso.clamp(
                        0.0, 1.0), // Asegurar que esté entre 0 y 1
                    center: Text(
                      '${(progreso.clamp(0.0, 1.0) * 100).toInt()}%',
=======
                    percent: progreso,
                    center: Text(
                      '${(progreso * 100).toInt()}%',
>>>>>>> 8f1d397338e300a443102a7f54c5ce411ddd3503
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14.0),
                    ),
                    progressColor: meta.completada
                        ? Colors.green
                        : estaVencida
                            ? Colors.red
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
                        _buildInfoRow(
                          'Objetivo:',
                          '${meta.cantidadObjetivo.toStringAsFixed(2)} €',
                        ),
                        const SizedBox(height: 4),
                        _buildInfoRow(
                          'Actual:',
                          '${meta.cantidadActual.toStringAsFixed(2)} €',
                        ),
                        const SizedBox(height: 4),
                        _buildInfoRow(
                          'Restante:',
                          '${_viewModel.calcularCantidadRestante(meta).toStringAsFixed(2)} €',
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
                    'Fecha objetivo: ${DateFormat('dd/MM/yyyy').format(meta.fechaObjetivo)}',
                    style: TextStyle(
                      color: estaVencida ? Colors.red : AppTheme.blanco,
                      fontWeight:
                          estaVencida ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
              if (!meta.completada && !estaVencida)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.timer_outlined,
                          size: 14, color: AppTheme.blanco),
                      const SizedBox(width: 4),
                      Text(
                        _viewModel.obtenerTextoTiempoRestante(meta),
                        style: TextStyle(
                          color: _viewModel.diasRestantes(meta) < 7
                              ? Colors.orange
                              : AppTheme.blanco,
                          fontWeight: _viewModel.diasRestantes(meta) < 7
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

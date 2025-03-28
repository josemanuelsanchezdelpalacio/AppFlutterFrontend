import 'package:flutter/material.dart';
import 'package:flutter_proyecto_app/components/barra_inferior_secciones.dart';
import 'package:flutter_proyecto_app/components/filtro_elementos.dart';
import 'package:flutter_proyecto_app/components/menu_desplegable.dart';
import 'package:flutter_proyecto_app/data/transaccion.dart';
import 'package:flutter_proyecto_app/models/transacciones_viewmodel.dart';
import 'package:flutter_proyecto_app/screens/add_transacciones_screen.dart';
import 'package:flutter_proyecto_app/screens/transacciones_imagen_screen.dart';
import 'package:flutter_proyecto_app/theme/app_theme.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

class TransaccionesScreen extends StatefulWidget {
  final int idUsuario;

  const TransaccionesScreen({
    super.key,
    required this.idUsuario,
  });

  @override
  State<TransaccionesScreen> createState() => _TransaccionesScreenState();
}

class _TransaccionesScreenState extends State<TransaccionesScreen> {
  late TransaccionesViewModel _viewModel;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _viewModel = TransaccionesViewModel(idUsuario: widget.idUsuario);
    _viewModel.addListener(_actualizarVista);
    _cargarTransacciones();

    _searchController.addListener(() {
      _viewModel.aplicarBusqueda(_searchController.text);
    });
  }

  @override
  void dispose() {
    _viewModel.removeListener(_actualizarVista);
    _searchController.dispose();
    super.dispose();
  }

  void _actualizarVista() {
    if (mounted) setState(() {});
  }

  Future<void> _cargarTransacciones() async {
    await _viewModel.cargarTransacciones();
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        _viewModel.aplicarBusqueda('');
      }
    });
  }

  Future<void> _confirmarEliminarTransaccion(int id) async {
    final confirmacion = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.gris,
        title: const Text(
          '¿Eliminar transacción?',
          style: TextStyle(color: AppTheme.blanco),
        ),
        content: const Text(
          'Esta acción no se puede deshacer.',
          style: TextStyle(color: AppTheme.blanco),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar', style: TextStyle(color: AppTheme.blanco)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmacion == true) {
      try {
        await _viewModel.eliminarTransaccion(id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Transacción eliminada'),
              backgroundColor: Colors.green,
            ),
          );
        }
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
  }

  Future<void> _confirmarEliminarSeleccionadas() async {
    final confirmacion = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.gris,
        title: const Text(
          '¿Eliminar transacciones seleccionadas?',
          style: TextStyle(color: AppTheme.blanco),
        ),
        content: Text(
          'Se eliminarán ${_viewModel.transaccionesSeleccionadas.length} transacciones. Esta acción no se puede deshacer.',
          style: const TextStyle(color: AppTheme.blanco),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar', style: TextStyle(color: AppTheme.blanco)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmacion == true) {
      try {
        await _viewModel.eliminarTransaccionesSeleccionadas();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${_viewModel.transaccionesSeleccionadas.length} transacciones eliminadas'),
              backgroundColor: Colors.green,
            ),
          );
        }
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
  }

  void _mostrarOpcionesTransaccion(Transaccion transaccion) {
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
              transaccion.descripcion,
              style: const TextStyle(
                color: AppTheme.blanco,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            if (transaccion.imagenUrl != null && transaccion.imagenUrl!.isNotEmpty)
              GestureDetector(
                onTap: () => _mostrarDetallesImagen(transaccion.id!),
                child: Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.black.withOpacity(0.2),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Hero(
                      tag: 'transaction-image-${transaccion.id}',
                      child: _buildTransactionImage(transaccion.imagenUrl),
                    ),
                  ),
                ),
              ),

            if (transaccion.imagenUrl != null && transaccion.imagenUrl!.isNotEmpty)
              ListTile(
                leading: const Icon(Icons.photo_library, color: AppTheme.naranja),
                title: const Text(
                  'Ver detalles de imagen',
                  style: TextStyle(color: AppTheme.blanco),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _mostrarDetallesImagen(transaccion.id!);
                },
              ),

            ListTile(
              leading: const Icon(Icons.edit, color: AppTheme.naranja),
              title: const Text(
                'Editar transacción',
                style: TextStyle(color: AppTheme.blanco),
              ),
              onTap: () {
                Navigator.pop(context);
                _navegarAEditar(transaccion);
              },
            ),

            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text(
                'Eliminar transacción',
                style: TextStyle(color: AppTheme.blanco),
              ),
              onTap: () {
                Navigator.pop(context);
                if (transaccion.id != null) {
                  _confirmarEliminarTransaccion(transaccion.id!);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _navegarAEditar(Transaccion transaccion) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddTransaccionesScreen(
          idUsuario: widget.idUsuario,
          transaccionEditar: transaccion,
        ),
      ),
    ).then((_) => _cargarTransacciones());
  }

  void _mostrarDetallesImagen(int idTransaccion) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TransaccionImagenScreen(
          idUsuario: widget.idUsuario,
          idTransaccion: idTransaccion,
        ),
      ),
    );
  }

  Widget _buildTransactionImage(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return const Icon(
        Icons.image_not_supported,
        color: AppTheme.naranja,
        size: 30,
      );
    }

    return CachedNetworkImage(
      imageUrl: _getApiImageUrl(imageUrl),
      fit: BoxFit.cover,
      placeholder: (context, url) => const Center(
        child: CircularProgressIndicator(
          color: AppTheme.naranja,
          strokeWidth: 2,
        ),
      ),
      errorWidget: (context, url, error) {
        return CachedNetworkImage(
          imageUrl: _getFallbackImageUrl(imageUrl),
          fit: BoxFit.cover,
          placeholder: (context, url) => const Center(
            child: CircularProgressIndicator(
              color: AppTheme.naranja,
              strokeWidth: 2,
            ),
          ),
          errorWidget: (context, url, error) {
            return Icon(
              _viewModel.getCategoryIcon("default"),
              color: AppTheme.naranja,
              size: 30,
            );
          },
        );
      },
    );
  }

  String _getApiImageUrl(String imageUrl) {
    final String baseUrl = 'http://10.0.2.2:8080';
    return '$baseUrl/api/transacciones/images/$imageUrl';
  }

  String _getFallbackImageUrl(String imageUrl) {
    final String baseUrl = 'http://10.0.2.2:8080';
    return '$baseUrl/uploads/images/$imageUrl';
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      autofocus: true,
      style: const TextStyle(color: AppTheme.blanco),
      decoration: InputDecoration(
        hintText: 'Buscar transacciones...',
        hintStyle: TextStyle(color: Colors.grey[400]),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear, color: Colors.grey),
                onPressed: () => _searchController.clear(),
              )
            : null,
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.naranja,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Balance actual',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Icon(Icons.content_copy, color: Colors.black.withOpacity(0.7)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                _viewModel.formatoMoneda(_viewModel.balance),
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                ),
              ),
            ),
          ),
          Container(height: 1, color: Colors.black.withOpacity(0.2)),
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.arrow_downward, color: Colors.green, size: 16),
                          SizedBox(width: 4),
                          Text('Ingresos', style: TextStyle(color: Colors.black)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _viewModel.formatoMoneda(_viewModel.totalIngresos),
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(width: 1, height: 50, color: Colors.black.withOpacity(0.2)),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.arrow_upward, color: Colors.red, size: 16),
                          SizedBox(width: 4),
                          Text('Gastos', style: TextStyle(color: Colors.black)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _viewModel.formatoMoneda(_viewModel.totalGastos),
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTransaccionItem(Transaccion transaccion) {
    final bool esIngreso = transaccion.tipoTransaccion == TipoTransacciones.INGRESO;
    final Color colorCantidad = esIngreso ? Colors.green : Colors.red;
    final String signo = esIngreso ? '+ ' : '- ';
    final bool isSelected = transaccion.id != null && 
        _viewModel.isTransaccionSeleccionada(transaccion.id);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        margin: EdgeInsets.zero,
        color: isSelected ? AppTheme.naranja.withOpacity(0.2) : AppTheme.gris,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: _viewModel.modoSeleccion
              ? () => _viewModel.toggleSeleccionTransaccion(transaccion.id)
              : () => _mostrarOpcionesTransaccion(transaccion),
          onLongPress: () {
            if (!_viewModel.modoSeleccion) {
              _viewModel.toggleSeleccionMultiple();
              _viewModel.toggleSeleccionTransaccion(transaccion.id);
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                if (_viewModel.modoSeleccion)
                  Checkbox(
                    value: isSelected,
                    onChanged: (_) => _viewModel.toggleSeleccionTransaccion(transaccion.id),
                    activeColor: AppTheme.naranja,
                    checkColor: Colors.black,
                  ),
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: AppTheme.gris.withOpacity(0.7),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: transaccion.imagenUrl != null && transaccion.imagenUrl!.isNotEmpty
                        ? GestureDetector(
                            onTap: () => _mostrarDetallesImagen(transaccion.id!),
                            child: Hero(
                              tag: 'transaction-image-${transaccion.id}',
                              child: _buildTransactionImage(transaccion.imagenUrl),
                            ),
                          )
                        : Icon(
                            _viewModel.getCategoryIcon(transaccion.categoria),
                            color: AppTheme.naranja,
                            size: 30,
                          ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          transaccion.descripcion,
                          style: const TextStyle(
                            color: AppTheme.blanco,
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                transaccion.categoria,
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 13,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(Icons.circle, size: 4, color: Colors.grey[400]),
                            const SizedBox(width: 8),
                            Text(
                              DateFormat('dd/MM/yyyy').format(transaccion.fechaTransaccion),
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Text(
                  signo + _viewModel.formatoMoneda(transaccion.cantidad),
                  style: TextStyle(
                    color: colorCantidad,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                if (!_viewModel.modoSeleccion) ...[
                  const SizedBox(width: 8),
                  const Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTransaccionesList() {
    if (_viewModel.isLoading) {
      return const Expanded(
        child: Center(
          child: CircularProgressIndicator(color: AppTheme.naranja),
        ),
      );
    }

    if (_viewModel.errorMessage != null) {
      return Expanded(
        child: Center(
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
                onPressed: _cargarTransacciones,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.naranja,
                ),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    if (_viewModel.transaccionesFiltradas.isEmpty) {
      return Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.account_balance_wallet, size: 70, color: Colors.grey),
              const SizedBox(height: 20),
              Text(
                _isSearching && _searchController.text.isNotEmpty
                    ? 'No se encontraron resultados para "${_searchController.text}"'
                    : 'No hay transacciones',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                'Añade una nueva transacción para comenzar',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 30),
              if (!_isSearching)
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddTransaccionesScreen(idUsuario: widget.idUsuario),
                      ),
                    ).then((_) => _cargarTransacciones());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.naranja,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  icon: const Icon(Icons.add, color: Colors.black),
                  label: const Text(
                    'NUEVA TRANSACCIÓN',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                ),
            ],
          ),
        ),
      );
    }

    return Expanded(
      child: RefreshIndicator(
        onRefresh: _cargarTransacciones,
        color: AppTheme.naranja,
        child: ListView.builder(
          itemCount: _viewModel.transaccionesFiltradas.length,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemBuilder: (context, index) => _buildTransaccionItem(
            _viewModel.transaccionesFiltradas[index],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Consumer<TransaccionesViewModel>(
        builder: (context, viewModel, _) {
          return Scaffold(
            backgroundColor: AppTheme.colorFondo,
            appBar: AppBar(
              title: _isSearching
                  ? _buildSearchField()
                  : viewModel.modoSeleccion
                      ? Text(
                          '${viewModel.transaccionesSeleccionadas.length} seleccionadas',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        )
                      : const Text(
                          'Transacciones',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
              leading: _isSearching
                  ? IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: _toggleSearch,
                    )
                  : viewModel.modoSeleccion
                      ? IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: viewModel.toggleSeleccionMultiple,
                        )
                      : null,
              actions: [
                if (!_isSearching && !viewModel.modoSeleccion)
                  IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: _toggleSearch,
                  ),
                if (!_isSearching && !viewModel.modoSeleccion)
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: viewModel.iniciarSeleccionMultiple,
                  ),
                if (viewModel.modoSeleccion) ...[
                  IconButton(
                    icon: const Icon(Icons.select_all),
                    onPressed: viewModel.transaccionesSeleccionadas.length == 
                            viewModel.transaccionesFiltradas.length
                        ? viewModel.deseleccionarTodas
                        : viewModel.seleccionarTodas,
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: viewModel.transaccionesSeleccionadas.isEmpty
                        ? null
                        : () => _confirmarEliminarSeleccionadas(),
                  ),
                ],
              ],
            ),
            drawer: !viewModel.modoSeleccion && !_isSearching
                ? MenuDesplegable(idUsuario: widget.idUsuario)
                : null,
            body: Column(
              children: [
                if (!viewModel.modoSeleccion && !_isSearching)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: FiltroElementos(
                      filtroActual: viewModel.filtroActual,
                      onFilterChanged: viewModel.aplicarFiltro,
                      filtros: [null, 'Ingresos', 'Gastos'],
                      fechaFiltro: viewModel.fechaFiltro,
                      onFechaChanged: viewModel.aplicarFiltroFecha,
                      mesFiltro: viewModel.mesFiltro,
                      onMesChanged: viewModel.aplicarFiltroMes,
                      mesesDisponibles: viewModel.mesesDisponibles,
                    ),
                  ),
                if (!viewModel.modoSeleccion && !_isSearching)
                  _buildBalanceCard(),
                if (_isSearching && _searchController.text.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Resultados para "${_searchController.text}"',
                            style: const TextStyle(
                              color: AppTheme.blanco,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Text(
                          '${viewModel.transaccionesFiltradas.length} resultado${viewModel.transaccionesFiltradas.length != 1 ? 's' : ''}',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                _buildTransaccionesList(),
              ],
            ),
            floatingActionButton: !viewModel.modoSeleccion
                ? FloatingActionButton(
                    backgroundColor: AppTheme.naranja,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AddTransaccionesScreen(idUsuario: widget.idUsuario),
                        ),
                      ).then((_) => _cargarTransacciones());
                    },
                    child: const Icon(Icons.add, color: Colors.black),
                  )
                : null,
            bottomNavigationBar: BarraInferiorSecciones(
              idUsuario: widget.idUsuario,
              indexActual: 1,
            ),
          );
        },
      ),
    );
  }
}


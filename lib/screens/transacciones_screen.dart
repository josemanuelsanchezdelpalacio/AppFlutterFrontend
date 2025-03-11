import 'package:flutter/material.dart';
import 'package:flutter_proyecto_app/components/custom_bottom_app_bar.dart';
import 'package:flutter_proyecto_app/components/filtro_elementos.dart';
import 'package:flutter_proyecto_app/components/menu_desplegable.dart';
import 'package:flutter_proyecto_app/data/transaccion.dart';
import 'package:flutter_proyecto_app/models/transacciones_viewmodel.dart';
import 'package:flutter_proyecto_app/screens/add_transacciones_screen.dart';
import 'package:flutter_proyecto_app/theme/app_theme.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

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
  late TransaccionesViewmodel _viewmodel;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _viewmodel = TransaccionesViewmodel(idUsuario: widget.idUsuario);
    _cargarTransacciones();

    // Añadir listener para búsqueda
    _searchController.addListener(() {
      _viewmodel.aplicarBusqueda(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _cargarTransacciones() async {
    try {
      await _viewmodel.cargarTransacciones();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar transacciones: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewmodel,
      child: Consumer<TransaccionesViewmodel>(
        builder: (context, viewmodel, _) {
          return Scaffold(
            backgroundColor: AppTheme.colorFondo,
            appBar: AppBar(
              title: _isSearching
                  ? _buildSearchField()
                  : !viewmodel.modoSeleccion
                      ? const Text(
                          'Transacciones',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        )
                      : Text(
                          '${viewmodel.transaccionesSeleccionadas.length} seleccionadas',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
              leading: _isSearching
                  ? IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: _toggleSearch,
                    )
                  : viewmodel.modoSeleccion
                      ? IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => viewmodel.toggleModoSeleccion(),
                        )
                      : null,
              actions: [
                if (!_isSearching && !viewmodel.modoSeleccion)
                  IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: _toggleSearch,
                  ),
                viewmodel.modoSeleccion
                    ? Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: viewmodel
                                    .transaccionesSeleccionadas.isEmpty
                                ? null
                                : () =>
                                    _confirmarEliminarSeleccionadas(context),
                          ),
                        ],
                      )
                    : !_isSearching
                        ? IconButton(
                            icon: const Icon(Icons.select_all),
                            onPressed: () => viewmodel.toggleModoSeleccion(),
                          )
                        : const SizedBox(),
              ],
            ),
            drawer: !viewmodel.modoSeleccion && !_isSearching
                ? MenuDesplegable(idUsuario: widget.idUsuario)
                : null,
            body: RefreshIndicator(
              onRefresh: _cargarTransacciones,
              color: AppTheme.naranja,
              child: Column(
                children: [
                  //uso el componente del filtro
                  if (!viewmodel.modoSeleccion && !_isSearching)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: FiltroElementos(
                        filtroActual: viewmodel.filtroActual,
                        onFilterChanged: viewmodel.aplicarFiltro,
                        filtros: viewmodel.opcionesFiltro,
                        fechaFiltro: viewmodel.fechaFiltro,
                        onFechaChanged: viewmodel.aplicarFiltroFecha,
                        mesFiltro: viewmodel.mesFiltro,
                        onMesChanged: viewmodel.aplicarFiltroMes,
                        mesesDisponibles: viewmodel.mesesDisponibles,
                      ),
                    ),

                  //tarjeta de balance
                  if (!viewmodel.modoSeleccion && !_isSearching)
                    _buildBalanceCard(),

                  // Texto de información de búsqueda si está buscando
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
                            '${viewmodel.transaccionesFiltradas.length} resultado${viewmodel.transaccionesFiltradas.length != 1 ? 's' : ''}',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),

                  //titulo de transacciones recientes
                  if (!viewmodel.modoSeleccion && !_isSearching)
                    const Padding(
                      padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Transacciones recientes',
                          style: TextStyle(
                            color: AppTheme.blanco,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                  //lista de transacciones
                  _buildTransaccionesList(),
                ],
              ),
            ),
            floatingActionButton: !viewmodel.modoSeleccion
                ? FloatingActionButton(
                    backgroundColor: AppTheme.naranja,
                    child: const Icon(Icons.add, color: Colors.black),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            AddTransaccionesScreen(idUsuario: widget.idUsuario),
                      ),
                    ).then((_) => _cargarTransacciones()),
                  )
                : null,
            bottomNavigationBar: CustomBottomNavBar(
              idUsuario: widget.idUsuario,
              currentIndex: 1,
            ),
          );
        },
      ),
    );
  }

  // Método para alternar el modo de búsqueda
  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        _viewmodel.aplicarBusqueda('');
      }
    });
  }

  // Campo de búsqueda
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
                onPressed: () {
                  _searchController.clear();
                },
              )
            : null,
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Consumer<TransaccionesViewmodel>(
      builder: (context, viewmodel, _) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.naranja,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              //balance total
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
                    Icon(Icons.content_copy,
                        color: Colors.black.withOpacity(0.7)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    viewmodel.formatoMoneda(viewmodel.balance),
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 28,
                    ),
                  ),
                ),
              ),

              //ingresos
              Container(
                height: 1,
                color: Colors.black.withOpacity(0.2),
              ),
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
                              Icon(Icons.arrow_downward,
                                  color: Colors.green, size: 16),
                              SizedBox(width: 4),
                              Text(
                                'Ingresos',
                                style: TextStyle(color: Colors.black),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            viewmodel.formatoMoneda(viewmodel.totalIngresos),
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

                  //gastos
                  Container(
                    width: 1,
                    height: 50,
                    color: Colors.black.withOpacity(0.2),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.arrow_upward,
                                  color: Colors.red, size: 16),
                              SizedBox(width: 4),
                              Text(
                                'Gastos',
                                style: TextStyle(color: Colors.black),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            viewmodel.formatoMoneda(viewmodel.totalGastos),
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
      },
    );
  }

  Widget _buildTransaccionesList() {
    return Consumer<TransaccionesViewmodel>(
      builder: (context, viewmodel, _) {
        if (viewmodel.isLoading) {
          return const Expanded(
            child: Center(
              child: CircularProgressIndicator(color: AppTheme.naranja),
            ),
          );
        }

        if (viewmodel.transaccionesFiltradas.isEmpty) {
          return Expanded(
            child: Center(
              child: Text(
                _isSearching && _searchController.text.isNotEmpty
                    ? 'No se encontraron resultados para "${_searchController.text}"'
                    : 'No hay transacciones. \nAñade una nueva transaccion para comenzar',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
            ),
          );
        }

        return Expanded(
          child: ListView.builder(
            itemCount: viewmodel.transaccionesFiltradas.length,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemBuilder: (context, index) {
              final transaccion = viewmodel.transaccionesFiltradas[index];
              return _buildTransaccionItem(context, transaccion, viewmodel);
            },
          ),
        );
      },
    );
  }

  Widget _buildTransaccionItem(BuildContext context, Transaccion transaccion,
      TransaccionesViewmodel viewmodel) {
    final bool esIngreso =
        transaccion.tipoTransaccion == TipoTransacciones.INGRESO;
    final Color colorCantidad = esIngreso ? Colors.green : Colors.red;
    final String signo = esIngreso ? '+ ' : '- ';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        margin: EdgeInsets.zero,
        color: AppTheme.gris,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: viewmodel.modoSeleccion
              ? () => viewmodel.toggleSeleccionTransaccion(transaccion.id)
              : () => _mostrarOpcionesTransaccion(context, transaccion),
          onLongPress: () {
            if (!viewmodel.modoSeleccion) {
              viewmodel.toggleModoSeleccion();
              viewmodel.toggleSeleccionTransaccion(transaccion.id);
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                //checkbox seleccion tipo transaccion
                if (viewmodel.modoSeleccion)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Checkbox(
                      value:
                          viewmodel.isTransaccionSeleccionada(transaccion.id),
                      onChanged: (_) =>
                          viewmodel.toggleSeleccionTransaccion(transaccion.id),
                      activeColor: AppTheme.naranja,
                      checkColor: Colors.black,
                    ),
                  ),

                //campo de categoria
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    viewmodel.getCategoryIcon(transaccion.categoria),
                    color: esIngreso ? Colors.green : Colors.red,
                  ),
                ),

                //informacion de la transaccion
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
                            overflow: TextOverflow.ellipsis,
                          ),
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
                                  overflow: TextOverflow.ellipsis,
                                ),
                                maxLines: 1,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(Icons.circle,
                                size: 4, color: Colors.grey[400]),
                            const SizedBox(width: 8),
                            Text(
                              DateFormat('dd/MM/yyyy')
                                  .format(transaccion.fechaTransaccion),
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

                //cantidad
                Text(
                  signo + viewmodel.formatoMoneda(transaccion.cantidad),
                  style: TextStyle(
                    color: colorCantidad,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),

                if (!viewmodel.modoSeleccion) ...[
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.chevron_right,
                    color: Colors.grey,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _mostrarOpcionesTransaccion(
      BuildContext context, Transaccion transaccion) {
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

            //boton editar
            ListTile(
              leading: const Icon(Icons.edit, color: AppTheme.naranja),
              title: const Text(
                'Editar transaccion',
                style: TextStyle(color: AppTheme.blanco),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddTransaccionesScreen(
                      idUsuario: widget.idUsuario,
                      transaccionEditar: transaccion,
                    ),
                  ),
                ).then((_) => _cargarTransacciones());
              },
            ),

            //boton eliminar
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text(
                'Eliminar transacción',
                style: TextStyle(color: AppTheme.blanco),
              ),
              onTap: () {
                Navigator.pop(context);
                _confirmarEliminarTransaccion(context, transaccion.id!);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmarEliminarTransaccion(
      BuildContext context, int id) async {
    final confirmacion = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.gris,
        title: const Text(
          '¿Eliminar transaccion?',
          style: TextStyle(color: AppTheme.blanco),
        ),
        content: const Text(
          'Esta accion no se puede deshacer.',
          style: TextStyle(color: AppTheme.blanco),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar',
                style: TextStyle(color: AppTheme.blanco)),
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
        await _viewmodel.eliminarTransaccion(id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Transacción eliminada')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al eliminar: $e')),
          );
        }
      }
    }
  }

  Future<void> _confirmarEliminarSeleccionadas(BuildContext context) async {
    final viewmodel =
        Provider.of<TransaccionesViewmodel>(context, listen: false);

    final confirmacion = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppTheme.gris,
        title: const Text(
          '¿Eliminar transacciones seleccionadas?',
          style: TextStyle(color: AppTheme.blanco),
        ),
        content: Text(
          'Se eliminaran ${viewmodel.transaccionesSeleccionadas.length} transacciones. Esta acción no se puede deshacer.',
          style: const TextStyle(color: AppTheme.blanco),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar',
                style: TextStyle(color: AppTheme.blanco)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmacion == true) {
      try {
        await viewmodel.eliminarTransaccionesSeleccionadas();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Transacciones eliminadas')),
          );
        }
        //desactivo el modo de seleccion despues de eliminar
        viewmodel.toggleModoSeleccion();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al eliminar: $e')),
          );
        }
      }
    }
  }
}

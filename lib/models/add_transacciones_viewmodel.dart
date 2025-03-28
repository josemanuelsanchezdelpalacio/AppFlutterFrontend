import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_proyecto_app/data/transaccion.dart';
import 'package:flutter_proyecto_app/data/categorias_data.dart';
import 'package:flutter_proyecto_app/services/transacciones_service.dart';

class AddTransaccionesViewModel extends ChangeNotifier {
  final int idUsuario;
  final Transaccion? transaccionEditar;
  final TransaccionesService _transaccionesService = TransaccionesService();

  AddTransaccionesViewModel({
    required this.idUsuario,
    this.transaccionEditar,
  });

  // Controladores
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController cantidadController = TextEditingController();
  final TextEditingController descripcionController = TextEditingController();
  final TextEditingController nuevaCategoriaController = TextEditingController();

  // Variables de estado
  TipoTransacciones _tipoTransaccion = TipoTransacciones.GASTO;
  String _categoria = 'Alimentación';
  DateTime _fechaTransaccion = DateTime.now();
  bool _transaccionRecurrente = false;
  String _frecuenciaRecurrencia = 'Mensual';
  DateTime? _fechaFinalizacionRecurrencia;
  bool _mostrarNuevaCategoria = false;
  bool _isLoading = false;
  File? _imagen;
  int? _presupuestoId;
  int? _metaAhorroId;

  // Categorías personalizadas
  final List<String> _categoriasPersonalizadasGastos = [];
  final List<String> _categoriasPersonalizadasIngresos = [];

  // Getters
  TipoTransacciones get tipoTransaccion => _tipoTransaccion;
  String get categoria => _categoria;
  DateTime get fechaTransaccion => _fechaTransaccion;
  bool get transaccionRecurrente => _transaccionRecurrente;
  String get frecuenciaRecurrencia => _frecuenciaRecurrencia;
  DateTime? get fechaFinalizacionRecurrencia => _fechaFinalizacionRecurrencia;
  bool get isLoading => _isLoading;
  bool get mostrarNuevaCategoria => _mostrarNuevaCategoria;
  File? get imagen => _imagen;
  int? get presupuestoId => _presupuestoId;
  int? get metaAhorroId => _metaAhorroId;

  List<String> get todasCategoriasGastos => [
        ...CategoriasData.categoriasGastos,
        ..._categoriasPersonalizadasGastos,
        'Personalizada'
      ];

  List<String> get todasCategoriasIngresos => [
        ...CategoriasData.categoriasIngresos,
        ..._categoriasPersonalizadasIngresos,
        'Personalizada'
      ];

  List<String> get categoriasPorTipo => CategoriasData.getCategoriasPorTipo(
      _tipoTransaccion,
      _categoriasPersonalizadasGastos,
      _categoriasPersonalizadasIngresos);

  // Setters
  void setTipoTransaccion(TipoTransacciones tipo) {
    _tipoTransaccion = tipo;
    _mostrarNuevaCategoria = false;
    nuevaCategoriaController.clear();

    final categoriasActuales = categoriasPorTipo;
    if (!categoriasActuales.contains(_categoria)) {
      _categoria = categoriasActuales.first;
    }
    notifyListeners();
  }

  void setCategoria(String nuevaCategoria) {
    if (nuevaCategoria == 'Personalizada') {
      _mostrarNuevaCategoria = true;
      nuevaCategoriaController.clear();
    } else {
      _categoria = nuevaCategoria;
      _mostrarNuevaCategoria = false;
    }
    notifyListeners();
  }

  void setFechaTransaccion(DateTime fecha) {
    _fechaTransaccion = fecha;
    notifyListeners();
  }

  void setTransaccionRecurrente(bool valor) {
    _transaccionRecurrente = valor;
    if (valor && _fechaFinalizacionRecurrencia == null) {
      _fechaFinalizacionRecurrencia =
          DateTime.now().add(const Duration(days: 30));
    }
    notifyListeners();
  }

  void setFrecuenciaRecurrencia(String frecuencia) {
    _frecuenciaRecurrencia = frecuencia;
    notifyListeners();
  }

  void setFechaFinalizacionRecurrencia(DateTime? fecha) {
    _fechaFinalizacionRecurrencia = fecha;
    notifyListeners();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setImagen(File? imagen) {
    _imagen = imagen;
    notifyListeners();
  }

  void setPresupuestoId(int? id) {
    _presupuestoId = id;
    _metaAhorroId = null;
    notifyListeners();
  }

  void setMetaAhorroId(int? id) {
    _metaAhorroId = id;
    _presupuestoId = null;
    notifyListeners();
  }

  // Métodos
  void init() {
    if (transaccionEditar != null) {
      _cargarDatosTransaccion();
    }
  }

  void _cargarDatosTransaccion() {
    final transaccion = transaccionEditar!;

    nombreController.text = transaccion.nombre ?? '';
    cantidadController.text = transaccion.cantidad.toString();
    descripcionController.text = transaccion.descripcion;
    _tipoTransaccion = transaccion.tipoTransaccion;

    final categoriasDisponibles = _tipoTransaccion == TipoTransacciones.GASTO
        ? CategoriasData.categoriasGastos
        : CategoriasData.categoriasIngresos;

    if (categoriasDisponibles.contains(transaccion.categoria)) {
      _categoria = transaccion.categoria;
    } else {
      final categoriasPersonalizadas =
          _tipoTransaccion == TipoTransacciones.GASTO
              ? _categoriasPersonalizadasGastos
              : _categoriasPersonalizadasIngresos;

      if (!categoriasPersonalizadas.contains(transaccion.categoria)) {
        if (_tipoTransaccion == TipoTransacciones.GASTO) {
          _categoriasPersonalizadasGastos.add(transaccion.categoria);
        } else {
          _categoriasPersonalizadasIngresos.add(transaccion.categoria);
        }
      }
      _categoria = transaccion.categoria;
    }

    _fechaTransaccion = transaccion.fechaTransaccion;
    _transaccionRecurrente = transaccion.transaccionRecurrente;

    if (transaccion.transaccionRecurrente &&
        transaccion.frecuenciaRecurrencia != null) {
      if (CategoriasData.frecuencias
          .contains(transaccion.frecuenciaRecurrencia)) {
        _frecuenciaRecurrencia = transaccion.frecuenciaRecurrencia!;
      } else {
        _frecuenciaRecurrencia = 'Mensual';
      }
    }

    _fechaFinalizacionRecurrencia = transaccion.fechaFinalizacionRecurrencia;

    if (_transaccionRecurrente && _fechaFinalizacionRecurrencia == null) {
      _fechaFinalizacionRecurrencia =
          DateTime.now().add(const Duration(days: 30));
    }

    _presupuestoId = transaccion.presupuestoId;
    _metaAhorroId = transaccion.metaAhorroId;
  }

  void agregarCategoriaPersonalizada(String nuevaCategoria) {
    if (nuevaCategoria.isEmpty) return;

    if (_tipoTransaccion == TipoTransacciones.GASTO) {
      if (!_categoriasPersonalizadasGastos.contains(nuevaCategoria) &&
          !CategoriasData.categoriasGastos.contains(nuevaCategoria)) {
        _categoriasPersonalizadasGastos.add(nuevaCategoria);
      }
    } else {
      if (!_categoriasPersonalizadasIngresos.contains(nuevaCategoria) &&
          !CategoriasData.categoriasIngresos.contains(nuevaCategoria)) {
        _categoriasPersonalizadasIngresos.add(nuevaCategoria);
      }
    }

    _categoria = nuevaCategoria;
    _mostrarNuevaCategoria = false;
    nuevaCategoriaController.clear();
    notifyListeners();
  }

  Future<void> guardarTransaccion() async {
    final double cantidad =
        double.parse(cantidadController.text.replaceAll(',', '.'));

    final transaccion = Transaccion(
      id: transaccionEditar?.id,
      nombre: nombreController.text.trim(),
      cantidad: cantidad,
      descripcion: descripcionController.text,
      tipoTransaccion: _tipoTransaccion,
      categoria: _categoria,
      fechaTransaccion: _fechaTransaccion,
      transaccionRecurrente: _transaccionRecurrente,
      frecuenciaRecurrencia:
          _transaccionRecurrente ? _frecuenciaRecurrencia : null,
      fechaFinalizacionRecurrencia:
          _transaccionRecurrente ? _fechaFinalizacionRecurrencia : null,
      presupuestoId: _presupuestoId,
      metaAhorroId: _metaAhorroId,
    );

    if (transaccionEditar == null) {
      await _transaccionesService.crearTransaccion(
          idUsuario, transaccion, _imagen);
    } else {
      await _transaccionesService.actualizarTransaccion(
          idUsuario, transaccionEditar!.id!, transaccion);
    }
  }
}


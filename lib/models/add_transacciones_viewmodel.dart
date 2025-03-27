<<<<<<< HEAD
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_proyecto_app/data/transaccion.dart';
import 'package:flutter_proyecto_app/data/categorias_data.dart';
import 'package:flutter_proyecto_app/services/transacciones_service.dart';

class AddTransaccionesViewModel extends ChangeNotifier {
=======
import 'package:flutter/material.dart';
import 'package:flutter_proyecto_app/data/transaccion.dart';
import 'package:flutter_proyecto_app/services/transacciones_service.dart';
import 'package:flutter_proyecto_app/data/categorias_data.dart'; // Importar el nuevo archivo

class AddTransaccionesViewModel {
>>>>>>> 8f1d397338e300a443102a7f54c5ce411ddd3503
  final int idUsuario;
  final Transaccion? transaccionEditar;
  final TransaccionesService _transaccionesService = TransaccionesService();

  AddTransaccionesViewModel({
    required this.idUsuario,
    this.transaccionEditar,
  });

<<<<<<< HEAD
  // Controladores
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController cantidadController = TextEditingController();
  final TextEditingController descripcionController = TextEditingController();
  final TextEditingController nuevaCategoriaController =
      TextEditingController();

  // Variables de estado
  TipoTransacciones _tipoTransaccion = TipoTransacciones.GASTO;
  String _categoria = 'Alimentación';
=======
  //key para el formulario
  final formKey = GlobalKey<FormState>();

  //controladores para los campos del formulario
  final cantidadController = TextEditingController();
  final descripcionController = TextEditingController();
  final nuevaCategoriaController = TextEditingController();

  //variables para almacenar los valores de los campos
  TipoTransacciones _tipoTransaccion = TipoTransacciones.GASTO;
  String _categoria = 'Alimentacion';
>>>>>>> 8f1d397338e300a443102a7f54c5ce411ddd3503
  DateTime _fechaTransaccion = DateTime.now();
  bool _transaccionRecurrente = false;
  String _frecuenciaRecurrencia = 'Mensual';
  DateTime? _fechaFinalizacionRecurrencia;
  bool _mostrarNuevaCategoria = false;
<<<<<<< HEAD
  bool _isLoading = false;
  File? _imagen;
  int? _presupuestoId;
  int? _metaAhorroId;

  // Categorías personalizadas
  final List<String> _categoriasPersonalizadasGastos = [];
  final List<String> _categoriasPersonalizadasIngresos = [];

  // Getters
=======

  bool _isLoading = false;

  //categorias personalizadas
  final List<String> _categoriasPersonalizadasGastos = [];
  final List<String> _categoriasPersonalizadasIngresos = [];

>>>>>>> 8f1d397338e300a443102a7f54c5ce411ddd3503
  TipoTransacciones get tipoTransaccion => _tipoTransaccion;
  String get categoria => _categoria;
  DateTime get fechaTransaccion => _fechaTransaccion;
  bool get transaccionRecurrente => _transaccionRecurrente;
  String get frecuenciaRecurrencia => _frecuenciaRecurrencia;
  DateTime? get fechaFinalizacionRecurrencia => _fechaFinalizacionRecurrencia;
  bool get isLoading => _isLoading;
  bool get mostrarNuevaCategoria => _mostrarNuevaCategoria;
<<<<<<< HEAD
  File? get imagen => _imagen;
  int? get presupuestoId => _presupuestoId;
  int? get metaAhorroId => _metaAhorroId;

=======

  //getters para categorías combinadas (predefinidas + personalizadas)
>>>>>>> 8f1d397338e300a443102a7f54c5ce411ddd3503
  List<String> get todasCategoriasGastos => [
        ...CategoriasData.categoriasGastos,
        ..._categoriasPersonalizadasGastos,
        'Nueva categoría...'
      ];
<<<<<<< HEAD

=======
  
>>>>>>> 8f1d397338e300a443102a7f54c5ce411ddd3503
  List<String> get todasCategoriasIngresos => [
        ...CategoriasData.categoriasIngresos,
        ..._categoriasPersonalizadasIngresos,
        'Nueva categoría...'
      ];

<<<<<<< HEAD
  List<String> get categoriasPorTipo => CategoriasData.getCategoriasPorTipo(
      _tipoTransaccion,
      _categoriasPersonalizadasGastos,
      _categoriasPersonalizadasIngresos);

  // Setters
=======
  //getter para obtener todas las categorías según el tipo de transacción
  List<String> get categoriasPorTipo =>
      CategoriasData.getCategoriasPorTipo(
        _tipoTransaccion, 
        _categoriasPersonalizadasGastos, 
        _categoriasPersonalizadasIngresos
      );

>>>>>>> 8f1d397338e300a443102a7f54c5ce411ddd3503
  void setTipoTransaccion(TipoTransacciones tipo) {
    _tipoTransaccion = tipo;
    _mostrarNuevaCategoria = false;
    nuevaCategoriaController.clear();

<<<<<<< HEAD
    final categoriasActuales = categoriasPorTipo;
    if (!categoriasActuales.contains(_categoria)) {
      _categoria = categoriasActuales.first;
    }
    notifyListeners();
=======
    //compruebo si la categoria actual existe en la lista correspondiente al nuevo tipo
    final categoriasActuales = categoriasPorTipo;

    //si la categoria actual no está en la lista, establezco la primera categoria como predeterminada
    if (!categoriasActuales.contains(_categoria)) {
      _categoria = categoriasActuales.first;
    }
>>>>>>> 8f1d397338e300a443102a7f54c5ce411ddd3503
  }

  void setCategoria(String nuevaCategoria) {
    if (nuevaCategoria == 'Nueva categoría...') {
      _mostrarNuevaCategoria = true;
      nuevaCategoriaController.clear();
    } else {
      _categoria = nuevaCategoria;
      _mostrarNuevaCategoria = false;
    }
<<<<<<< HEAD
    notifyListeners();
=======
>>>>>>> 8f1d397338e300a443102a7f54c5ce411ddd3503
  }

  void setFechaTransaccion(DateTime fecha) {
    _fechaTransaccion = fecha;
<<<<<<< HEAD
    notifyListeners();
=======
>>>>>>> 8f1d397338e300a443102a7f54c5ce411ddd3503
  }

  void setTransaccionRecurrente(bool valor) {
    _transaccionRecurrente = valor;
    if (valor && _fechaFinalizacionRecurrencia == null) {
      _fechaFinalizacionRecurrencia =
          DateTime.now().add(const Duration(days: 30));
    }
<<<<<<< HEAD
    notifyListeners();
=======
>>>>>>> 8f1d397338e300a443102a7f54c5ce411ddd3503
  }

  void setFrecuenciaRecurrencia(String frecuencia) {
    _frecuenciaRecurrencia = frecuencia;
<<<<<<< HEAD
    notifyListeners();
=======
>>>>>>> 8f1d397338e300a443102a7f54c5ce411ddd3503
  }

  void setFechaFinalizacionRecurrencia(DateTime? fecha) {
    _fechaFinalizacionRecurrencia = fecha;
<<<<<<< HEAD
    notifyListeners();
=======
>>>>>>> 8f1d397338e300a443102a7f54c5ce411ddd3503
  }

  void setLoading(bool loading) {
    _isLoading = loading;
<<<<<<< HEAD
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

    if (transaccion.nombre != null && transaccion.nombre!.isNotEmpty) {
      nombreController.text = transaccion.nombre!;
    }

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
=======
>>>>>>> 8f1d397338e300a443102a7f54c5ce411ddd3503
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
<<<<<<< HEAD
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
      // Solo incluir IDs si realmente están asignados
      presupuestoId: _presupuestoId,
      metaAhorroId: _metaAhorroId,
    );

    if (transaccionEditar == null) {
      await _transaccionesService.crearTransaccion(
          idUsuario, transaccion, _imagen);
    } else {
      await _transaccionesService.actualizarTransaccion(
          idUsuario, transaccionEditar!.id!, transaccion);
=======
  }

  //inicializo ViewModel con datos existentes si es edición
  void init() {
    if (transaccionEditar != null) {
      _cargarDatosTransacciones();
    }
  }

  //cargo los datos de la transaccion a editar
  void _cargarDatosTransacciones() {
    final transaccion = transaccionEditar!;
    cantidadController.text = transaccion.cantidad.toString();
    descripcionController.text = transaccion.descripcion;
    _tipoTransaccion = transaccion.tipoTransaccion;

    //compruebo que la categoria de la transaccion exista en la lista correspondiente
    final categoriasDisponibles = _tipoTransaccion == TipoTransacciones.GASTO
        ? CategoriasData.categoriasGastos
        : CategoriasData.categoriasIngresos;

    //si la categoria existe en la lista, la asignamos, sino la agregamos a las categorías personalizadas
    if (categoriasDisponibles.contains(transaccion.categoria)) {
      _categoria = transaccion.categoria;
    } else {
      //compruebo si es una categoría personalizada existente
      final categoriasPersonalizadas =
          _tipoTransaccion == TipoTransacciones.GASTO
              ? _categoriasPersonalizadasGastos
              : _categoriasPersonalizadasIngresos;

      if (categoriasPersonalizadas.contains(transaccion.categoria)) {
        _categoria = transaccion.categoria;
      } else {
        //si no existe en ninguna lista, la agregamos como categoría personalizada
        if (_tipoTransaccion == TipoTransacciones.GASTO) {
          _categoriasPersonalizadasGastos.add(transaccion.categoria);
        } else {
          _categoriasPersonalizadasIngresos.add(transaccion.categoria);
        }
        _categoria = transaccion.categoria;
      }
    }

    _fechaTransaccion = transaccion.fechaTransaccion;
    _transaccionRecurrente = transaccion.transaccionRecurrente;

    //compruebo que la frecuencia de recurrencia sea valida
    if (transaccion.transaccionRecurrente &&
        transaccion.frecuenciaRecurrencia != null) {
      if (CategoriasData.frecuencias.contains(transaccion.frecuenciaRecurrencia)) {
        _frecuenciaRecurrencia = transaccion.frecuenciaRecurrencia!;
      } else {
        _frecuenciaRecurrencia = 'Mensual';
      }
    }

    _fechaFinalizacionRecurrencia = transaccion.fechaFinalizacionRecurrencia;

    //si es recurrente pero no tiene fecha de finalizacion establezco una por defecto
    if (_transaccionRecurrente && _fechaFinalizacionRecurrencia == null) {
      _fechaFinalizacionRecurrencia =
          DateTime.now().add(const Duration(days: 30));
    }
  }

  //libero recursos
  void dispose() {
    cantidadController.dispose();
    descripcionController.dispose();
    nuevaCategoriaController.dispose();
  }

  //guardo o actualizar la transaccion
  Future<void> guardarTransaccion() async {
    if (formKey.currentState!.validate()) {
      setLoading(true);

      try {
        final double cantidad =
            double.parse(cantidadController.text.replaceAll(',', '.'));

        final transaccion = Transaccion(
          id: transaccionEditar?.id,
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
        );

        if (transaccionEditar == null) {
          //crear nueva transaccion
          await _transaccionesService.crearTransaccion(idUsuario, transaccion);
        } else {
          //actualizo la transaccion existente
          await _transaccionesService.actualizarTransaccion(
            idUsuario,
            transaccionEditar!.id!,
            transaccion,
          );
        }

        return Future.value();
      } finally {
        setLoading(false);
      }
>>>>>>> 8f1d397338e300a443102a7f54c5ce411ddd3503
    }
  }
}


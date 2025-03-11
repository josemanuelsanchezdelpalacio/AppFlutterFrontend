import 'package:flutter/material.dart';
import 'package:flutter_proyecto_app/data/transaccion.dart';
import 'package:flutter_proyecto_app/services/transacciones_service.dart';

class AddTransaccionesViewModel {
  final int idUsuario;
  final Transaccion? transaccionEditar;
  final TransaccionesService _transaccionesService = TransaccionesService();

  AddTransaccionesViewModel({
    required this.idUsuario,
    this.transaccionEditar,
  });

  //key para el formulario
  final formKey = GlobalKey<FormState>();

  //controladores para los campos del formulario
  final cantidadController = TextEditingController();
  final descripcionController = TextEditingController();
  final nuevaCategoriaController = TextEditingController();

  //variables para almacenar los valores de los campos
  TipoTransacciones _tipoTransaccion = TipoTransacciones.GASTO;
  String _categoria = 'Alimentacion';
  DateTime _fechaTransaccion = DateTime.now();
  bool _transaccionRecurrente = false;
  String _frecuenciaRecurrencia = 'Mensual';
  DateTime? _fechaFinalizacionRecurrencia;
  bool _mostrarNuevaCategoria = false;

  bool _isLoading = false;

  //categorias predefinidas para gastos e ingresos
  final List<String> categoriasGastos = [
    'Alimentación',
    'Transporte',
    'Vivienda',
    'Entretenimiento',
    'Salud',
    'Educación',
    'Ropa',
    'Servicios',
    'Deudas',
    'Otros',
  ];

  final List<String> categoriasIngresos = [
    'Salario',
    'Inversiones',
    'Freelance',
    'Regalo',
    'Reembolso',
    'Venta',
    'Otros',
  ];

  // Categorías personalizadas
  final List<String> _categoriasPersonalizadasGastos = [];
  final List<String> _categoriasPersonalizadasIngresos = [];

  final List<String> frecuencias = [
    'Diaria',
    'Semanal',
    'Quincenal',
    'Mensual',
    'Anual',
  ];

  TipoTransacciones get tipoTransaccion => _tipoTransaccion;
  String get categoria => _categoria;
  DateTime get fechaTransaccion => _fechaTransaccion;
  bool get transaccionRecurrente => _transaccionRecurrente;
  String get frecuenciaRecurrencia => _frecuenciaRecurrencia;
  DateTime? get fechaFinalizacionRecurrencia => _fechaFinalizacionRecurrencia;
  bool get isLoading => _isLoading;
  bool get mostrarNuevaCategoria => _mostrarNuevaCategoria;

  // Getters para categorías combinadas (predefinidas + personalizadas)
  List<String> get todasCategoriasGastos => [
        ...categoriasGastos,
        ..._categoriasPersonalizadasGastos,
        'Nueva categoría...'
      ];
  List<String> get todasCategoriasIngresos => [
        ...categoriasIngresos,
        ..._categoriasPersonalizadasIngresos,
        'Nueva categoría...'
      ];

  // Getter para obtener todas las categorías según el tipo de transacción
  List<String> get categoriasPorTipo =>
      _tipoTransaccion == TipoTransacciones.GASTO
          ? todasCategoriasGastos
          : todasCategoriasIngresos;

  void setTipoTransaccion(TipoTransacciones tipo) {
    _tipoTransaccion = tipo;
    _mostrarNuevaCategoria = false;
    nuevaCategoriaController.clear();

    //compruebo si la categoria actual existe en la lista correspondiente al nuevo tipo
    final categoriasActuales = categoriasPorTipo;

    //si la categoria actual no está en la lista, establezco la primera categoria como predeterminada
    if (!categoriasActuales.contains(_categoria)) {
      _categoria = categoriasActuales.first;
    }
  }

  void setCategoria(String nuevaCategoria) {
    if (nuevaCategoria == 'Nueva categoría...') {
      _mostrarNuevaCategoria = true;
      nuevaCategoriaController.clear();
    } else {
      _categoria = nuevaCategoria;
      _mostrarNuevaCategoria = false;
    }
  }

  void setFechaTransaccion(DateTime fecha) {
    _fechaTransaccion = fecha;
  }

  void setTransaccionRecurrente(bool valor) {
    _transaccionRecurrente = valor;
    if (valor && _fechaFinalizacionRecurrencia == null) {
      _fechaFinalizacionRecurrencia =
          DateTime.now().add(const Duration(days: 30));
    }
  }

  void setFrecuenciaRecurrencia(String frecuencia) {
    _frecuenciaRecurrencia = frecuencia;
  }

  void setFechaFinalizacionRecurrencia(DateTime? fecha) {
    _fechaFinalizacionRecurrencia = fecha;
  }

  void setLoading(bool loading) {
    _isLoading = loading;
  }

  void agregarCategoriaPersonalizada(String nuevaCategoria) {
    if (nuevaCategoria.isEmpty) return;

    if (_tipoTransaccion == TipoTransacciones.GASTO) {
      if (!_categoriasPersonalizadasGastos.contains(nuevaCategoria) &&
          !categoriasGastos.contains(nuevaCategoria)) {
        _categoriasPersonalizadasGastos.add(nuevaCategoria);
      }
    } else {
      if (!_categoriasPersonalizadasIngresos.contains(nuevaCategoria) &&
          !categoriasIngresos.contains(nuevaCategoria)) {
        _categoriasPersonalizadasIngresos.add(nuevaCategoria);
      }
    }

    _categoria = nuevaCategoria;
    _mostrarNuevaCategoria = false;
    nuevaCategoriaController.clear();
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
        ? categoriasGastos
        : categoriasIngresos;

    //si la categoria existe en la lista, la asignamos, sino la agregamos a las categorías personalizadas
    if (categoriasDisponibles.contains(transaccion.categoria)) {
      _categoria = transaccion.categoria;
    } else {
      // Verificar si es una categoría personalizada existente
      final categoriasPersonalizadas =
          _tipoTransaccion == TipoTransacciones.GASTO
              ? _categoriasPersonalizadasGastos
              : _categoriasPersonalizadasIngresos;

      if (categoriasPersonalizadas.contains(transaccion.categoria)) {
        _categoria = transaccion.categoria;
      } else {
        // Si no existe en ninguna lista, la agregamos como categoría personalizada
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
      if (frecuencias.contains(transaccion.frecuenciaRecurrencia)) {
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
    }
  }
}

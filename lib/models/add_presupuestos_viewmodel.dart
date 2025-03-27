import 'package:flutter/material.dart';
import 'package:flutter_proyecto_app/data/categorias_data.dart';
import 'package:flutter_proyecto_app/data/presupuesto.dart';
import 'package:flutter_proyecto_app/services/presupuestos_service.dart';

class AddPresupuestoViewModel {
  AddPresupuestoViewModel({
    required this.idUsuario,
    this.presupuestoParaEditar,
    required this.onStateChanged,
  });

<<<<<<< HEAD
  //campos y servicio
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final PresupuestosService _presupuestoService = PresupuestosService();

  //variables para el id del usuario y contexto de edición
=======
  // Campos y servicio
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final PresupuestosService _presupuestoService = PresupuestosService();

  // Variables para el id del usuario y contexto de edición
>>>>>>> 8f1d397338e300a443102a7f54c5ce411ddd3503
  final int idUsuario;
  final Presupuesto? presupuestoParaEditar;
  final VoidCallback onStateChanged;

<<<<<<< HEAD
  //controladores para los campos
=======
  // Controladores para los campos
>>>>>>> 8f1d397338e300a443102a7f54c5ce411ddd3503
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController cantidadController = TextEditingController();
  final TextEditingController nuevaCategoriaController = TextEditingController();

<<<<<<< HEAD
  //estado del formulario
=======
  // Estado del formulario
>>>>>>> 8f1d397338e300a443102a7f54c5ce411ddd3503
  bool isLoading = false;
  String errorMessage = '';
  bool isEditMode = false;
  int? presupuestoId;
  bool mostrarCampoNuevaCategoria = false;

<<<<<<< HEAD
  //uso categorías predefinidas de CategoriasData
=======
  // Usar categorías predefinidas de CategoriasData
>>>>>>> 8f1d397338e300a443102a7f54c5ce411ddd3503
  final List<String> categoriasPredefinidas = CategoriasData.categoriasGastos;

  final List<String> _categoriasPersonalizadas = [];

  List<String> get categorias {
    return [
      ...categoriasPredefinidas,
      ..._categoriasPersonalizadas,
      'Personalizada'
    ];
  }

<<<<<<< HEAD
  //variables de estado
=======
  // Variables de estado
>>>>>>> 8f1d397338e300a443102a7f54c5ce411ddd3503
  String _categoriaSeleccionada = CategoriasData.categoriasGastos.first;
  DateTime _fechaInicio = DateTime.now();
  DateTime _fechaFin = DateTime.now().add(const Duration(days: 30));
  double _cantidadGastada = 0.0;

  String get categoriaSeleccionada => _categoriaSeleccionada;
  DateTime get fechaInicio => _fechaInicio;
  DateTime get fechaFin => _fechaFin;
  double get cantidadGastada => _cantidadGastada;

  set categoriaSeleccionada(String categoria) {
    _categoriaSeleccionada = categoria;

    mostrarCampoNuevaCategoria = (categoria == 'Personalizada');

    onStateChanged();
  }

<<<<<<< HEAD
  //metodo para agregar una nueva categoría personalizada
=======
  // Método para agregar una nueva categoría personalizada
>>>>>>> 8f1d397338e300a443102a7f54c5ce411ddd3503
  void agregarCategoriaPersonalizada(String nuevaCategoria) {
    if (nuevaCategoria.isNotEmpty &&
        !_categoriasPersonalizadas.contains(nuevaCategoria) &&
        !categoriasPredefinidas.contains(nuevaCategoria)) {
      _categoriasPersonalizadas.add(nuevaCategoria);
      _categoriaSeleccionada = nuevaCategoria;
      mostrarCampoNuevaCategoria = false;
      nuevaCategoriaController.clear();
      onStateChanged();
    }
  }

<<<<<<< HEAD
  //metodo para inicializar los campos con datos del presupuesto existente si estamos editando
=======
  // Método para inicializar los campos con datos del presupuesto existente si estamos editando
>>>>>>> 8f1d397338e300a443102a7f54c5ce411ddd3503
  void inicializarFormulario() {
    if (presupuestoParaEditar != null) {
      final presupuesto = presupuestoParaEditar!;
      isEditMode = true;
      presupuestoId = presupuesto.id;

<<<<<<< HEAD
      //relleno todos los campos
      nombreController.text = presupuesto.nombre ?? '';
      cantidadController.text = presupuesto.cantidad.toString();

      //compruebo si la categoría existe en la lista de categorías
      final categoriaNormalizada = _normalizarCategoria(presupuesto.categoria);

      //si la categoría no está en las predefinidas la agrego a las personalizadas
=======
      // Relleno todos los campos
      nombreController.text = presupuesto.nombre ?? '';
      cantidadController.text = presupuesto.cantidad.toString();

      // Corrigo el problema de codificación para la categoría
      // Compruebo si la categoría existe en la lista de categorías
      final categoriaNormalizada = _normalizarCategoria(presupuesto.categoria);

      // Si la categoría no está en las predefinidas, la agregamos a las personalizadas
>>>>>>> 8f1d397338e300a443102a7f54c5ce411ddd3503
      if (!categoriasPredefinidas.contains(categoriaNormalizada) &&
          !_categoriasPersonalizadas.contains(categoriaNormalizada) &&
          categoriaNormalizada != 'Personalizada') {
        _categoriasPersonalizadas.add(categoriaNormalizada);
      }

      if (categorias.contains(categoriaNormalizada)) {
        _categoriaSeleccionada = categoriaNormalizada;
      } else {
<<<<<<< HEAD
        //si no se encuentra uso el primer valor por defecto
=======
        // Si no se encuentra uso el primer valor por defecto
>>>>>>> 8f1d397338e300a443102a7f54c5ce411ddd3503
        _categoriaSeleccionada = categorias.first;
      }

      _fechaInicio = presupuesto.fechaInicio;
      _fechaFin = presupuesto.fechaFin;
      _cantidadGastada = presupuesto.cantidadGastada;
    }
  }

<<<<<<< HEAD
  //metodo para normalizar la categoría (corrige problemas de codificación)
  String _normalizarCategoria(String categoria) {
    //mapeo de posibles categorías con problemas de codificación
=======
  // Método para normalizar la categoría (corrige problemas de codificación)
  String _normalizarCategoria(String categoria) {
    // Mapeo de posibles categorías con problemas de codificación
>>>>>>> 8f1d397338e300a443102a7f54c5ce411ddd3503
    final Map<String, String> mapeoCategoriasCorrectas = {
      'AlimentaciÃ³n': 'Alimentación',
      'EducaciÃ³n': 'Educación',
      'TransportaciÃ³n': 'Transporte',
    };

    return mapeoCategoriasCorrectas[categoria] ?? categoria;
  }

<<<<<<< HEAD
  //metodo para actualizar las fechas
  void actualizarFechaInicio(DateTime fecha) {
    _fechaInicio = fecha;
    //aseguro que la fecha de fin no sea anterior a la de inicio
=======
  // Libero recursos
  void dispose() {
    nombreController.dispose();
    cantidadController.dispose();
    nuevaCategoriaController.dispose();
  }

  // Método para actualizar las fechas
  void actualizarFechaInicio(DateTime fecha) {
    _fechaInicio = fecha;
    // Aseguro que la fecha de fin no sea anterior a la de inicio
>>>>>>> 8f1d397338e300a443102a7f54c5ce411ddd3503
    if (_fechaInicio.isAfter(_fechaFin)) {
      _fechaFin = _fechaInicio.add(const Duration(days: 1));
    }
    onStateChanged();
  }

  void actualizarFechaFin(DateTime fecha) {
    _fechaFin = fecha;
    onStateChanged();
  }

<<<<<<< HEAD
  //metodos de validación
=======
  // Métodos de validación
>>>>>>> 8f1d397338e300a443102a7f54c5ce411ddd3503
  String? validarNombre(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Por favor ingresa un nombre para el presupuesto';
    }
    if (value.trim().length < 2) {
      return 'El nombre debe tener al menos 2 caracteres';
    }
    return null;
  }

  String? validarMonto(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ingresa una cantidad';
    }

<<<<<<< HEAD
    //reemplazo coma con punto para el análisis
=======
    // Reemplazo coma con punto para el análisis
>>>>>>> 8f1d397338e300a443102a7f54c5ce411ddd3503
    final valorNumerico = value.replaceAll(',', '.');

    try {
      final cantidad = double.parse(valorNumerico);
      if (cantidad <= 0) {
        return 'La cantidad debe ser mayor a 0';
      }

      // Validación adicional para modo de edición
      if (isEditMode && cantidad < _cantidadGastada) {
        return 'La cantidad debe ser mayor o igual a lo ya gastado (\$${_cantidadGastada.toStringAsFixed(2)})';
      }
    } catch (e) {
      return 'Ingresa una cantidad válida';
    }

    return null;
  }

  String? validarCategoria(String? value) {
    if (value == 'Agregar categoría personalizada...') {
      return 'Por favor ingresa una nueva categoría o selecciona una existente';
    }
    return null;
  }

  String? validarNuevaCategoria(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Por favor ingresa el nombre de la categoría';
    }
    if (value.trim().length < 2) {
      return 'El nombre debe tener al menos 2 caracteres';
    }
    return null;
  }

<<<<<<< HEAD
  //metodo para guardar presupuesto
  Future<bool> guardarPresupuesto() async {
    //compruebo si se está intentando guardar
=======
  // Método para guardar presupuesto
  Future<bool> guardarPresupuesto() async {
    // Verificar si se está intentando guardar con "Agregar categoría personalizada..." seleccionada
>>>>>>> 8f1d397338e300a443102a7f54c5ce411ddd3503
    if (_categoriaSeleccionada == 'Agregar categoría personalizada...') {
      errorMessage = 'Por favor selecciona una categoría o agrega una nueva';
      onStateChanged();
      return false;
    }

    if (formKey.currentState!.validate()) {
      try {
        isLoading = true;
        errorMessage = '';
        onStateChanged();

<<<<<<< HEAD
        //analizo la cantidad del presupuesto
        final double cantidad =
            double.parse(cantidadController.text.replaceAll(',', '.'));

        //creo el objeto de presupuesto
=======
        // Analizo la cantidad del presupuesto
        final double cantidad =
            double.parse(cantidadController.text.replaceAll(',', '.'));

        // Creo el objeto de presupuesto
>>>>>>> 8f1d397338e300a443102a7f54c5ce411ddd3503
        final presupuesto = Presupuesto(
          id: isEditMode ? presupuestoId : null,
          nombre: nombreController.text.trim(),
          categoria: _categoriaSeleccionada,
          cantidad: cantidad,
          fechaInicio: _fechaInicio,
          fechaFin: _fechaFin,
          cantidadGastada: isEditMode ? _cantidadGastada : 0.0,
          cantidadRestante: cantidad - (isEditMode ? _cantidadGastada : 0.0),
        );

<<<<<<< HEAD
        //envio los datos al servidor
=======
        // Envío los datos al servidor
>>>>>>> 8f1d397338e300a443102a7f54c5ce411ddd3503
        if (isEditMode && presupuestoId != null) {
          await _presupuestoService.actualizarPresupuesto(
              idUsuario, presupuestoId!, presupuesto);
        } else {
          await _presupuestoService.crearPresupuesto(idUsuario, presupuesto);
        }

<<<<<<< HEAD
        //reinicio formulario si se está creando un nuevo presupuesto
=======
        // Reinicio formulario si se está creando un nuevo presupuesto
>>>>>>> 8f1d397338e300a443102a7f54c5ce411ddd3503
        if (!isEditMode) {
          nombreController.clear();
          cantidadController.clear();
          _categoriaSeleccionada = categorias.first;
          _fechaInicio = DateTime.now();
          _fechaFin = DateTime.now().add(const Duration(days: 30));
          onStateChanged();
        }

        return true;
      } catch (e) {
        errorMessage =
            'Error al ${isEditMode ? 'actualizar' : 'crear'} el presupuesto: ${e.toString()}';
        onStateChanged();
        return false;
      } finally {
        isLoading = false;
        onStateChanged();
      }
    }
    return false;
  }
<<<<<<< HEAD

  //libero recursos
  void dispose() {
    nombreController.dispose();
    cantidadController.dispose();
    nuevaCategoriaController.dispose();
  }
}

=======
}
>>>>>>> 8f1d397338e300a443102a7f54c5ce411ddd3503

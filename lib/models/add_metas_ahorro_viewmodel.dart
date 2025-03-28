import 'package:flutter/material.dart';
import 'package:flutter_proyecto_app/data/categorias_data.dart';
import 'package:flutter_proyecto_app/data/metas_ahorro.dart';
import 'package:flutter_proyecto_app/services/metas_ahorro_service.dart';

class AddMetasAhorroViewModel {
  final int idUsuario;
  final MetaAhorro? metaAhorroParaEditar;
  final MetasAhorroService _metasAhorroService = MetasAhorroService();

  //controladores para los campos
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController categoriaController = TextEditingController();
  final TextEditingController categoriaPersonalizadaController =
      TextEditingController();
  final TextEditingController nuevaCategoriaController = TextEditingController();
  final TextEditingController cantidadObjetivoController =
      TextEditingController();
  final TextEditingController cantidadActualController =
      TextEditingController();

  DateTime _fechaObjetivo = DateTime.now().add(const Duration(days: 30));
  bool _isLoading = false;
  String? _errorMessage;
  bool _isEditing = false;
  int? _metaId;
  bool _isCustomCategory = false;
  bool mostrarCampoNuevaCategoria = false;

  //uso categorías predefinidas de ingresos de CategoriasData
  List<String> categoriasPredefinidas = CategoriasData.categoriasIngresos;

  AddMetasAhorroViewModel({
    required this.idUsuario,
    this.metaAhorroParaEditar,
  }) {
    _inicializar();
  }

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isEditing => _isEditing;
  DateTime get fechaObjetivo => _fechaObjetivo;
  bool get isCustomCategory => _isCustomCategory;
  List<String> get categorias => [...categoriasPredefinidas, 'Personalizada'];

  void _inicializar() {
    if (metaAhorroParaEditar != null) {
      _isEditing = true;
      _metaId = metaAhorroParaEditar!.id;
      nombreController.text = metaAhorroParaEditar!.nombre;

      // Determino si es una categoría personalizada
      if (!categoriasPredefinidas.contains(metaAhorroParaEditar!.categoria)) {
        _isCustomCategory = true;
        categoriaPersonalizadaController.text = metaAhorroParaEditar!.categoria;
        categoriaController.text = 'Personalizada';
        mostrarCampoNuevaCategoria = true;
      } else {
        categoriaController.text = metaAhorroParaEditar!.categoria;
      }

      cantidadObjetivoController.text =
          metaAhorroParaEditar!.cantidadObjetivo.toString();
      cantidadActualController.text =
          metaAhorroParaEditar!.cantidadActual.toString();
      _fechaObjetivo = metaAhorroParaEditar!.fechaObjetivo;
    } else {
      //inicializo para una nueva meta con valores por defecto
      nombreController.text = '';
      categoriaController.text = categoriasPredefinidas.first;
      cantidadActualController.text = '0.0';
    }
  }

  //metodos para actualizar el estado
  void setLoading(bool loading) {
    _isLoading = loading;
  }

  void updateFechaObjetivo(DateTime fecha) {
    _fechaObjetivo = fecha;
  }

  void toggleCustomCategory(bool value) {
    _isCustomCategory = value;
  }

  void agregarCategoriaPersonalizada(String nuevaCategoria) {
    if (nuevaCategoria.isNotEmpty && !categoriasPredefinidas.contains(nuevaCategoria)) {
      categoriasPredefinidas.add(nuevaCategoria);
      categoriaController.text = nuevaCategoria;
      _isCustomCategory = false;
      nuevaCategoriaController.clear();
    }
  }

  void addNewCategory(String newCategory) {
    agregarCategoriaPersonalizada(newCategory);
  }

  // Reseteo el formulario para nueva entrada
  void resetForm() {
    nombreController.text = '';
    categoriaController.text = categoriasPredefinidas.first;
    categoriaPersonalizadaController.clear();
    cantidadObjetivoController.clear();
    cantidadActualController.text = '0.0';
    _fechaObjetivo = DateTime.now().add(const Duration(days: 30));
    _errorMessage = null;
    _isCustomCategory = false;
    mostrarCampoNuevaCategoria = false;
  }

  //metodo para guardar la meta de ahorro
  Future<String> guardarMetaAhorro() async {
    _errorMessage = null;

    try {
      // Validación del nombre
      if (nombreController.text.trim().isEmpty) {
        throw Exception('El nombre de la meta no puede estar vacío');
      }

      // Determino la categoría final
      final categoria = _isCustomCategory && mostrarCampoNuevaCategoria && 
                      nuevaCategoriaController.text.isNotEmpty
          ? nuevaCategoriaController.text.trim()
          : (_isCustomCategory && categoriaPersonalizadaController.text.isNotEmpty
              ? categoriaPersonalizadaController.text.trim()
              : categoriaController.text.trim());

      final metaAhorro = MetaAhorro(
        id: _isEditing ? _metaId : null,
        nombre: nombreController.text.trim(),
        categoria: categoria,
        cantidadObjetivo:
            double.parse(cantidadObjetivoController.text.replaceAll(',', '.')),
        cantidadActual:
            double.parse(cantidadActualController.text.replaceAll(',', '.')),
        fechaObjetivo: _fechaObjetivo,
        completada: double.parse(
                cantidadActualController.text.replaceAll(',', '.')) >=
            double.parse(cantidadObjetivoController.text.replaceAll(',', '.')),
      );

      if (_isEditing) {
        //actualizo la meta existente
        await _metasAhorroService.actualizarMetaAhorro(
            idUsuario, metaAhorro.id!, metaAhorro);
        return 'Meta de ahorro actualizada correctamente';
      } else {
        //creo una nueva meta
        await _metasAhorroService.crearMetaAhorro(idUsuario, metaAhorro);
        return 'Meta de ahorro creada correctamente';
      }
    } catch (e) {
      _errorMessage =
          'Error al ${_isEditing ? "actualizar" : "crear"} la meta de ahorro: $e';
      throw Exception(_errorMessage);
    }
  }

  //libero recursos
  void dispose() {
    nombreController.dispose();
    categoriaController.dispose();
    categoriaPersonalizadaController.dispose();
    nuevaCategoriaController.dispose();
    cantidadObjetivoController.dispose();
    cantidadActualController.dispose();
  }
}


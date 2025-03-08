import 'package:flutter/material.dart';
import 'package:flutter_proyecto_app/data/presupuesto.dart';
import 'package:flutter_proyecto_app/services/presupuestos_service.dart';

class AddPresupuestoViewModel {
  // Form and service
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final PresupuestosService _presupuestoService = PresupuestosService();
  
  // User and editing context
  final int idUsuario;
  final Presupuesto? presupuestoParaEditar;
  final VoidCallback onStateChanged;
  
  // Controllers
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController cantidadController = TextEditingController();
  
  // Form state
  bool isLoading = false;
  String errorMessage = '';
  bool isEditMode = false;
  int? presupuestoId;
  
  // Dropdown options
  final List<String> categorias = [
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
  
  // Private state variables
  String _categoriaSeleccionada = 'Alimentación';
  DateTime _fechaInicio = DateTime.now();
  DateTime _fechaFin = DateTime.now().add(const Duration(days: 30));
  double _cantidadGastada = 0.0;
  
  // Getters
  String get categoriaSeleccionada => _categoriaSeleccionada;
  DateTime get fechaInicio => _fechaInicio;
  DateTime get fechaFin => _fechaFin;
  double get cantidadGastada => _cantidadGastada;
  
  // Setters
  set categoriaSeleccionada(String categoria) {
    _categoriaSeleccionada = categoria;
    onStateChanged();
  }
  
  // Constructor
  AddPresupuestoViewModel({
    required this.idUsuario,
    this.presupuestoParaEditar,
    required this.onStateChanged
  });
  
  // Initialize form with existing budget data if editing
  void inicializarFormulario() {
    if (presupuestoParaEditar != null) {
      final presupuesto = presupuestoParaEditar!;
      isEditMode = true;
      presupuestoId = presupuesto.id;
      
      // Populate all fields
      nombreController.text = presupuesto.nombre ?? '';
      cantidadController.text = presupuesto.cantidad.toString();
      
      // Corregir el problema de codificación para la categoría
      // Verificar si la categoría existe en la lista de categorías
      final categoriaNormalizada = _normalizarCategoria(presupuesto.categoria);
      if (categorias.contains(categoriaNormalizada)) {
        _categoriaSeleccionada = categoriaNormalizada;
      } else {
        // Si no se encuentra, usar el primer valor por defecto
        _categoriaSeleccionada = categorias.first;
      }
      
      _fechaInicio = presupuesto.fechaInicio;
      _fechaFin = presupuesto.fechaFin;
      _cantidadGastada = presupuesto.cantidadGastada;
    }
  }
  
  // Método para normalizar la categoría (corrige problemas de codificación)
  String _normalizarCategoria(String categoria) {
    // Mapeo de posibles categorías con problemas de codificación
    final Map<String, String> mapeoCategoriasCorrectas = {
      'AlimentaciÃ³n': 'Alimentación',
      'EducaciÃ³n': 'Educación',
      'TransportaciÃ³n': 'Transporte',
    };
    
    return mapeoCategoriasCorrectas[categoria] ?? categoria;
  }
  
  // Cleanup method
  void dispose() {
    nombreController.dispose();
    cantidadController.dispose();
  }
  
  // Date manipulation methods
  void actualizarFechaInicio(DateTime fecha) {
    _fechaInicio = fecha;
    // Ensure end date is not before start date
    if (_fechaInicio.isAfter(_fechaFin)) {
      _fechaFin = _fechaInicio.add(const Duration(days: 1));
    }
    onStateChanged();
  }
  
  void actualizarFechaFin(DateTime fecha) {
    _fechaFin = fecha;
    onStateChanged();
  }
  
  // Validation methods
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
      return 'Por favor ingresa un monto';
    }
    
    // Replace comma with dot for parsing
    final valorNumerico = value.replaceAll(',', '.');
    
    try {
      final monto = double.parse(valorNumerico);
      if (monto <= 0) {
        return 'El monto debe ser mayor a 0';
      }
      
      // Additional validation for edit mode
      if (isEditMode && monto < _cantidadGastada) {
        return 'El monto debe ser mayor o igual a lo ya gastado (\$${_cantidadGastada.toStringAsFixed(2)})';
      }
    } catch (e) {
      return 'Ingresa un monto válido';
    }
    
    return null;
  }
  
  // Save budget method
  Future<bool> guardarPresupuesto() async {
    if (formKey.currentState!.validate()) {
      try {
        isLoading = true;
        errorMessage = '';
        onStateChanged();
        
        // Parse budget amount
        final double monto = double.parse(
          cantidadController.text.replaceAll(',', '.')
        );
        
        // Create budget object
        final presupuesto = Presupuesto(
          id: isEditMode ? presupuestoId : null,
          nombre: nombreController.text.trim(),
          categoria: _categoriaSeleccionada,
          cantidad: monto,
          fechaInicio: _fechaInicio,
          fechaFin: _fechaFin,
          cantidadGastada: isEditMode ? _cantidadGastada : 0.0,
          cantidadRestante: monto - (isEditMode ? _cantidadGastada : 0.0),
        );
        
        // Send to server
        if (isEditMode && presupuestoId != null) {
          await _presupuestoService.actualizarPresupuesto(
            idUsuario, 
            presupuestoId!, 
            presupuesto
          );
        } else {
          await _presupuestoService.crearPresupuesto(
            idUsuario, 
            presupuesto
          );
        }
        
        // Reset form if creating new budget
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
        errorMessage = 'Error al ${isEditMode ? 'actualizar' : 'crear'} el presupuesto: ${e.toString()}';
        onStateChanged();
        return false;
      } finally {
        isLoading = false;
        onStateChanged();
      }
    }
    return false;
  }
}


import 'package:flutter/material.dart';
import 'package:flutter_proyecto_app/data/transaccion.dart';
import 'package:flutter_proyecto_app/services/transacciones_service.dart';

class AddTransactionViewModel {
  final int idUsuario;
  final Transaccion? transaccionEditar;
  final TransaccionesService _transaccionesService = TransaccionesService();
  
  // Key para el formulario
  final formKey = GlobalKey<FormState>();
  
  // Controladores para los campos del formulario
  final cantidadController = TextEditingController();
  final descripcionController = TextEditingController();
  
  // Variables para almacenar los valores del formulario
  TipoTransacciones _tipoTransaccion = TipoTransacciones.GASTO;
  String _categoria = 'Alimentación';
  DateTime _fechaTransaccion = DateTime.now();
  bool _transaccionRecurrente = false;
  String _frecuenciaRecurrencia = 'Mensual';
  DateTime? _fechaFinalizacionRecurrencia;
  
  bool _isLoading = false;
  
  // Categorías predefinidas para gastos e ingresos
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
  
  final List<String> frecuencias = [
    'Diaria',
    'Semanal',
    'Quincenal',
    'Mensual',
    'Anual',
  ];
  
  AddTransactionViewModel({
    required this.idUsuario,
    this.transaccionEditar,
  });
  
  // Getters y Setters
  TipoTransacciones get tipoTransaccion => _tipoTransaccion;
  String get categoria => _categoria;
  DateTime get fechaTransaccion => _fechaTransaccion;
  bool get transaccionRecurrente => _transaccionRecurrente;
  String get frecuenciaRecurrencia => _frecuenciaRecurrencia;
  DateTime? get fechaFinalizacionRecurrencia => _fechaFinalizacionRecurrencia;
  bool get isLoading => _isLoading;
  
  void setTipoTransaccion(TipoTransacciones tipo) {
    _tipoTransaccion = tipo;
    
    // Verificar si la categoría actual existe en la lista correspondiente al nuevo tipo
    final categoriasActuales = tipo == TipoTransacciones.GASTO 
        ? categoriasGastos 
        : categoriasIngresos;
    
    // Si la categoría actual no está en la lista, establecer la primera categoría como predeterminada
    if (!categoriasActuales.contains(_categoria)) {
      _categoria = categoriasActuales.first;
    }
  }
  
  void setCategoria(String nuevaCategoria) {
    _categoria = nuevaCategoria;
  }
  
  void setFechaTransaccion(DateTime fecha) {
    _fechaTransaccion = fecha;
  }
  
  void setTransaccionRecurrente(bool valor) {
    _transaccionRecurrente = valor;
    if (valor && _fechaFinalizacionRecurrencia == null) {
      _fechaFinalizacionRecurrencia = DateTime.now().add(const Duration(days: 30));
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
  
  // Inicializar ViewModel con datos existentes si es edición
  void init() {
    if (transaccionEditar != null) {
      _loadTransaccionData();
    }
  }
  
  // Cargar datos de la transacción a editar
  void _loadTransaccionData() {
    final transaccion = transaccionEditar!;
    cantidadController.text = transaccion.cantidad.toString();
    descripcionController.text = transaccion.descripcion;
    _tipoTransaccion = transaccion.tipoTransaccion;
    
    // Verificamos que la categoría de la transacción exista en la lista correspondiente
    final categoriasDisponibles = transaccion.tipoTransaccion == TipoTransacciones.GASTO 
        ? categoriasGastos 
        : categoriasIngresos;
    
    // Si la categoría existe en la lista, la asignamos, sino usamos la primera de la lista
    if (categoriasDisponibles.contains(transaccion.categoria)) {
      _categoria = transaccion.categoria;
    } else {
      _categoria = categoriasDisponibles.first;
    }
    
    _fechaTransaccion = transaccion.fechaTransaccion;
    _transaccionRecurrente = transaccion.transaccionRecurrente;
    
    // Asegurarnos de que la frecuencia de recurrencia sea válida
    if (transaccion.transaccionRecurrente && transaccion.frecuenciaRecurrencia != null) {
      if (frecuencias.contains(transaccion.frecuenciaRecurrencia)) {
        _frecuenciaRecurrencia = transaccion.frecuenciaRecurrencia!;
      } else {
        _frecuenciaRecurrencia = 'Mensual'; // Valor por defecto
      }
    }
    
    _fechaFinalizacionRecurrencia = transaccion.fechaFinalizacionRecurrencia;
    
    // Si es recurrente pero no tiene fecha de finalización, establecer una por defecto
    if (_transaccionRecurrente && _fechaFinalizacionRecurrencia == null) {
      _fechaFinalizacionRecurrencia = DateTime.now().add(const Duration(days: 30));
    }
  }
  
  // Liberar recursos
  void dispose() {
    cantidadController.dispose();
    descripcionController.dispose();
  }
  
  // Guardar o actualizar la transacción
  Future<void> guardarTransaccion() async {
    if (formKey.currentState!.validate()) {
      setLoading(true);
      
      try {
        final double cantidad = double.parse(cantidadController.text.replaceAll(',', '.'));
        
        final transaccion = Transaccion(
          id: transaccionEditar?.id,
          cantidad: cantidad,
          descripcion: descripcionController.text,
          tipoTransaccion: _tipoTransaccion,
          categoria: _categoria,
          fechaTransaccion: _fechaTransaccion,
          transaccionRecurrente: _transaccionRecurrente,
          frecuenciaRecurrencia: _transaccionRecurrente ? _frecuenciaRecurrencia : null,
          fechaFinalizacionRecurrencia: _transaccionRecurrente ? _fechaFinalizacionRecurrencia : null,
        );

        if (transaccionEditar == null) {
          // Crear nueva transacción
          await _transaccionesService.crearTransaccion(idUsuario, transaccion);
        } else {
          // Actualizar transacción existente
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


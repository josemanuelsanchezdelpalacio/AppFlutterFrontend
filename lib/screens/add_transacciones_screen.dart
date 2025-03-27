<<<<<<< HEAD
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_proyecto_app/components/asignacion_transaccion_screen.dart';
import 'package:flutter_proyecto_app/components/barra_inferior_secciones.dart';
=======
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_proyecto_app/components/custom_bottom_app_bar.dart';
>>>>>>> 8f1d397338e300a443102a7f54c5ce411ddd3503
import 'package:flutter_proyecto_app/components/menu_desplegable.dart';
import 'package:flutter_proyecto_app/data/transaccion.dart';
import 'package:flutter_proyecto_app/data/categorias_data.dart';
import 'package:flutter_proyecto_app/models/add_transacciones_viewmodel.dart';
import 'package:flutter_proyecto_app/theme/app_theme.dart';
<<<<<<< HEAD
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
=======
import 'package:intl/intl.dart';
>>>>>>> 8f1d397338e300a443102a7f54c5ce411ddd3503

class AddTransaccionesScreen extends StatefulWidget {
  final int idUsuario;
  final Transaccion? transaccionEditar;

  const AddTransaccionesScreen({
<<<<<<< HEAD
    Key? key,
    required this.idUsuario,
    this.transaccionEditar,
  }) : super(key: key);

  @override
  _AddTransaccionesScreenState createState() => _AddTransaccionesScreenState();
}

class _AddTransaccionesScreenState extends State<AddTransaccionesScreen> {
  final _formKey = GlobalKey<FormState>();
  late AddTransaccionesViewModel _viewModel;
  final TextEditingController _categoriaController = TextEditingController();
  final FocusNode _categoriaFocusNode = FocusNode();
  bool _isCustomCategory = false;
=======
    super.key,
    required this.idUsuario,
    this.transaccionEditar,
  });

  @override
  State<AddTransaccionesScreen> createState() => _AddTransaccionesScreenState();
}

class _AddTransaccionesScreenState extends State<AddTransaccionesScreen> {
  late AddTransaccionesViewModel _viewModel;
>>>>>>> 8f1d397338e300a443102a7f54c5ce411ddd3503

  @override
  void initState() {
    super.initState();
    _viewModel = AddTransaccionesViewModel(
      idUsuario: widget.idUsuario,
      transaccionEditar: widget.transaccionEditar,
    );
<<<<<<< HEAD
    _viewModel.init();
    
    if (widget.transaccionEditar != null && 
        !CategoriasData.categoriasGastos.contains(widget.transaccionEditar!.categoria) &&
        !CategoriasData.categoriasIngresos.contains(widget.transaccionEditar!.categoria)) {
      _isCustomCategory = true;
      _categoriaController.text = widget.transaccionEditar!.categoria;
    }
=======

    //inicializo el ViewModel
    _viewModel.init();
>>>>>>> 8f1d397338e300a443102a7f54c5ce411ddd3503
  }

  @override
  void dispose() {
    _viewModel.dispose();
<<<<<<< HEAD
    _categoriaController.dispose();
    _categoriaFocusNode.dispose();
    super.dispose();
  }

  Future<void> _selectImage() async {
    try {
      final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        _viewModel.setImagen(File(pickedFile.path));
      }
    } catch (e) {
      _showSnackBar('Error al seleccionar la imagen', isError: true);
    }
  }

  Future<void> _selectDate(bool isFinishDate) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isFinishDate 
          ? _viewModel.fechaFinalizacionRecurrencia ?? DateTime.now().add(const Duration(days: 30))
          : _viewModel.fechaTransaccion,
      firstDate: isFinishDate ? DateTime.now() : DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppTheme.naranja,
            onPrimary: AppTheme.colorFondo,
            surface: AppTheme.gris,
            onSurface: AppTheme.blanco,
          ),
          dialogBackgroundColor: AppTheme.colorFondo,
        ),
        child: child!,
      ),
    );

    if (picked != null) {
      isFinishDate 
          ? _viewModel.setFechaFinalizacionRecurrencia(picked)
          : _viewModel.setFechaTransaccion(picked);
    }
  }

  Future<void> _selectAssignment() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AsignacionTransaccionScreen(
          idUsuario: widget.idUsuario,
          tipoTransaccion: _viewModel.tipoTransaccion,
          categoria: _viewModel.categoria,
        ),
      ),
    );

    if (result != null && result is Map<String, dynamic>) {
      result['tipo'] == 'presupuesto'
          ? _viewModel.setPresupuestoId(result['id'] as int)
          : _viewModel.setMetaAhorroId(result['id'] as int);
    }
  }

  Future<void> _saveTransaction() async {
    if (!_formKey.currentState!.validate()) {
      _showSnackBar('Completa todos los campos requeridos');
      return;
    }

    if (_viewModel.transaccionRecurrente && _viewModel.fechaFinalizacionRecurrencia == null) {
      _showSnackBar('Selecciona una fecha de finalización');
      return;
    }

    try {
      _viewModel.setLoading(true);
      await _viewModel.guardarTransaccion();

      if (!mounted) return;
      
      _showSnackBar(widget.transaccionEditar == null 
          ? 'Transacción creada' 
          : 'Transacción actualizada', isSuccess: true);
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('Error al guardar: ${e.toString()}', isError: true);
    } finally {
      if (mounted) _viewModel.setLoading(false);
    }
  }

  void _showSnackBar(String message, {bool isError = false, bool isSuccess = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : (isSuccess ? Colors.green : Colors.orange),
      ),
    );
  }

  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Comprobante', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _selectImage,
          child: Container(
            height: 120,
            decoration: BoxDecoration(
              color: AppTheme.gris,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.naranja.withOpacity(0.3)),
            ),
            child: _viewModel.imagen != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(_viewModel.imagen!, fit: BoxFit.cover),
                  )
                : Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add_a_photo, color: AppTheme.naranja),
                        const SizedBox(height: 4),
                        Text('Agregar imagen', style: TextStyle(color: AppTheme.naranja)),
                      ],
                    ),
                  ),
          ),
        ),
        if (_viewModel.imagen != null)
          TextButton(
            onPressed: () => _viewModel.setImagen(null),
            child: const Text('Eliminar imagen', style: TextStyle(color: Colors.red)),
          ),
      ],
    );
  }

  Widget _buildTypeSelector() {
    return Row(
      children: [
        Expanded(
          child: _TypeButton(
            icon: Icons.arrow_downward,
            text: 'Gasto',
            isSelected: _viewModel.tipoTransaccion == TipoTransacciones.GASTO,
            onTap: () => _viewModel.setTipoTransaccion(TipoTransacciones.GASTO),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _TypeButton(
            icon: Icons.arrow_upward,
            text: 'Ingreso',
            isSelected: _viewModel.tipoTransaccion == TipoTransacciones.INGRESO,
            onTap: () => _viewModel.setTipoTransaccion(TipoTransacciones.INGRESO),
          ),
        ),
      ],
    );
  }

  Widget _buildRecurringSection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Transacción recurrente', style: TextStyle(fontWeight: FontWeight.bold)),
            Switch(
              value: _viewModel.transaccionRecurrente,
              onChanged: _viewModel.setTransaccionRecurrente,
              activeColor: AppTheme.naranja,
            ),
          ],
        ),
        if (_viewModel.transaccionRecurrente) ...[
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _viewModel.frecuenciaRecurrencia,
            items: CategoriasData.frecuencias.map((f) => 
              DropdownMenuItem(value: f, child: Text(f))).toList(),
            onChanged: (v) => _viewModel.setFrecuenciaRecurrencia(v!),
            decoration: InputDecoration(
              labelText: 'Frecuencia',
              labelStyle: const TextStyle(color: Colors.white70),
              prefixIcon: Icon(Icons.repeat, color: AppTheme.naranja),
              border: const OutlineInputBorder(),
              filled: true,
              fillColor: AppTheme.gris,
            ),
            dropdownColor: AppTheme.gris,
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: () => _selectDate(true),
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: 'Fecha final',
                labelStyle: const TextStyle(color: Colors.white70),
                prefixIcon: Icon(Icons.event_busy, color: AppTheme.naranja),
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: AppTheme.gris,
              ),
              child: Text(
                _viewModel.fechaFinalizacionRecurrencia != null
                    ? DateFormat('dd/MM/yyyy').format(_viewModel.fechaFinalizacionRecurrencia!)
                    : 'Seleccionar',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAssignmentButton() {
    if (_viewModel.tipoTransaccion == TipoTransacciones.GASTO || 
        _viewModel.tipoTransaccion == TipoTransacciones.INGRESO) {
      return Column(
        children: [
          OutlinedButton(
            onPressed: _selectAssignment,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.naranja,
              side: BorderSide(color: AppTheme.naranja),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(_viewModel.tipoTransaccion == TipoTransacciones.GASTO 
                    ? Icons.account_balance_wallet 
                    : Icons.savings,
                    color: AppTheme.naranja),
                const SizedBox(width: 8),
                Text(_viewModel.tipoTransaccion == TipoTransacciones.GASTO 
                    ? 'Asignar a presupuesto' 
                    : 'Asignar a meta'),
              ],
            ),
          ),
          if (_viewModel.presupuestoId != null || _viewModel.metaAhorroId != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check, color: Colors.green, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    _viewModel.presupuestoId != null 
                        ? 'Asignado a presupuesto' 
                        : 'Asignado a meta',
                    style: TextStyle(color: Colors.green),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, size: 20),
                    color: Colors.red,
                    onPressed: () => _viewModel.presupuestoId != null
                        ? _viewModel.setPresupuestoId(null)
                        : _viewModel.setMetaAhorroId(null),
                  ),
                ],
              ),
            ),
        ],
      );
    }
    return const SizedBox();
  }

  Widget _buildCategoryField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Categoría', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        if (!_isCustomCategory)
          DropdownButtonFormField<String>(
            value: _viewModel.categoria.isNotEmpty && 
                   _viewModel.categoriasPorTipo.contains(_viewModel.categoria)
                ? _viewModel.categoria
                : null,
            items: [
              ..._viewModel.categoriasPorTipo.map((category) => DropdownMenuItem(
                value: category,
                child: Text(category, style: const TextStyle(color: Colors.white)),
              )).toList(),
              const DropdownMenuItem(
                value: 'Personalizada',
                child: Text('Personalizada', style: TextStyle(color: AppTheme.naranja)),
              ),
            ],
            onChanged: (value) {
              if (value == 'Personalizada') {
                setState(() {
                  _isCustomCategory = true;
                  _viewModel.setCategoria('');
                });
                Future.delayed(const Duration(milliseconds: 100), () {
                  _categoriaFocusNode.requestFocus();
                });
              } else {
                _viewModel.setCategoria(value!);
              }
            },
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.category, color: AppTheme.naranja),
              border: const OutlineInputBorder(),
              filled: true,
              fillColor: AppTheme.gris,
            ),
            dropdownColor: AppTheme.gris,
            style: const TextStyle(color: Colors.white),
            icon: Icon(Icons.arrow_drop_down, color: AppTheme.naranja),
            validator: (value) {
              if ((value == null || value.isEmpty) && !_isCustomCategory) {
                return 'Selecciona una categoría';
              }
              return null;
            },
          ),
        if (_isCustomCategory)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _categoriaController,
                focusNode: _categoriaFocusNode,
                decoration: InputDecoration(
                  labelText: 'Escribe tu categoría personalizada',
                  labelStyle: const TextStyle(color: Colors.white70),
                  prefixIcon: Icon(Icons.create, color: AppTheme.naranja),
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: AppTheme.gris,
                ),
                style: const TextStyle(color: Colors.white),
                onChanged: (value) => _viewModel.setCategoria(value),
                validator: (value) => value!.isEmpty ? 'Ingresa una categoría' : null,
                maxLength: 50,
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _isCustomCategory = false;
                    _categoriaController.clear();
                    _viewModel.setCategoria('');
                  });
                },
                child: const Text('Volver a la lista de categorías', 
                    style: TextStyle(color: AppTheme.naranja)),
              ),
            ],
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditMode = widget.transaccionEditar != null;

    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Consumer<AddTransaccionesViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            backgroundColor: AppTheme.colorFondo,
            appBar: AppBar(
              title: Text(isEditMode ? 'Editar transacción' : 'Nueva transacción'),
              backgroundColor: AppTheme.colorFondo,
              elevation: 0,
              iconTheme: const IconThemeData(color: Colors.white),
            ),
            drawer: MenuDesplegable(idUsuario: widget.idUsuario),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    // Tipo de transacción
                    _buildTypeSelector(),
                    const SizedBox(height: 20),

                    // Campos básicos
                    TextFormField(
                      controller: viewModel.nombreController,
                      decoration: InputDecoration(
                        labelText: 'Nombre',
                        labelStyle: const TextStyle(color: Colors.white70),
                        prefixIcon: Icon(Icons.label, color: AppTheme.naranja),
                        border: const OutlineInputBorder(),
                        filled: true,
                        fillColor: AppTheme.gris,
                      ),
                      style: const TextStyle(color: Colors.white),
                      validator: (v) => v!.isEmpty ? 'Ingresa un nombre' : null,
                      maxLength: 100,
                    ),
                    const SizedBox(height: 12),
                    
                    TextFormField(
                      controller: viewModel.cantidadController,
                      decoration: InputDecoration(
                        labelText: 'Cantidad',
                        labelStyle: const TextStyle(color: Colors.white70),
                        prefixIcon: Icon(Icons.attach_money, color: AppTheme.naranja),
                        border: const OutlineInputBorder(),
                        filled: true,
                        fillColor: AppTheme.gris,
                      ),
                      style: const TextStyle(color: Colors.white),
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                      ],
                      validator: (v) => double.tryParse(v!.replaceAll(',', '.')) == null 
                          ? 'Cantidad inválida' 
                          : null,
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: viewModel.descripcionController,
                      decoration: InputDecoration(
                        labelText: 'Descripción',
                        labelStyle: const TextStyle(color: Colors.white70),
                        prefixIcon: Icon(Icons.description, color: AppTheme.naranja),
                        border: const OutlineInputBorder(),
                        filled: true,
                        fillColor: AppTheme.gris,
                      ),
                      style: const TextStyle(color: Colors.white),
                      maxLength: 200,
                    ),
                    const SizedBox(height: 12),

                    // Campo de categoría modificado
                    _buildCategoryField(),
                    const SizedBox(height: 12),

                    // Fecha
                    InkWell(
                      onTap: () => _selectDate(false),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Fecha',
                          labelStyle: const TextStyle(color: Colors.white70),
                          prefixIcon: Icon(Icons.calendar_today, color: AppTheme.naranja),
                          border: const OutlineInputBorder(),
                          filled: true,
                          fillColor: AppTheme.gris,
                        ),
                        child: Text(
                          DateFormat('dd/MM/yyyy').format(viewModel.fechaTransaccion),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Asignación
                    _buildAssignmentButton(),
                    const SizedBox(height: 16),

                    // Imagen
                    _buildImagePicker(),
                    const SizedBox(height: 16),

                    // Recurrente
                    _buildRecurringSection(),
                    const SizedBox(height: 24),

                    // Botón guardar
                    ElevatedButton(
                      onPressed: viewModel.isLoading ? null : _saveTransaction,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.naranja,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: viewModel.isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(isEditMode ? 'ACTUALIZAR' : 'GUARDAR'),
=======
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //determino si estamos en modo edicion
    final bool isEditMode = widget.transaccionEditar != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? 'Editar transaccion' : 'Nueva transaccion'),
        centerTitle: true,
      ),
      drawer: MenuDesplegable(idUsuario: widget.idUsuario),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _viewModel.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //tipo de transaccion (Ingreso/Gasto)
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.gris,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tipo de transaccion',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTypeButton(
                            title: 'Gasto',
                            icon: Icons.arrow_downward,
                            isSelected: _viewModel.tipoTransaccion ==
                                TipoTransacciones.GASTO,
                            onTap: () {
                              setState(() {
                                _viewModel.setTipoTransaccion(
                                    TipoTransacciones.GASTO);
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTypeButton(
                            title: 'Ingreso',
                            icon: Icons.arrow_upward,
                            isSelected: _viewModel.tipoTransaccion ==
                                TipoTransacciones.INGRESO,
                            onTap: () {
                              setState(() {
                                _viewModel.setTipoTransaccion(
                                    TipoTransacciones.INGRESO);
                              });
                            },
                          ),
                        ),
                      ],
>>>>>>> 8f1d397338e300a443102a7f54c5ce411ddd3503
                    ),
                  ],
                ),
              ),
<<<<<<< HEAD
            ),
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

class _TypeButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  const _TypeButton({
    required this.icon,
    required this.text,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.naranja.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppTheme.naranja : Colors.grey,
=======

              const SizedBox(height: 20),

              // Cantidad - Solo permitir números y decimales
              TextFormField(
                controller: _viewModel.cantidadController,
                decoration: const InputDecoration(
                  labelText: 'Cantidad',
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa una cantidad';
                  }
                  if (double.tryParse(value.replaceAll(',', '.')) == null) {
                    return 'Por favor ingresa un numero valido';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              //campo de descripcion
              TextFormField(
                controller: _viewModel.descripcionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  prefixIcon: Icon(Icons.description),
                  hintText: 'Ingresa una descripción',
                ),
                maxLength: 200,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa una descripcion';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              //campo de categoria
              _buildCategoriasDropdown(),

              // Sección mejorada de Nueva categoría
              if (_viewModel.mostrarNuevaCategoria) ...[
                const SizedBox(height: 16),
                _buildNuevaCategoriaSection(),
              ],

              const SizedBox(height: 16),

              //campo de fecha
              InkWell(
                onTap: () => _selectDate(context, false),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Fecha',
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    DateFormat('dd/MM/yyyy')
                        .format(_viewModel.fechaTransaccion),
                    style: const TextStyle(color: AppTheme.blanco),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              //campo de transaccion recurrente
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.gris,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '¿Es una transaccion recurrente?',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Switch(
                          value: _viewModel.transaccionRecurrente,
                          onChanged: (value) {
                            setState(() {
                              _viewModel.setTransaccionRecurrente(value);
                            });
                          },
                          activeColor: AppTheme.naranja,
                        ),
                      ],
                    ),
                    if (_viewModel.transaccionRecurrente) ...[
                      const SizedBox(height: 16),

                      //frecuencia de recurrencia
                      DropdownButtonFormField<String>(
                        value: _viewModel.frecuenciaRecurrencia,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Frecuencia',
                          prefixIcon: Icon(Icons.repeat),
                        ),
                        style: const TextStyle(color: AppTheme.blanco),
                        dropdownColor: AppTheme.colorFondo,
                        items: CategoriasData.frecuencias.map((String frecuencia) {
                          return DropdownMenuItem<String>(
                            value: frecuencia,
                            child: Text(
                              frecuencia,
                              style: const TextStyle(color: AppTheme.blanco),
                            ),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _viewModel.setFrecuenciaRecurrencia(newValue);
                            });
                          }
                        },
                        validator: (_viewModel.transaccionRecurrente)
                            ? (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor selecciona una frecuencia';
                                }
                                return null;
                              }
                            : null,
                      ),

                      const SizedBox(height: 16),

                      // Fecha de finalización
                      InkWell(
                        onTap: () => _selectDate(context, true),
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Fecha de finalizacion',
                            prefixIcon: Icon(Icons.event_busy),
                          ),
                          child: Text(
                            _viewModel.fechaFinalizacionRecurrencia != null
                                ? DateFormat('dd/MM/yyyy').format(
                                    _viewModel.fechaFinalizacionRecurrencia!)
                                : 'Seleccionar fecha',
                            style: const TextStyle(color: AppTheme.blanco),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 30),

              //boton para guardar o actualizar
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _viewModel.isLoading ? null : _guardarTransaccion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.naranja,
                    foregroundColor: AppTheme.blanco,
                    disabledBackgroundColor: AppTheme.naranja.withOpacity(0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _viewModel.isLoading
                      ? const CircularProgressIndicator(
                          color: AppTheme.colorFondo)
                      : Text(
                          isEditMode ? 'ACTUALIZAR' : 'GUARDAR',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar:
          CustomBottomNavBar(idUsuario: widget.idUsuario, currentIndex: 1),
    );
  }

  //metodo para construir la lista desplegable de categorias
  Widget _buildCategoriasDropdown() {
    //obtener todas las categorías según el tipo de transacción seleccionado
    final categorias = _viewModel.categoriasPorTipo;

    //si la categoria actual no esta en la lista actual de categorias,
    //uso la primera categoria de la lista como valor por defecto
    String currentValue = _viewModel.categoria;
    if (!categorias.contains(currentValue)) {
      currentValue = categorias.first;
      //actualizo el valor en el ViewModel
      _viewModel.setCategoria(currentValue);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppTheme.gris,
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonFormField<String>(
            value: currentValue,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Categoria',
              prefixIcon: Icon(Icons.category),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 8),
            ),
            style: const TextStyle(color: AppTheme.blanco),
            dropdownColor: AppTheme.colorFondo,
            icon: const Icon(Icons.arrow_drop_down, color: AppTheme.naranja),
            items: categorias.map((String categoria) {
              // Personalización del estilo para la opción "Nueva categoría..."
              if (categoria == 'Nueva categoría...') {
                return DropdownMenuItem<String>(
                  value: categoria,
                  child: Row(
                    children: [
                      const Icon(Icons.add, color: AppTheme.naranja, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        categoria,
                        style: const TextStyle(
                          color: AppTheme.naranja,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return DropdownMenuItem<String>(
                value: categoria,
                child: Text(
                  categoria,
                  style: const TextStyle(color: AppTheme.blanco),
                ),
              );
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  _viewModel.setCategoria(newValue);
                });
              }
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor selecciona una categoria';
              }
              return null;
            },
          ),
        ),
        
        // Botón para añadir una nueva categoría
        if (!_viewModel.mostrarNuevaCategoria) ...[
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () {
              setState(() {
                _viewModel.setCategoria('Nueva categoría...');
              });
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.naranja,
              side: BorderSide(color: AppTheme.naranja.withOpacity(0.5)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.add_circle_outline),
            label: const Text('Añadir nueva categoría'),
          ),
        ],
      ],
    );
  }

  // Nueva sección para añadir categoría personalizada
  Widget _buildNuevaCategoriaSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.gris.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.naranja.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Nueva categoría personalizada',
            style: TextStyle(
              color: AppTheme.blanco,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _viewModel.nuevaCategoriaController,
            decoration: InputDecoration(
              labelText: 'Nombre de la categoría',
              prefixIcon: const Icon(Icons.create_new_folder_outlined),
              hintText: 'Ej: Mascotas, Aficiones, etc.',
              filled: true,
              fillColor: AppTheme.gris,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            inputFormatters: [
              FilteringTextInputFormatter.allow(
                  RegExp(r'[a-zA-ZáéíóúÁÉÍÓÚüÜñÑ0-9\s]')),
            ],
            style: const TextStyle(color: AppTheme.blanco),
            validator: _viewModel.mostrarNuevaCategoria
                ? (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa un nombre para la categoría';
                    }
                    return null;
                  }
                : null,
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    final nuevaCategoria =
                        _viewModel.nuevaCategoriaController.text.trim();
                    if (nuevaCategoria.isNotEmpty) {
                      setState(() {
                        _viewModel.agregarCategoriaPersonalizada(nuevaCategoria);
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.naranja,
                    foregroundColor: AppTheme.colorFondo,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  icon: const Icon(Icons.add),
                  label: const Text(
                    'Agregar categoría',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () {
                  setState(() {
                    _viewModel.setCategoria(_viewModel.categoriasPorTipo.first);
                    _viewModel.nuevaCategoriaController.clear();
                  });
                },
                style: IconButton.styleFrom(
                  backgroundColor: Colors.grey.withOpacity(0.2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(
                  Icons.close,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  //metodo para mostrar un dialogo de seleccion de fecha
  Future<void> _selectDate(BuildContext context, bool isFinishDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isFinishDate
          ? _viewModel.fechaFinalizacionRecurrencia ??
              DateTime.now().add(const Duration(days: 30))
          : _viewModel.fechaTransaccion,
      firstDate: isFinishDate ? DateTime.now() : DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.naranja,
              onPrimary: AppTheme.colorFondo,
              surface: AppTheme.gris,
              onSurface: AppTheme.blanco,
            ),
            dialogBackgroundColor: AppTheme.colorFondo,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isFinishDate) {
          _viewModel.setFechaFinalizacionRecurrencia(picked);
        } else {
          _viewModel.setFechaTransaccion(picked);
        }
      });
    }
  }

  //metodo para guardar la transaccion
  Future<void> _guardarTransaccion() async {
    //valido el formulario antes de intentar guardar
    if (!_viewModel.formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Completa todos los campos requeridos correctamente'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Si se está mostrando la nueva categoría pero no se ha agregado aún
    if (_viewModel.mostrarNuevaCategoria) {
      final nuevaCategoria = _viewModel.nuevaCategoriaController.text.trim();
      if (nuevaCategoria.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Debes agregar un nombre para la nueva categoría'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // Agregar la nueva categoría
      setState(() {
        _viewModel.agregarCategoriaPersonalizada(nuevaCategoria);
      });
    }

    // Si la transacción es recurrente, valido que se haya seleccionado una fecha de finalización
    if (_viewModel.transaccionRecurrente &&
        _viewModel.fechaFinalizacionRecurrencia == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Selecciona una fecha de finalizacion para la transaccion recurrente'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      await _viewModel.guardarTransaccion();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.transaccionEditar == null
                ? 'Transaccion creada correctamente'
                : 'Transaccion actualizada correctamente'),
            backgroundColor: Colors.green,
          ),
        );

        //cuando guardo la transaccion vuelve a la pantalla de TransaccionesScreen
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Error al guardar la transaccion';
        if (e.toString().contains('presupuesto')) {
          errorMessage =
              'La transaccion se actualizo pero hubo un error al actualizar el presupuesto';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildTypeButton({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.naranja.withOpacity(0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppTheme.naranja : Colors.grey,
            width: 1,
>>>>>>> 8f1d397338e300a443102a7f54c5ce411ddd3503
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
<<<<<<< HEAD
            Icon(icon, color: isSelected ? AppTheme.naranja : Colors.grey),
            const SizedBox(width: 8),
            Text(text, style: TextStyle(
              color: isSelected ? AppTheme.naranja : Colors.grey,
              fontWeight: FontWeight.bold,
            )),
=======
            Icon(
              icon,
              color: isSelected ? AppTheme.naranja : Colors.grey,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? AppTheme.naranja : Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
>>>>>>> 8f1d397338e300a443102a7f54c5ce411ddd3503
          ],
        ),
      ),
    );
  }
}


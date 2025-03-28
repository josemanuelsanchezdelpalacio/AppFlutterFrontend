import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_proyecto_app/components/asignacion_transaccion_screen.dart';
import 'package:flutter_proyecto_app/components/barra_inferior_secciones.dart';
import 'package:flutter_proyecto_app/components/menu_desplegable.dart';
import 'package:flutter_proyecto_app/data/transaccion.dart';
import 'package:flutter_proyecto_app/data/categorias_data.dart';
import 'package:flutter_proyecto_app/models/add_transacciones_viewmodel.dart';
import 'package:flutter_proyecto_app/theme/app_theme.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class AddTransaccionesScreen extends StatefulWidget {
  final int idUsuario;
  final Transaccion? transaccionEditar;

  const AddTransaccionesScreen({
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

  @override
  void initState() {
    super.initState();
    _viewModel = AddTransaccionesViewModel(
      idUsuario: widget.idUsuario,
      transaccionEditar: widget.transaccionEditar,
    );
    _viewModel.init();
    
    if (widget.transaccionEditar != null && 
        !CategoriasData.categoriasGastos.contains(widget.transaccionEditar!.categoria) &&
        !CategoriasData.categoriasIngresos.contains(widget.transaccionEditar!.categoria)) {
      _isCustomCategory = true;
      _categoriaController.text = widget.transaccionEditar!.categoria;
    }
  }

  @override
  void dispose() {
    _viewModel.dispose();
    _categoriaController.dispose();
    _categoriaFocusNode.dispose();
    super.dispose();
  }

  void _mostrarInfoAsignacion(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppTheme.colorFondo,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: const BorderSide(color: AppTheme.naranja, width: 2),
          ),
          title: const Text(
            'Información sobre asignaciones',
            style: TextStyle(
              color: AppTheme.naranja,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _infoSection(
                  'Asignación a Presupuestos',
                  'Puedes asignar gastos a presupuestos específicos para llevar un mejor control. Selecciona un presupuesto existente de la misma categoría que tu transacción.',
                ),
                const SizedBox(height: 12),
                _infoSection(
                  'Asignación a Metas de Ahorro',
                  'Los ingresos pueden asignarse a metas de ahorro para contribuir directamente a tus objetivos financieros. Selecciona una meta existente para asignar este ingreso.',
                ),
                const SizedBox(height: 12),
                _infoSection(
                  'Categorías Personalizadas',
                  'Puedes crear categorías personalizadas para adaptar la aplicación a tus necesidades. Las categorías nuevas se guardarán para futuras transacciones.',
                ),
                const SizedBox(height: 12),
                _infoSection(
                  'Transacciones Recurrentes',
                  'Marca una transacción como recurrente para que se repita automáticamente según la frecuencia seleccionada. Puedes establecer una fecha de finalización.',
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text(
                'Entendido',
                style: TextStyle(
                  color: AppTheme.naranja,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _infoSection(String title, String description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppTheme.naranja,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: const TextStyle(
            color: AppTheme.blanco,
            fontSize: 14,
          ),
        ),
      ],
    );
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
              ..._viewModel.categoriasPorTipo.where((c) => c != 'Personalizada').map((category) => DropdownMenuItem(
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
              actions: [
                IconButton(
                  icon: const Icon(Icons.info_outline, color: Colors.white),
                  onPressed: () => _mostrarInfoAsignacion(context),
                  tooltip: 'Información sobre asignaciones',
                ),
              ],
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
                    ),
                  ],
                ),
              ),
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
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? AppTheme.naranja : Colors.grey),
            const SizedBox(width: 8),
            Text(text, style: TextStyle(
              color: isSelected ? AppTheme.naranja : Colors.grey,
              fontWeight: FontWeight.bold,
            )),
          ],
        ),
      ),
    );
  }
}


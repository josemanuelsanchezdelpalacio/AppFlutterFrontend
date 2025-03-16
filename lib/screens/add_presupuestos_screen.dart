import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_proyecto_app/components/custom_bottom_app_bar.dart';
import 'package:flutter_proyecto_app/components/menu_desplegable.dart';
import 'package:flutter_proyecto_app/data/presupuesto.dart';
import 'package:flutter_proyecto_app/models/add_presupuestos_viewmodel.dart';
import 'package:flutter_proyecto_app/screens/presupuestos_screen.dart';
import 'package:flutter_proyecto_app/theme/app_theme.dart';
import 'package:intl/intl.dart';

class AddPresupuestoScreen extends StatefulWidget {
  final int idUsuario;
  final Presupuesto? presupuestoParaEditar;

  const AddPresupuestoScreen({
    super.key,
    required this.idUsuario,
    this.presupuestoParaEditar,
  });

  @override
  State<AddPresupuestoScreen> createState() => _AddPresupuestoScreenState();
}

class _AddPresupuestoScreenState extends State<AddPresupuestoScreen> {
  late AddPresupuestoViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = AddPresupuestoViewModel(
        idUsuario: widget.idUsuario,
        presupuestoParaEditar: widget.presupuestoParaEditar,
        onStateChanged: () {
          if (mounted) setState(() {});
        });
    _viewModel.inicializarFormulario();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            _viewModel.isEditMode ? 'Editar presupuesto' : 'Crear presupuesto'),
        centerTitle: true,
      ),
      drawer: MenuDesplegable(idUsuario: widget.idUsuario),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _viewModel.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeaderSection(),
                  const SizedBox(height: 24),
                  _buildNombreInput(),
                  const SizedBox(height: 16),
                  _buildCategoriaDropdown(),
                  if (_viewModel.mostrarCampoNuevaCategoria) ...[
                    const SizedBox(height: 16),
                    _buildNuevaCategoriaInput(),
                  ],
                  const SizedBox(height: 16),
                  _buildMontoInput(),
                  const SizedBox(height: 16),
                  _buildFechasSection(),
                  const SizedBox(height: 32),
                  _buildGuardarButton(),
                  if (_viewModel.errorMessage.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      _viewModel.errorMessage,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        idUsuario: widget.idUsuario,
        currentIndex: 3,
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.gris,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            Icons.account_balance_wallet,
            size: 48,
            color: AppTheme.naranja,
          ),
          const SizedBox(height: 16),
          Text(
            _viewModel.isEditMode ? 'Editar presupuesto' : 'Nuevo presupuesto',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.blanco,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _viewModel.isEditMode
                ? 'Modifica los detalles de tu presupuesto'
                : 'Crea un presupuesto para controlar tus gastos',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.grey,
            ),
          ),
          if (_viewModel.isEditMode && _viewModel.cantidadGastada > 0) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.naranja.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Cantidad gastada hasta ahora: \$${_viewModel.cantidadGastada.toStringAsFixed(2)}',
                style: TextStyle(
                  color: AppTheme.naranja,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNombreInput() {
    return TextFormField(
      controller: _viewModel.nombreController,
      decoration: InputDecoration(
        labelText: 'Nombre del presupuesto',
        prefixIcon: const Icon(Icons.label_outline),
        hintText: 'Ej: Vacaciones, Compras del mes, etc.',
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
      validator: (value) => _viewModel.validarNombre(value),
      textCapitalization: TextCapitalization.sentences,
    );
  }

  Widget _buildCategoriaDropdown() {
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
            decoration: const InputDecoration(
              labelText: 'Categoría',
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 8),
            ),
            value: _viewModel.categorias.contains(_viewModel.categoriaSeleccionada)
                ? _viewModel.categoriaSeleccionada
                : _viewModel.categorias.first,
            dropdownColor: AppTheme.gris,
            style: const TextStyle(color: AppTheme.blanco),
            icon: const Icon(Icons.arrow_drop_down, color: AppTheme.naranja),
            items: _viewModel.categorias.map((String categoria) {
              return DropdownMenuItem<String>(
                value: categoria,
                child: Text(
                  categoria,
                  style: TextStyle(
                    fontStyle: categoria == 'Personalizada'
                        ? FontStyle.italic
                        : FontStyle.normal,
                  ),
                ),
              );
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  _viewModel.categoriaSeleccionada = newValue;
                });
              }
            },
            validator: (value) => _viewModel.validarCategoria(value),
          ),
        ),
        const SizedBox(height: 8),
        if (!_viewModel.mostrarCampoNuevaCategoria)
          OutlinedButton.icon(
            onPressed: () {
              setState(() {
                _viewModel.categoriaSeleccionada = 'Personalizada';
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
    );
  }

  Widget _buildNuevaCategoriaInput() {
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
            validator: _viewModel.mostrarCampoNuevaCategoria
                ? (value) => _viewModel.validarNuevaCategoria(value)
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
                      _viewModel.agregarCategoriaPersonalizada(nuevaCategoria);
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
                    _viewModel.categoriaSeleccionada = 
                        _viewModel.categorias.first;  // Reset to default category
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

  Widget _buildMontoInput() {
    return TextFormField(
      controller: _viewModel.cantidadController,
      decoration: InputDecoration(
        labelText: 'Cantidad presupuestada',
        prefixIcon: const Icon(Icons.attach_money),
        hintText: 'Ej: 1000.00',
        filled: true,
        fillColor: AppTheme.gris,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
        TextInputFormatter.withFunction((oldValue, newValue) {
          if (newValue.text.isEmpty) {
            return newValue;
          }

          if (newValue.text.contains('.')) {
            final parts = newValue.text.split('.');
            if (parts.length > 2) {
              return oldValue;
            }

            if (parts.length == 2 && parts[1].length > 2) {
              return TextEditingValue(
                text: '${parts[0]}.${parts[1].substring(0, 2)}',
                selection: TextSelection.collapsed(offset: parts[0].length + 3),
              );
            }
          }

          return newValue;
        }),
      ],
      style: const TextStyle(color: AppTheme.blanco),
      validator: (value) => _viewModel.validarMonto(value),
    );
  }

  Widget _buildFechasSection() {
    final DateFormat formatter = DateFormat('dd/MM/yyyy');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Periodo del presupuesto',
          style: TextStyle(
            color: AppTheme.blanco,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildDatePickerCard(
                title: 'Fecha inicio',
                date: _viewModel.fechaInicio,
                onTap: () => _seleccionarFecha(context, true),
                formatter: formatter,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildDatePickerCard(
                title: 'Fecha fin',
                date: _viewModel.fechaFin,
                onTap: () => _seleccionarFecha(context, false),
                formatter: formatter,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDatePickerCard({
    required String title,
    required DateTime date,
    required VoidCallback onTap,
    required DateFormat formatter,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.gris,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calendar_today,
                    color: AppTheme.naranja, size: 16),
                const SizedBox(width: 8),
                Text(
                  formatter.format(date),
                  style: const TextStyle(
                    color: AppTheme.blanco,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _seleccionarFecha(BuildContext context, bool esInicio) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: esInicio ? _viewModel.fechaInicio : _viewModel.fechaFin,
      firstDate: esInicio
          ? (_viewModel.isEditMode ? DateTime(2020) : DateTime.now())
          : _viewModel.fechaInicio,
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
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
      if (esInicio) {
        _viewModel.actualizarFechaInicio(picked);
      } else {
        _viewModel.actualizarFechaFin(picked);
      }
      setState(() {});
    }
  }

  Widget _buildGuardarButton() {
    return ElevatedButton(
      onPressed:
          _viewModel.isLoading ? null : () => _guardarPresupuesto(context),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        backgroundColor: AppTheme.naranja,
        foregroundColor: AppTheme.colorFondo,
        disabledBackgroundColor: AppTheme.naranja.withOpacity(0.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: _viewModel.isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                color: AppTheme.colorFondo,
                strokeWidth: 3,
              ),
            )
          : Text(
              _viewModel.isEditMode
                  ? 'Actualizar presupuesto'
                  : 'Guardar presupuesto',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
    );
  }

  Future<void> _guardarPresupuesto(BuildContext context) async {
    FocusScope.of(context).unfocus();

    try {
      final bool resultado = await _viewModel.guardarPresupuesto();

      if (!mounted) return;

      if (resultado) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_viewModel.isEditMode
                ? 'Presupuesto actualizado correctamente'
                : 'Presupuesto creado correctamente'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PresupuestosScreen(
              idUsuario: widget.idUsuario,
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_viewModel.errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}


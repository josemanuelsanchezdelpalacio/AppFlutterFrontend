import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_proyecto_app/components/custom_bottom_app_bar.dart';
import 'package:flutter_proyecto_app/components/menu_desplegable.dart';
import 'package:flutter_proyecto_app/data/transaccion.dart';
import 'package:flutter_proyecto_app/models/add_transacciones_viewmodel.dart';
import 'package:flutter_proyecto_app/theme/app_theme.dart';
import 'package:intl/intl.dart';

class AddTransactionScreen extends StatefulWidget {
  final int idUsuario;
  final Transaccion? transaccionEditar;

  const AddTransactionScreen({
    Key? key,
    required this.idUsuario,
    this.transaccionEditar,
  }) : super(key: key);

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  late AddTransactionViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = AddTransactionViewModel(
      idUsuario: widget.idUsuario,
      transaccionEditar: widget.transaccionEditar,
    );

    // Inicializar el ViewModel
    _viewModel.init();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Determinar si estamos en modo edición
    final bool isEditMode = widget.transaccionEditar != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? 'Editar Transacción' : 'Nueva Transacción'),
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
              // Tipo de transacción (Ingreso/Gasto)
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
                      'Tipo de Transacción',
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
                    ),
                  ],
                ),
              ),

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
                    return 'Por favor ingresa un número válido';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Descripción - Permitir caracteres alfanuméricos
              TextFormField(
                controller: _viewModel.descripcionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  prefixIcon: Icon(Icons.description),
                  hintText: 'Ingresa una descripción',
                ),
                maxLength: 100, // Limitar longitud
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa una descripción';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Categoría - Widget actualizado para evitar el error
              _buildCategoriasDropdown(),

              const SizedBox(height: 16),

              // Fecha de transacción
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
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Transacción recurrente
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
                          '¿Es una transacción recurrente?',
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

                      // Frecuencia de recurrencia
                      DropdownButtonFormField<String>(
                        value: _viewModel.frecuenciaRecurrencia,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Frecuencia',
                          prefixIcon: Icon(Icons.repeat),
                        ),
                        items: _viewModel.frecuencias.map((String frecuencia) {
                          return DropdownMenuItem<String>(
                            value: frecuencia,
                            child: Text(frecuencia),
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
                            labelText: 'Fecha de finalización',
                            prefixIcon: Icon(Icons.event_busy),
                          ),
                          child: Text(
                            _viewModel.fechaFinalizacionRecurrencia != null
                                ? DateFormat('dd/MM/yyyy').format(
                                    _viewModel.fechaFinalizacionRecurrencia!)
                                : 'Seleccionar fecha',
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Botón para guardar
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _viewModel.isLoading ? null : _guardarTransaccion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.naranja,
                    foregroundColor: AppTheme.blanco,
                    disabledBackgroundColor: AppTheme.naranja.withOpacity(0.5),
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

  // Nuevo método para construir el dropdown de categorías
  Widget _buildCategoriasDropdown() {
    // Obtener las categorías según el tipo de transacción seleccionado
    final categorias = _viewModel.tipoTransaccion == TipoTransacciones.GASTO
        ? _viewModel.categoriasGastos
        : _viewModel.categoriasIngresos;

    // Si la categoría actual no está en la lista actual de categorías,
    // usamos la primera categoría de la lista como valor por defecto
    String currentValue = _viewModel.categoria;
    if (!categorias.contains(currentValue)) {
      currentValue = categorias.first;
      // Actualizamos el valor en el ViewModel
      _viewModel.setCategoria(currentValue);
    }

    return DropdownButtonFormField<String>(
      value: currentValue,
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: 'Categoría',
        prefixIcon: Icon(Icons.category),
      ),
      items: categorias.map((String categoria) {
        return DropdownMenuItem<String>(
          value: categoria,
          child: Text(categoria),
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
          return 'Por favor selecciona una categoría';
        }
        return null;
      },
    );
  }

  // Método para mostrar un diálogo de selección de fecha
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

  // Método para guardar la transacción
  Future<void> _guardarTransaccion() async {
    // Validar el formulario antes de intentar guardar
    if (!_viewModel.formKey.currentState!.validate()) {
      // Si el formulario no es válido, mostrar un mensaje
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Por favor completa todos los campos requeridos correctamente'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Si la transacción es recurrente, validar que se haya seleccionado una fecha de finalización
    if (_viewModel.transaccionRecurrente &&
        _viewModel.fechaFinalizacionRecurrencia == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Por favor selecciona una fecha de finalización para la transacción recurrente'),
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
                ? 'Transacción creada con éxito'
                : 'Transacción actualizada con éxito'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate back regardless of any potential budget update issues
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        // Show a more specific error message
        String errorMessage = 'Error al guardar la transacción';
        if (e.toString().contains('presupuesto')) {
          errorMessage =
              'La transacción se actualizó pero hubo un error al actualizar el presupuesto. Por favor, verifique su presupuesto.';
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
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
          ],
        ),
      ),
    );
  }
}

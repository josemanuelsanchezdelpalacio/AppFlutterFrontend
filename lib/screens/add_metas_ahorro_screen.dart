import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_proyecto_app/components/custom_bottom_app_bar.dart';
import 'package:flutter_proyecto_app/components/menu_desplegable.dart';
import 'package:flutter_proyecto_app/data/metas_ahorro.dart';
import 'package:flutter_proyecto_app/models/add_metas_ahorro_viewmodel.dart';
import 'package:flutter_proyecto_app/theme/app_theme.dart';
import 'package:intl/intl.dart';

class AddMetasAhorroScreen extends StatefulWidget {
  final int idUsuario;
  final MetaAhorro? metaAhorroParaEditar;

  const AddMetasAhorroScreen({
    super.key,
    required this.idUsuario,
    this.metaAhorroParaEditar,
  });

  @override
  State<AddMetasAhorroScreen> createState() => _AddMetasAhorroScreenState();
}

class _AddMetasAhorroScreenState extends State<AddMetasAhorroScreen> {
  final _formKey = GlobalKey<FormState>();
  late AddMetasAhorroViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = AddMetasAhorroViewModel(
      idUsuario: widget.idUsuario,
      metaAhorroParaEditar: widget.metaAhorroParaEditar,
    );
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _viewModel.fechaObjetivo,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.naranja,
              onPrimary: AppTheme.blanco,
              surface: AppTheme.gris,
              onSurface: AppTheme.blanco,
            ),
            dialogBackgroundColor: AppTheme.colorFondo,
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _viewModel.fechaObjetivo) {
      setState(() {
        _viewModel.updateFechaObjetivo(picked);
      });
    }
  }

  Future<void> _guardarMetaAhorro() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _viewModel.setLoading(true);
      });

      try {
        final result = await _viewModel.guardarMetaAhorro();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result),
              backgroundColor: Colors.green,
            ),
          );

          // Navegar a MetasAhorroScreen después de guardar
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_viewModel.errorMessage ?? 'Error desconocido'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        setState(() {
          _viewModel.setLoading(false);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _viewModel.isEditing
              ? 'Editar Meta de Ahorro'
              : 'Nueva Meta de Ahorro',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      drawer: MenuDesplegable(idUsuario: widget.idUsuario),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Tarjeta de Meta de Ahorro con icono mejorado
                    Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: AppTheme.gris,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Icono centrado (ahora naranja en vez de negro con fondo naranja)
                            Icon(
                              Icons.savings,
                              color: AppTheme.naranja,
                              size: 48,
                            ),
                            const SizedBox(height: 16),
                            // Texto "Nueva Meta de Ahorro" o "Editar Meta de Ahorro"
                            Text(
                              _viewModel.isEditing
                                  ? 'Editar Meta de Ahorro'
                                  : 'Nueva Meta de Ahorro',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.blanco,
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Texto descriptivo
                            const Text(
                              'Crea una meta para controlar tus ahorros',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Nombre de la Meta de Ahorro
                    TextFormField(
                      controller: _viewModel.nombreController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre de la Meta',
                        prefixIcon: Icon(Icons.bookmark),
                        hintText: 'Ej: Viaje a Paris, Nuevo Coche, etc.',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Por favor ingresa un nombre para tu meta';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Categoría
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _viewModel.categoriaController.text.isEmpty
                                ? _viewModel.categorias.first
                                : _viewModel.categoriaController.text,
                            decoration: const InputDecoration(
                              labelText: 'Categoría',
                              prefixIcon: Icon(Icons.category),
                            ),
                            dropdownColor: AppTheme.gris,
                            items: _viewModel.categorias.map((categoria) {
                              return DropdownMenuItem(
                                value: categoria,
                                child: Text(
                                  categoria,
                                  style:
                                      const TextStyle(color: AppTheme.blanco),
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _viewModel.categoriaController.text = value;
                                  if (value == 'Personalizada') {
                                    _viewModel.toggleCustomCategory(true);
                                  } else {
                                    _viewModel.toggleCustomCategory(false);
                                  }
                                });
                              }
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor selecciona una categoría';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),

                    // Campo de categoría personalizada
                    if (_viewModel.isCustomCategory)
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: TextFormField(
                          controller:
                              _viewModel.categoriaPersonalizadaController,
                          decoration: const InputDecoration(
                            labelText: 'Categoría Personalizada',
                            prefixIcon: Icon(Icons.add_circle_outline),
                            hintText: 'Ej: Educación, Navidad, Compras, etc.',
                          ),
                          // Permitir solo letras y espacios para la categoría personalizada
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'[a-zA-ZáéíóúÁÉÍÓÚüÜñÑ\s]')),
                          ],
                          validator: (value) {
                            if (_viewModel.isCustomCategory &&
                                (value == null || value.trim().isEmpty)) {
                              return 'Por favor ingresa una categoría personalizada';
                            }
                            return null;
                          },
                        ),
                      ),

                    const SizedBox(height: 16),

                    // Cantidad Objetivo
                    TextFormField(
                      controller: _viewModel.cantidadObjetivoController,
                      decoration: const InputDecoration(
                        labelText: 'Cantidad Objetivo',
                        prefixIcon: Icon(Icons.attach_money),
                      ),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      // Mejorado para aceptar solo números con hasta 2 decimales
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^\d+([.,]\d{0,2})?$')),
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingresa el monto objetivo';
                        }

                        // Reemplazar coma por punto para conversión a double
                        final normalizedValue = value.replaceAll(',', '.');
                        final amount = double.tryParse(normalizedValue);

                        if (amount == null || amount <= 0) {
                          return 'Ingresa un monto válido mayor a 0';
                        }
                        return null;
                      },
                      // Formatea el texto para mostrar correctamente al usuario
                      onChanged: (value) {
                        if (value.isNotEmpty) {
                          final normalizedValue = value.replaceAll(',', '.');
                          if (double.tryParse(normalizedValue) != null) {
                            // No hacemos nada, el valor es válido
                          }
                        }
                      },
                    ),

                    const SizedBox(height: 16),

                    // Cantidad Actual
                    TextFormField(
                      controller: _viewModel.cantidadActualController,
                      decoration: const InputDecoration(
                        labelText: 'Cantidad Actual',
                        prefixIcon: Icon(Icons.attach_money),
                        hintText: '0.00',
                      ),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      // Mejorado para aceptar solo números con hasta 2 decimales
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^\d+([.,]\d{0,2})?$')),
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingresa la cantidad actual';
                        }

                        // Reemplazar coma por punto para conversión a double
                        final normalizedValue = value.replaceAll(',', '.');
                        final amount = double.tryParse(normalizedValue);

                        if (amount == null || amount < 0) {
                          return 'Ingresa un monto válido (puede ser 0)';
                        }
                        return null;
                      },
                      // Formatea el texto para mostrar correctamente al usuario
                      onChanged: (value) {
                        if (value.isNotEmpty) {
                          final normalizedValue = value.replaceAll(',', '.');
                          if (double.tryParse(normalizedValue) != null) {
                            // No hacemos nada, el valor es válido
                          }
                        }
                      },
                    ),

                    const SizedBox(height: 16),

                    // Fecha Objetivo
                    InkWell(
                      onTap: () => _selectDate(context),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Fecha Objetivo',
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              DateFormat('dd/MM/yyyy')
                                  .format(_viewModel.fechaObjetivo),
                              style: const TextStyle(color: AppTheme.blanco),
                            ),
                            const Icon(
                              Icons.arrow_drop_down,
                              color: AppTheme.naranja,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Mensaje de error
                    if (_viewModel.errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Text(
                          _viewModel.errorMessage!,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                      ),

                    // Botón guardar
                    ElevatedButton(
                      onPressed:
                          _viewModel.isLoading ? null : _guardarMetaAhorro,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.naranja,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        disabledBackgroundColor:
                            AppTheme.naranja.withOpacity(0.5),
                      ),
                      child: _viewModel.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: AppTheme.blanco,
                                strokeWidth: 3,
                              ),
                            )
                          : Text(
                              _viewModel.isEditing
                                  ? 'ACTUALIZAR META DE AHORRO'
                                  : 'GUARDAR META DE AHORRO',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        idUsuario: widget.idUsuario,
        currentIndex: 2, // Corresponde a la pestaña de Metas
      ),
    );
  }
}

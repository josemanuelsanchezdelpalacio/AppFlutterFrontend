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
  bool mostrarCampoNuevaCategoria = false;

  @override
  void initState() {
    super.initState();
    _viewModel = AddMetasAhorroViewModel(
      idUsuario: widget.idUsuario,
      metaAhorroParaEditar: widget.metaAhorroParaEditar,
    );
    // Verificar si necesitamos mostrar el campo de nueva categoría
    mostrarCampoNuevaCategoria = _viewModel.categoriaController.text == 'Personalizada';
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
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Icono centrado
                            const Icon(
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
                                fontSize: 20,
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
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Nombre de la Meta de Ahorro
                    TextFormField(
                      controller: _viewModel.nombreController,
                      decoration: InputDecoration(
                        labelText: 'Nombre de la Meta',
                        prefixIcon: const Icon(Icons.bookmark),
                        hintText: 'Ej: Viaje a Paris, Nuevo Coche, etc.',
                        filled: true,
                        fillColor: AppTheme.gris,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      style: const TextStyle(color: AppTheme.blanco),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'[a-zA-ZáéíóúÁÉÍÓÚüÜñÑ0-9\s]')),
                      ],
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Por favor ingresa un nombre para tu meta';
                        }
                        return null;
                      },
                      textCapitalization: TextCapitalization.sentences,
                    ),

                    const SizedBox(height: 16),

                    // Sección de categoría con dropdown
                    _buildCategoriaDropdown(),
                    
                    // Sección para nueva categoría personalizada (solo si se selecciona)
                    if (mostrarCampoNuevaCategoria) ...[
                      const SizedBox(height: 16),
                      _buildNuevaCategoriaInput(),
                    ],

                    const SizedBox(height: 16),

                    // Cantidad Objetivo
                    TextFormField(
                      controller: _viewModel.cantidadObjetivoController,
                      decoration: InputDecoration(
                        labelText: 'Cantidad Objetivo',
                        prefixIcon: const Icon(Icons.attach_money),
                        hintText: 'Ej: 1000.00',
                        filled: true,
                        fillColor: AppTheme.gris,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      style: const TextStyle(color: AppTheme.blanco),
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
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingresa el monto objetivo';
                        }

                        final amount = double.tryParse(value);

                        if (amount == null || amount <= 0) {
                          return 'Ingresa un monto válido mayor a 0';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Cantidad Actual
                    TextFormField(
                      controller: _viewModel.cantidadActualController,
                      decoration: InputDecoration(
                        labelText: 'Cantidad Actual',
                        prefixIcon: const Icon(Icons.attach_money),
                        hintText: '0.00',
                        filled: true,
                        fillColor: AppTheme.gris,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      style: const TextStyle(color: AppTheme.blanco),
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
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingresa la cantidad actual';
                        }

                        final amount = double.tryParse(value);

                        if (amount == null || amount < 0) {
                          return 'Ingresa un monto válido (puede ser 0)';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Fecha Objetivo - Usar un selector de fecha similar al de presupuestos
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Fecha objetivo',
                          style: TextStyle(
                            color: AppTheme.blanco,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: () => _selectDate(context),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppTheme.gris,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today,
                                    color: AppTheme.naranja, size: 16),
                                const SizedBox(width: 8),
                                Text(
                                  DateFormat('dd/MM/yyyy').format(_viewModel.fechaObjetivo),
                                  style: const TextStyle(
                                    color: AppTheme.blanco,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Mensaje de error
                    if (_viewModel.errorMessage != null) ...[
                      Text(
                        _viewModel.errorMessage!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Botón guardar
                    ElevatedButton(
                      onPressed: _viewModel.isLoading ? null : _guardarMetaAhorro,
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
                              _viewModel.isEditing
                                  ? 'Actualizar meta de ahorro'
                                  : 'Guardar meta de ahorro',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
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
            value: _viewModel.categorias.contains(_viewModel.categoriaController.text)
                ? _viewModel.categoriaController.text
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
                  _viewModel.categoriaController.text = newValue;
                  mostrarCampoNuevaCategoria = (newValue == 'Personalizada');
                  
                  if (newValue != 'Personalizada') {
                    // Si no es personalizada, asegurarse de que el ViewModel lo sepa
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
        const SizedBox(height: 8),
        if (!mostrarCampoNuevaCategoria)
          OutlinedButton.icon(
            onPressed: () {
              setState(() {
                _viewModel.categoriaController.text = 'Personalizada';
                mostrarCampoNuevaCategoria = true;
                _viewModel.toggleCustomCategory(true);
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
            validator: mostrarCampoNuevaCategoria
                ? (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ingresa un nombre para la categoría';
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
                        // Añadir la nueva categoría y seleccionarla
                        _viewModel.addNewCategory(nuevaCategoria);
                        mostrarCampoNuevaCategoria = false;
                        
                        // Si estamos en modo de edición, asignar la categoría al controlador correspondiente
                        if (_viewModel.isEditing) {
                          _viewModel.categoriaPersonalizadaController.text = nuevaCategoria;
                        }
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
                    _viewModel.categoriaController.text = 
                        _viewModel.categorias.first;  // Reset to default category
                    _viewModel.nuevaCategoriaController.clear();
                    mostrarCampoNuevaCategoria = false;
                    _viewModel.toggleCustomCategory(false);
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
}


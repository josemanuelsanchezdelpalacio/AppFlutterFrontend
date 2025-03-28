import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_proyecto_app/components/barra_inferior_secciones.dart';
import 'package:flutter_proyecto_app/components/menu_desplegable.dart';
import 'package:flutter_proyecto_app/data/categorias_data.dart';
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
  final TextEditingController _categoriaController = TextEditingController();
  final FocusNode _categoriaFocusNode = FocusNode();
  bool _isCustomCategory = false;

  @override
  void initState() {
    super.initState();
    _viewModel = AddMetasAhorroViewModel(
      idUsuario: widget.idUsuario,
      metaAhorroParaEditar: widget.metaAhorroParaEditar,
    );
    
    // Verificar si la categoría es personalizada
    if (widget.metaAhorroParaEditar != null && 
        !CategoriasData.categoriasIngresos.contains(widget.metaAhorroParaEditar!.categoria)) {
      _isCustomCategory = true;
      _categoriaController.text = widget.metaAhorroParaEditar!.categoria;
    }
  }

  @override
  void dispose() {
    _viewModel.dispose();
    _categoriaController.dispose();
    _categoriaFocusNode.dispose();
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
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Si es categoría personalizada, asignar el valor del campo de texto
    if (_isCustomCategory) {
      _viewModel.categoriaController.text = _categoriaController.text.trim();
    }

    setState(() {
      _viewModel.setLoading(true);
    });

    try {
      final result = await _viewModel.guardarMetaAhorro();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
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
      if (mounted) {
        setState(() {
          _viewModel.setLoading(false);
        });
      }
    }
  }

  Widget _buildCategoryField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Categoría', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        if (!_isCustomCategory)
          DropdownButtonFormField<String>(
            value: _viewModel.categoriaController.text.isNotEmpty && 
                   CategoriasData.categoriasIngresos.contains(_viewModel.categoriaController.text)
                ? _viewModel.categoriaController.text
                : null,
            items: [
              ...CategoriasData.categoriasIngresos.map((category) => DropdownMenuItem(
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
                  _viewModel.categoriaController.text = '';
                });
                Future.delayed(const Duration(milliseconds: 100), () {
                  _categoriaFocusNode.requestFocus();
                });
              } else {
                _viewModel.categoriaController.text = value!;
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
                onChanged: (value) => _viewModel.categoriaController.text = value,
                validator: (value) => value!.isEmpty ? 'Ingresa una categoría' : null,
                maxLength: 50,
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _isCustomCategory = false;
                    _categoriaController.clear();
                    _viewModel.categoriaController.text = '';
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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _viewModel.isEditing
              ? 'Editar Meta de Ahorro'
              : 'Nueva Meta de Ahorro',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: AppTheme.colorFondo,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: MenuDesplegable(idUsuario: widget.idUsuario),
      backgroundColor: AppTheme.colorFondo,
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
                            const Icon(
                              Icons.savings,
                              color: AppTheme.naranja,
                              size: 48,
                            ),
                            const SizedBox(height: 16),
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

                    // Campo de categoría mejorado
                    _buildCategoryField(),

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

                    // Fecha Objetivo
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
      bottomNavigationBar: BarraInferiorSecciones(
        idUsuario: widget.idUsuario,
        indexActual: 2,
      ),
    );
  }
}


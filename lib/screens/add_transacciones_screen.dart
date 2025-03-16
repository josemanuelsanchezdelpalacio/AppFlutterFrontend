import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_proyecto_app/components/custom_bottom_app_bar.dart';
import 'package:flutter_proyecto_app/components/menu_desplegable.dart';
import 'package:flutter_proyecto_app/data/transaccion.dart';
import 'package:flutter_proyecto_app/data/categorias_data.dart';
import 'package:flutter_proyecto_app/models/add_transacciones_viewmodel.dart';
import 'package:flutter_proyecto_app/theme/app_theme.dart';
import 'package:intl/intl.dart';

class AddTransaccionesScreen extends StatefulWidget {
  final int idUsuario;
  final Transaccion? transaccionEditar;

  const AddTransaccionesScreen({
    super.key,
    required this.idUsuario,
    this.transaccionEditar,
  });

  @override
  State<AddTransaccionesScreen> createState() => _AddTransaccionesScreenState();
}

class _AddTransaccionesScreenState extends State<AddTransaccionesScreen> {
  late AddTransaccionesViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = AddTransaccionesViewModel(
      idUsuario: widget.idUsuario,
      transaccionEditar: widget.transaccionEditar,
    );

    //inicializo el ViewModel
    _viewModel.init();
  }

  @override
  void dispose() {
    _viewModel.dispose();
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


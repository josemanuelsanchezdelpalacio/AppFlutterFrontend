import 'package:flutter/material.dart';
import 'package:flutter_proyecto_app/theme/app_theme.dart';
import 'package:intl/intl.dart';

class FiltroElementos extends StatelessWidget {
  final String? filtroActual;
  final Function(String?) onFilterChanged;
  final List<String?> filtros;
  final DateTime? fechaFiltro;
  final Function(DateTime?) onFechaChanged;
  final DateTime? mesFiltro;
  final Function(DateTime?)? onMesChanged;
  final List<String?>? mesesDisponibles;

  const FiltroElementos({
    super.key,
    required this.filtroActual,
    required this.onFilterChanged,
    required this.filtros,
    this.fechaFiltro,
    required this.onFechaChanged,
    this.mesFiltro,
    this.onMesChanged,
    this.mesesDisponibles,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8.0),
      child: Column(
        children: [
<<<<<<< HEAD
=======
          // Filtro principal
>>>>>>> 8f1d397338e300a443102a7f54c5ce411ddd3503
          Row(
            children: [
              const Text(
                'Filtrar:',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                  color: AppTheme.blanco,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.gris,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: InkWell(
<<<<<<< HEAD
                    onTap: () => _mostrarOpcionesFiltrado(context),
=======
                    onTap: () => _showFilterOptions(context),
>>>>>>> 8f1d397338e300a443102a7f54c5ce411ddd3503
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              filtroActual ?? 'Todos',
                              style: const TextStyle(
                                color: AppTheme.blanco,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.filter_list,
                            color: AppTheme.naranja,
                            size: 22,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

<<<<<<< HEAD
          //filtro por mes de creación
=======
          // Filtro de mes (si está disponible)
>>>>>>> 8f1d397338e300a443102a7f54c5ce411ddd3503
          if (onMesChanged != null && mesesDisponibles != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Text(
                  'Mes:',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    color: AppTheme.blanco,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppTheme.gris,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: InkWell(
                      onTap: () => _showMesOptions(context),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                mesFiltro != null
                                    ? DateFormat('MMMM yyyy', 'es')
                                        .format(mesFiltro!)
                                    : 'Todos los meses',
                                style: const TextStyle(
                                  color: AppTheme.blanco,
                                ),
                              ),
                            ),
                            IconButton(
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              icon: Icon(
                                mesFiltro != null
                                    ? Icons.clear
                                    : Icons.calendar_month,
                                color: AppTheme.naranja,
                                size: 22,
                              ),
                              onPressed: mesFiltro != null
                                  ? () => onMesChanged!(null)
                                  : () => _showMesOptions(context),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],

<<<<<<< HEAD
          //filtro por fecha especifica
=======
          // Filtro de fecha (si está disponible)
>>>>>>> 8f1d397338e300a443102a7f54c5ce411ddd3503
          if (fechaFiltro != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Text(
                  'Fecha:',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    color: AppTheme.blanco,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppTheme.gris,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: InkWell(
<<<<<<< HEAD
                      onTap: () => _seleccionarFecha(context),
=======
                      onTap: () => _selectDate(context),
>>>>>>> 8f1d397338e300a443102a7f54c5ce411ddd3503
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                DateFormat('dd/MM/yyyy').format(fechaFiltro!),
                                style: const TextStyle(
                                  color: AppTheme.blanco,
                                ),
                              ),
                            ),
                            IconButton(
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              icon: const Icon(
                                Icons.clear,
                                color: AppTheme.naranja,
                                size: 22,
                              ),
                              onPressed: () => onFechaChanged(null),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

<<<<<<< HEAD
  //metodo para mostrar todas las opciones de filtrado
  void _mostrarOpcionesFiltrado(BuildContext context) {
=======
  void _showFilterOptions(BuildContext context) {
>>>>>>> 8f1d397338e300a443102a7f54c5ce411ddd3503
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.gris,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Seleccionar filtro',
              style: TextStyle(
                color: AppTheme.blanco,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...filtros.map((filtro) => ListTile(
                  title: Text(
                    filtro ?? 'Todos',
                    style: const TextStyle(color: AppTheme.blanco),
                  ),
                  leading: filtro == filtroActual
                      ? const Icon(Icons.check_circle, color: AppTheme.naranja)
                      : const Icon(Icons.circle_outlined,
                          color: AppTheme.blanco),
                  onTap: () {
                    onFilterChanged(filtro);
                    Navigator.pop(context);
                  },
                )),
          ],
        ),
      ),
    );
  }

<<<<<<< HEAD
  //metodo para mostrar opciones de mes
=======
  // Nuevo método para mostrar opciones de mes
>>>>>>> 8f1d397338e300a443102a7f54c5ce411ddd3503
  void _showMesOptions(BuildContext context) {
    if (mesesDisponibles == null || onMesChanged == null) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.gris,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Seleccionar mes',
              style: TextStyle(
                color: AppTheme.blanco,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: mesesDisponibles!.length,
                itemBuilder: (context, index) {
                  final mesTexto = mesesDisponibles![index];
                  final esSeleccionado = mesTexto == null
                      ? mesFiltro == null
                      : mesFiltro != null &&
                          DateFormat('MMMM yyyy', 'es').format(mesFiltro!) ==
                              mesTexto;

                  return ListTile(
                    title: Text(
                      mesTexto ?? 'Todos los meses',
                      style: const TextStyle(color: AppTheme.blanco),
                    ),
                    leading: esSeleccionado
                        ? const Icon(Icons.check_circle,
                            color: AppTheme.naranja)
                        : const Icon(Icons.circle_outlined,
                            color: AppTheme.blanco),
                    onTap: () {
                      DateTime? fechaMes;
                      if (mesTexto != null) {
                        try {
                          fechaMes =
                              DateFormat('MMMM yyyy', 'es').parse(mesTexto);
                        } catch (_) {}
                      }
                      onMesChanged!(fechaMes);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

<<<<<<< HEAD
  Future<void> _seleccionarFecha(BuildContext context) async {
=======
  Future<void> _selectDate(BuildContext context) async {
>>>>>>> 8f1d397338e300a443102a7f54c5ce411ddd3503
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: fechaFiltro ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.naranja,
              onPrimary: Colors.black,
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
      onFechaChanged(picked);
    }
  }
}
<<<<<<< HEAD


=======
>>>>>>> 8f1d397338e300a443102a7f54c5ce411ddd3503

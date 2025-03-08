import 'package:flutter/material.dart';
import 'package:flutter_proyecto_app/theme/app_theme.dart';

class FilterBar extends StatelessWidget {
  final String? filtroActual;
  final Function(String?) onFilterChanged;
  final List<String?> filtros;
  
  const FilterBar({
    Key? key,
    required this.filtroActual,
    required this.onFilterChanged,
    required this.filtros,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8.0),
      child: Row(
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
                onTap: () => _showFilterOptions(context),
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
                      Icon(
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
    );
  }

  void _showFilterOptions(BuildContext context) {
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
                : const Icon(Icons.circle_outlined, color: AppTheme.blanco),
              onTap: () {
                onFilterChanged(filtro);
                Navigator.pop(context);
              },
            )).toList(),
          ],
        ),
      ),
    );
  }
}


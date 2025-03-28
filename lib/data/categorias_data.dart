import 'package:flutter_proyecto_app/data/transaccion.dart';

class CategoriasData {
  //categorias predefinidas para gastos
  static final List<String> categoriasGastos = [
    'Alimentación',
    'Transporte',
    'Vivienda',
    'Entretenimiento',
    'Salud',
    'Educación',
    'Ropa',
    'Servicios',
    'Deudas',
    'Otros',
  ];

  //categorias predefinidas para ingresos
  static final List<String> categoriasIngresos = [
    'Salario',
    'Inversiones',
    'Freelance',
    'Regalo',
    'Reembolso',
    'Venta',
    'Otros',
  ];

  //frecuencias de recurrencia
  static final List<String> frecuencias = [
    'Diaria',
    'Semanal',
    'Quincenal',
    'Mensual',
    'Anual',
  ];

  //metodo para obtener categorías según el tipo de transaccion
  static List<String> getCategoriasPorTipo(
    TipoTransacciones tipo,
    List<String> categoriasPersonalizadasGastos,
    List<String> categoriasPersonalizadasIngresos,
  ) {
    if (tipo == TipoTransacciones.GASTO) {
      return [
        ...categoriasGastos,
        ...categoriasPersonalizadasGastos
      ];
    } else {
      return [
        ...categoriasIngresos,
        ...categoriasPersonalizadasIngresos
      ];
    }
  }
}



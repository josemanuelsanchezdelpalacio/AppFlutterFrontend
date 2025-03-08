import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_proyecto_app/data/metas_ahorro.dart';
import 'package:flutter_proyecto_app/data/presupuesto.dart';
import 'package:flutter_proyecto_app/data/transaccion.dart';
import 'package:flutter_proyecto_app/services/metas_ahorro_service.dart';
import 'package:flutter_proyecto_app/services/presupuestos_service.dart';
import 'package:flutter_proyecto_app/services/transacciones_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'package:csv/csv.dart';

class ExportarDatosViewmodel extends ChangeNotifier {
  final int idUsuario;
  final TransaccionesService _transaccionesService = TransaccionesService();
  final PresupuestosService _presupuestosService = PresupuestosService();
  final MetasAhorroService _metasAhorroService = MetasAhorroService();

  bool transaccionesExistentes = false;
  bool presupuestosExistentes= false;
  bool metasExistentes = false;

  List<Transaccion> transacciones = [];
  List<Presupuesto> presupuestos = [];
  List<MetaAhorro> metasAhorro = [];

  final DateFormat formatoDatos = DateFormat('dd/MM/yyyy');

  ExportarDatosViewmodel({required this.idUsuario}) {
    cargarDatos();
  }

  //metodo para cargar los datos
  Future<void> cargarDatos() async {
    notifyListeners();

    try {
      final transaccionesData =
          await _transaccionesService.obtenerTransacciones(idUsuario);
      final presupuestosData =
          await _presupuestosService.obtenerPresupuestos(idUsuario);
      final metasAhorroData =
          await _metasAhorroService.obtenerMetasAhorro(idUsuario);

      transacciones = transaccionesData;
      presupuestos = presupuestosData;
      metasAhorro = metasAhorroData;

      transaccionesExistentes = transacciones.isNotEmpty;
      presupuestosExistentes= presupuestos.isNotEmpty;
      metasExistentes = metasAhorro.isNotEmpty;

      notifyListeners();
    } catch (e) {
      notifyListeners();
      throw Exception('Error al cargar los datos: $e');
    }
  }

  //metodo para exportar los datos en PDF
  Future<void> exportarPDF() async {
    notifyListeners();

    try {
      final pdf = pw.Document();

      //creo el documento PDF con todos los datos
      pdf.addPage(pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        header: (context) => pw.Center(
          child: pw.Text(
            'Resumen financiero',
            style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
          ),
        ),
        footer: (context) => pw.Center(
          child: pw.Text('Generado el ${formatoDatos.format(DateTime.now())}',
              style: const pw.TextStyle(fontSize: 10)),
        ),
        build: (context) => [
          if (transaccionesExistentes) ...[
            pw.Header(level: 1, text: 'Transacciones'),
            _buildTablaPDFTransacciones()
          ],
          if (presupuestosExistentes) ...[
            pw.SizedBox(height: 20),
            pw.Header(level: 1, text: 'Presupuestos'),
            _buildTablaPDFPresupuestos()
          ],
          if (metasExistentes) ...[
            pw.SizedBox(height: 20),
            pw.Header(level: 1, text: 'Metas de ahorro'),
            _buildTablaPDFMetas()
          ]
        ],
      ));

      //guardar y compartir el PDF
      final output = await getTemporaryDirectory();
      final file = File(
          "${output.path}/datos_financieros_${DateTime.now().millisecondsSinceEpoch}.pdf");
      await file.writeAsBytes(await pdf.save());

      Share.shareXFiles([XFile(file.path)], text: 'Mis datos financieros');

      notifyListeners();
    } catch (e) {
      notifyListeners();
      throw Exception('Error al exportar a PDF: $e');
    }
  }

  pw.Widget _buildTablaPDFTransacciones() {
    return pw.Table(border: pw.TableBorder.all(), columnWidths: {
      0: const pw.FlexColumnWidth(1.5), //fecha
      1: const pw.FlexColumnWidth(1.2), //tipo
      2: const pw.FlexColumnWidth(2), //categoria
      3: const pw.FlexColumnWidth(1.2), //cantidad
      4: const pw.FlexColumnWidth(2), //descripción
    }, children: [
      //encabezados
      pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey300),
          children: [
            _pdfCeldasTablas('Fecha', isHeader: true),
            _pdfCeldasTablas('Tipo', isHeader: true),
            _pdfCeldasTablas('Categoria', isHeader: true),
            _pdfCeldasTablas('Cantidad', isHeader: true),
            _pdfCeldasTablas('Descripción', isHeader: true),
          ]),
      // Datos
      ...transacciones
          .map((t) => pw.TableRow(children: [
                _pdfCeldasTablas(formatoDatos.format(t.fechaTransaccion)),
                _pdfCeldasTablas(t.tipoTransaccion == TipoTransacciones.INGRESO
                    ? 'Ingreso'
                    : 'Gasto'),
                _pdfCeldasTablas(t.categoria),
                _pdfCeldasTablas('\$${t.cantidad.toStringAsFixed(2)}'),
                _pdfCeldasTablas(t.descripcion),
              ]))
          .toList(),
    ]);
  }

  pw.Widget _buildTablaPDFPresupuestos() {
    return pw.Table(border: pw.TableBorder.all(), columnWidths: {
      0: const pw.FlexColumnWidth(2), //categoria
      1: const pw.FlexColumnWidth(1.5), //cantidad total
      2: const pw.FlexColumnWidth(1.5), //gastado
      3: const pw.FlexColumnWidth(1.5), //restante
      4: const pw.FlexColumnWidth(1.5), //periodo
    }, children: [
      //encabezados
      pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey300),
          children: [
            _pdfCeldasTablas('Categoria', isHeader: true),
            _pdfCeldasTablas('Presupuesto', isHeader: true),
            _pdfCeldasTablas('Gastado', isHeader: true),
            _pdfCeldasTablas('Restante', isHeader: true),
            _pdfCeldasTablas('Periodo', isHeader: true),
          ]),
      //datos
      ...presupuestos
          .map((p) => pw.TableRow(children: [
                _pdfCeldasTablas(p.categoria),
                _pdfCeldasTablas('\$${p.cantidad.toStringAsFixed(2)}'),
                _pdfCeldasTablas('\$${(p.cantidadGastada).toStringAsFixed(2)}'),
                _pdfCeldasTablas(
                    '\$${(p.cantidadRestante).toStringAsFixed(2)}'),
                _pdfCeldasTablas(
                    '${formatoDatos.format(p.fechaInicio)} - ${formatoDatos.format(p.fechaFin)}'),
              ]))
          .toList(),
    ]);
  }

  pw.Widget _buildTablaPDFMetas() {
    return pw.Table(border: pw.TableBorder.all(), columnWidths: {
      0: const pw.FlexColumnWidth(2), //nombre
      1: const pw.FlexColumnWidth(1.5), //objetivo
      2: const pw.FlexColumnWidth(1.5), //actual
      3: const pw.FlexColumnWidth(1), //completado
      4: const pw.FlexColumnWidth(1.5), //fecha objetivo
    }, children: [
      //encabezados
      pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey300),
          children: [
            _pdfCeldasTablas('Nombre', isHeader: true),
            _pdfCeldasTablas('Objetivo', isHeader: true),
            _pdfCeldasTablas('Actual', isHeader: true),
            _pdfCeldasTablas('Estado', isHeader: true),
            _pdfCeldasTablas('Fecha limite', isHeader: true),
          ]),
      //datos
      ...metasAhorro
          .map((m) => pw.TableRow(children: [
                _pdfCeldasTablas(m.nombre),
                _pdfCeldasTablas('\$${m.cantidadObjetivo.toStringAsFixed(2)}'),
                _pdfCeldasTablas('\$${m.cantidadActual.toStringAsFixed(2)}'),
                _pdfCeldasTablas(m.completada ? 'Completada' : 'Pendiente'),
                _pdfCeldasTablas(formatoDatos.format(m.fechaObjetivo)),
              ]))
          .toList(),
    ]);
  }

  pw.Widget _pdfCeldasTablas(String text, {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontWeight: isHeader ? pw.FontWeight.bold : null,
        ),
        textAlign: isHeader ? pw.TextAlign.center : pw.TextAlign.left,
      ),
    );
  }

  Future<void> exportarDatosAJson() async {
    notifyListeners();

    try {
      final Map<String, dynamic> exportData = {
        'transacciones': transacciones.map((t) => t.toJson()).toList(),
        'presupuestos': presupuestos.map((p) => p.toJson()).toList(),
        'metasAhorro': metasAhorro.map((m) => m.toJson()).toList(),
      };

      final String jsonData = jsonEncode(exportData);

      // Guardar archivo JSON
      final output = await getTemporaryDirectory();
      final file = File(
          "${output.path}/datos_financieros_${DateTime.now().millisecondsSinceEpoch}.json");
      await file.writeAsBytes(utf8.encode(jsonData));

      Share.shareXFiles([XFile(file.path)],
          text: 'Mis datos financieros (JSON)');

      notifyListeners();
    } catch (e) {
      notifyListeners();
      throw Exception('Error al exportar a JSON: $e');
    }
  }

  Future<void> exportarDatosACSV() async {
    notifyListeners();

    try {
      final dir = await getTemporaryDirectory();
      final List<File> files = [];

      //exportar transacciones
      if (transaccionesExistentes) {
        final transaccionesCSV = [
          ['ID', 'Tipo', 'Categoría', 'Cantidad', 'Fecha', 'Descripción'],
          ...transacciones.map((t) => [
                t.id,
                t.tipoTransaccion == TipoTransacciones.INGRESO
                    ? 'Ingreso'
                    : 'Gasto',
                t.categoria,
                t.cantidad,
                formatoDatos.format(t.fechaTransaccion),
                t.descripcion
              ])
        ];

        final String transaccionesCsvData =
            const ListToCsvConverter().convert(transaccionesCSV);
        final fileTransacciones = File(
            "${dir.path}/transacciones_${DateTime.now().millisecondsSinceEpoch}.csv");
        await fileTransacciones.writeAsBytes(utf8.encode(transaccionesCsvData));
        files.add(fileTransacciones);
      }

      //exportar presupuestos
      if (presupuestosExistentes) {
        final presupuestosCSV = [
          [
            'ID',
            'Categoría',
            'Cantidad',
            'Gastado',
            'Restante',
            'Fecha Inicio',
            'Fecha Fin'
          ],
          ...presupuestos.map((p) => [
                p.id,
                p.categoria,
                p.cantidad,
                p.cantidadGastada,
                p.cantidadRestante,
                formatoDatos.format(p.fechaInicio),
                formatoDatos.format(p.fechaFin)
              ])
        ];

        final String presupuestosCsvData =
            const ListToCsvConverter().convert(presupuestosCSV);
        final filePresupuestos = File(
            "${dir.path}/presupuestos_${DateTime.now().millisecondsSinceEpoch}.csv");
        await filePresupuestos.writeAsBytes(utf8.encode(presupuestosCsvData));
        files.add(filePresupuestos);
      }

      //exportar metas
      if (metasExistentes) {
        final metasCSV = [
          [
            'ID',
            'Nombre',
            'Objetivo',
            'Actual',
            'Completada',
            'Fecha Objetivo'
          ],
          ...metasAhorro.map((m) => [
                m.id,
                m.nombre,
                m.cantidadObjetivo,
                m.cantidadActual,
                m.completada ? 'Sí' : 'No',
                formatoDatos.format(m.fechaObjetivo)
              ])
        ];

        final String metasCsvData =
            const ListToCsvConverter().convert(metasCSV);
        final fileMetas = File(
            "${dir.path}/metas_ahorro_${DateTime.now().millisecondsSinceEpoch}.csv");
        await fileMetas.writeAsBytes(utf8.encode(metasCsvData));
        files.add(fileMetas);
      }

      if (files.isNotEmpty) {
        Share.shareXFiles(files.map((f) => XFile(f.path)).toList(),
            text: 'Mis datos financieros (CSV)');
      } else {
        throw Exception('No hay datos para exportar');
      }

      notifyListeners();
    } catch (e) {
      notifyListeners();
      throw Exception('Error al exportar a CSV: $e');
    }
  }

  bool get hasAnyData => transaccionesExistentes || presupuestosExistentes|| metasExistentes;
}

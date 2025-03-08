import 'dart:convert';
import 'package:flutter_proyecto_app/data/transaccion.dart';
import 'package:flutter_proyecto_app/services/metas_ahorro_service.dart';
import 'package:flutter_proyecto_app/services/presupuestos_service.dart';
import 'package:http/http.dart' as http;

class TransaccionesService {
  //url base del backend donde se gestionan las transacciones
  static const String baseUrl = 'http://10.0.2.2:8080/api/transacciones';

  final PresupuestosService _presupuestosService = PresupuestosService();
  final MetasAhorroService _metasAhorroService = MetasAhorroService();

  //metodo para crear una nueva transaccion en el backend
  Future<Transaccion> crearTransaccion(
      int idUsuario, Transaccion transaccion) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/crearTransacciones?idUsuario=$idUsuario'),
        headers: {'Content-Type': 'application/json'},
        //convierto la transaccion a JSON
        body: jsonEncode(transaccion.toJson()),
      );

      if (response.statusCode == 200) {
        //convierto el JSON a un objeto
        return Transaccion.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Error al crear la transaccion: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error al crear la transaccion: $e');
    }
  }

  //metodo para obtener todas las transacciones del usuario
  Future<List<Transaccion>> obtenerTransacciones(int idUsuario) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/obtenerTransacciones?idUsuario=$idUsuario'),
      );

      if (response.statusCode == 200) {
        List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList
            .map((json) => Transaccion.fromJson(json))
            .toList(); // Convierte la lista JSON a lista de objetos Transaccion
      } else {
        throw Exception('Error al obtener las transacciones: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error al obtener las transacciones: $e');
    }
  }

  //metodo para obtener transacciones dentro de un rango de fechas especifico
  Future<List<Transaccion>> obtenerTransaccionesPorFecha(
    int idUsuario,
    DateTime fechaInicio,
    DateTime fechaFin,
  ) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$baseUrl/transacciones-rango-fechas?idUsuario=$idUsuario'
          //parseo las fechas para que tengan un correcto formato
          '&fechaInicio=${fechaInicio.toIso8601String().split('T')[0]}'
          '&fechaFin=${fechaFin.toIso8601String().split('T')[0]}',
        ),
      );

      if (response.statusCode == 200) {
        List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((json) => Transaccion.fromJson(json)).toList();
      } else {
        throw Exception(
            'Error al obtener las transacciones por fecha: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error al obtener las transacciones por fecha: $e');
    }
  }

  //metodo para obtener una transaccion especifica por su id
  Future<Transaccion> obtenerTransaccionPorId(
      int idUsuario, int idTransaccion) async {
    try {
      //obtengo todas las transacciones y se busca la que tenga el id especificado
      final List<Transaccion> transacciones =
          await obtenerTransacciones(idUsuario);

      final transaccion = transacciones.firstWhere(
        (t) => t.id == idTransaccion,
        orElse: () =>
            throw Exception('Transaccion no encontrada con ID: $idTransaccion'),
      );

      return transaccion;
    } catch (e) {
      throw Exception('Error al obtener la transaccion: $e');
    }
  }

  //metodo para actualizar una transaccion existente
  Future<Transaccion> actualizarTransaccion(
    int idUsuario,
    int idTransaccion,
    Transaccion transaccion,
  ) async {
    try {
      final transaccionOriginal =
          await obtenerTransaccionPorId(idUsuario, idTransaccion);

      final response = await http.put(
        Uri.parse(
            '$baseUrl/actualizarTransacciones?idTransaccion=$idTransaccion&idUsuario=$idUsuario'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(transaccion.toJson()),
      );

      if (response.statusCode == 200) {
        final transaccionActualizada =
            Transaccion.fromJson(jsonDecode(response.body));

        // Try to update budgets but don't let it stop the transaction update if it fails
        try {
          // Revert original transaction effects
          if (transaccionOriginal.tipoTransaccion == TipoTransacciones.GASTO) {
            await _presupuestosService.revertirTransaccion(
                idUsuario, transaccionOriginal);
          } else if (transaccionOriginal.tipoTransaccion ==
              TipoTransacciones.INGRESO) {
            await _metasAhorroService.revertirTransaccion(
                idUsuario, transaccionOriginal);
          }

          // Apply updated transaction effects
          if (transaccionActualizada.tipoTransaccion ==
              TipoTransacciones.GASTO) {
            await _presupuestosService.actualizarPresupuestosConTransaccion(
                idUsuario, transaccionActualizada);
          } else if (transaccionActualizada.tipoTransaccion ==
              TipoTransacciones.INGRESO) {
            await _metasAhorroService.actualizarMetasPorTransaccion(
                idUsuario, transaccionActualizada);
          }
        } catch (budgetError) {
          // Log the error but continue with returning the updated transaction
          print('Error al actualizar presupuestos/metas: $budgetError');
        }

        return transaccionActualizada;
      } else {
        throw Exception('Error al actualizar la transaccion: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error al actualizar la transaccion: $e');
    }
  }

  //metodo para eliminar una transaccion existente
  Future<void> eliminarTransaccion(int idUsuario, int idTransaccion) async {
    try {
      final transaccion =
          await obtenerTransaccionPorId(idUsuario, idTransaccion);

      final response = await http.delete(
        Uri.parse(
            '$baseUrl/borrarTransacciones?idTransaccion=$idTransaccion&idUsuario=$idUsuario'),
      );

      if (response.statusCode == 204) {
        //revierto los efectos segun el tipo de transaccion eliminada
        if (transaccion.tipoTransaccion == TipoTransacciones.GASTO) {
          await _presupuestosService.revertirTransaccion(
              idUsuario, transaccion);
        } else if (transaccion.tipoTransaccion == TipoTransacciones.INGRESO) {
          await _metasAhorroService.revertirTransaccion(idUsuario, transaccion);
        }
      } else {
        throw Exception('Error al eliminar la transacción: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error al eliminar la transacción: $e');
    }
  }
}

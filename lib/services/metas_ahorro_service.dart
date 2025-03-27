import 'dart:convert';
import 'package:flutter_proyecto_app/data/metas_ahorro.dart';
import 'package:flutter_proyecto_app/data/transaccion.dart';
import 'package:http/http.dart' as http;

class MetasAhorroService {
  static const String baseUrl = 'http://10.0.2.2:8080/api/metas-ahorro';

  //metodo para crear una nueva meta de ahorro
  Future<MetaAhorro> crearMetaAhorro(
      int idUsuario, MetaAhorro metaAhorro) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/crear?idUsuario=$idUsuario'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(metaAhorro.toJson()),
      );

      if (response.statusCode == 200) {
        return MetaAhorro.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Error al crear la meta de ahorro: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error al crear la meta de ahorro: $e');
    }
  }

  //metodo para obtener todas las metas de ahorro de un usuario
  Future<List<MetaAhorro>> obtenerMetasAhorro(int idUsuario) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/listar?idUsuario=$idUsuario'),
      );

      if (response.statusCode == 200) {
        List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((json) => MetaAhorro.fromJson(json)).toList();
      } else {
        throw Exception(
            'Error al obtener las metas de ahorro: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error al obtener las metas de ahorro: $e');
    }
  }

  //metodo para obtener una meta de ahorro especifica por su id
  Future<MetaAhorro> obtenerMetaAhorroPorId(
      int idUsuario, int idMetaAhorro) async {
    try {
      final response = await http.get(
        Uri.parse(
            '$baseUrl/obtener?idUsuario=$idUsuario&idMetaAhorro=$idMetaAhorro'),
      );

      if (response.statusCode == 200) {
        return MetaAhorro.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Error al obtener la meta de ahorro: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error al obtener la meta de ahorro: $e');
    }
  }

  //metodo para actualizar una meta de ahorro existente
  Future<MetaAhorro> actualizarMetaAhorro(
    int idUsuario,
    int idMetaAhorro,
    MetaAhorro metaAhorro,
  ) async {
    try {
      final response = await http.put(
        Uri.parse(
            '$baseUrl/actualizar?idMetaAhorro=$idMetaAhorro&idUsuario=$idUsuario'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(metaAhorro.toJson()),
      );

      if (response.statusCode == 200) {
        return MetaAhorro.fromJson(jsonDecode(response.body));
      } else {
        throw Exception(
            'Error al actualizar la meta de ahorro: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error al actualizar la meta de ahorro: $e');
    }
  }

  //metodo para eliminar una meta de ahorro
  Future<void> eliminarMetaAhorro(int idUsuario, int idMetaAhorro) async {
    try {
      final response = await http.delete(
        Uri.parse(
            '$baseUrl/eliminar?idMetaAhorro=$idMetaAhorro&idUsuario=$idUsuario'),
      );

      if (response.statusCode != 204) {
        throw Exception(
            'Error al eliminar la meta de ahorro: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error al eliminar la meta de ahorro: $e');
    }
  }

  //metodo para actualizar las metas de ahorro afectadas por una transaccion
  Future<void> actualizarMetasPorTransaccion(
      int idUsuario, Transaccion transaccion) async {
    if (transaccion.tipoTransaccion != TipoTransacciones.INGRESO ||
        transaccion.metaAhorroId == null) return;

    try {
      final meta =
          await obtenerMetaAhorroPorId(idUsuario, transaccion.metaAhorroId!);

      //incremento la cantidad actual
      double nuevaCantidadActual = meta.cantidadActual + transaccion.cantidad;
      bool estaCompletada = nuevaCantidadActual >= meta.cantidadObjetivo;

      //limito la cantidad actual al objetivo si se completa
      if (nuevaCantidadActual > meta.cantidadObjetivo) {
        nuevaCantidadActual = meta.cantidadObjetivo;
      }

      //actualizo la meta
      final metaActualizada = MetaAhorro(
        id: meta.id,
        nombre: meta.nombre,
        categoria: meta.categoria,
        cantidadObjetivo: meta.cantidadObjetivo,
        cantidadActual: nuevaCantidadActual,
        fechaObjetivo: meta.fechaObjetivo,
        completada: estaCompletada,
      );

      await actualizarMetaAhorro(idUsuario, meta.id!, metaActualizada);
    } catch (e) {
      throw Exception('Error al actualizar meta por transacción: $e');
    }
  }

  Future<void> revertirTransaccion(
      int idUsuario, Transaccion transaccion) async {
    if (transaccion.tipoTransaccion != TipoTransacciones.INGRESO ||
        transaccion.metaAhorroId == null) return;

    try {
      final meta =
          await obtenerMetaAhorroPorId(idUsuario, transaccion.metaAhorroId!);

      // Calcular los nuevos valores
      double nuevaCantidadActual = meta.cantidadActual - transaccion.cantidad;
      if (nuevaCantidadActual < 0) nuevaCantidadActual = 0;

      bool estaCompletada = nuevaCantidadActual >= meta.cantidadObjetivo;

      // Actualizar la meta
      final metaActualizada = MetaAhorro(
        id: meta.id,
        nombre: meta.nombre,
        categoria: meta.categoria,
        cantidadObjetivo: meta.cantidadObjetivo,
        cantidadActual: nuevaCantidadActual,
        fechaObjetivo: meta.fechaObjetivo,
        completada: estaCompletada,
      );

      await actualizarMetaAhorro(idUsuario, meta.id!, metaActualizada);
    } catch (e) {
      throw Exception('Error al revertir transacción en meta: $e');
    }
  }
}

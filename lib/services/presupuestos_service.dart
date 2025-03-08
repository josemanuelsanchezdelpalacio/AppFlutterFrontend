import 'dart:convert';
import 'package:flutter_proyecto_app/data/presupuesto.dart';
import 'package:flutter_proyecto_app/data/transaccion.dart';
import 'package:http/http.dart' as http;

class PresupuestosService {
  static const String baseUrl = 'http://10.0.2.2:8080/api/presupuestos';

  //metodo para crear un nuevo presupuesto
  Future<Presupuesto> crearPresupuesto(
      int idUsuario, Presupuesto presupuesto) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/crearPresupuesto?idUsuario=$idUsuario'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(presupuesto.toJson()),
      );

      if (response.statusCode == 200) {
        return Presupuesto.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Error al crear el presupuesto: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error al crear el presupuesto: $e');
    }
  }

  //metodo para obtener todos los presupuestos de un usuario
  Future<List<Presupuesto>> obtenerPresupuestos(int idUsuario) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/obtenerPresupuesto?idUsuario=$idUsuario'),
      );

      if (response.statusCode == 200) {
        List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((json) => Presupuesto.fromJson(json)).toList();
      } else {
        throw Exception('Error al obtener los presupuestos: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error al obtener los presupuestos: $e');
    }
  }

  //metodo para obtener una transaccion especifica por su id
  Future<Presupuesto> obtenerPresupuestoPorId(
      int idUsuario, int idPresupuesto) async {
    try {
      final response = await http.get(
        Uri.parse(
            '$baseUrl/obtenerPresupuestoPorId?idUsuario=$idUsuario&idPresupuesto=$idPresupuesto'),
      );

      if (response.statusCode == 200) {
        return Presupuesto.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Error al obtener el presupuesto: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error al obtener el presupuesto: $e');
    }
  }

  //metodo para actualizar un presupuesto existente
  Future<Presupuesto> actualizarPresupuesto(
    int idUsuario,
    int idPresupuesto,
    Presupuesto presupuesto,
  ) async {
    try {
      final response = await http.put(
        Uri.parse(
            '$baseUrl/actualizarPresupuesto?idPresupuesto=$idPresupuesto&idUsuario=$idUsuario'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(presupuesto.toJson()),
      );

      if (response.statusCode == 200) {
        return Presupuesto.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Error al actualizar el presupuesto: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error al actualizar el presupuesto: $e');
    }
  }

  //metodo para un presupuesto
  Future<void> eliminarPresupuesto(int idUsuario, int idPresupuesto) async {
    try {
      final response = await http.delete(
        Uri.parse(
            '$baseUrl/borrarPresupuesto?idPresupuesto=$idPresupuesto&idUsuario=$idUsuario'),
      );

      if (response.statusCode != 204) {
        throw Exception('Error al eliminar el presupuesto: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error al eliminar el presupuesto: $e');
    }
  }

  //metodo para actualizar los presupuestos afectados por una transaccion
  Future<void> actualizarPresupuestosConTransaccion(
      int idUsuario, Transaccion transaccion) async {

    //compruebo que la transaccion es de tipo gasto
    if (transaccion.tipoTransaccion != TipoTransacciones.GASTO) return;

    try {
      //obtengo los presupuestos del usuario
      final presupuestos = await obtenerPresupuestos(idUsuario);

      //encuentro presupuestos aplicables
      final presupuestosAplicables = presupuestos
          .where((presupuesto) =>
              presupuesto.categoria == transaccion.categoria &&
              presupuesto.isTransactionApplicable(transaccion.fechaTransaccion))
          .toList();

      //actualizo cada presupuesto
      for (var presupuesto in presupuestosAplicables) {
        //creo presupuesto actualizado
        final presupuestoActualizado =
            presupuesto.updateWithTransaction(transaccion.cantidad);

        //guardo los cambios en el backend
        await actualizarPresupuesto(
            idUsuario, presupuesto.id!, presupuestoActualizado);
      }
    } catch (e) {
      throw Exception('Error al actualizar presupuestos: $e');
    }
  }

  //metodo para revertir los efectos de una transaccion en los presupuestos
  Future<void> revertirTransaccion(
      int idUsuario, Transaccion transaccion) async {
    if (transaccion.tipoTransaccion != TipoTransacciones.GASTO) return;

    try {
      //obtengo presupuestos afectados
      final presupuestos = await obtenerPresupuestos(idUsuario);

      final presupuestosAfectados = presupuestos
          .where((p) =>
              p.categoria == transaccion.categoria &&
              !transaccion.fechaTransaccion.isBefore(p.fechaInicio) &&
              !transaccion.fechaTransaccion.isAfter(p.fechaFin))
          .toList();

      //revierto los efectos en cada presupuesto
      for (var presupuesto in presupuestosAfectados) {

        //calculo los nuevos valores restando la transaccion
        double nuevaCantidadGastada =
            (presupuesto.cantidadGastada) - transaccion.cantidad;
        
        //aseguro que no quede en negativo
        if (nuevaCantidadGastada < 0) nuevaCantidadGastada = 0;

        double nuevaCantidadRestante =
            presupuesto.cantidad - nuevaCantidadGastada;

        //actualizo el presupuesto con los nuevos valores
        final presupuestoActualizado = Presupuesto(
          id: presupuesto.id,
          categoria: presupuesto.categoria,
          cantidad: presupuesto.cantidad,
          fechaInicio: presupuesto.fechaInicio,
          fechaFin: presupuesto.fechaFin,
          cantidadGastada: nuevaCantidadGastada,
          cantidadRestante: nuevaCantidadRestante,
        );

        //actualizo el presupuesto en el backend
        await actualizarPresupuesto(
            idUsuario, presupuesto.id!, presupuestoActualizado);
      }
    } catch (e) {
      throw Exception('Error al revertir transacción en presupuestos: $e');
    }
  }
}

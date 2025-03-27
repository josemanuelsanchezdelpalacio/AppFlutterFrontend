import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_proyecto_app/components/barra_inferior_secciones.dart';
import 'package:flutter_proyecto_app/components/menu_desplegable.dart';
import 'package:flutter_proyecto_app/data/transaccion.dart';
import 'package:flutter_proyecto_app/services/transacciones_service.dart';
import 'package:flutter_proyecto_app/theme/app_theme.dart';
import 'package:intl/intl.dart';

class TransaccionImagenScreen extends StatefulWidget {
  final int idUsuario;
  final int idTransaccion;

  const TransaccionImagenScreen({
    Key? key,
    required this.idUsuario,
    required this.idTransaccion,
  }) : super(key: key);

  @override
  State<TransaccionImagenScreen> createState() =>
      _TransaccionImagenScreenState();
}

class _TransaccionImagenScreenState extends State<TransaccionImagenScreen> {
  final TransaccionesService _transaccionesService = TransaccionesService();
  bool _isLoading = true;
  Transaccion? _transaccion;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _cargarTransaccion();
  }

  Future<void> _cargarTransaccion() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final transaccion = await _transaccionesService.obtenerTransaccionPorId(
        widget.idUsuario,
        widget.idTransaccion,
      );

      setState(() {
        _transaccion = transaccion;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al cargar la imagen: $e';
        _isLoading = false;
      });
    }
  }

  String _formatoFecha(DateTime fecha) {
    return DateFormat('dd/MM/yyyy', 'es').format(fecha);
  }

  String _formatoMoneda(double cantidad) {
    final formatoMoneda = NumberFormat.currency(locale: 'es_ES', symbol: '€');
    return formatoMoneda.format(cantidad);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.colorFondo,
      appBar: AppBar(
        backgroundColor: AppTheme.colorFondo,
        title: const Text(
          'Detalle de Imagen',
          style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.blanco),
        ),
        iconTheme: const IconThemeData(color: AppTheme.blanco),
      ),
      drawer: MenuDesplegable(idUsuario: widget.idUsuario),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.naranja),
            )
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.naranja,
                          foregroundColor: Colors.black,
                        ),
                        onPressed: _cargarTransaccion,
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                )
              : _buildContent(),
      bottomNavigationBar: BarraInferiorSecciones(
        idUsuario: widget.idUsuario,
        indexActual: 1,
      ),
    );
  }

  Widget _buildContent() {
    if (_transaccion == null) {
      return Center(
        child: Text(
          'No se encontró la transacción',
          style: TextStyle(color: AppTheme.blanco),
        ),
      );
    }

    if (_transaccion!.imagenUrl == null || _transaccion!.imagenUrl!.isEmpty) {
      return Center(
        child: Text(
          'Esta transacción no tiene imagen asociada',
          style: TextStyle(color: AppTheme.blanco),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _cargarTransaccion,
      color: AppTheme.naranja,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Sección de información de la transacción
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 0,
                color: AppTheme.gris,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _transaccion!.descripcion,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.blanco,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            _transaccion!.tipoTransaccion ==
                                    TipoTransacciones.INGRESO
                                ? Icons.arrow_downward
                                : Icons.arrow_upward,
                            color: _transaccion!.tipoTransaccion ==
                                    TipoTransacciones.INGRESO
                                ? Colors.green
                                : Colors.red,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _formatoMoneda(_transaccion!.cantidad),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: _transaccion!.tipoTransaccion ==
                                      TipoTransacciones.INGRESO
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, 
                            size: 16, 
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _formatoFecha(_transaccion!.fechaTransaccion),
                            style: TextStyle(color: Colors.grey[400]),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.category, 
                            size: 16, 
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _transaccion!.categoria,
                            style: TextStyle(color: Colors.grey[400]),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Sección de la imagen
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Card(
                elevation: 0,
                color: AppTheme.gris,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'Imagen adjunta',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.blanco,
                        ),
                      ),
                    ),
                    Container(
                      constraints: const BoxConstraints(
                        maxHeight: 400,
                      ),
                      child: Hero(
                        tag: 'transaction-image-${widget.idTransaccion}',
                        child: InteractiveViewer(
                          minScale: 0.5,
                          maxScale: 3.0,
                          child: _buildImageWidget(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            
            // Espacio adicional al final para mejor experiencia de scrolling
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildImageWidget() {
    final String baseUrl = 'http://10.0.2.2:8080';
    final String imageUrl = _transaccion!.imagenUrl!;

    // Always use the correct API endpoint for images
    final String fullImageUrl = imageUrl.startsWith('http')
        ? imageUrl
        : '$baseUrl/api/transacciones/images/$imageUrl';

    return CachedNetworkImage(
      imageUrl: fullImageUrl,
      fit: BoxFit.contain,
      placeholder: (context, url) => const Center(
        child: CircularProgressIndicator(color: AppTheme.naranja),
      ),
      errorWidget: (context, url, error) {
        // Try fallback path if the first attempt fails
        if (!url.contains('/api/transacciones/images/')) {
          return _buildFallbackImageWidget(imageUrl);
        }

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.broken_image, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Error al cargar la imagen',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.naranja,
                foregroundColor: Colors.black,
              ),
              onPressed: _cargarTransaccion,
              child: const Text('Reintentar'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFallbackImageWidget(String imageUrl) {
    final String baseUrl = 'http://10.0.2.2:8080';
    final String fallbackUrl = '$baseUrl/uploads/images/$imageUrl';

    return CachedNetworkImage(
      imageUrl: fallbackUrl,
      fit: BoxFit.contain,
      placeholder: (context, url) => const Center(
        child: CircularProgressIndicator(color: AppTheme.naranja),
      ),
      errorWidget: (context, url, error) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.broken_image, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Error al cargar la imagen',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.naranja,
                foregroundColor: Colors.black,
              ),
              onPressed: _cargarTransaccion,
              child: const Text('Reintentar'),
            ),
          ],
        );
      },
    );
  }
}


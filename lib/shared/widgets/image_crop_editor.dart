import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image/image.dart' as img;

class ImageCropEditor extends StatefulWidget {
  final File imageFile;
  final VoidCallback onCancel;
  final Function(File) onCropComplete;

  const ImageCropEditor({
    super.key,
    required this.imageFile,
    required this.onCancel,
    required this.onCropComplete,
  });

  @override
  State<ImageCropEditor> createState() => _ImageCropEditorState();
}

class _ImageCropEditorState extends State<ImageCropEditor> {
  final TransformationController _transformationController =
      TransformationController();
  final GlobalKey _repaintBoundaryKey = GlobalKey();
  bool _isCropping = false;
  double _currentScale = 1.0;

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  void _zoomIn() {
    setState(() {
      _currentScale = (_currentScale * 1.2).clamp(0.5, 4.0);
      _transformationController.value = Matrix4.identity()
        ..scale(_currentScale);
    });
  }

  void _zoomOut() {
    setState(() {
      _currentScale = (_currentScale / 1.2).clamp(0.5, 4.0);
      _transformationController.value = Matrix4.identity()
        ..scale(_currentScale);
    });
  }

  void _panLeft() {
    final matrix = _transformationController.value.clone();
    matrix.translate(50.0, 0.0);
    _transformationController.value = matrix;
  }

  void _panRight() {
    final matrix = _transformationController.value.clone();
    matrix.translate(-50.0, 0.0);
    _transformationController.value = matrix;
  }

  void _panUp() {
    final matrix = _transformationController.value.clone();
    matrix.translate(0.0, 50.0);
    _transformationController.value = matrix;
  }

  void _panDown() {
    final matrix = _transformationController.value.clone();
    matrix.translate(0.0, -50.0);
    _transformationController.value = matrix;
  }

  void _resetTransform() {
    setState(() {
      _currentScale = 1.0;
      _transformationController.value = Matrix4.identity();
    });
  }

  Future<void> _cropImage() async {
    setState(() {
      _isCropping = true;
    });

    try {
      // Get the RenderRepaintBoundary
      final RenderRepaintBoundary boundary =
          _repaintBoundaryKey.currentContext!.findRenderObject()
              as RenderRepaintBoundary;

      // Capture the image
      final ui.Image image = await boundary.toImage(pixelRatio: 2.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();

      // Decode image
      img.Image? decodedImage = img.decodeImage(pngBytes);
      if (decodedImage == null) {
        throw Exception('Failed to decode image');
      }

      // Resize to max 1024x1024 while maintaining aspect ratio
      if (decodedImage.width > 1024 || decodedImage.height > 1024) {
        // Determine which dimension to resize based on
        if (decodedImage.width >= decodedImage.height) {
          // Landscape or square - resize by width
          decodedImage = img.copyResize(
            decodedImage,
            width: 1024,
            maintainAspect: true,
            interpolation: img.Interpolation.linear,
          );
        } else {
          // Portrait - resize by height
          decodedImage = img.copyResize(
            decodedImage,
            height: 1024,
            maintainAspect: true,
            interpolation: img.Interpolation.linear,
          );
        }
      }

      // Compress to JPEG with 80% quality
      final jpegBytes = img.encodeJpg(decodedImage, quality: 80);

      // Save to temporary file
      final tempDir = Directory.systemTemp;
      final tempFile = File(
        '${tempDir.path}/cropped_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      await tempFile.writeAsBytes(jpegBytes);

      debugPrint('📸 Compressed image size: ${jpegBytes.length} bytes');
      debugPrint(
        '📸 Image dimensions: ${decodedImage.width}x${decodedImage.height}',
      );

      widget.onCropComplete(tempFile);
    } catch (e) {
      debugPrint('Error cropping image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to crop image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCropping = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final cropAreaSize = size.width * 0.6 > 500 ? 500.0 : size.width * 0.6;

    return Container(
      color: Colors.black,
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            color: theme.colorScheme.surface,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: _isCropping ? null : widget.onCancel,
                  icon: const Icon(Icons.close),
                  label: const Text('Cancel'),
                ),
                const Text(
                  'Zoom, Pan & Crop Image',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton.icon(
                  onPressed: _isCropping ? null : _cropImage,
                  icon: _isCropping
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.check),
                  label: const Text('Done'),
                ),
              ],
            ),
          ),

          // Image Editor Area
          Expanded(
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Full background image with zoom/pan
                  InteractiveViewer(
                    transformationController: _transformationController,
                    minScale: 0.5,
                    maxScale: 4.0,
                    panEnabled: false,
                    scaleEnabled: false,
                    child: Image.file(widget.imageFile, fit: BoxFit.contain),
                  ),

                  // Crop overlay
                  IgnorePointer(
                    child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      color: Colors.black54,
                      child: Center(
                        child: Container(
                          width: cropAreaSize,
                          height: cropAreaSize,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.5),
                                blurRadius: 10,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Capture area (hidden, only for cropping)
                  Positioned.fill(
                    child: Center(
                      child: RepaintBoundary(
                        key: _repaintBoundaryKey,
                        child: ClipRect(
                          child: SizedBox(
                            width: cropAreaSize,
                            height: cropAreaSize,
                            child: InteractiveViewer(
                              transformationController:
                                  _transformationController,
                              minScale: 0.5,
                              maxScale: 4.0,
                              panEnabled: false,
                              scaleEnabled: false,
                              child: Image.file(
                                widget.imageFile,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Instructions
          Container(
            padding: const EdgeInsets.all(16),
            color: theme.colorScheme.surface,
            child: Column(
              children: [
                // Zoom controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: _isCropping ? null : _zoomOut,
                      icon: const Icon(Icons.zoom_out),
                      tooltip: 'Zoom Out',
                      style: IconButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary.withOpacity(
                          0.1,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${(_currentScale * 100).toStringAsFixed(0)}%',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: _isCropping ? null : _zoomIn,
                      icon: const Icon(Icons.zoom_in),
                      tooltip: 'Zoom In',
                      style: IconButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary.withOpacity(
                          0.1,
                        ),
                      ),
                    ),
                    const SizedBox(width: 24),
                    IconButton(
                      onPressed: _isCropping ? null : _resetTransform,
                      icon: const Icon(Icons.refresh),
                      tooltip: 'Reset',
                      style: IconButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary.withOpacity(
                          0.1,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Pan controls
                Column(
                  children: [
                    IconButton(
                      onPressed: _isCropping ? null : _panUp,
                      icon: const Icon(Icons.arrow_upward),
                      tooltip: 'Pan Up',
                      style: IconButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary.withOpacity(
                          0.1,
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: _isCropping ? null : _panLeft,
                          icon: const Icon(Icons.arrow_back),
                          tooltip: 'Pan Left',
                          style: IconButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary
                                .withOpacity(0.1),
                          ),
                        ),
                        const SizedBox(width: 80),
                        IconButton(
                          onPressed: _isCropping ? null : _panRight,
                          icon: const Icon(Icons.arrow_forward),
                          tooltip: 'Pan Right',
                          style: IconButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary
                                .withOpacity(0.1),
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: _isCropping ? null : _panDown,
                      icon: const Icon(Icons.arrow_downward),
                      tooltip: 'Pan Down',
                      style: IconButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary.withOpacity(
                          0.1,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Use buttons above to zoom and pan, then tap Done',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:pintopia/models/wall.dart';
import 'package:pintopia/widgets/common/copyable_link.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ShareWallSheet extends StatelessWidget {
  final Wall wall;
  final GlobalKey qrKey = GlobalKey();

  ShareWallSheet({
    super.key,
    required this.wall,
  });

  String _buildWallLink() {
    return 'https://app.pintopia.org/#/wall/${wall.id}';
  }

  String _buildAdminLink() {
    return 'https://app.pintopia.org/#/wall/${wall.id}?a=${wall.adminCode}';
  }

  Future<void> _saveQrCode(BuildContext context) async {
    try {
      final boundary =
          qrKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;

      // Save to gallery
      await ImageGallerySaver.saveImage(
        byteData.buffer.asUint8List(),
        name: 'qr_code_${wall.id}',
        quality: 100,
      );

      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Erfolg'),
            content: const Text('QR-Code wurde in der Galerie gespeichert'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Fehler'),
            content: const Text('QR-Code konnte nicht gespeichert werden'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Wall teilen',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            CopyableLink(url: _buildWallLink()),
            Text(
              'Teile diese Wall per Link oder QR-Code',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.color
                        ?.withValues(alpha: 0.7),
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 200.0,
                  child: RepaintBoundary(
                    key: qrKey,
                    child: QrImageView(
                      data: _buildWallLink(),
                      size: 200.0,
                      embeddedImage:
                          const AssetImage('assets/icons/icon_circle.png'),
                      embeddedImageStyle: const QrEmbeddedImageStyle(
                        size: Size(50, 50),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.download),
                      onPressed: () => _saveQrCode(context),
                    ),
                    Text(
                      'QR-Code\nherunterladen',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 32),
            Text(
              'Admin-Link',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            CopyableLink(url: _buildAdminLink()),
            Text(
              'Mit diesem Link können Admins die Wall bearbeiten.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.color
                        ?.withValues(alpha: 0.7),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

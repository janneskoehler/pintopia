import 'package:flutter/material.dart';
import '../models/wall.dart';
import '../services/firebase_service.dart';
import 'wall_form.dart';
import 'sheet_bar.dart';

class EditWallSheet extends StatelessWidget {
  final Wall wall;
  final String wallId;
  final FirebaseService firebaseService;

  const EditWallSheet({
    super.key,
    required this.wall,
    required this.wallId,
    required this.firebaseService,
  });

  @override
  Widget build(BuildContext context) {
    final nameController = TextEditingController(text: wall.title);
    String? selectedImage = wall.assetImageName;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SheetBar(
            title: 'Pinnwand bearbeiten',
            leftAction: TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                minimumSize: Size.zero,
                padding: const EdgeInsets.all(8),
              ),
              child: const Text('Abbrechen'),
            ),
            rightAction: TextButton(
              onPressed: () async {
                await firebaseService.updateWall(
                  wallId,
                  nameController.text,
                  selectedImage ?? '',
                );
                if (context.mounted) Navigator.pop(context);
              },
              style: TextButton.styleFrom(
                minimumSize: Size.zero,
                padding: const EdgeInsets.all(8),
              ),
              child: const Text('Speichern'),
            ),
          ),
          const SizedBox(height: 16),
          WallForm(
            nameController: nameController,
            selectedAssetImage: selectedImage,
            onAssetImageSelected: (image) => selectedImage = image,
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            icon: const Icon(Icons.delete_forever),
            label: const Text('Pinnwand löschen'),
            onPressed: () => _showDeleteConfirmation(context),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pinnwand löschen'),
        content: const Text(
          'Möchtest du diese Pinnwand wirklich löschen? '
          'Diese Aktion kann nicht rückgängig gemacht werden.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () async {
              await firebaseService.deleteWall(wallId);
              if (context.mounted) {
                Navigator.pop(context); // Dialog schließen
                Navigator.pop(context); // Settings-Sheet schließen
                Navigator.pop(context); // Zurück zur Übersicht
              }
            },
            child: const Text('Löschen'),
          ),
        ],
      ),
    );
  }
}

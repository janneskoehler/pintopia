import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'wall_form.dart';
import '../../services/firebase_service.dart';
import '../../services/storage_service.dart';
import '../common/sheet_bar.dart';

class AddWallSheet extends StatefulWidget {
  const AddWallSheet({super.key, required this.storageService});

  final StorageService storageService;

  static void show(BuildContext context, StorageService storageService) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => AddWallSheet(storageService: storageService),
    );
  }

  @override
  State<AddWallSheet> createState() => _AddWallSheetState();
}

class _AddWallSheetState extends State<AddWallSheet> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController idController = TextEditingController();
  final PageController pageController = PageController();
  String? selectedAssetImage;
  bool isCreatingNew = true;
  bool isSecondPage = false;
  final FirebaseService _firebaseService = FirebaseService();

  @override
  void dispose() {
    nameController.dispose();
    idController.dispose();
    pageController.dispose();
    super.dispose();
  }

  void _goToNextPage(bool createNew) {
    setState(() {
      isCreatingNew = createNew;
      isSecondPage = true;
    });
    pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _goBack() {
    if (isSecondPage) {
      setState(() => isSecondPage = false);
      pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pop(context);
    }
  }

  Future<void> _createNewBoard() async {
    if (nameController.text.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Fehlender Name'),
            content: const Text('Bitte gib einen Namen für die Pinnwand ein.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
      return;
    }

    if (selectedAssetImage == null) return;

    try {
      final wall = await _firebaseService.createWall(
        nameController.text,
        selectedAssetImage!,
      );

      await widget.storageService.addWall(wall.id, isAdmin: true);
      await widget.storageService.saveLastWallId(wall.id);

      if (mounted) {
        Navigator.pop(context);
        context.goNamed(
          'wall-detail',
          pathParameters: {'id': wall.id},
        );
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Fehler'),
            content: Text('Fehler beim Erstellen der Pinnwand: $e'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  void _openExistingBoard() async {
    if (idController.text.isEmpty) return;

    String? wallId;
    String? adminCode;

    try {
      final uri = Uri.parse(idController.text);
      final segments = uri.pathSegments;
      if (segments.length >= 2 && segments[0] == 'wall') {
        wallId = segments[1];
        adminCode = uri.queryParameters['a'];
      }
    } catch (e) {
      // Try to use direct input as wallId
      wallId = idController.text;
    }

    if (wallId == null) return;

    final wall = await _firebaseService.getWall(wallId);
    if (wall == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pinnwand nicht gefunden')),
      );
      return;
    }

    if (adminCode != null && adminCode == wall.adminCode) {
      await widget.storageService.addWall(wallId, isAdmin: true);
    } else {
      await widget.storageService.addWall(wallId);
    }

    if (mounted) {
      Navigator.pop(context);
      context.goNamed(
        'wall-detail',
        pathParameters: {'id': wallId},
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      constraints: const BoxConstraints(maxHeight: 640),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SheetBar(
            title: 'Pinnwand hinzufügen',
            leftAction: TextButton(
              onPressed: _goBack,
              style: TextButton.styleFrom(
                minimumSize: Size.zero,
                padding: const EdgeInsets.all(8),
              ),
              child: Text(isSecondPage ? 'Zurück' : 'Abbrechen'),
            ),
            rightAction: isSecondPage
                ? TextButton(
                    onPressed:
                        isCreatingNew ? _createNewBoard : _openExistingBoard,
                    style: TextButton.styleFrom(
                      minimumSize: Size.zero,
                      padding: const EdgeInsets.all(8),
                    ),
                    child: Text(isCreatingNew ? 'Erstellen' : 'Öffnen'),
                  )
                : null,
          ),
          const SizedBox(height: 16),
          Flexible(
            child: PageView(
              controller: pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                // First page: Selection
                SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 200),
                      FilledButton.tonal(
                        onPressed: () => _goToNextPage(true),
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(50),
                        ),
                        child: const Text('Neue Pinnwand erstellen'),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Row(
                          children: const [
                            Expanded(child: Divider()),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.0),
                              child: Text('oder'),
                            ),
                            Expanded(child: Divider()),
                          ],
                        ),
                      ),
                      FilledButton.tonal(
                        onPressed: () => _goToNextPage(false),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(50),
                        ),
                        child: const Text('Vorhandene Pinnwand öffnen'),
                      ),
                    ],
                  ),
                ),
                // Second page: Form
                SingleChildScrollView(
                  child: isCreatingNew
                      ? WallForm(
                          nameController: nameController,
                          selectedAssetImage: selectedAssetImage,
                          onAssetImageSelected: (assetName) {
                            setState(() {
                              selectedAssetImage = assetName;
                            });
                          },
                        )
                      : TextField(
                          controller: idController,
                          decoration: const InputDecoration(
                            labelText: 'Pinnwand Link',
                            hintText: 'https://app.pintopia.org/wall/...',
                          ),
                          onChanged: (value) {
                            try {
                              final uri = Uri.parse(value);
                              final segments = uri.pathSegments;
                              if (segments.length >= 2 &&
                                  segments[0] == 'wall') {
                                final adminCode = uri.queryParameters['a'];
                                if (adminCode != null) {
                                  // Handle admin code
                                }
                              }
                            } catch (e) {
                              // Invalid URL format
                            }
                          },
                        ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

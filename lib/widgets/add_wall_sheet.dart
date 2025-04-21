import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'wall_form.dart';
import '../services/firebase_service.dart';
import '../services/storage_service.dart';

class AddWallSheet extends StatefulWidget {
  const AddWallSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => const AddWallSheet(),
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
  final StorageService _storageService = StorageService();

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

      await _storageService.addWall(wall.id, isAdmin: true);
      await _storageService.saveLastWallId(wall.id);

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

    try {
      final boardId = idController.text;
      await _storageService.addWall(boardId);

      if (mounted) {
        Navigator.pop(context);
        context.goNamed(
          'wall-detail',
          pathParameters: {'id': boardId},
        );
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Fehler'),
            content: Text('Fehler beim Öffnen der Pinnwand: $e'),
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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 150,
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: _goBack,
                  style: TextButton.styleFrom(
                    minimumSize: Size.zero,
                    padding: const EdgeInsets.all(8),
                  ),
                  child: Text(isSecondPage ? 'Zurück' : 'Abbrechen'),
                ),
              ),
              Expanded(
                child: Text(
                  'Pinnwand hinzufügen',
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
              ),
              Container(
                width: 150,
                alignment: Alignment.centerRight,
                child: isSecondPage
                    ? TextButton(
                        onPressed: isCreatingNew
                            ? _createNewBoard
                            : _openExistingBoard,
                        style: TextButton.styleFrom(
                          minimumSize: Size.zero,
                          padding: const EdgeInsets.all(8),
                        ),
                        child: const Text('Erstellen'),
                      )
                    : const SizedBox(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Flexible(
            child: PageView(
              controller: pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                // Erste Seite: Auswahl
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
                // Zweite Seite: Formular
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
                            labelText: 'Pinnwand ID',
                            hintText: 'Geben Sie die Pinnwand ID ein',
                          ),
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

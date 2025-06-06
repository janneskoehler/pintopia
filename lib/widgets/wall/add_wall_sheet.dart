import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pintopia/services/firebase_service.dart';
import 'package:pintopia/services/storage_service.dart';
import 'package:pintopia/widgets/common/sheet_bar.dart';
import 'package:pintopia/widgets/wall/wall_form.dart';

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
  final TextEditingController wallLinkController = TextEditingController();
  final PageController pageController = PageController();
  String? selectedAssetImage;
  bool isCreatingNew = true;
  bool isSecondPage = false;
  final FirebaseService _firebaseService = FirebaseService();

  @override
  void dispose() {
    nameController.dispose();
    wallLinkController.dispose();
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

  Future<void> _createNewWall() async {
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
      if (context.mounted) {
        final dialogContext = context;
        showDialog(
          context: dialogContext,
          builder: (BuildContext dialogContext) {
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
  }

  Future<void> _openExistingWall() async {
    if (wallLinkController.text.isEmpty) return;

    String? wallId;
    String? adminCode;

    try {
      // Clean up the input by removing any '#/' prefix that might confuse the URI parser
      String cleanedInput = wallLinkController.text;
      if (cleanedInput.contains('#/')) {
        cleanedInput = cleanedInput.replaceAll('#/', '');
      }

      final uri = Uri.parse(cleanedInput);

      // Check if it's in the format https://app.pintopia.org/wall/{wallId}
      if (uri.host == 'app.pintopia.org') {
        final pathSegments = uri.pathSegments;

        if (pathSegments.length >= 2 && pathSegments[0] == 'wall') {
          wallId = pathSegments[1];
          adminCode = uri.queryParameters['a'];
        }
      }

      // Show alert if no valid wallId was found
      if (wallId == null) {
        // Show alert for incorrect URL format
        if (mounted) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Ungültiges Format'),
                content: const Text(
                  'Der Link hat nicht das richtige Format. Bitte verwende einen Link der Form: https://app.pintopia.org/#/wall/...',
                ),
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
        return;
      }
    } catch (e) {
      // Show alert for invalid URI
      if (mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Ungültiger Link'),
              content: const Text(
                'Der eingegebene Link ist ungültig. Bitte überprüfe den Link und versuche es erneut.',
              ),
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
      return;
    }

    final wall = await _firebaseService.getWall(wallId);
    if (wall == null) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Pinnwand nicht gefunden'),
            content: const Text(
              'Die angegebene Pinnwand konnte nicht gefunden werden. Bitte überprüfe den Link und versuche es erneut.',
            ),
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
    if (!mounted) return const SizedBox.shrink();
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
                        isCreatingNew ? _createNewWall : _openExistingWall,
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
                      const SizedBox(height: 200),
                      FilledButton.tonal(
                        onPressed: () => _goToNextPage(true),
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(50),
                        ),
                        child: const Text('Neue Pinnwand erstellen'),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: Row(
                          children: [
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
                          controller: wallLinkController,
                          decoration: const InputDecoration(
                            labelText: 'Pinnwand Link',
                            hintText: 'https://app.pintopia.org/#/wall/...',
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

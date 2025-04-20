import 'package:flutter/material.dart';
import 'create_board_form.dart';

class AddBoardSheet extends StatefulWidget {
  const AddBoardSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => const AddBoardSheet(),
    );
  }

  @override
  State<AddBoardSheet> createState() => _AddBoardSheetState();
}

class _AddBoardSheetState extends State<AddBoardSheet> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController idController = TextEditingController();
  final PageController pageController = PageController();
  String? selectedAssetImage;
  bool isCreatingNew = true;
  bool isSecondPage = false;

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
            content: const Text('Bitte gib einen Namen für das Board ein.'),
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
      // TODO: Implementiere Board-Erstellung
      Navigator.pop(context);
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Fehler'),
            content: Text('Fehler beim Erstellen des Boards: $e'),
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
                  'Board hinzufügen',
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
              ),
              Container(
                width: 150,
                alignment: Alignment.centerRight,
                child: isSecondPage
                    ? TextButton(
                        onPressed: isCreatingNew ? _createNewBoard : null,
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
                        child: const Text('Neues Board erstellen'),
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
                        child: const Text('Vorhandenes Board öffnen'),
                      ),
                    ],
                  ),
                ),
                // Zweite Seite: Formular
                SingleChildScrollView(
                  child: isCreatingNew
                      ? CreateBoardForm(
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
                            labelText: 'Board ID',
                            hintText: 'Geben Sie die Board ID ein',
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

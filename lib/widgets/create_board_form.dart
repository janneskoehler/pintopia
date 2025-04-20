import 'dart:math';
import 'package:flutter/material.dart';

class CreateBoardForm extends StatefulWidget {
  final TextEditingController nameController;
  final String? selectedAssetImage;
  final Function(String) onAssetImageSelected;

  const CreateBoardForm({
    super.key,
    required this.nameController,
    required this.selectedAssetImage,
    required this.onAssetImageSelected,
  });

  @override
  State<CreateBoardForm> createState() => _CreateBoardFormState();
}

class _CreateBoardFormState extends State<CreateBoardForm> {
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    if (widget.selectedAssetImage == null) {
      Future.microtask(() {
        final randomIndex =
            (1 + Random().nextInt(8)).toString().padLeft(2, '0');
        widget.onAssetImageSelected('thumb$randomIndex.jpg');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: widget.nameController,
          decoration: InputDecoration(
            labelText: 'Name des Boards',
            hintText: 'Geben Sie einen Namen ein',
            errorText: _hasError ? 'Bitte geben Sie einen Namen ein' : null,
          ),
          onChanged: (value) {
            setState(() {
              _hasError = value.isEmpty;
            });
          },
        ),
        const SizedBox(height: 16),
        if (widget.selectedAssetImage != null)
          Image.asset(
            'assets/images/${widget.selectedAssetImage}',
            height: 100,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        const SizedBox(height: 16),
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Wähle ein Bild:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          crossAxisCount: 4,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          children: [
            for (var i = 1; i <= 8; i++)
              InkWell(
                onTap: () => widget.onAssetImageSelected(
                    'thumb${i.toString().padLeft(2, '0')}.jpg'),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: widget.selectedAssetImage ==
                              'thumb${i.toString().padLeft(2, '0')}.jpg'
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.surfaceContainer,
                      width: 4,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.asset(
                      'assets/images/thumb${i.toString().padLeft(2, '0')}.jpg',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

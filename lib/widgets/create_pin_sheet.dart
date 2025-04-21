import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'dart:math';

class CreatePinSheet extends StatefulWidget {
  final String wallId;

  const CreatePinSheet({
    super.key,
    required this.wallId,
  });

  @override
  State<CreatePinSheet> createState() => _CreatePinSheetState();
}

class _CreatePinSheetState extends State<CreatePinSheet> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  final _urlController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _firebaseService = FirebaseService();
  bool _isLoading = false;
  bool _urlOnly = false;
  static const availableColors = [
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.deepPurple,
    Colors.indigo,
    Colors.blue,
    Colors.lightBlue,
    Colors.cyan,
    Colors.teal,
    Colors.green,
    Colors.lightGreen,
    Colors.lime,
    Colors.yellow,
    Colors.amber,
    Colors.orange,
    Colors.deepOrange,
    Colors.brown,
    Colors.grey,
    Colors.blueGrey,
  ];

  final _random = Random();
  late Color _selectedColor =
      availableColors[_random.nextInt(availableColors.length)];

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Abbrechen'),
                ),
                Text(
                  'Neuen Pin erstellen',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                TextButton(
                  onPressed: _isLoading ? null : _createPin,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Erstellen'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Titel',
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
                  value?.isEmpty == true ? 'Bitte Titel eingeben' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _urlController,
              decoration: const InputDecoration(
                labelText: 'URL (optional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.link),
              ),
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 8),
            CheckboxListTile(
              title: const Text('Nur URL anzeigen'),
              value: _urlOnly,
              onChanged: (value) {
                setState(() => _urlOnly = value ?? false);
              },
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),
            if (!_urlOnly) ...[
              const SizedBox(height: 16),
              TextFormField(
                controller: _bodyController,
                decoration: const InputDecoration(
                  labelText: 'Inhalt',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) =>
                    value?.isEmpty == true ? 'Bitte Inhalt eingeben' : null,
              ),
            ],
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Farbe'),
              trailing: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: _selectedColor,
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Farbe wählen'),
                    content: SingleChildScrollView(
                      child: BlockPicker(
                        pickerColor: _selectedColor,
                        onColorChanged: (color) {
                          setState(() => _selectedColor = color);
                          Navigator.of(context).pop();
                        },
                        availableColors: availableColors,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createPin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _firebaseService.createPin(
        wallId: widget.wallId,
        title: _titleController.text,
        body: _urlOnly ? '' : _bodyController.text,
        color: _selectedColor,
        url: _urlController.text.isEmpty ? null : _urlController.text,
        urlOnly: _urlOnly,
      );
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler beim Erstellen: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }
}

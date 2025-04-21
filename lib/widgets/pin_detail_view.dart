import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/attachment.dart';
import '../models/pin.dart';
import '../services/firebase_service.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class PinDetailView extends StatefulWidget {
  final Pin pin;
  final bool isAdmin;

  const PinDetailView({
    super.key,
    required this.pin,
    this.isAdmin = false,
  });

  @override
  State<PinDetailView> createState() => _PinDetailViewState();
}

class _PinDetailViewState extends State<PinDetailView> {
  bool _isEditMode = false;
  bool _isSaving = false;
  late TextEditingController _titleController;
  late TextEditingController _bodyController;
  late Color _selectedColor;
  final _firebaseService = FirebaseService();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.pin.title);
    _bodyController = TextEditingController(text: widget.pin.body);
    _selectedColor = widget.pin.color;
  }

  void _showColorPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Farbe wählen'),
        content: SingleChildScrollView(
          child: BlockPicker(
            pickerColor: _selectedColor,
            onColorChanged: (color) {
              setState(() {
                _selectedColor = color;
              });
              Navigator.of(context).pop();
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Abbrechen'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    setState(() {
      _isSaving = true;
    });

    try {
      final updatedPin = widget.pin.copyWith(
        title: _titleController.text,
        body: _bodyController.text,
        color: _selectedColor,
        updatedAt: DateTime.now(),
      );

      await _firebaseService.updatePin(updatedPin);

      setState(() {
        _isEditMode = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Fehler beim Speichern der Änderungen'),
        ),
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 800),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28.0)),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AspectRatio(
                aspectRatio: 3 / 1,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (widget.pin.attachments.isNotEmpty &&
                        widget.pin.attachments.first.type ==
                            AttachmentType.image)
                      Image.network(
                        widget.pin.attachments.first.url,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Image.asset(
                            'assets/images/thumb01.jpg',
                            fit: BoxFit.cover,
                          );
                        },
                      )
                    else
                      Image.asset(
                        'assets/images/thumb01.jpg',
                        fit: BoxFit.cover,
                      ),
                    Container(
                      decoration: BoxDecoration(
                        color: widget.pin.color.withOpacity(0.7),
                      ),
                    ),
                    if (widget.isAdmin)
                      Positioned(
                        top: 16,
                        right: 16,
                        child: _isEditMode
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    onPressed: _showColorPicker,
                                    icon: const Icon(Icons.color_lens),
                                    style: IconButton.styleFrom(
                                      backgroundColor: _selectedColor,
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        _titleController.text =
                                            widget.pin.title;
                                        _bodyController.text = widget.pin.body;
                                        _selectedColor = widget.pin.color;
                                        _isEditMode = false;
                                      });
                                    },
                                    icon: const Icon(Icons.close),
                                    style: IconButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    onPressed: _isSaving ? null : _saveChanges,
                                    icon: _isSaving
                                        ? const SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: CircularProgressIndicator(),
                                          )
                                        : const Icon(Icons.check),
                                    style: IconButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: Colors.black87,
                                    ),
                                  ),
                                ],
                              )
                            : IconButton(
                                onPressed: () {
                                  setState(() {
                                    _isEditMode = true;
                                  });
                                },
                                icon: const Icon(Icons.edit),
                                style: IconButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.black87,
                                ),
                              ),
                      ),
                    Center(
                      child: _isEditMode
                          ? TextField(
                              controller: _titleController,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineLarge
                                  ?.copyWith(color: Colors.white),
                              textAlign: TextAlign.center,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                              ),
                            )
                          : Text(
                              widget.pin.title,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineLarge
                                  ?.copyWith(color: Colors.white),
                              textAlign: TextAlign.center,
                            ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 200),
                      child: _isEditMode
                          ? TextField(
                              controller: _bodyController,
                              style: Theme.of(context).textTheme.bodyLarge,
                              maxLines: null,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                              ),
                            )
                          : Text(
                              widget.pin.body,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                    ),
                    if (widget.pin.url != null) ...[
                      const SizedBox(height: 16.0),
                      ElevatedButton.icon(
                        onPressed: () async {
                          final url = Uri.parse(widget.pin.url!);
                          if (await canLaunchUrl(url)) {
                            await launchUrl(url);
                          }
                        },
                        icon: const Icon(Icons.link),
                        label: const Text('Link öffnen'),
                      ),
                    ],
                    const SizedBox(height: 32.0),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

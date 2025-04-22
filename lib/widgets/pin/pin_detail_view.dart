import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/attachment.dart';
import '../../models/pin.dart';
import '../../services/firebase_service.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class PinDetailView extends StatefulWidget {
  final Pin pin;
  final bool isAdmin;
  final bool initialEditMode;

  const PinDetailView({
    super.key,
    required this.pin,
    this.isAdmin = false,
    this.initialEditMode = false,
  });

  @override
  State<PinDetailView> createState() => _PinDetailViewState();
}

class _PinDetailViewState extends State<PinDetailView> {
  late bool _isEditMode;
  bool _isSaving = false;
  late TextEditingController _titleController;
  late TextEditingController _bodyController;
  late TextEditingController _urlController;
  late TextEditingController _urlLabelController;
  late Color _selectedColor;
  late bool _selectedDirectLink;
  final _firebaseService = FirebaseService();
  late Stream<Pin> _pinStream;

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.initialEditMode;
    _initializeControllers(widget.pin);
    _pinStream =
        _firebaseService.getPinStream(widget.pin.wallId, widget.pin.id);
  }

  void _initializeControllers(Pin pin) {
    _titleController = TextEditingController(text: pin.title);
    _bodyController = TextEditingController(text: pin.body);
    _urlController = TextEditingController(text: pin.url ?? '');
    _urlLabelController = TextEditingController(text: pin.urlLabel ?? '');
    _selectedColor = pin.color;
    _selectedDirectLink = pin.directLink;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    _urlController.dispose();
    _urlLabelController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    setState(() {
      _isSaving = true;
    });

    try {
      final title = _titleController.text.trim();
      if (title.isEmpty) {
        throw Exception('Bitte geben Sie einen Titel ein');
      }

      final updatedPin = widget.pin.copyWith(
        title: title,
        body: _bodyController.text,
        color: _selectedColor,
        url: _urlController.text.isEmpty ? null : _urlController.text,
        urlLabel:
            _urlLabelController.text.isEmpty ? null : _urlLabelController.text,
        directLink: _selectedDirectLink,
        updatedAt: DateTime.now(),
      );

      if (widget.pin.isNew) {
        await _firebaseService.createPin(updatedPin);
      } else {
        await _firebaseService.updatePin(updatedPin);
      }

      if (context.mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (context.mounted) {
        await showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: const Text('Fehler beim Speichern'),
            content: Text(e.toString()),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.initialEditMode && widget.pin.isNew) {
      return _buildPinDetail(widget.pin);
    }

    return StreamBuilder<Pin>(
      stream: _pinStream,
      initialData: widget.pin,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Fehler beim Laden des Pins'));
        }

        final pin = snapshot.data!;
        return _buildPinDetail(pin);
      },
    );
  }

  Widget _buildPinDetail(Pin pin) {
    if (!_isEditMode) {
      _initializeControllers(pin);
    }

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
                    if (pin.attachments.isNotEmpty &&
                        pin.attachments.first.type == AttachmentType.image)
                      Image.network(
                        pin.attachments.first.url,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Image.asset(
                            'assets/images/thumb00.png',
                            fit: BoxFit.cover,
                          );
                        },
                      )
                    else
                      Image.asset(
                        'assets/images/thumb00.png',
                        fit: BoxFit.cover,
                      ),
                    Container(
                      decoration: BoxDecoration(
                        color: _selectedColor.withOpacity(0.7),
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
                                      backgroundColor: Colors.white,
                                      foregroundColor: _selectedColor,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  if (!widget.pin.isNew) ...[
                                    IconButton(
                                      onPressed: _handleDelete,
                                      icon: const Icon(Icons.delete),
                                      style: IconButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        foregroundColor: Colors.red,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                  ],
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
                                  const SizedBox(width: 8),
                                  IconButton(
                                    onPressed: () => _handleClose(pin),
                                    icon: const Icon(Icons.close),
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
                                hintText: 'Titel',
                                hintStyle: TextStyle(
                                  color: Colors.white54,
                                ),
                              ),
                            )
                          : Text(
                              pin.title,
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
                    if (_isEditMode) ...[
                      SwitchListTile(
                        title: const Text('Direkt-Link'),
                        subtitle: const Text(
                          'Beim Klick auf den Pin wird der Link direkt geöffnet, '
                          'ohne den Pin-Inhalt anzuzeigen.',
                        ),
                        value: _selectedDirectLink,
                        onChanged: (bool value) {
                          setState(() {
                            _selectedDirectLink = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
                    if (!_isEditMode || !_selectedDirectLink) ...[
                      ConstrainedBox(
                        constraints: const BoxConstraints(minHeight: 120),
                        child: _isEditMode
                            ? TextField(
                                controller: _bodyController,
                                style: Theme.of(context).textTheme.bodyLarge,
                                minLines: 4,
                                maxLines: null,
                                textAlignVertical: TextAlignVertical.top,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  hintText: 'Inhalt',
                                ),
                              )
                            : Text(
                                pin.body,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                      ),
                    ],
                    if (_isEditMode || pin.url != null || pin.directLink) ...[
                      const SizedBox(height: 16.0),
                      if (_isEditMode) ...[
                        TextField(
                          controller: _urlController,
                          decoration: const InputDecoration(
                            labelText: 'Link (optional)',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        if (!_selectedDirectLink) ...[
                          const SizedBox(height: 16.0),
                          TextField(
                            controller: _urlLabelController,
                            decoration: const InputDecoration(
                              labelText: 'Link Beschriftung (optional)',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ],
                      ] else
                        ElevatedButton.icon(
                          onPressed: () async {
                            try {
                              final url = Uri.parse(pin.url!);
                              if (await canLaunchUrl(url)) {
                                await launchUrl(url);
                              } else {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'Der Link konnte nicht geöffnet werden'),
                                    ),
                                  );
                                }
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Ungültiger Link'),
                                  ),
                                );
                              }
                            }
                          },
                          icon: const Icon(Icons.link),
                          label: Text(pin.urlLabel ?? 'Link öffnen'),
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

  void _handleClose(Pin pin) {
    if (widget.initialEditMode) {
      Navigator.of(context).pop();
    } else {
      setState(() {
        _titleController.text = pin.title;
        _bodyController.text = pin.body;
        _urlController.text = pin.url ?? '';
        _urlLabelController.text = pin.urlLabel ?? '';
        _selectedColor = pin.color;
        _selectedDirectLink = pin.directLink;
        _isEditMode = false;
      });
    }
  }

  Future<void> _handleDelete() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Pin löschen'),
        content: const Text('Möchten Sie diesen Pin wirklich löschen?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Löschen',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (shouldDelete == true && context.mounted) {
      try {
        Navigator.of(context).pop(); // Schließe zuerst den Detail-Dialog
        await _firebaseService.deletePin(widget.pin);
      } catch (e) {
        if (context.mounted) {
          await showDialog(
            context: context,
            builder: (BuildContext context) => AlertDialog(
              title: const Text('Fehler'),
              content: Text(e.toString()),
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
}

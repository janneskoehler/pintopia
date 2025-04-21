import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CopyableLink extends StatelessWidget {
  final String url;

  const CopyableLink({
    super.key,
    required this.url,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12.0,
              vertical: 8.0,
            ),
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).dividerColor,
              ),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Text(
              url,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.copy),
          onPressed: () {
            Clipboard.setData(ClipboardData(text: url));
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Erfolg'),
                content: const Text('Link in die Zwischenablage kopiert'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

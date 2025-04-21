import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/attachment.dart';
import '../models/pin.dart';

class PinDetailView extends StatelessWidget {
  final Pin pin;
  final bool isAdmin;

  const PinDetailView({
    super.key,
    required this.pin,
    this.isAdmin = false,
  });

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
                    if (pin.attachments.isNotEmpty &&
                        pin.attachments.first.type == AttachmentType.image)
                      Image.network(
                        pin.attachments.first.url,
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
                        color: pin.color.withOpacity(0.7),
                      ),
                    ),
                    if (isAdmin)
                      Positioned(
                        top: 16,
                        right: 16,
                        child: IconButton(
                          onPressed: () {
                            // TODO: Implement edit functionality
                          },
                          icon: const Icon(Icons.edit),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black87,
                          ),
                        ),
                      ),
                    Center(
                      child: Text(
                        pin.title,
                        style:
                            Theme.of(context).textTheme.headlineLarge?.copyWith(
                                  color: Colors.white,
                                ),
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
                      child: Text(
                        pin.body,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                    if (pin.url != null) ...[
                      const SizedBox(height: 16.0),
                      ElevatedButton.icon(
                        onPressed: () async {
                          final url = Uri.parse(pin.url!);
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

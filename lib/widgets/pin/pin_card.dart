import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/pin.dart';
import '../../models/attachment.dart';
import 'pin_detail_view.dart';

class PinCard extends StatelessWidget {
  final Pin pin;
  final bool isAdmin;
  final bool isEditMode;

  const PinCard({
    super.key,
    required this.pin,
    this.isAdmin = false,
    this.isEditMode = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _handleTap(context),
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 8.0,
        shadowColor: Colors.black.withOpacity(0.4),
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
                color: pin.color.withOpacity(0.7),
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (pin.directLink) ...[
                      const Icon(
                        Icons.link,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 8),
                    ],
                    Flexible(
                      child: Text(
                        pin.title,
                        style:
                            Theme.of(context).textTheme.headlineLarge?.copyWith(
                                  color: Colors.white,
                                ),
                        textAlign: TextAlign.center,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (isAdmin && isEditMode)
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  icon: const Icon(Icons.edit),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black87,
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => Dialog(
                        child: PinDetailView(
                          pin: pin,
                          isAdmin: true,
                          initialEditMode: true,
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleTap(BuildContext context) async {
    if (pin.directLink && pin.url != null) {
      final url = Uri.parse(pin.url!);
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      }
    } else {
      showDialog(
        context: context,
        builder: (context) => Dialog(
          child: PinDetailView(
            pin: pin,
            isAdmin: isAdmin,
          ),
        ),
      );
    }
  }
}

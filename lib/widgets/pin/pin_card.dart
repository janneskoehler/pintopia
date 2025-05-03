import 'package:flutter/material.dart';
import 'package:pintopia/models/attachment.dart';
import 'package:pintopia/models/pin.dart';
import 'package:pintopia/services/device_service.dart';
import 'package:pintopia/widgets/pin/pin_detail_view.dart';
import 'package:url_launcher/url_launcher.dart';

class PinCard extends StatelessWidget {
  final Pin pin;
  final bool isAdmin;
  final bool isEditMode;
  final VoidCallback? onLongPress;
  final bool isNew;

  const PinCard({
    super.key,
    required this.pin,
    this.isAdmin = false,
    this.isEditMode = false,
    this.onLongPress,
    this.isNew = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: !isEditMode ? () => _handleTap(context) : null,
      onLongPress: isAdmin ? onLongPress : null,
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 8.0,
        shadowColor: Colors.black.withValues(alpha: 0.4),
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
                color: pin.color.withValues(alpha: 0.7),
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
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
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
                    DeviceService.showResponsiveBottomSheet(
                      context: context,
                      child: PinDetailView(
                        pin: pin,
                        isAdmin: true,
                        initialEditMode: true,
                      ),
                    );
                  },
                ),
              ),
            if (isNew && !isEditMode)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 2,
                    ),
                  ),
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
      // Use the responsive bottom sheet service to show the pin detail
      await DeviceService.showResponsiveBottomSheet(
        context: context,
        child: PinDetailView(
          pin: pin,
          isAdmin: isAdmin,
        ),
      );
    }
  }
}

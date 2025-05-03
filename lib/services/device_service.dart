// ignore_for_file: avoid_classes_with_only_static_members

import 'package:flutter/material.dart';

class DeviceService {
  /// Checks if the current device is considered small based on screen width
  /// Small devices are defined as having a width less than 600 logical pixels
  static bool isSmallDevice(BuildContext context) {
    return MediaQuery.of(context).size.width < 600;
  }

  /// Checks if the current device is in portrait orientation
  static bool isPortrait(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.portrait;
  }

  /// Checks if the current device is a tablet based on screen width
  /// Tablets are defined as having a width of 600 logical pixels or more
  static bool isTablet(BuildContext context) {
    return MediaQuery.of(context).size.width >= 600;
  }

  /// Shows a bottom sheet or full-height modal based on device size
  /// On small devices, shows the content as a full-height modal
  /// On larger devices, shows the content as a standard bottom sheet
  static Future<T?> showResponsiveBottomSheet<T>({
    required BuildContext context,
    required Widget child,
    bool isScrollControlled = true,
    bool isDismissible = true,
    bool enableDrag = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      useSafeArea: true,
      builder: (context) {
        final isSmall = isSmallDevice(context);
        // On small devices, use almost full screen height
        return Container(
          height: isSmall ? MediaQuery.of(context).size.height * 0.9 : null,
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: child,
        );
      },
    );
  }
}

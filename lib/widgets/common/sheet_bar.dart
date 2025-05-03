import 'package:flutter/material.dart';

class SheetBar extends StatelessWidget {
  final String title;
  final Widget? leftAction;
  final Widget? rightAction;

  const SheetBar({
    super.key,
    required this.title,
    this.leftAction,
    this.rightAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          width: 100,
          alignment: Alignment.centerLeft,
          child: leftAction ?? const SizedBox(),
        ),
        Expanded(
          child: Text(
            title,
            style: MediaQuery.of(context).size.width < 800
                ? Theme.of(context).textTheme.titleMedium
                : Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Container(
          width: 100,
          alignment: Alignment.centerRight,
          child: rightAction ?? const SizedBox(),
        ),
      ],
    );
  }
}

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
          width: 150,
          alignment: Alignment.centerLeft,
          child: leftAction ?? const SizedBox(),
        ),
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
        ),
        Container(
          width: 150,
          alignment: Alignment.centerRight,
          child: rightAction ?? const SizedBox(),
        ),
      ],
    );
  }
}

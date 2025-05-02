import 'package:flutter/material.dart';

class AddWallCard extends StatelessWidget {
  final void Function(BuildContext) onTap;

  const AddWallCard({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => onTap(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: ColoredBox(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Icon(
                  Icons.add,
                  size: 48,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12.0),
                child: Center(
                  child: Text(
                    'Pinnwand hinzufügen',
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../models/wall.dart';
import '../widgets/add_board_sheet.dart';

class WallListScreen extends StatelessWidget {
  // Beispieldaten - später durch echte Daten ersetzen
  final List<Wall> walls = [
    Wall(
      id: 'w4k2m9p8n5x7j3h1v6q0',
      title: 'Erste Wand',
      imageUrl:
          'https://cdn.dribbble.com/userupload/42988464/file/original-75b938f17c8abe352125452d791106cd.png?resize=752x&vertical=center',
    ),
    Wall(
      id: 'a7b4c1d8e5f2g9h6i3j0',
      title: 'Zweite Wand',
      imageUrl:
          'https://cdn.dribbble.com/userupload/42986776/file/original-d409b0853dfdbd0dd483adb7782d1595.png?resize=2048x1536&vertical=center',
    ),
    Wall(
      id: 'r5t2y9u6i3o0p7l4k1m8',
      title: 'Dritte Wand kafen afneifoafnifnsfuef sodf',
      imageUrl:
          'https://cdn.dribbble.com/userupload/42982895/file/original-1f9e8ad2cbb2db4a29bed8fde6f4eba4.jpg?resize=2048x1490&vertical=center',
    ),
  ];

  WallListScreen({super.key});

  void _showBoardSheet(BuildContext context) {
    AddBoardSheet.show(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pinboards'),
      ),
      body: GridView.extent(
        padding: const EdgeInsets.all(8.0),
        maxCrossAxisExtent: 400,
        childAspectRatio: 4 / 3,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        children: [
          ...walls.map((wall) => Card(
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => _showBoardSheet(context),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AspectRatio(
                        aspectRatio: 16 / 9,
                        child: wall.assetImageName != null
                            ? Image.asset(
                                'assets/images/${wall.assetImageName}',
                                fit: BoxFit.cover,
                              )
                            : Image.network(
                                wall.imageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Center(
                                    child: Icon(
                                      Icons.image_not_supported,
                                      size: 50,
                                    ),
                                  );
                                },
                              ),
                      ),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12.0),
                          child: Center(
                            child: Text(
                              wall.title,
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
              )),
          // Neues Board Element
          Card(
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => _showBoardSheet(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image.asset(
                      'assets/images/pinboard.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12.0),
                      child: Center(
                        child: Text(
                          'Board hinzufügen',
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
          ),
        ],
      ),
    );
  }
}

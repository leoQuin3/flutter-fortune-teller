import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Categories extends ConsumerStatefulWidget {
  const Categories({super.key});

  static const routeName = '/categoryPage';

  @override
  ConsumerState<Categories> createState() => _CategoriesState();
}

class _CategoriesState extends ConsumerState<Categories> {
  final Map<int, bool> _hoverStates = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Test GridView'),
      ),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1.5,
        ),
        padding: EdgeInsets.all(10),
        itemCount: 4,
        itemBuilder: (context, index) {
          return MouseRegion(
            onEnter: (_) => setState(() => _hoverStates[index] = true),
            onExit: (_) => setState(() => _hoverStates[index] = false),
            child: GestureDetector(
              onTap: () {
                if (index == 0) {
                  Navigator.pushNamed(context, '/define screen');
                } else if (index == 1) {
                  Navigator.pushNamed(context, '/defineScreen2');
                }
              },
              child: Stack(
                alignment: Alignment.center,
                children: [
                  _hoverStates[index] == true
                      ? Image.asset(
                          'assets/gif${index + 1}.gif',
                          fit: BoxFit.cover,
                        )
                      : Icon(
                          Icons.image,
                          size: 50,
                          color: Colors.black45,
                        ),
                  Positioned(
                    child: Text(
                      'Box ${index + 1}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        backgroundColor: Colors.black54,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

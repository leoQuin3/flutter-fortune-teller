import 'package:csc322_starter_app/widgets/general/categories.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CategoriesScreen extends ConsumerStatefulWidget {
  const CategoriesScreen({super.key});

  static const routeName = '/categoryPage';

  @override
  ConsumerState<CategoriesScreen> createState() => _CategoriesState();
}

class _CategoriesState extends ConsumerState<CategoriesScreen> {
  final Map<int, bool> _hoverStates = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Categories', style: TextStyle(color: Theme.of(context).colorScheme.onPrimary)),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: <Color>[
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.secondary,
          ], begin: Alignment.topCenter, end: Alignment.bottomCenter),
        ),
        child: GridView.builder(
          padding: EdgeInsets.symmetric(vertical: 50, horizontal: 20),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 25,
            mainAxisSpacing: 45,
            childAspectRatio: 1.5,
          ),
          itemCount: 6,
          itemBuilder: (context, index) {
            // Get category styling
            Color categoryColor = getCategoryColor(Categories.values[index]);
            String categoryText = getCategoryName(Categories.values[index]);
            IconData categoryIcon = getCategoryIcon(Categories.values[index]);

            return GestureDetector(
              onTap: () {},
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      Theme.of(context).colorScheme.onSurface.withAlpha(200),
                      Theme.of(context).colorScheme.onSurface,
                    ],
                    radius: 1,
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      categoryIcon,
                      color: categoryColor,
                    ),
                    SizedBox(width: 14),
                    Text(
                      categoryText,
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

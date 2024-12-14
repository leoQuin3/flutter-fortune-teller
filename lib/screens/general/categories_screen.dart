import 'package:csc322_starter_app/main.dart';
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Filter By Category',
            style: TextStyle(color: Theme.of(context).colorScheme.onPrimary)),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        iconTheme: IconThemeData(
          color: Theme.of(context).colorScheme.onPrimary,
        ),
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
          itemCount: 8,
          itemBuilder: (context, index) {
            if (index == Categories.values.length) {
              return _lastGridItem();
            } else {
              return _buildCategoryGridItem(index);
            }
          },
        ),
      ),
    );
  }

  Widget _buildCategoryGridItem(int index) {
    // Get category styling
    Color categoryColor = getCategoryColor(Categories.values[index]);
    String categoryText = getFormattedCategoryName(Categories.values[index]);
    IconData categoryIcon = getCategoryIcon(Categories.values[index]);

    return GestureDetector(
      // Filter fortunes by category
      onTap: () {
        var fortuneProvider = ref.read(providerFortunes);
        fortuneProvider.setFilter(Categories.values[index]);
        fortuneProvider.enableFilter(true);
        Navigator.of(context).pop();
      },
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
  }

  Widget _lastGridItem() => GestureDetector(
        // Filter fortunes by category
        onTap: () {
          var fortuneProvider = ref.read(providerFortunes);
          fortuneProvider.enableFilter(false);
          Navigator.of(context).pop();
        },
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
              // Icon(
              //   Icons.auto_awesome,
              //   color: Colors.white,
              // ),
              // SizedBox(width: 14),
              Text(
                'All',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ],
          ),
        ),
      );
}

import 'package:flutter/material.dart';

// *****************************************
// Bottom Navigation bar (James)
// *****************************************
class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
            icon: Icon(Icons.home), label: 'Fortune Teller'),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_circle),
          label: 'Saved Fortunes',
        ),
      ],
      backgroundColor: Theme.of(context).colorScheme.onSurface,
      unselectedItemColor: Theme.of(context).colorScheme.surface.withOpacity(0.5),
      selectedItemColor: Theme.of(context).colorScheme.primary,
    );
  }
}

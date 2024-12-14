// -----------------------------------------------------------------------
// Filename: widget_primary_scaffold.dart
// Original Author: Dan Grissom
// Creation Date: 5/27/2024
// Copyright: (c) 2024 CSC322
// Description: This file contains the primary scaffold for the app.

//////////////////////////////////////////////////////////////////////////
// Imports
//////////////////////////////////////////////////////////////////////////
// Dart imports

// Flutter external package imports
import 'package:csc322_starter_app/main.dart';
import 'package:csc322_starter_app/screens/general/categories_screen.dart';
import 'package:csc322_starter_app/widgets/general/categories.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// App relative file imports
import '../../screens/general/screen_fortune_list.dart';
import '../../screens/general/screen_home.dart';
import 'package:go_router/go_router.dart';
import 'widget_app_drawer.dart';

// Custom file imports
import 'package:csc322_starter_app/widgets/general/bottom_nav_bar.dart';

//////////////////////////////////////////////////////////////////////////
// Localized provider for the current tab index
//////////////////////////////////////////////////////////////////////////
final providerPrimaryBottomNavTabIndex = StateProvider<int>((ref) => 0);

// **********************************************************
// Main scaffold that holds everything together
// **********************************************************
class WidgetPrimaryScaffold extends ConsumerStatefulWidget {
  static const routeName = "/home";

  const WidgetPrimaryScaffold({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  ConsumerState<WidgetPrimaryScaffold> createState() =>
      _WidgetPrimaryScaffoldState();
}

//////////////////////////////////////////////////////////////////////////
// The actual STATE which is managed by the above widget.
//////////////////////////////////////////////////////////////////////////
class _WidgetPrimaryScaffoldState extends ConsumerState<WidgetPrimaryScaffold> {
  // The "instance variables" managed in this state
  var _isInit = true;
  late Image shareImageFocus;
  late Image shareImageLightUnfocused;
  late Image shareImageDarkUnfocused;
  CupertinoTabController controller = CupertinoTabController();

  @override
  void initState() {
    super.initState();
  }

  ////////////////////////////////////////////////////////////////////////
  // Gets the current state of the providers for consumption on
  // this page
  ////////////////////////////////////////////////////////////////////////
  _init() async {
    // Get providers
  }

  ////////////////////////////////////////////////////////////////
  // Runs the following code once upon initialization
  ////////////////////////////////////////////////////////////////
  @override
  void didChangeDependencies() {
    // If first time running this code, update provider settings
    if (_isInit) {
      _init();
    }

    // Now initialized; run super method
    _isInit = false;
    super.didChangeDependencies();
  }

  ////////////////////////////////////////////////////////////////
  // Describes menu options for the chat screen
  ////////////////////////////////////////////////////////////////
  List<PopupMenuEntry<String>> _getMenu() {
    return <PopupMenuEntry<String>>[
      //////////////////////////////////////////////////////////
      // Edit-style options
      //////////////////////////////////////////////////////////
      PopupMenuItem(
        child: Row(
          children: [
            Icon(Icons.share, size: 25),
            SizedBox(width: 10),
            Text("Share"),
          ],
        ),
        value: "Share",
      ),
      PopupMenuItem(
        child: Row(
          children: [
            Icon(Icons.edit, size: 25),
            SizedBox(width: 10),
            Text("Rename"),
          ],
        ),
        value: "Rename",
      ),
      PopupMenuItem(
        child: Row(
          children: [
            Icon(Icons.delete, size: 25),
            SizedBox(width: 10),
            Text("Delete"),
          ],
        ),
        value: "Delete",
      ),
    ];
  }

  ////////////////////////////////////////////////////////////////
  // Takes in the current tab index and returns the appropriate
  // screen to display.
  ////////////////////////////////////////////////////////////////
  Widget _getScreenToDisplay(int currentTabIndex) {
    // Show main screen
    if (currentTabIndex == BottomNavSelection.HOME_SCREEN.index)
      return ScreenHome();
    // Show saved fortunes
    else if (currentTabIndex == BottomNavSelection.ALTERNATE_SCREEN.index)
      return ScreenFortuneList();
    else
      return ScreenHome();
  }

  ////////////////////////////////////////////////////////////////
  // Takes in the current tab index and returns the appropriate
  // app bar widget to display.
  ////////////////////////////////////////////////////////////////
  Widget _getAppBarTitle(int currentTabIndex) {
    if (currentTabIndex == BottomNavSelection.HOME_SCREEN.index)
      return Text("Home",
          style: TextStyle(color: Theme.of(context).colorScheme.onPrimary));
    else
      return Text("Saved Fortunes",
          style: TextStyle(color: Theme.of(context).colorScheme.onPrimary));
  }

  ////////////////////////////////////////////////////////////////
  // Takes in the current tab index and returns the appropriate
  // actions to display in the app bar (right side).
  ////////////////////////////////////////////////////////////////
  List<Widget>? _getAppBarActions(int currentTabIndex) {
    // Get fortunes provider
    var fortunesProvider = ref.watch(providerFortunes);

    // Initialize the actions
    List<List<Widget>> actions = [
      [
        IconButton(
          onPressed: () {},
          icon: Icon(Icons.settings),
        ),
      ],
      [
        Stack(
          children: [
            IconButton(
              onPressed: () {
                context.push(CategoriesScreen.routeName);
              },
              icon: Icon(
                Icons.filter_list,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
            if (fortunesProvider.isFiltered)
              Positioned(
                child: Icon(
                  getCategoryIcon(fortunesProvider.currentCategoryFilter),
                  size: 16,
                ),
                bottom: 0,
                right: 4,
              ),
          ],
        ),
      ]
    ];

    // If not chat tab, return null (no actions)
    return actions.isEmpty ? null : actions[currentTabIndex];
  }

  ////////////////////////////////////////////////////////////////
  // Primary Flutter method overridden which describes the layout
  // and bindings for this widget.
  ////////////////////////////////////////////////////////////////
  @override
  Widget build(BuildContext context) {
    // Get providers
    final currentTabIndex = ref.watch(providerPrimaryBottomNavTabIndex);

    // Return the scaffold
    return Scaffold(
      appBar: AppBar(
        actions: _getAppBarActions(currentTabIndex),
        title: _getAppBarTitle(currentTabIndex),
        backgroundColor: Theme.of(context).colorScheme.primary,
        centerTitle: true,
        iconTheme:
            IconThemeData(color: Theme.of(context).colorScheme.onPrimary),
      ),

      // *************************
      // Drawer with settings
      // *************************
      drawer: WidgetAppDrawer(),

      // ********************************************
      // Main content (Home screen, Alternate screen)
      // ********************************************
      body: _getScreenToDisplay(currentTabIndex),

      // **************************************
      // Bottom navigator bar
      // **************************************
      bottomNavigationBar: BottomNavBar(
        currentIndex: currentTabIndex,
        onTap: (index) {
          ref.read(providerPrimaryBottomNavTabIndex.notifier).state = index;
        },
      ),
    );
  }
}

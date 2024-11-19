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
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// App relative file imports
import '../../screens/general/screen_alternate.dart';
import '../../screens/general/screen_home.dart';
import 'widget_primary_app_bar.dart';
import 'widget_app_drawer.dart';
import '../../main.dart';

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
  // int _currentTabIndex = 0;
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
    if (currentTabIndex == BottomNavSelection.HOME_SCREEN.index)
      return ScreenHome();
    else if (currentTabIndex == BottomNavSelection.ALTERNATE_SCREEN.index)
      return ScreenAlternate();
    else
      return ScreenHome();
  }

  ////////////////////////////////////////////////////////////////
  // Takes in the current tab index and returns the appropriate
  // app bar widget to display.
  ////////////////////////////////////////////////////////////////
  Widget _getAppBarTitle(int currentTabIndex) {
    if (currentTabIndex == BottomNavSelection.HOME_SCREEN.index)
      return Text("Home");
    else
      return Text("Alternate");
  }

  ////////////////////////////////////////////////////////////////
  // Takes in the current tab index and returns the appropriate
  // actions to display in the app bar (right side).
  ////////////////////////////////////////////////////////////////
  List<Widget>? _getAppBarActions(int currentTabIndex) {
    // Initialize the actions
    List<Widget> actions = [];

    // If not chat tab, return null (no actions)
    return actions.isEmpty ? null : actions;
  }

  ////////////////////////////////////////////////////////////////
  // Primary Flutter method overriden which describes the layout
  // and bindings for this widget.
  ////////////////////////////////////////////////////////////////
  @override
  Widget build(BuildContext context) {
    // Get providers
    final currentTabIndex = ref.watch(providerPrimaryBottomNavTabIndex);

    // Return the scaffold
    return Scaffold(
      appBar: WidgetPrimaryAppBar(
        // Add a plus icon followed by the 3-dots vertical icon on the right
        actionButtons: _getAppBarActions(currentTabIndex),
        title: _getAppBarTitle(currentTabIndex),
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

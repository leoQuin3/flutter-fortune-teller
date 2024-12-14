// -----------------------------------------------------------------------
// Filename: screen_alternative.dart
// Original Author: Dan Grissom
// Creation Date: 10/31/2024
// Copyright: (c) 2024 CSC322
// Description: This file contains the screen for a dummy alternative screen
//               history screen.

//////////////////////////////////////////////////////////////////////////
// Imports
//////////////////////////////////////////////////////////////////////////

// Flutter imports
import 'dart:async';

// Flutter external package imports
import 'package:csc322_starter_app/main.dart';
import 'package:csc322_starter_app/models/fortune.dart';
import 'package:csc322_starter_app/providers/provider_fortunes.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

// Custom file imports
import 'package:csc322_starter_app/widgets/general/fortune_list_item.dart';

// ***************************************************
// Show list of all fortunes saved
// ***************************************************
class ScreenFortuneList extends ConsumerStatefulWidget {
  static const routeName = '/alternative';

  @override
  ConsumerState<ScreenFortuneList> createState() => _ScreenAlternateState();
}

//////////////////////////////////////////////////////////////////////////
// The actual STATE which is managed by the above widget.
//////////////////////////////////////////////////////////////////////////
class _ScreenAlternateState extends ConsumerState<ScreenFortuneList> {
  // The "instance variables" managed in this state
  bool _isInit = true;

  ////////////////////////////////////////////////////////////////
  // Runs the following code once upon initialization
  ////////////////////////////////////////////////////////////////
  @override
  void didChangeDependencies() {
    // If first time running this code, update provider settings
    if (_isInit) {
      _init();
      _isInit = false;
      super.didChangeDependencies();
    }
  }

  @override
  void initState() {
    super.initState();
  }

  ////////////////////////////////////////////////////////////////
  // Initializes state variables and resources
  ////////////////////////////////////////////////////////////////
  Future<void> _init() async {}

  // ****************************************************
  // Show list of all fortunes saved to and from database
  // ****************************************************
  @override
  Widget build(BuildContext context) {
    var fortuneProvider = ref.read(providerFortunes.notifier);
    List<Fortune> fortuneList;

    fortuneProvider.fetchFortunesFromProfile();

    if (fortuneProvider.isFiltered) {
      fortuneList = ref.watch(providerFortunes).getFilteredFortunes();
    } else {
      fortuneList = ref.watch(providerFortunes).fortunes;
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.secondary,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: RefreshIndicator(
          onRefresh: fortuneProvider.fetchFortunesFromProfile,
          child: ListView.builder(
            itemCount: fortuneList.length,
            itemBuilder: (context, index) => Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Dismissible(
                    key: Key(fortuneList[index].id),
                    direction: DismissDirection.endToStart,
                    child: FortuneListItem(
                      text: fortuneList[index].text,
                      category: fortuneList[index].category,
                    ),

                    // Red background when deleting
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.only(right: 20),
                      color: Colors.red,
                      child: Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed: (direction) {
                      Fortune deletedFortune = fortuneList[index];
                      ProviderFortunes readFortuneProvider =
                          ref.read(providerFortunes.notifier);

                      readFortuneProvider.removeFortune(deletedFortune);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              const Text('Fortune deleted.'),
                              Spacer(),
                              TextButton(
                                onPressed: () {
                                  readFortuneProvider.addFortuneAtIndex(
                                      deletedFortune, index);
                                },
                                child: const Text(
                                  'Undo',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

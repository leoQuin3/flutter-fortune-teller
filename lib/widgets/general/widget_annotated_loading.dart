// -----------------------------------------------------------------------
// Filename: widget_annotated_loading.dart
// Original Author: Dan Grissom
// Creation Date: 5/27/2024
// Copyright: (c) 2024 CSC322
// Description: This file contains a widget for displaying a loading
//              animation with a timeout feature.

////////////////////////////////////////////////////////////////////////////////////////////
// Imports
////////////////////////////////////////////////////////////////////////////////////////////
// Dart imports
import 'dart:async';

// Flutter external package imports
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

// App relative file imports
import '../../main.dart';
import '../../util/logging/app_logger.dart';
import '../../providers/provider_auth.dart';
import '../../util/message_display/snackbar.dart';

//////////////////////////////////////////////////////////////////
// StateLESS widget which only has data that is initialized when
// widget is created (cannot update except when re-created).
//////////////////////////////////////////////////////////////////
class WidgetAnnotatedLoading extends ConsumerStatefulWidget {
  // Final variables
  final String loadingText;
  final double height;
  final bool timeOutEnabled;
  final int timeOutSecs;
  final String timeOutTextPrefix;
  final int timeOutCountdownBeginsAtSecs;
  final bool timeOutSignsOut;
  final bool quietTimeOut;
  final Function()? timeOutCallback;
  final List<String>? loadingTexts;

  // Constructor
  const WidgetAnnotatedLoading({
    this.height = 250,
    this.loadingText = "",
    this.timeOutEnabled = false,
    this.timeOutSecs = 15,
    this.timeOutTextPrefix = "Loading",
    this.timeOutCountdownBeginsAtSecs = 5,
    this.timeOutSignsOut = false,
    this.timeOutCallback,
    this.quietTimeOut = false,
    this.loadingTexts,
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState<WidgetAnnotatedLoading> createState() => _WidgetAnnotatedLoading();
}

//////////////////////////////////////////////////////////////////
// The actual STATE which is managed by the above widget.
//////////////////////////////////////////////////////////////////
class _WidgetAnnotatedLoading extends ConsumerState<WidgetAnnotatedLoading> {
  // Instance variables being managed by state
  var _isInit = true;
  late ProviderAuth _providerAuth;
  Timer? _timeoutTimer;
  int _countDownSecs = 0;
  late int _timeoutSecs = 0;
  int _displayIndex = 0;

  // Static variables
  static String _lastLoadingText = ""; // Used if widget being re-used instead of disposed

  ////////////////////////////////////////////////////////////////
  // Runs when widget is disposed
  ////////////////////////////////////////////////////////////////
  @override
  void dispose() {
    // Cancel timer since widget is being disposed
    _timeoutTimer?.cancel();
    AppLogger.print("TIMER CANCELLED @ ${_timeoutSecs - _countDownSecs}/$_timeoutSecs (${widget.loadingText}) ");

    super.dispose();
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
  // Gets the current state of the providers for consumption on
  // this page
  //
  // NOTE: See the class comments above about the timer not being
  //       cancelled when a new AnnotatedLoadingWidget is created.
  ////////////////////////////////////////////////////////////////
  _init() async {
    // Get the necessary providers
    _providerAuth = ref.watch(providerAuth);

    // Set a timeout timer
    if (widget.timeOutEnabled) {
      // Initialize the timer
      _countDownSecs = widget.timeOutSecs;
      _timeoutSecs = widget.timeOutSecs;
      _lastLoadingText = widget.loadingText;
      AppLogger.print("TIMER INIT: 0/$_timeoutSecs (${widget.loadingText}), _isInit=$_isInit");

      ///////////////////////////////////////////////////////////
      // Launch the timer to trigger every 1s
      _timeoutTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
        // If the loading widget has changed, extend/modify the timer
        if (_lastLoadingText.isNotEmpty && _lastLoadingText != widget.loadingText) {
          // Update the timer
          int remainingSecs = _timeoutSecs - timer.tick;
          if (remainingSecs < widget.timeOutSecs) {
            // Extend the timer
            _timeoutSecs += widget.timeOutSecs - remainingSecs;
            AppLogger.print(
                "TIMER EXTENDED @ ${timer.tick}s ($_lastLoadingText => ${widget.loadingText} @ +${widget.timeOutSecs}s timeout)");
          } else {
            // Modify the timer
            _timeoutSecs = timer.tick + widget.timeOutSecs;
            AppLogger.print(
                "TIMER CONTRACTED @ ${timer.tick}s ($_lastLoadingText => ${widget.loadingText} @ ${widget.timeOutSecs}s timeout)");
          }

          // Update the last loading text
          _lastLoadingText = widget.loadingText;
        }
        AppLogger.debug("TIMER TICK ${timer.tick}/$_timeoutSecs (${widget.loadingText})");

        // Update the countdown seconds
        setState(() {
          _countDownSecs = _timeoutSecs - timer.tick;
          if (timer.tick % 5 == 0 && widget.loadingTexts != null) {
            _displayIndex++;
            _displayIndex %= widget.loadingTexts!.length;
          }
        });

        // If timer is complete, cancel the timer and execute the callback
        if (timer.tick >= _timeoutSecs) {
          // Cancel timer due to timeout
          AppLogger.debug("TIMER EXPIRED @ ${timer.tick}/$_timeoutSecs  (${widget.loadingText})");
          _timeoutTimer?.cancel();

          // Attempt to execute signout or callback
          if (widget.timeOutEnabled) {
            if (widget.timeOutSignsOut) {
              // Cancel the sign-in, show error message, logout and notify listeners
              Snackbar.show(
                  SnackbarDisplayType.SB_ERROR,
                  "${widget.timeOutTextPrefix} took too long; logging out to protect your privacy. Please check internet connection and try again",
                  context);
              await _providerAuth.clearAuthedUserDetailsAndSignout();
            } else if (widget.timeOutCallback != null) {
              // Execute the callback method and display a message
              widget.timeOutCallback!();
              if (!widget.quietTimeOut) {
                Snackbar.show(SnackbarDisplayType.SB_ERROR,
                    "${widget.timeOutTextPrefix} took too long. Please check your internet connection.", context);
              }
            }
          } else {}
        }
      });
    }
  }

  ////////////////////////////////////////////////////////////////
  // When multiple loading texts have been provided, gets the
  // the next loading text to display based on the displayIndex.
  // If multiple loading texts have NOT been provided, returns
  // the single loading text.
  ////////////////////////////////////////////////////////////////
  String getLoadingText() {
    if (widget.loadingTexts != null && widget.loadingTexts!.isNotEmpty) {
      return widget.loadingTexts![_displayIndex];
    } else {
      return widget.loadingText;
    }
  }

  ////////////////////////////////////////////////////////////////
  // Primary Flutter method overriden which describes the layout
  // and bindings for this widget.
  ////////////////////////////////////////////////////////////////
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Center(
          child: Lottie.asset(
            MediaQuery.of(context).platformBrightness == Brightness.light
                // ? 'animations/loading_light_mode.json'
                ? 'animations/CI.json'
                : 'animations/CI.json',
            animate: true,
            height: widget.height,
          ),
        ),
        SizedBox(
          height: widget.loadingText.isEmpty ? 0 : 10,
        ),
        if (widget.loadingText.isNotEmpty || widget.loadingTexts != null)
          Center(
              child: Text(
            getLoadingText(),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium,
          )),
        if (widget.timeOutEnabled && _countDownSecs <= widget.timeOutCountdownBeginsAtSecs && !widget.quietTimeOut)
          Center(
              child: Text("Timing out in $_countDownSecs seconds...",
                  style: const TextStyle(fontStyle: FontStyle.italic))),
      ],
    );
  }
}

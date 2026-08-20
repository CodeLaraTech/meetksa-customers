import 'dart:async';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/services/native_print_service.dart';
import '../../../core/services/webview_service.dart';
import '../../../core/utils/logger.dart';

class SuiteWebViewController extends ChangeNotifier {
  final WebViewService _webViewService;

  WebViewController? _webViewController;
  WebViewController? get webViewController => _webViewController;

  int _loadingProgress = 0;
  int get loadingProgress => _loadingProgress;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  bool _isInitialLoading = true;
  bool get isInitialLoading => _isInitialLoading;

  bool _hasLoadError = false;
  bool get hasLoadError => _hasLoadError;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Timer? _timeoutTimer;

  SuiteWebViewController({WebViewService? webViewService})
      : _webViewService = webViewService ?? WebViewService();

  void _startTimeoutTimer() {
    _cancelTimeoutTimer();
    _timeoutTimer = Timer(AppConstants.webViewTimeout, () {
      if (_isLoading) {
        AppLogger.error('WebView page load timed out after ${AppConstants.webViewTimeout.inSeconds}s');
        _hasLoadError = true;
        _errorMessage = 'Connection timed out. Please check your connection and try again.';
        _isLoading = false;
        notifyListeners();
      }
    });
  }

  void _cancelTimeoutTimer() {
    _timeoutTimer?.cancel();
    _timeoutTimer = null;
  }

  void initializeController({
    required String url,
    required VoidCallback onInitialLoadSuccess,
    required void Function(String message) onInitialLoadFailure,
    BuildContext? context,
  }) {
    AppLogger.info('Initializing WebViewController for URL: $url');
    _isLoading = true;
    _hasLoadError = false;
    _startTimeoutTimer();
    notifyListeners();

    _webViewController = _webViewService.createController(
      initialUrl: url,
      context: context,
      onProgress: (progress) {
        _loadingProgress = progress;
        if (progress == 100) {
          _isLoading = false;
          _cancelTimeoutTimer();
        }
        notifyListeners();
      },
      onPageStarted: (startedUrl) {
        _isLoading = true;
        _hasLoadError = false;
        _startTimeoutTimer();
        notifyListeners();
      },
      onPageFinished: (finishedUrl) {
        _isLoading = false;
        _isInitialLoading = false;
        _cancelTimeoutTimer();
        notifyListeners();
        onInitialLoadSuccess();
      },
      onWebResourceError: (error) {
        // Ignore minor non-failing resource load errors (e.g. favicon 404)
        if (error.isForMainFrame ?? true) {
          _hasLoadError = true;
          _errorMessage = error.description;
          _isLoading = false;
          _cancelTimeoutTimer();
          notifyListeners();
          onInitialLoadFailure(error.description);
        }
      },
    );
  }

  Future<bool> handleBackPress() async {
    if (_webViewController != null && await _webViewController!.canGoBack()) {
      await _webViewController!.goBack();
      return true; // Handled back in WebView
    }
    return false; // Allow app exit or root back
  }

  Future<void> reload() async {
    AppLogger.info('Reloading WebView');
    _hasLoadError = false;
    _isLoading = true;
    _startTimeoutTimer();
    notifyListeners();
    await _webViewController?.reload();
  }

  Future<void> handleDownloadPrint(BuildContext context) async {
    final controller = _webViewController;
    if (controller == null) return;

    try {
      final currentUrl = await controller.currentUrl() ?? '';
      AppLogger.info('SuiteWebViewController: Header Print / Save as PDF triggered for URL: $currentUrl');

      // Step 1: Scan page for any /pdf/download link
      final dynamic rawResult = await controller.runJavaScriptReturningResult('''
        (function() {
          const dlLink = document.querySelector('a[href*="/pdf/download"], a[href*="/pdf"]');
          if (dlLink && dlLink.href) return dlLink.href;
          return '';
        })();
      ''');

      String foundUrl = rawResult.toString().replaceAll('"', '').trim();
      if (foundUrl == 'null') foundUrl = '';

      final targetUrl = foundUrl.isNotEmpty ? foundUrl : currentUrl;
      if (targetUrl.isNotEmpty) {
        await NativePrintService().printUrl(targetUrl);
      }
    } catch (e) {
      AppLogger.error('SuiteWebViewController: Error in handleDownloadPrint', error: e);
    }
  }

  @override
  void dispose() {
    _cancelTimeoutTimer();
    super.dispose();
  }
}

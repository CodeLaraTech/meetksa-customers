import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_urls.dart';
import '../../../../core/services/connectivity_service.dart';
import '../../../../core/widgets/connection_banner.dart';
import '../../../connectivity/presentation/widgets/offline_banner.dart';
import '../../../error/presentation/screens/error_screen.dart';
import '../../logic/webview_controller.dart';
import '../../../../core/constants/permission_constants.dart';
import '../../../../core/services/permission_service.dart';
import '../widgets/webview_loading.dart';
import '../widgets/webview_skeleton.dart';
import '../widgets/webview_toolbar.dart';

class WebViewScreen extends StatefulWidget {
  const WebViewScreen({super.key});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final SuiteWebViewController _controller;
  late final ConnectivityService _connectivityService;
  StreamSubscription<ConnectionStatus>? _connectivitySub;

  ConnectionStatus _connectionStatus = ConnectionStatus.online;
  bool _isInitialLoadFailed = false;

  @override
  void initState() {
    super.initState();
    _controller = SuiteWebViewController();
    _connectivityService = ConnectivityService();

    _connectivitySub = _connectivityService.onStatusChanged.listen((status) {
      if (mounted) {
        setState(() {
          _connectionStatus = status;
        });
      }
    });

    _initWebView();
  }

  void _initWebView() async {
    // Ensure native OS permissions (Location, Camera, Storage/Photos) are active for WebView
    final permissionService = PermissionService();
    await permissionService.requestPermission(AppPermissionType.location);
    await permissionService.requestPermission(AppPermissionType.camera);
    await permissionService.requestPermission(AppPermissionType.photosAndFiles);

    if (!mounted) return;

    _controller.initializeController(
      url: AppUrls.mainWebViewUrl,
      context: context,
      onInitialLoadSuccess: () {
        if (mounted && _isInitialLoadFailed) {
          setState(() {
            _isInitialLoadFailed = false;
          });
        }
      },
      onInitialLoadFailure: (message) {
        if (mounted) {
          setState(() {
            _isInitialLoadFailed = true;
          });
        }
      },
    );
  }

  bool _isNetworkError(String? errorMessage) {
    if (!_connectivityService.isOnline || _connectionStatus == ConnectionStatus.offline) {
      return true;
    }
    if (errorMessage == null) return false;
    final lower = errorMessage.toLowerCase();
    return lower.contains('internet') ||
        lower.contains('disconnected') ||
        lower.contains('network') ||
        lower.contains('connection') ||
        lower.contains('host') ||
        lower.contains('dns') ||
        lower.contains('name_not_resolved') ||
        lower.contains('timed_out') ||
        lower.contains('address_unreachable') ||
        lower.contains('failed to connect');
  }

  @override
  void dispose() {
    _connectivitySub?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // If initial load failed because offline or connection dropped, display OfflineScreen
    if (_isInitialLoadFailed ||
        (_connectionStatus == ConnectionStatus.offline && _controller.isLoading) ||
        (_controller.hasLoadError && _isNetworkError(_controller.errorMessage))) {
      return OfflineScreen(
        onRetry: () async {
          await _connectivityService.checkConnection();
          if (mounted) {
            setState(() {
              _isInitialLoadFailed = false;
            });
            _controller.reload();
          }
        },
      );
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final handled = await _controller.handleBackPress();
        if (!handled && context.mounted) {
          Navigator.of(context).maybePop();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(WebViewToolbar.slimHeaderHeight),
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return WebViewToolbar(
                onRefresh: () => _controller.reload(),
                isConnecting: _controller.isLoading,
                connectionStatus: _connectionStatus,
              );
            },
          ),
        ),
        body: Stack(
          children: [
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                if (_controller.hasLoadError && _isNetworkError(_controller.errorMessage)) {
                  return OfflineScreen(
                    onRetry: () async {
                      await _connectivityService.checkConnection();
                      if (mounted) {
                        setState(() {
                          _isInitialLoadFailed = false;
                        });
                        _controller.reload();
                      }
                    },
                  );
                }

                if (_controller.hasLoadError) {
                  return ErrorScreen(
                    errorMessage: _controller.errorMessage,
                    onRetry: () => _controller.reload(),
                  );
                }

                final webViewController = _controller.webViewController;
                if (webViewController == null) {
                  return const WebViewSkeletonLoader();
                }

                return Stack(
                  children: [
                    RefreshIndicator(
                      color: AppConstants.secondaryAccent,
                      backgroundColor: AppConstants.surfaceContainer,
                      onRefresh: () async {
                        await _controller.reload();
                      },
                      child: WebViewWidget(
                        controller: webViewController,
                        gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{
                          Factory<OneSequenceGestureRecognizer>(
                            EagerGestureRecognizer.new,
                          ),
                        },
                      ),
                    ),
                    if (_controller.isInitialLoading)
                      const WebViewSkeletonLoader(),
                  ],
                );
              },
            ),

            // Top Slim Progress Bar
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: WebViewLoadingProgressBar(
                    progress: _controller.loadingProgress,
                  ),
                );
              },
            ),

            // Subtle Floating In-App Offline Banner (Appears when internet is lost while inside WebView)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: ConnectionBanner(status: _connectionStatus),
            ),
          ],
        ),
      ),
    );
  }
}

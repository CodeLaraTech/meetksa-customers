import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

import '../constants/app_constants.dart';
import '../constants/permission_constants.dart';
import '../utils/logger.dart';
import '../utils/validators.dart';
import 'download_service.dart';
import 'external_url_service.dart';
import 'native_print_service.dart';
import 'permission_service.dart';
import 'webview_bridge_service.dart';

class WebViewService {
  final PermissionService _permissionService;
  final ExternalUrlService _externalUrlService;
  final WebViewBridgeService _bridgeService;

  WebViewService({
    PermissionService? permissionService,
    ExternalUrlService? externalUrlService,
    WebViewBridgeService? bridgeService,
  })  : _permissionService = permissionService ?? PermissionService(),
        _externalUrlService = externalUrlService ?? ExternalUrlService(),
        _bridgeService = bridgeService ?? WebViewBridgeService();

  WebViewController createController({
    required String initialUrl,
    required void Function(int progress) onProgress,
    required void Function(String url) onPageStarted,
    required void Function(String url) onPageFinished,
    required void Function(WebResourceError error) onWebResourceError,
    BuildContext? context,
  }) {
    late final WebViewController controller;

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(AppConstants.backgroundColor)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: onProgress,
          onPageStarted: (url) {
            AppLogger.webView('Page started: $url');
            _bridgeService.injectGeolocationPolyfill(controller);
            onPageStarted(url);
          },
          onPageFinished: (url) {
            AppLogger.webView('Page finished: $url');
            _bridgeService.injectGeolocationPolyfill(controller);
            if (url.contains('/pdf/download')) {
              AppLogger.webView('WebViewService: Printable document loaded — triggering native Save as PDF');
              NativePrintService().printUrl(url);
            }
            onPageFinished(url);
          },
          onWebResourceError: (error) {
            AppLogger.error('WebView resource error: ${error.description}');
            onWebResourceError(error);
          },
          onNavigationRequest: (NavigationRequest request) async {
            final String url = request.url;

            // /pdf/download: get real session cookies via Android CookieManager
            // (includes HttpOnly cookies that JS document.cookie cannot read)
            if (_isDownloadableFileUrl(url)) {
              AppLogger.webView('Intercepted PDF download URL: $url');
              final currentUrl = await controller.currentUrl();
              if (context != null && context.mounted) {
                await DownloadService().downloadFile(
                  url: url,
                  referer: currentUrl,
                  context: context,
                );
              }
              return NavigationDecision.prevent;
            }
            // Handle external schemes (tel:, mailto:, whatsapp:, etc.)
            if (UrlValidators.isExternalScheme(url)) {
              await _externalUrlService.launchExternalUrl(url);
              return NavigationDecision.prevent;
            }

            // Restrict web navigation to allowed domains
            if (UrlValidators.isAllowedDomain(url)) {
              return NavigationDecision.navigate;
            }

            // Launch untrusted external HTTPS domain in system browser
            if (UrlValidators.isValidUrl(url)) {
              await _externalUrlService.launchExternalUrl(url);
              return NavigationDecision.prevent;
            }

            return NavigationDecision.prevent;
          },
        ),
      );

    // Register Native Location & Download JavaScript Bridge Channel if BuildContext is supplied
    if (context != null) {
      _bridgeService.addJavaScriptChannel(context, controller);
    }

    if (controller.platform is WebKitWebViewController) {
      (controller.platform as WebKitWebViewController).setAllowsBackForwardNavigationGestures(true);
    }

    if (controller.platform is AndroidWebViewController) {
      final androidController = controller.platform as AndroidWebViewController;
      androidController.setGeolocationEnabled(true);


      androidController.setGeolocationPermissionsPromptCallbacks(
        onShowPrompt: (request) async {
          AppLogger.webView('Geolocation prompt request for origin: ${request.origin}');
          final status = await _permissionService.requestPermission(AppPermissionType.location);
          final bool isTrustedDomain = UrlValidators.isAllowedDomain(request.origin);
          if (status == AppPermissionStatus.granted && isTrustedDomain) {
            return const GeolocationPermissionsResponse(
              allow: true,
              retain: true,
            );
          }
          return const GeolocationPermissionsResponse(
            allow: false,
            retain: false,
          );
        },
      );

      // Handle HTML5 File Uploads (<input type="file"> / Camera image picker)
      androidController.setOnShowFileSelector(
        (FileSelectorParams params) async {
          AppLogger.webView('File selector requested. Mode: ${params.mode}');
          await _permissionService.requestPermission(AppPermissionType.photosAndFiles);
          await _permissionService.requestPermission(AppPermissionType.camera);

          try {
            final FilePickerResult? result = await FilePicker.platform.pickFiles(
              type: FileType.any,
              allowMultiple: params.mode == FileSelectorMode.openMultiple,
            );

            if (result != null && result.files.isNotEmpty) {
              final List<String> fileUris = result.files
                  .where((file) => file.path != null)
                  .map((file) => Uri.file(file.path!).toString())
                  .toList();
              AppLogger.webView('Picked ${fileUris.length} file URIs for WebView upload');
              return fileUris;
            }
          } catch (e) {
            AppLogger.error('Error picking files for WebView: $e');
          }
          return [];
        },
      );

      androidController.setOnPlatformPermissionRequest(
        (PlatformWebViewPermissionRequest request) async {
          AppLogger.webView('Platform permission request for resources: ${request.types}');
          
          for (final resource in request.types) {
            if (resource == WebViewPermissionResourceType.camera) {
              await _permissionService.requestPermission(AppPermissionType.camera);
            }
          }

          request.grant();
        },
      );
    }

    controller.loadRequest(Uri.parse(initialUrl));
    return controller;
  }

  bool _isDownloadableFileUrl(String url) {
    final lower = url.toLowerCase();
    final uri = Uri.tryParse(url);
    final path = uri?.path.toLowerCase() ?? '';

    // Allow all web pages (including printable HTML ticket documents /pdf/download) to navigate freely.
    // Only intercept explicit binary file downloads.
    return lower.contains('download=true') ||
        path.endsWith('.png') ||
        path.endsWith('.jpg') ||
        path.endsWith('.jpeg') ||
        path.endsWith('.doc') ||
        path.endsWith('.docx') ||
        path.endsWith('.xls') ||
        path.endsWith('.xlsx') ||
        path.endsWith('.csv') ||
        path.endsWith('.zip') ||
        lower.startsWith('data:application/pdf') ||
        lower.startsWith('blob:');
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../constants/app_urls.dart';
import '../constants/permission_constants.dart';
import '../utils/logger.dart';
import '../utils/validators.dart';
import 'download_service.dart';
import 'location_service.dart';
import 'notification_service.dart';
import 'permission_service.dart';

import 'native_print_service.dart';

class WebViewBridgeService {
  final LocationService _locationService;
  final NotificationService _notificationService;
  final PermissionService _permissionService;

  WebViewBridgeService({
    LocationService? locationService,
    NotificationService? notificationService,
    PermissionService? permissionService,
  })  : _locationService = locationService ?? LocationService(),
        _notificationService = notificationService ?? NotificationService(),
        _permissionService = permissionService ?? PermissionService();

  /// Combined JavaScript Polyfill for Geolocation, Notifications, AND PDF Download / Print
  static const String nativeBridgePolyfillScript = '''
(function() {
  if (window.__meetKsaNativeBridgeInjected) return;
  window.__meetKsaNativeBridgeInjected = true;

  // --- 1. GEOLOCATION POLYFILL ---
  window.__meetKsaCallbacks = window.__meetKsaCallbacks || {};
  let __meetKsaCallbackId = 0;

  function registerCallback(success, error) {
    const id = ++__meetKsaCallbackId;
    window.__meetKsaCallbacks[id] = { success: success, error: error };
    return id;
  }

  window.__meetKsaHandleLocationSuccess = function(callbackId, lat, lng, accuracy, heading, speed, altitude) {
    const cb = window.__meetKsaCallbacks[callbackId];
    if (cb && typeof cb.success === 'function') {
      const position = {
        coords: {
          latitude: lat,
          longitude: lng,
          accuracy: accuracy || 10,
          altitude: altitude || null,
          altitudeAccuracy: null,
          heading: heading || null,
          speed: speed || null
        },
        timestamp: Date.now()
      };
      cb.success(position);
      delete window.__meetKsaCallbacks[callbackId];
    }
  };

  window.__meetKsaHandleLocationError = function(callbackId, code, message) {
    const cb = window.__meetKsaCallbacks[callbackId];
    if (cb && typeof cb.error === 'function') {
      const err = {
        code: code || 1,
        message: message || "Unable to determine your current location."
      };
      cb.error(err);
      delete window.__meetKsaCallbacks[callbackId];
    }
  };

  if (!navigator.geolocation) {
    navigator.geolocation = {};
  }

  const originalGetCurrentPosition = navigator.geolocation.getCurrentPosition;
  const originalWatchPosition = navigator.geolocation.watchPosition;

  navigator.geolocation.getCurrentPosition = function(success, error, options) {
    const callbackId = registerCallback(success, error);
    if (window.FlutterNativeBridge && window.FlutterNativeBridge.postMessage) {
      window.FlutterNativeBridge.postMessage(JSON.stringify({
        action: 'getCurrentPosition',
        callbackId: callbackId,
        options: options || {}
      }));
    } else if (typeof originalGetCurrentPosition === 'function') {
      originalGetCurrentPosition.call(navigator.geolocation, success, error, options);
    } else if (typeof error === 'function') {
      error({ code: 1, message: "Native location bridge not available." });
    }
  };

  navigator.geolocation.watchPosition = function(success, error, options) {
    const callbackId = registerCallback(success, error);
    if (window.FlutterNativeBridge && window.FlutterNativeBridge.postMessage) {
      window.FlutterNativeBridge.postMessage(JSON.stringify({
        action: 'getCurrentPosition',
        callbackId: callbackId,
        options: options || {}
      }));
    } else if (typeof originalWatchPosition === 'function') {
      return originalWatchPosition.call(navigator.geolocation, success, error, options);
    }
    return callbackId;
  };

  // --- 2. HTML5 NOTIFICATION POLYFILL ---
  function NativeNotification(title, options) {
    this.title = title || '';
    this.options = options || {};
    
    if (window.FlutterNativeBridge && window.FlutterNativeBridge.postMessage) {
      window.FlutterNativeBridge.postMessage(JSON.stringify({
        action: 'showNotification',
        title: this.title,
        body: this.options.body || '',
        icon: this.options.icon || '',
        data: this.options.data || {}
      }));
    }
  }

  NativeNotification.permission = 'granted';

  NativeNotification.requestPermission = function(callback) {
    if (window.FlutterNativeBridge && window.FlutterNativeBridge.postMessage) {
      window.FlutterNativeBridge.postMessage(JSON.stringify({
        action: 'requestNotificationPermission'
      }));
    }
    const result = 'granted';
    if (typeof callback === 'function') callback(result);
    return Promise.resolve(result);
  };

  window.Notification = NativeNotification;

  // Intercept ServiceWorker showNotification if registered
  if (navigator.serviceWorker && typeof ServiceWorkerRegistration !== 'undefined') {
    const origShowNotification = ServiceWorkerRegistration.prototype.showNotification;
    ServiceWorkerRegistration.prototype.showNotification = function(title, options) {
      if (window.FlutterNativeBridge && window.FlutterNativeBridge.postMessage) {
        window.FlutterNativeBridge.postMessage(JSON.stringify({
          action: 'showNotification',
          title: title || '',
          body: (options && options.body) || '',
          icon: (options && options.icon) || ''
        }));
        return Promise.resolve();
      }
      if (origShowNotification) {
        return origShowNotification.call(this, title, options);
      }
      return Promise.resolve();
    };
  }

  // --- 3. PRINT & DOWNLOAD PDF POLYFILL ---
  function __meetKsaDownloadUrl(url, fileName) {
    if (!url) return;
    if (url.startsWith('data:')) {
      if (window.FlutterNativeBridge && window.FlutterNativeBridge.postMessage) {
        window.FlutterNativeBridge.postMessage(JSON.stringify({
          action: 'downloadFile',
          url: url,
          fileName: fileName
        }));
      }
      return;
    }

    fetch(url, { credentials: 'include' })
      .then(function(res) {
        if (!res.ok) throw new Error('HTTP ' + res.status);
        const contentType = (res.headers.get('content-type') || '').toLowerCase();
        if (contentType.includes('text/html')) {
          throw new Error('Server returned HTML instead of PDF');
        }
        return res.blob();
      })
      .then(function(blob) {
        if (blob.type && blob.type.includes('text/html')) {
          throw new Error('Blob is HTML');
        }
        const reader = new FileReader();
        reader.onloadend = function() {
          if (window.FlutterNativeBridge && window.FlutterNativeBridge.postMessage) {
            window.FlutterNativeBridge.postMessage(JSON.stringify({
              action: 'downloadFile',
              url: reader.result,
              fileName: fileName
            }));
          }
        };
        reader.readAsDataURL(blob);
      })
      .catch(function() {
        // Fallback: request native download with current page as referer
        if (window.FlutterNativeBridge && window.FlutterNativeBridge.postMessage) {
          window.FlutterNativeBridge.postMessage(JSON.stringify({
            action: 'downloadFile',
            url: url,
            fileName: fileName,
            referer: window.location.href
          }));
        }
      });
  }

  window.print = function() {
    if (window.FlutterNativeBridge && window.FlutterNativeBridge.postMessage) {
      window.FlutterNativeBridge.postMessage(JSON.stringify({
        action: 'printPage',
        url: window.location.href
      }));
    }
  };

  document.addEventListener('click', function(e) {
    let target = e.target;
    while (target && target.tagName !== 'A') {
      target = target.parentElement;
    }
    if (target && target.href) {
      const href = target.href;
      const lower = href.toLowerCase();
      // Only intercept raw blob:, data:, or explicit file download extensions
      if (
        href.startsWith('blob:') ||
        href.startsWith('data:application/pdf') ||
        lower.endsWith('.zip') ||
        lower.endsWith('.xlsx') ||
        lower.endsWith('.csv') ||
        (target.hasAttribute('download') && !lower.contains('/pdf/download'))
      ) {
        e.preventDefault();
        const fName = target.getAttribute('download') || target.download || ('MeetKSA_File_' + Date.now());
        __meetKsaDownloadUrl(href, fName);
      }
    }
  }, true);

})();
''';

  /// Injects native polyfill scripts into the webview controller
  Future<void> injectGeolocationPolyfill(WebViewController controller) async {
    try {
      await controller.runJavaScript(nativeBridgePolyfillScript);
      AppLogger.webView(
          'WebViewBridgeService: Native Geolocation, Notification, & Print/Download polyfills injected.');
    } catch (e) {
      AppLogger.error('WebViewBridgeService: Error injecting polyfill script',
          error: e);
    }
  }

  /// Registers JavaScript channel on WebViewController to handle bridge messages from WebView
  void addJavaScriptChannel(
    BuildContext context,
    WebViewController controller,
  ) {
    controller.addJavaScriptChannel(
      'FlutterNativeBridge',
      onMessageReceived: (JavaScriptMessage message) async {
        AppLogger.webView('WebViewBridgeService: Received bridge message.');
        try {
          final Map<String, dynamic> data = jsonDecode(message.message);
          final String action = data['action'] ?? '';
          final int callbackId = data['callbackId'] ?? 0;

          if (action == 'getCurrentPosition') {
            await _handleLocationRequest(context, controller, callbackId);
          } else if (action == 'showNotification') {
            final String title = data['title'] ?? 'SuiteKonnect Alert';
            final String body = data['body'] ?? '';
            AppLogger.webView(
                'WebViewBridgeService: Website triggered notification: "$title" - "$body"');
            await _notificationService.showNotification(
                title: title, body: body);
          } else if (action == 'requestNotificationPermission') {
            AppLogger.webView(
                'WebViewBridgeService: Website requested notification permission.');
            await _permissionService
                .requestPermission(AppPermissionType.notifications);
          } else if (action == 'downloadFile') {
            final String url = data['url'] ?? '';
            final String? fileName = data['fileName'];
            final String? cookies = data['cookies'];
            final String? referer = data['referer'];
            AppLogger.webView(
                'WebViewBridgeService: Website triggered download file: $fileName');
            if (url.isNotEmpty) {
              await DownloadService().downloadFile(
                url: url,
                customFileName: fileName,
                cookies: cookies,
                referer: referer,
                context: context,
              );
            }
          } else if (action == 'printPage') {
            final String url = data['url'] ?? '';
            AppLogger.webView(
                'WebViewBridgeService: Website called window.print() — opening native Save as PDF / Print dialog: $url');
            final currentUrl = await controller.currentUrl();
            final printTargetUrl = (url.isNotEmpty && url != 'about:blank') ? url : (currentUrl ?? '');
            if (printTargetUrl.isNotEmpty) {
              await NativePrintService().printUrl(printTargetUrl);
            }
          }
        } catch (e) {
          AppLogger.error(
              'WebViewBridgeService: Error parsing message: ${message.message}',
              error: e);
        }
      },
    );
  }

  /// Handles incoming location request from WebView
  Future<void> _handleLocationRequest(
    BuildContext context,
    WebViewController controller,
    int callbackId,
  ) async {
    final String? currentUrl = await controller.currentUrl();
    AppLogger.webView(
        'WebViewBridgeService: Processing location request for URL: $currentUrl');

    // 1. Security Check: Validate trusted host origin
    if (currentUrl != null &&
        !UrlValidators.isAllowedDomain(currentUrl) &&
        !currentUrl.contains(AppUrls.trustedBaseDomain)) {
      AppLogger.error(
          'WebViewBridgeService: Denied location request for untrusted origin: $currentUrl');
      await controller.runJavaScript(
        'window.__meetKsaHandleLocationError($callbackId, 1, "Location access denied for untrusted domain.");',
      );
      return;
    }

    // 2. Fetch Native High-Accuracy Device Position
    try {
      final Position position = await _locationService.getCurrentLocation();

      final String jsCode = '''
        window.__meetKsaHandleLocationSuccess(
          $callbackId,
          ${position.latitude},
          ${position.longitude},
          ${position.accuracy},
          ${position.heading},
          ${position.speed},
          ${position.altitude}
        );
      ''';

      await controller.runJavaScript(jsCode);
      AppLogger.webView(
          'WebViewBridgeService: Returned native coordinates to WebView.');
    } on LocationServiceException catch (e) {
      AppLogger.error(
          'WebViewBridgeService: LocationServiceException: ${e.message}');

      await controller.runJavaScript(
        'window.__meetKsaHandleLocationError($callbackId, 1, "${e.message}");',
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: const Color(0xFFEF4444),
            action: e.message.contains('Settings')
                ? SnackBarAction(
                    label: 'Open Settings',
                    textColor: Colors.white,
                    onPressed: () => PermissionService().openAppSettings(),
                  )
                : null,
          ),
        );
      }
    } catch (e) {
      AppLogger.error(
          'WebViewBridgeService: Unexpected error getting native location',
          error: e);
      await controller.runJavaScript(
        'window.__meetKsaHandleLocationError($callbackId, 2, "Unable to determine your current location. Please try again.");',
      );
    }
  }
}

import 'package:flutter/services.dart';

import '../utils/logger.dart';

/// Bridges Flutter with Android's native PrintManager to open the system
/// "Save as PDF" / Print dialog for any web page or printable document URL.
class NativePrintService {
  static const _channel = MethodChannel('meetksa/print');

  static final NativePrintService _instance = NativePrintService._();
  factory NativePrintService() => _instance;
  NativePrintService._();

  Future<bool> printUrl(String url, {String title = 'Maintenance_Work_Document'}) async {
    try {
      AppLogger.info('NativePrintService: Invoking native print for URL: $url');
      final result = await _channel.invokeMethod<bool>('printUrl', {
        'url': url,
        'title': title,
      });
      return result ?? false;
    } catch (e) {
      AppLogger.error('NativePrintService: Error invoking native print', error: e);
      return false;
    }
  }
}

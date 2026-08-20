import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../constants/permission_constants.dart';
import '../utils/logger.dart';
import 'native_cookie_service.dart';
import 'notification_service.dart';
import 'permission_service.dart';

class DownloadService {
  static final DownloadService _instance = DownloadService._internal();
  factory DownloadService() => _instance;
  DownloadService._internal();

  final PermissionService _permissionService = PermissionService();
  final NotificationService _notificationService = NotificationService();

  /// Downloads a file from an HTTP/HTTPS URL or Base64 data URI into Mobile Storage
  Future<File?> downloadFile({
    required String url,
    String? customFileName,
    String? userAgent,
    String? cookies,
    String? referer,
    BuildContext? context,
  }) async {
    try {
      AppLogger.info('DownloadService: Starting download: ${url.length > 100 ? "${url.substring(0, 100)}..." : url}');

      await _permissionService.requestPermission(AppPermissionType.photosAndFiles);

      List<int> fileBytes = [];
      String fileName = customFileName ?? _extractFileName(url);

      // ── Base64 Data URI ───────────────────────────────────────────────────
      if (url.startsWith('data:')) {
        final commaIndex = url.indexOf(',');
        if (commaIndex == -1) throw Exception('Invalid data URI');

        final meta = url.substring(0, commaIndex);
        final base64Data = url.substring(commaIndex + 1);

        if (customFileName == null) {
          final ext = _getExtensionFromMimeType(meta);
          fileName = 'MeetKSA_${DateTime.now().millisecondsSinceEpoch}$ext';
        }

        fileBytes = base64Decode(base64Data.replaceAll(RegExp(r'\s+'), ''));
        AppLogger.info('DownloadService: Decoded base64 data URI — ${fileBytes.length} bytes');

      // ── HTTP / HTTPS URL ──────────────────────────────────────────────────
      } else {
        final uri = Uri.parse(url);
        final client = HttpClient();
        client.badCertificateCallback = (cert, host, port) => true;

        // Automatically fetch merged session cookies from Android CookieManager if not supplied
        String activeCookies = cookies ?? '';
        if (activeCookies.isEmpty) {
          activeCookies = await NativeCookieService().getCookiesForUrl(url);
        }

        final request = await client.getUrl(uri);
        request.followRedirects = true;
        request.maxRedirects = 15;

        final ua = userAgent ??
            'Mozilla/5.0 (Linux; Android 14; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36';

        request.headers.set(HttpHeaders.userAgentHeader, ua);
        request.headers.set(
          HttpHeaders.acceptHeader,
          'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,application/pdf,*/*;q=0.8',
        );

        if (activeCookies.isNotEmpty) {
          request.headers.set(HttpHeaders.cookieHeader, activeCookies);
        }

        final ref = referer ?? '${uri.scheme}://${uri.host}/';
        request.headers.set(HttpHeaders.refererHeader, ref);
        request.headers.set('Upgrade-Insecure-Requests', '1');
        request.headers.set('Sec-Fetch-Dest', 'document');
        request.headers.set('Sec-Fetch-Mode', 'navigate');
        request.headers.set('Sec-Fetch-Site', 'same-origin');
        request.headers.set('Sec-Fetch-User', '?1');

        final response = await request.close();
        AppLogger.info('DownloadService: HTTP ${response.statusCode} (content-type: ${response.headers.contentType}) for $url');

        fileBytes = await response.fold<List<int>>(
          <int>[],
          (prev, chunk) => prev..addAll(chunk),
        );

        // Derive name from Content-Disposition header if available
        final disposition = response.headers.value('content-disposition');
        if (disposition != null && customFileName == null) {
          final parsedName = _parseContentDispositionFileName(disposition);
          if (parsedName != null && parsedName.isNotEmpty) {
            fileName = parsedName;
          }
        }
      }

      if (fileBytes.isEmpty) {
        throw Exception('File is empty (0 bytes received)');
      }

      // Check if file is expected to be a PDF
      if (fileName.toLowerCase().endsWith('.pdf') || url.toLowerCase().contains('pdf')) {
        final sampleStr = String.fromCharCodes(fileBytes.take(1024));
        final bool isRealPdf = sampleStr.contains('%PDF');

        if (!isRealPdf) {
          if (sampleStr.contains('<html') || sampleStr.contains('<!doctype') || sampleStr.contains('<body')) {
            final snippet = sampleStr.length > 300 ? sampleStr.substring(0, 300) : sampleStr;
            AppLogger.error('DownloadService: Server returned HTML web page instead of PDF binary. Snippet: $snippet');
            throw Exception('Session authentication required. Please ensure you are logged into your account in the app.');
          }
        }
      }

      AppLogger.info('DownloadService: Received ${fileBytes.length} bytes — saving as $fileName');

      // ── Save to Downloads ─────────────────────────────────────────────────
      final Directory targetDir = await _getMobileStorageDirectory();
      final String safeFileName = _sanitizeFileName(fileName);
      final File savedFile = File('${targetDir.path}/$safeFileName');

      await savedFile.writeAsBytes(fileBytes, flush: true);
      AppLogger.info('DownloadService: Saved successfully → ${savedFile.path}');

      await _notificationService.showNotification(
        title: '📄 Download Complete',
        body: '$safeFileName saved to Downloads',
        payload: savedFile.path,
      );

      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.greenAccent, size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'PDF downloaded successfully',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF0F172A),
            duration: const Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }

      return savedFile;
    } catch (e) {
      AppLogger.error('DownloadService: Download failed', error: e);
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    e.toString().replaceAll('Exception: ', ''),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFFEF4444),
            duration: const Duration(seconds: 5),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
      return null;
    }
  }

  Future<Directory> _getMobileStorageDirectory() async {
    if (Platform.isAndroid) {
      final publicDownloadDir = Directory('/storage/emulated/0/Download');
      if (await publicDownloadDir.exists()) return publicDownloadDir;
      final externalDir = await getExternalStorageDirectory();
      if (externalDir != null) return externalDir;
    }
    return getApplicationDocumentsDirectory();
  }

  String _extractFileName(String url) {
    try {
      final uri = Uri.parse(url);
      final pathSegments = uri.pathSegments;
      for (final segment in pathSegments.reversed) {
        if (segment.contains('.')) {
          return segment;
        }
      }
      if (pathSegments.isNotEmpty) {
        final lastSegment = pathSegments.last;
        return 'Doc_${lastSegment}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      }
    } catch (_) {}
    return 'Document_${DateTime.now().millisecondsSinceEpoch}.pdf';
  }

  String? _parseContentDispositionFileName(String disposition) {
    try {
      final regExp = RegExp(r'''filename\*?=(?:[\"']?([^\"';]+)[\"']?|utf-8''(.+))''', caseSensitive: false);
      final match = regExp.firstMatch(disposition);
      if (match != null) {
        final name = match.group(2) ?? match.group(1);
        if (name != null) return Uri.decodeComponent(name.trim());
      }
    } catch (_) {}
    return null;
  }

  String _getExtensionFromMimeType(String meta) {
    if (meta.contains('pdf')) return '.pdf';
    if (meta.contains('png')) return '.png';
    if (meta.contains('jpeg') || meta.contains('jpg')) return '.jpg';
    if (meta.contains('csv')) return '.csv';
    return '.pdf';
  }

  String _sanitizeFileName(String name) {
    return name.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
  }
}

package com.meetksa.customer

import android.content.Context
import android.net.Uri
import android.print.PrintAttributes
import android.print.PrintManager
import android.webkit.CookieManager
import android.webkit.WebView
import android.webkit.WebViewClient
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val COOKIE_CHANNEL = "meetksa/cookies"
    private val PRINT_CHANNEL = "meetksa/print"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, COOKIE_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getCookies" -> {
                        val url = call.argument<String>("url") ?: ""
                        val cookieManager = CookieManager.getInstance()
                        val domains = mutableListOf<String>()
                        if (url.isNotEmpty()) {
                            domains.add(url)
                            try {
                                val uri = Uri.parse(url)
                                val host = uri.host ?: ""
                                if (host.isNotEmpty()) {
                                    val scheme = uri.scheme ?: "https"
                                    domains.add("$scheme://$host")
                                    val parts = host.split(".")
                                    if (parts.size >= 2) {
                                        val baseDomain = parts.takeLast(2).joinToString(".")
                                        domains.add("$scheme://$baseDomain")
                                        domains.add("$scheme://customer.$baseDomain")
                                    }
                                }
                            } catch (_: Exception) {}
                        }
                        val cookieMap = mutableMapOf<String, String>()
                        for (domain in domains) {
                            val c = cookieManager.getCookie(domain)
                            if (!c.isNullOrEmpty()) {
                                val pairs = c.split(";")
                                for (pair in pairs) {
                                    val trimmed = pair.trim()
                                    val eqIndex = trimmed.indexOf('=')
                                    if (eqIndex > 0) {
                                        val key = trimmed.substring(0, eqIndex).trim()
                                        val value = trimmed.substring(eqIndex + 1).trim()
                                        cookieMap[key] = value
                                    }
                                }
                            }
                        }
                        val mergedCookies = cookieMap.entries.joinToString("; ") { "${it.key}=${it.value}" }
                        result.success(mergedCookies)
                    }
                    else -> result.notImplemented()
                }
            }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, PRINT_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "printUrl" -> {
                        val url = call.argument<String>("url") ?: ""
                        val title = call.argument<String>("title") ?: "Document"
                        if (url.isNotEmpty()) {
                            printUrl(url, title)
                            result.success(true)
                        } else {
                            result.error("INVALID_URL", "URL cannot be empty", null)
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun printUrl(url: String, jobName: String) {
        runOnUiThread {
            try {
                val printManager = getSystemService(Context.PRINT_SERVICE) as? PrintManager ?: return@runOnUiThread
                val printWebView = WebView(this)
                printWebView.settings.javaScriptEnabled = true
                printWebView.settings.domStorageEnabled = true
                printWebView.settings.loadWithOverviewMode = true
                printWebView.settings.useWideViewPort = true

                val cookieManager = CookieManager.getInstance()
                cookieManager.setAcceptCookie(true)
                cookieManager.setAcceptThirdPartyCookies(printWebView, true)

                printWebView.webViewClient = object : WebViewClient() {
                    override fun onPageFinished(view: WebView?, finishedUrl: String?) {
                        super.onPageFinished(view, finishedUrl)
                        val printAdapter = view?.createPrintDocumentAdapter(jobName)
                        if (printAdapter != null) {
                            val printAttributes = PrintAttributes.Builder()
                                .setMediaSize(PrintAttributes.MediaSize.ISO_A4)
                                .setColorMode(PrintAttributes.COLOR_MODE_COLOR)
                                .setMinMargins(PrintAttributes.Margins.NO_MARGINS)
                                .build()
                            printManager.print(jobName, printAdapter, printAttributes)
                        }
                    }
                }
                printWebView.loadUrl(url)
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }
    }
}

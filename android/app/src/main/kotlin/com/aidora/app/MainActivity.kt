package com.aidora.app

import android.content.Intent
import android.net.Uri
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val CHANNEL = "com.aidora.app/deep_links"
    private var initialLink: String? = null
    private var channel: MethodChannel? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Store initial deep link (cold start)
        initialLink = intent?.data?.toString()

        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        channel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "getInitialLink" -> {
                    result.success(initialLink)
                    initialLink = null // consume once
                }
                else -> result.notImplemented()
            }
        }
    }

    // Handle deep link while app is already running (warm start)
    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        val uri: Uri? = intent.data
        if (uri != null) {
            channel?.invokeMethod("onDeepLink", uri.toString())
        }
    }
}

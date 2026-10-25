package com.example.clarion

import android.app.Activity
import android.content.ActivityNotFoundException
import android.content.Intent
import android.speech.RecognizerIntent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/// Flutter shell plus the home-widget channel and the system speech sheet.
class MainActivity : FlutterActivity() {
    private var pendingVoice: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "update" -> {
                        val budget = call.argument<String>("budget") ?: ""
                        val hold = call.argument<String>("hold") ?: ""
                        val endsAt = (call.argument<Any>("endsAt") as? Number)?.toLong() ?: 0L
                        getSharedPreferences(ClarionWidgetProvider.PREFS, MODE_PRIVATE)
                            .edit()
                            .putString(ClarionWidgetProvider.KEY_BUDGET, budget)
                            .putString(ClarionWidgetProvider.KEY_HOLD, hold)
                            .putLong(ClarionWidgetProvider.KEY_ENDS, endsAt)
                            .apply()
                        ClarionWidgetProvider.refresh(this)
                        result.success(null)
                    }
                    "listen" -> startVoice(result)
                    else -> result.notImplemented()
                }
            }
    }

    private fun startVoice(result: MethodChannel.Result) {
        if (pendingVoice != null) {
            result.success(null)
            return
        }
        val intent = Intent(RecognizerIntent.ACTION_RECOGNIZE_SPEECH).apply {
            putExtra(
                RecognizerIntent.EXTRA_LANGUAGE_MODEL,
                RecognizerIntent.LANGUAGE_MODEL_FREE_FORM,
            )
            putExtra(RecognizerIntent.EXTRA_PROMPT, "Say your goal")
        }
        pendingVoice = result
        try {
            @Suppress("DEPRECATION")
            startActivityForResult(intent, VOICE_REQUEST)
        } catch (_: ActivityNotFoundException) {
            pendingVoice = null
            result.success(null)
        }
    }

    @Deprecated("The system speech sheet still returns through the activity result.")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        if (requestCode == VOICE_REQUEST) {
            val pending = pendingVoice
            pendingVoice = null
            val words = if (resultCode == Activity.RESULT_OK) {
                data?.getStringArrayListExtra(RecognizerIntent.EXTRA_RESULTS)?.firstOrNull()
            } else {
                null
            }
            pending?.success(words)
            return
        }
        @Suppress("DEPRECATION")
        super.onActivityResult(requestCode, resultCode, data)
    }

    companion object {
        const val CHANNEL = "com.example.clarion/home_widget"
        private const val VOICE_REQUEST = 4107
    }
}

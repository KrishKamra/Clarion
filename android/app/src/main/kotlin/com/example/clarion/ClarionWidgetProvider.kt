package com.example.clarion

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews

/// Home-screen widget: budget left, and the live cooling-off timer.
///
/// The timer is recomputed from the stored end time on each update, including
/// the 30-minute system refresh, so it stays honest while the app is closed.
class ClarionWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        manager: AppWidgetManager,
        ids: IntArray,
    ) {
        val prefs = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
        val budget = prefs.getString(KEY_BUDGET, null) ?: "Open Clarion"
        val hold = prefs.getString(KEY_HOLD, null) ?: "No cooling-off hold"
        val endsAt = prefs.getLong(KEY_ENDS, 0L)
        val holdText = when {
            endsAt <= 0L -> hold
            else -> {
                val left = endsAt - System.currentTimeMillis()
                if (left <= 0L) "$hold · ready" else "$hold · ${formatRemaining(left)} left"
            }
        }
        val open = PendingIntent.getActivity(
            context,
            0,
            Intent(context, MainActivity::class.java),
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
        for (id in ids) {
            val views = RemoteViews(context.packageName, R.layout.clarion_widget)
            views.setTextViewText(R.id.widget_budget, budget)
            views.setTextViewText(R.id.widget_hold, holdText)
            views.setOnClickPendingIntent(R.id.widget_root, open)
            manager.updateAppWidget(id, views)
        }
    }

    companion object {
        const val PREFS = "clarion_widget"
        const val KEY_BUDGET = "budget"
        const val KEY_HOLD = "hold"
        const val KEY_ENDS = "endsAt"

        fun refresh(context: Context) {
            val manager = AppWidgetManager.getInstance(context)
            val ids = manager.getAppWidgetIds(
                ComponentName(context, ClarionWidgetProvider::class.java),
            )
            if (ids.isEmpty()) return
            val intent = Intent(context, ClarionWidgetProvider::class.java).apply {
                action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
                putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, ids)
            }
            context.sendBroadcast(intent)
        }

        private fun formatRemaining(millis: Long): String {
            val totalMinutes = (millis / 60000L).coerceAtLeast(0L)
            val hours = totalMinutes / 60L
            val minutes = totalMinutes % 60L
            return if (hours > 0L) "${hours}h ${minutes}m" else "${minutes}m"
        }
    }
}

package com.example.clarion

import android.app.AlarmManager
import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Paint
import android.graphics.RectF
import android.graphics.Typeface
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.text.format.DateFormat
import android.text.format.DateUtils
import android.util.SizeF
import android.view.View
import android.widget.RemoteViews
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale
import kotlin.math.max
import kotlin.math.min

/// Home-screen widget: what is left of the month's budget, the cooling-off
/// hold that ends soonest, and (at 4×3) the watchlist and what waiting has
/// saved.
///
/// One layout per size bucket. On Android 12+ all of them are handed to the
/// launcher at once, so resizing swaps layouts instantly; before that the
/// bucket is picked from the widget's reported size.
///
/// A hold shows the clock time it ends rather than a ticking countdown —
/// always accurate between updates, and calm. An alarm refreshes the widget
/// the moment the hold ends so it reads "Ready to decide" on time.
class ClarionWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        manager: AppWidgetManager,
        ids: IntArray,
    ) {
        val state = WidgetState.read(context)
        for (id in ids) render(context, manager, id, state)
        scheduleHoldEnd(context, state)
    }

    override fun onAppWidgetOptionsChanged(
        context: Context,
        manager: AppWidgetManager,
        id: Int,
        options: Bundle,
    ) {
        render(context, manager, id, WidgetState.read(context))
    }

    private fun render(
        context: Context,
        manager: AppWidgetManager,
        id: Int,
        state: WidgetState,
    ) {
        val views = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            RemoteViews(Bucket.entries.associate { SizeF(it.minWidth, it.minHeight) to build(context, state, it) })
        } else {
            val options = manager.getAppWidgetOptions(id)
            // Portrait: the narrowest width and the tallest height apply.
            val width = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_WIDTH)
            val height = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MAX_HEIGHT)
            build(context, state, Bucket.pick(width.toFloat(), height.toFloat()))
        }
        manager.updateAppWidget(id, views)
    }

    private fun build(context: Context, s: WidgetState, bucket: Bucket): RemoteViews {
        val views = RemoteViews(context.packageName, bucket.layout)
        val density = context.resources.displayMetrics.density

        views.setOnClickPendingIntent(R.id.widget_root, openApp(context, null))
        views.setImageViewBitmap(
            R.id.widget_ring,
            ringBitmap(context, s, (bucket.ringDp * density).toInt(), bucket.ringLabel),
        )
        if (s.empty) {
            views.setTextViewText(R.id.widget_budget, context.getString(R.string.widget_open_app))
            views.setTextViewText(R.id.widget_caption, context.getString(R.string.widget_open_app_caption))
        } else {
            views.setTextViewText(R.id.widget_budget, s.budget)
            views.setTextViewText(R.id.widget_caption, s.caption)
            views.setTextColor(
                R.id.widget_budget,
                context.getColor(if (s.over) R.color.widget_rose else R.color.widget_text_primary),
            )
        }
        views.setContentDescription(R.id.widget_ring, context.getString(R.string.widget_used, s.percent))

        if (bucket.hasHeader) {
            views.setTextViewText(
                R.id.widget_month,
                SimpleDateFormat("MMMM", Locale.getDefault()).format(Date()),
            )
        }
        if (bucket.hasHold) bindHold(context, views, s, bucket)
        if (bucket.hasStats) {
            views.setTextViewText(R.id.widget_watching, s.watching.toString())
            views.setTextViewText(
                R.id.widget_at_target,
                if (s.atTarget > 0) {
                    context.getString(R.string.widget_at_target, s.atTarget)
                } else {
                    context.getString(R.string.widget_none_at_target)
                },
            )
            views.setTextColor(
                R.id.widget_at_target,
                context.getColor(if (s.atTarget > 0) R.color.widget_emerald else R.color.widget_text_secondary),
            )
            views.setTextViewText(R.id.widget_saved, s.saved.ifEmpty { "—" })
            views.setTextViewText(R.id.widget_avoided, context.getString(R.string.widget_avoided, s.avoided))
        }
        return views
    }

    private fun bindHold(context: Context, views: RemoteViews, s: WidgetState, bucket: Bucket) {
        val now = System.currentTimeMillis()
        if (s.endsAt <= 0L) {
            views.setImageViewResource(R.id.widget_hold_dot, R.drawable.widget_dot_emerald)
            views.setTextViewText(R.id.widget_hold_title, context.getString(R.string.widget_no_hold))
            views.setTextViewText(R.id.widget_hold_time, if (bucket == Bucket.SMALL) context.getString(R.string.widget_no_hold) else "")
            views.setViewVisibility(R.id.widget_hold_progress, View.GONE)
            views.setTextColor(R.id.widget_hold_title, context.getColor(R.color.widget_text_secondary))
            return
        }

        views.setOnClickPendingIntent(R.id.widget_hold_row, openApp(context, s.holdId))
        views.setTextViewText(R.id.widget_hold_title, s.hold)
        views.setTextColor(R.id.widget_hold_title, context.getColor(R.color.widget_text_primary))
        val ready = now >= s.endsAt
        views.setImageViewResource(
            R.id.widget_hold_dot,
            if (ready) R.drawable.widget_dot_emerald else R.drawable.widget_dot_rose,
        )
        val more = if (s.holdCount > 1 && bucket != Bucket.SMALL) {
            "  " + context.getString(R.string.widget_more_holds, s.holdCount - 1)
        } else {
            ""
        }
        val time = when {
            ready -> context.getString(R.string.widget_ready)
            bucket == Bucket.LARGE -> readyAt(context, s.endsAt) + " · " + remaining(context, s.endsAt - now)
            else -> readyAt(context, s.endsAt)
        }
        views.setTextViewText(R.id.widget_hold_time, time + more)
        views.setTextColor(
            R.id.widget_hold_time,
            context.getColor(if (ready) R.color.widget_emerald else R.color.widget_text_secondary),
        )

        val span = (s.endsAt - s.startsAt).takeIf { s.startsAt > 0L && it > 0L } ?: DateUtils.DAY_IN_MILLIS
        val passed = ((now - (s.endsAt - span)).toDouble() / span).coerceIn(0.0, 1.0)
        views.setViewVisibility(R.id.widget_hold_progress, if (ready) View.GONE else View.VISIBLE)
        views.setProgressBar(R.id.widget_hold_progress, 1000, (passed * 1000).toInt(), false)
    }

    /// "Ready 9:40 PM", or "Ready tomorrow 9:40 AM", in the device's clock.
    private fun readyAt(context: Context, at: Long): String {
        val clock = DateFormat.getTimeFormat(context).format(Date(at))
        val day = if (DateUtils.isToday(at)) clock else context.getString(R.string.widget_tomorrow, clock)
        return context.getString(R.string.widget_ready_at, day)
    }

    private fun remaining(context: Context, millis: Long): String {
        val minutes = max(1L, millis / DateUtils.MINUTE_IN_MILLIS)
        return if (minutes >= 60) {
            context.getString(R.string.widget_hours_left, ((minutes + 30) / 60).toInt())
        } else {
            context.getString(R.string.widget_minutes_left, minutes.toInt())
        }
    }

    /// The budget ring: committed spend against the ceiling in the same
    /// emerald / amber / rose zones as the in-app barometer.
    private fun ringBitmap(context: Context, s: WidgetState, px: Int, label: Boolean): Bitmap {
        val size = max(px, 1)
        val bitmap = Bitmap.createBitmap(size, size, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(bitmap)
        val stroke = size * 0.09f
        val inset = stroke / 2 + 1
        val oval = RectF(inset, inset, size - inset, size - inset)
        val paint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            style = Paint.Style.STROKE
            strokeWidth = stroke
            strokeCap = Paint.Cap.ROUND
        }
        paint.color = context.getColor(R.color.widget_hairline)
        canvas.drawOval(oval, paint)

        val zone = when {
            s.ratio > 1.0 -> R.color.widget_rose
            s.ratio >= 0.85 -> R.color.widget_amber
            else -> R.color.widget_emerald
        }
        paint.color = context.getColor(zone)
        val sweep = (min(s.ratio, 1.0) * 360).toFloat()
        if (sweep > 0f) canvas.drawArc(oval, -90f, max(sweep, 2f), false, paint)

        if (label) {
            val text = Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = context.getColor(R.color.widget_text_primary)
                textAlign = Paint.Align.CENTER
                textSize = size * 0.26f
                typeface = Typeface.create("sans-serif-medium", Typeface.NORMAL)
                fontFeatureSettings = "tnum"
            }
            val percent = "${s.percent}%"
            val y = size / 2f - (text.descent() + text.ascent()) / 2
            canvas.drawText(percent, size / 2f, y, text)
        }
        return bitmap
    }

    private fun openApp(context: Context, productId: String?): PendingIntent {
        val intent = if (productId.isNullOrEmpty()) {
            Intent(context, MainActivity::class.java)
        } else {
            Intent(Intent.ACTION_VIEW, Uri.parse("clarion://product/$productId"), context, MainActivity::class.java)
        }
        return PendingIntent.getActivity(
            context,
            productId?.hashCode() ?: 0,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
    }

    /// Refresh once more when the soonest hold ends. Inexact is fine: the
    /// time shown is the end time itself, so only the "Ready" flip waits.
    private fun scheduleHoldEnd(context: Context, s: WidgetState) {
        val alarms = context.getSystemService(AlarmManager::class.java) ?: return
        val pending = PendingIntent.getBroadcast(
            context,
            HOLD_END_REQUEST,
            updateIntent(context, ids(context)),
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
        alarms.cancel(pending)
        if (s.endsAt > System.currentTimeMillis()) {
            alarms.set(AlarmManager.RTC, s.endsAt + 1000L, pending)
        }
    }

    /// Size buckets, smallest first. Minimums are in dp.
    private enum class Bucket(
        val layout: Int,
        val minWidth: Float,
        val minHeight: Float,
        val ringDp: Int,
        val ringLabel: Boolean,
        val hasHeader: Boolean,
        val hasHold: Boolean,
        val hasStats: Boolean,
    ) {
        TINY(R.layout.clarion_widget_tiny, 100f, 40f, 32, false, false, false, false),
        STRIP(R.layout.clarion_widget_strip, 220f, 40f, 34, false, false, true, false),
        SMALL(R.layout.clarion_widget_small, 100f, 100f, 40, true, false, true, false),
        MEDIUM(R.layout.clarion_widget_medium, 220f, 100f, 52, true, true, true, false),
        LARGE(R.layout.clarion_widget_large, 220f, 190f, 64, true, true, true, true);

        companion object {
            fun pick(width: Float, height: Float): Bucket = when {
                width >= LARGE.minWidth && height >= LARGE.minHeight -> LARGE
                width >= MEDIUM.minWidth && height >= MEDIUM.minHeight -> MEDIUM
                width >= STRIP.minWidth -> STRIP
                height >= SMALL.minHeight -> SMALL
                width <= 0f -> MEDIUM
                else -> TINY
            }
        }
    }

    /// The last snapshot the app wrote through the `update` channel call.
    private class WidgetState(p: SharedPreferences) {
        val budget = p.getString(KEY_BUDGET, null).orEmpty()
        val caption = p.getString(KEY_CAPTION, null).orEmpty()
        val ratio = p.getFloat(KEY_RATIO, 0f).toDouble()
        val over = p.getBoolean(KEY_OVER, false)
        val hold = p.getString(KEY_HOLD, null).orEmpty()
        val holdId = p.getString(KEY_HOLD_ID, null).orEmpty()
        val startsAt = p.getLong(KEY_STARTS, 0L)
        val endsAt = p.getLong(KEY_ENDS, 0L)
        val holdCount = p.getInt(KEY_HOLD_COUNT, 0)
        val watching = p.getInt(KEY_WATCHING, 0)
        val atTarget = p.getInt(KEY_AT_TARGET, 0)
        val saved = p.getString(KEY_SAVED, null).orEmpty()
        val avoided = p.getInt(KEY_AVOIDED, 0)

        val empty get() = budget.isEmpty()
        val percent get() = (ratio * 100).toInt().coerceAtLeast(0)

        companion object {
            fun read(context: Context) = WidgetState(context.getSharedPreferences(PREFS, Context.MODE_PRIVATE))
        }
    }

    companion object {
        const val PREFS = "clarion_widget"
        const val KEY_BUDGET = "budget"
        const val KEY_CAPTION = "budgetCaption"
        const val KEY_RATIO = "ratio"
        const val KEY_OVER = "over"
        const val KEY_HOLD = "hold"
        const val KEY_HOLD_ID = "holdId"
        const val KEY_STARTS = "startsAt"
        const val KEY_ENDS = "endsAt"
        const val KEY_HOLD_COUNT = "holdCount"
        const val KEY_WATCHING = "watching"
        const val KEY_AT_TARGET = "atTarget"
        const val KEY_SAVED = "saved"
        const val KEY_AVOIDED = "avoided"
        private const val HOLD_END_REQUEST = 7301

        /// Stores the app's snapshot and redraws every placed widget.
        fun save(context: Context, values: Map<String, Any?>) {
            fun long(key: String) = (values[key] as? Number)?.toLong() ?: 0L
            fun int(key: String) = (values[key] as? Number)?.toInt() ?: 0
            fun string(key: String) = values[key] as? String ?: ""
            context.getSharedPreferences(PREFS, Context.MODE_PRIVATE).edit()
                .putString(KEY_BUDGET, string(KEY_BUDGET))
                .putString(KEY_CAPTION, string(KEY_CAPTION))
                .putFloat(KEY_RATIO, (values[KEY_RATIO] as? Number)?.toFloat() ?: 0f)
                .putBoolean(KEY_OVER, values[KEY_OVER] as? Boolean ?: false)
                .putString(KEY_HOLD, string(KEY_HOLD))
                .putString(KEY_HOLD_ID, string(KEY_HOLD_ID))
                .putLong(KEY_STARTS, long(KEY_STARTS))
                .putLong(KEY_ENDS, long(KEY_ENDS))
                .putInt(KEY_HOLD_COUNT, int(KEY_HOLD_COUNT))
                .putInt(KEY_WATCHING, int(KEY_WATCHING))
                .putInt(KEY_AT_TARGET, int(KEY_AT_TARGET))
                .putString(KEY_SAVED, string(KEY_SAVED))
                .putInt(KEY_AVOIDED, int(KEY_AVOIDED))
                .apply()
            refresh(context)
        }

        fun refresh(context: Context) {
            val ids = ids(context)
            if (ids.isEmpty()) return
            context.sendBroadcast(updateIntent(context, ids))
        }

        private fun ids(context: Context): IntArray =
            AppWidgetManager.getInstance(context).getAppWidgetIds(
                ComponentName(context, ClarionWidgetProvider::class.java),
            )

        private fun updateIntent(context: Context, ids: IntArray) =
            Intent(context, ClarionWidgetProvider::class.java).apply {
                action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
                putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, ids)
            }
    }
}

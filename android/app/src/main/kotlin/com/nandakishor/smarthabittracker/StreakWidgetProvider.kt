package com.nandakishor.smarthabittracker

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.graphics.BitmapFactory
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider
import java.text.SimpleDateFormat
import java.util.Calendar
import java.util.Date
import java.util.Locale

class StreakWidgetProvider : HomeWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        val state = WidgetState.from(widgetData)
        val mood = state.mood()

        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.streak_widget_layout).apply {
                setTextViewText(R.id.widget_streak_count, "${state.streak} 🔥")
                setTextViewText(R.id.widget_message, state.message(mood))

                widgetData.getString("ember_$mood", null)
                    ?.let { BitmapFactory.decodeFile(it) }
                    ?.let { setImageViewBitmap(R.id.widget_ember, it) }

                setOnClickPendingIntent(
                    R.id.widget_root,
                    HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java)
                )
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}

/**
 * The widget's view of today. Mirrors emberMoodFor() in
 * lib/presentation/widgets/mascot/ember_mood.dart, so the widget can change
 * mood (e.g. "worried" after 6 PM, or a new day) without opening the app.
 */
private data class WidgetState(
    val streak: Int,
    val completed: Int,
    val total: Int,
    val perfect: Boolean,
    val freezeSavedYesterday: Boolean,
    val isToday: Boolean,
    val hour: Int,
) {
    fun mood(): String = when {
        total == 0 -> "idle"
        perfect -> "celebrating"
        freezeSavedYesterday && completed == 0 -> "frozen"
        hour >= WORRY_HOUR && streak > 0 -> "worried"
        completed > 0 -> "cheering"
        else -> "idle"
    }

    fun message(mood: String): String = when (mood) {
        "celebrating" -> "All done today!"
        "frozen" -> "Saved by a freeze"
        "worried" -> "Streak at risk!"
        "cheering" -> "$completed of $total done"
        else -> if (total == 0) "Add a habit" else "$total habits today"
    }

    companion object {
        const val WORRY_HOUR = 18

        fun from(data: SharedPreferences): WidgetState {
            val today = SimpleDateFormat("yyyy-MM-dd", Locale.US).format(Date())
            // Data saved on an earlier day: nothing is done yet today.
            val isToday = data.getString("data_date", null) == today
            return WidgetState(
                streak = data.getInt("streak_count", 0),
                completed = if (isToday) data.getInt("completed_count", 0) else 0,
                total = data.getInt("total_count", 0),
                perfect = isToday && data.getBoolean("is_today_perfect", false),
                freezeSavedYesterday = isToday && data.getBoolean("freeze_saved_yesterday", false),
                isToday = isToday,
                hour = Calendar.getInstance().get(Calendar.HOUR_OF_DAY),
            )
        }
    }
}

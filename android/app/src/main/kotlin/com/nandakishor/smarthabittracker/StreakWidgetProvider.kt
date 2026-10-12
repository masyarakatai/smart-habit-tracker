package com.nandakishor.smarthabittracker

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

class StreakWidgetProvider : HomeWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.streak_widget_layout).apply {
                val streakCount = widgetData.getInt("streak_count", 0)
                val message = widgetData.getString("widget_message", "Track daily habits")

                setTextViewText(R.id.widget_streak_count, "$streakCount")
                setTextViewText(R.id.widget_message, message)
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}

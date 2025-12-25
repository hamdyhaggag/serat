package com.serat.app.serat

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.graphics.Color
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

class PrayerWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.prayer_widget).apply {
                // Header Details
                setTextViewText(R.id.widget_current_time, widgetData.getString("current_time", "00:00"))
                setTextViewText(R.id.widget_hijri_date, widgetData.getString("hijri_date", "--"))

                // Progress Logic
                val progress = widgetData.getInt("progress", 0)
                val colorHex = widgetData.getString("progress_color", "#00FFCC")
                
                // Hide all first
                setViewVisibility(R.id.progress_green, View.GONE)
                setViewVisibility(R.id.progress_red, View.GONE)
                setViewVisibility(R.id.progress_yellow, View.GONE)

                // Show and update the correct one based on color stored
                val targetId = when(colorHex) {
                    "#FF4444" -> R.id.progress_red
                    "#FFD700" -> R.id.progress_yellow
                    else -> R.id.progress_green
                }
                
                setViewVisibility(targetId, View.VISIBLE)
                setProgressBar(targetId, 100, progress, false)

                // Footer Countdown
                setTextViewText(R.id.widget_rem_h, widgetData.getString("rem_h", "0"))
                setTextViewText(R.id.widget_rem_m, widgetData.getString("rem_m", "00"))
                
                // Status Label (Iqamah/Prayer)
                val label = widgetData.getString("iqamah_label", "للصلاة")
                setTextViewText(R.id.widget_label, label)
                if (colorHex == "#FFD700") {
                    setTextColor(R.id.widget_label, Color.parseColor("#FFD700"))
                } else {
                    setTextColor(R.id.widget_label, Color.parseColor("#CCFFFFFF"))
                }

                // Prayer Names & Times
                setTextViewText(R.id.widget_prev_name, widgetData.getString("prev_name", "--"))
                setTextViewText(R.id.widget_prev_time, widgetData.getString("prev_time", "--:--"))
                setTextViewText(R.id.widget_next_name, widgetData.getString("next_name", "--"))
                setTextViewText(R.id.widget_next_time, widgetData.getString("next_time", "--:--"))
            }
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}

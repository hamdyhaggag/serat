package com.serat.app.serat

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.os.Bundle
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

class ListPrayerWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.list_prayer_widget).apply {
                // Click to Open App
                val pendingIntent = HomeWidgetLaunchIntent.getActivity(
                    context,
                    MainActivity::class.java
                )
                setOnClickPendingIntent(R.id.widget_root, pendingIntent)

                val nextIndex = widgetData.getInt("next_index", -1)

                // List of Row and Text IDs for easier mapping
                val rows = arrayOf(
                    R.id.row_fajr, R.id.row_sunrise, R.id.row_dhuhr,
                    R.id.row_asr, R.id.row_maghrib, R.id.row_isha
                )
                
                val names = arrayOf("fajr", "sunrise", "dhuhr", "asr", "maghrib", "isha")

                for (i in rows.indices) {
                    val name = names[i]
                    val time = widgetData.getString("${name}_time", "--:--")
                    val ampm = widgetData.getString("${name}_ampm", "")

                    // Update contents
                    val timeId = when(i) {
                        0 -> R.id.time_fajr
                        1 -> R.id.time_sunrise
                        2 -> R.id.time_dhuhr
                        3 -> R.id.time_asr
                        4 -> R.id.time_maghrib
                        else -> R.id.time_isha
                    }
                    val ampmId = when(i) {
                        0 -> R.id.ampm_fajr
                        1 -> R.id.ampm_sunrise
                        2 -> R.id.ampm_dhuhr
                        3 -> R.id.ampm_asr
                        4 -> R.id.ampm_maghrib
                        else -> R.id.ampm_isha
                    }

                    setTextViewText(timeId, time)
                    setTextViewText(ampmId, ampm)

                    // Highlight logic
                    if (i == nextIndex) {
                        setInt(rows[i], "setBackgroundResource", R.drawable.prayer_highlight_background)
                    } else {
                        setInt(rows[i], "setBackgroundResource", 0) // Transparent
                    }
                }
            }
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }

    override fun onAppWidgetOptionsChanged(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int,
        newOptions: android.os.Bundle
    ) {
        super.onAppWidgetOptionsChanged(context, appWidgetManager, appWidgetId, newOptions)
        val widgetData = es.antonborri.home_widget.HomeWidgetPlugin.getData(context)
        onUpdate(context, appWidgetManager, intArrayOf(appWidgetId), widgetData)
    }
}

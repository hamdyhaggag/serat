package com.serat.app.serat

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.content.Intent
import android.os.Bundle
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider
import es.antonborri.home_widget.HomeWidgetPlugin
import android.util.Log

class ListPrayerWidgetProvider : HomeWidgetProvider() {
    private val TAG = "ListPrayerWidgetProvider"

    override fun onEnabled(context: Context) {
        super.onEnabled(context)
        Log.d(TAG, "Widget enabled - initializing default data")
        
        // Initialize with default placeholder data so the widget shows something immediately
        try {
            val prefs = HomeWidgetPlugin.getData(context)
            val editor = prefs.edit()
            
            // Check if data already exists, if not initialize with defaults
            if (!prefs.contains("fajr_time")) {
                editor.putString("fajr_time", "--:--")
                editor.putString("fajr_ampm", "")
                editor.putString("sunrise_time", "--:--")
                editor.putString("sunrise_ampm", "")
                editor.putString("dhuhr_time", "--:--")
                editor.putString("dhuhr_ampm", "")
                editor.putString("asr_time", "--:--")
                editor.putString("asr_ampm", "")
                editor.putString("maghrib_time", "--:--")
                editor.putString("maghrib_ampm", "")
                editor.putString("isha_time", "--:--")
                editor.putString("isha_ampm", "")
                editor.putInt("next_index", 0)
                editor.apply()
                Log.d(TAG, "Default widget data initialized")
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error initializing default widget data: ${e.message}", e)
        }
    }

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        
        // Handle BOOT_COMPLETED and other broadcasts to refresh widget
        if (intent.action == Intent.ACTION_BOOT_COMPLETED ||
            intent.action == "android.appwidget.action.APPWIDGET_UPDATE") {
            Log.d(TAG, "Received broadcast: ${intent.action}")
        }
    }

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        for (appWidgetId in appWidgetIds) {
            try {
                val views = RemoteViews(context.packageName, R.layout.list_prayer_widget).apply {
                    // Click to Open App
                    val pendingIntent = HomeWidgetLaunchIntent.getActivity(
                        context,
                        MainActivity::class.java
                    )
                    setOnClickPendingIntent(R.id.widget_root, pendingIntent)

                    val nextIndex = widgetData.getInt("next_index", 0)

                    // List of Row and Text IDs for easier mapping
                    val rows = arrayOf(
                        R.id.row_fajr, R.id.row_sunrise, R.id.row_dhuhr,
                        R.id.row_asr, R.id.row_maghrib, R.id.row_isha
                    )
                    
                    val names = arrayOf("fajr", "sunrise", "dhuhr", "asr", "maghrib", "isha")

                    for (i in rows.indices) {
                        val name = names[i]
                        val time = widgetData.getString("${name}_time", "--:--") ?: "--:--"
                        val ampm = widgetData.getString("${name}_ampm", "") ?: ""

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
            } catch (e: Exception) {
                Log.e(TAG, "Error updating widget $appWidgetId: ${e.message}", e)
                // Create a basic fallback widget view
                try {
                    val fallbackViews = RemoteViews(context.packageName, R.layout.list_prayer_widget).apply {
                        val pendingIntent = HomeWidgetLaunchIntent.getActivity(
                            context,
                            MainActivity::class.java
                        )
                        setOnClickPendingIntent(R.id.widget_root, pendingIntent)
                    }
                    appWidgetManager.updateAppWidget(appWidgetId, fallbackViews)
                } catch (fallbackError: Exception) {
                    Log.e(TAG, "Fallback also failed: ${fallbackError.message}", fallbackError)
                }
            }
        }
    }

    override fun onAppWidgetOptionsChanged(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int,
        newOptions: android.os.Bundle
    ) {
        super.onAppWidgetOptionsChanged(context, appWidgetManager, appWidgetId, newOptions)
        try {
            val widgetData = HomeWidgetPlugin.getData(context)
            onUpdate(context, appWidgetManager, intArrayOf(appWidgetId), widgetData)
        } catch (e: Exception) {
            Log.e(TAG, "Error in onAppWidgetOptionsChanged: ${e.message}", e)
        }
    }
}

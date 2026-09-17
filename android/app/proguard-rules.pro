-keep class com.bytedance.sdk.shortplay.** { *; }
-keep class com.bytedance.** { *; }

# Optional BytePlus VOD enhancement modules are referenced reflectively by the
# player but are not shipped by Dramaverse. Core playback does not require them.
-dontwarn com.bytedance.bmf_mods_api.**
-dontwarn com.bytedance.bmf_mods_lite_api.**
-dontwarn com.bytedance.bpea.basics.**
-dontwarn com.bytedance.crash.**
-dontwarn com.bytedancehttpdns.httpdns.**
-dontwarn com.google.android.exoplayer2.util.Log
-dontwarn com.ss.ttm.utils.InitConfig$Type
-dontwarn com.ss.ugc.clientai.core.api.**

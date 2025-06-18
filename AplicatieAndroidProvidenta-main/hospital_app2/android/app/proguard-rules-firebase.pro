# Keep Firebase classes
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-keep class com.google.firebase.messaging.** { *; }

# Keep FCM classes
-keep class com.google.firebase.messaging.FirebaseMessagingService { *; }
-keep class com.google.firebase.iid.FirebaseInstanceId { *; }
-keep class com.google.firebase.iid.FirebaseInstanceIdService { *; }

# Keep platform channels
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugins.** { *; }

# Keep notification plugin classes
-keep class com.dexterous.** { *; }
-keep class me.carda.** { *; }

# Keep model classes used in platform channels
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}

# Keep Flutter engine
-keep class io.flutter.embedding.engine.** { *; }
-keep class io.flutter.embedding.android.** { *; }
-keep class io.flutter.plugin.common.** { *; }

# Keep notification channel details
-keepnames class * extends android.content.BroadcastReceiver
-keepnames class * extends android.app.Service

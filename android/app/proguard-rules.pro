# Flutter
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.embedding.**

# GetX
-keep class com.google.** { *; }
-keepattributes *Annotation*
-keepattributes SourceFile,LineNumberTable

# flutter_local_notifications
-keep class com.dexterous.** { *; }

# mobile_scanner
-keep class com.google.zxing.** { *; }
-keep class com.journeyapps.** { *; }

# Keep app models
-keep class com.aidora.** { *; }

# General
-dontwarn **
-keep class * extends java.lang.annotation.Annotation { *; }

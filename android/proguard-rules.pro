-dontoptimize
-dontpreverify

-dontwarn cn.jpush.**
-keep class cn.jpush.** { *; }
-keep class * extends cn.jpush.android.helpers.JPushMessageReceiver { *; }

-dontwarn cn.jiguang.**
-keep class cn.jiguang.** { *; }

# xiaomi
-dontwarn com.xiaomi.push.**
-keep class com.xiaomi.push.** { *; }

# huawei
-ignorewarning
-keepattributes *Annotation*
-keepattributes Exceptions
-keepattributes InnerClasses
-keepattributes Signature
-keepattributes SourceFile,LineNumberTable
-keep class com.hianalytics.android.**{*;}
-keep class com.huawei.updatesdk.**{*;}
-keep class com.huawei.hms.**{*;}

# meizu
-dontwarn com.meizu.cloud.**
-keep class com.meizu.cloud.** { *; }

# VIVO
-dontwarn com.vivo.push.**
-keep class com.vivo.push.**{*; }
-keep class com.vivo.vms.**{*; }

# OPPO
-dontwarn com.coloros.mcsdk.**
-keep class com.coloros.mcsdk.** { *; }
-dontwarn com.heytap.**
-keep class com.heytap.** { *; }
-dontwarn com.mcs.**
-keep class com.mcs.** { *; }




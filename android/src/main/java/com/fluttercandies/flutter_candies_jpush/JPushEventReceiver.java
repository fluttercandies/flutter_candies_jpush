package com.fluttercandies.flutter_candies_jpush;

import android.content.Context;
import android.content.Intent;
import android.os.Handler;
import android.util.Log;
import android.util.Pair;

import com.google.gson.Gson;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import cn.jpush.android.api.CmdMessage;
import cn.jpush.android.api.CustomMessage;
import cn.jpush.android.api.JPushInterface;
import cn.jpush.android.api.JPushMessage;
import cn.jpush.android.api.NotificationMessage;
import cn.jpush.android.service.JPushMessageReceiver;
import io.flutter.plugin.common.MethodChannel;

/**
 * 基于广播接收各种回调
 */
public class JPushEventReceiver extends JPushMessageReceiver {
    static FlutterCandiesJPushPlugin plugin;
    static String registrationId;
    static List<MethodChannel.Result> obtainRidCache = new ArrayList<>();
    static HashMap<Integer, Pair<String, MethodChannel.Result>> callbacks = new HashMap<>();

    @Override // 注册成功回调
    public void onRegister(Context context, String registrationId) {
        super.onRegister(context, registrationId);
        JPushEventReceiver.registrationId = registrationId;
        for (MethodChannel.Result result : JPushEventReceiver.obtainRidCache) {
            result.success(registrationId);
        }
        JPushEventReceiver.obtainRidCache.clear();
    }

    @SuppressWarnings({"ConstantConditions"})
    @Override // 别名操作回调
    public void onAliasOperatorResult(Context context, JPushMessage jPushMessage) {
        super.onAliasOperatorResult(context, jPushMessage);
        Pair<String, MethodChannel.Result> callback = callbacks.remove(jPushMessage.getSequence());
        switch (callback.first) {
            case "setAlias":
            case "deleteAlias":
                callback.second.success(jPushMessage.getErrorCode() == 0);
                break;
            case "getAlias":
                callback.second.success(jPushMessage.getAlias());
                break;
        }
        if (jPushMessage.getErrorCode() == 0) return;
        Log.d(FlutterCandiesJPushPlugin.TAG, callback.first + " error:" + jPushMessage.getErrorCode());

    }

    @SuppressWarnings({"ConstantConditions"})
    @Override // 标签操作回调
    public void onTagOperatorResult(Context context, JPushMessage jPushMessage) {
        super.onTagOperatorResult(context, jPushMessage);
        Pair<String, MethodChannel.Result> callback = callbacks.remove(jPushMessage.getSequence());
        switch (callback.first) {
            case "setTags":
            case "addTags":
            case "deleteTags":
            case "cleanTags":
                callback.second.success(jPushMessage.getErrorCode() == 0);
                break;
            case "getAllTags":
                callback.second.success(jPushMessage.getTags());
                break;
        }
        if (jPushMessage.getErrorCode() == 0) return;
        Log.d(FlutterCandiesJPushPlugin.TAG, callback.first + " error:" + jPushMessage.getErrorCode());
    }

    @SuppressWarnings({"ConstantConditions"})
    @Override // 查询标签绑定状态回调
    public void onCheckTagOperatorResult(Context context, JPushMessage jPushMessage) {
        super.onCheckTagOperatorResult(context, jPushMessage);
        Pair<String, MethodChannel.Result> callback = callbacks.remove(jPushMessage.getSequence());
        callback.second.success(jPushMessage.getTagCheckStateResult());
        if (jPushMessage.getErrorCode() == 0) return;
        Log.d(FlutterCandiesJPushPlugin.TAG, callback.first + " " + jPushMessage.getCheckTag() + " error:" + jPushMessage.getErrorCode());
    }

    @Override // 长连接状态回调
    public void onConnected(Context context, boolean b) {
        super.onConnected(context, b);
    }

    @Override // 交互事件回调
    public void onCommandResult(Context context, CmdMessage cmdMessage) {
        super.onCommandResult(context, cmdMessage);
    }

    @Override // 通知开关状态回调
    public void onNotificationSettingsCheck(Context context, boolean b, int i) {
        super.onNotificationSettingsCheck(context, b, i);
        if (plugin == null) return;
    }

    @SuppressWarnings({"ConstantConditions"})
    @Override // 设置手机号码回调
    public void onMobileNumberOperatorResult(Context context, JPushMessage jPushMessage) {
        super.onMobileNumberOperatorResult(context, jPushMessage);
        Pair<String, MethodChannel.Result> callback = callbacks.remove(jPushMessage.getSequence());
        callback.second.success(jPushMessage.getErrorCode() == 0);
        if (jPushMessage.getErrorCode() == 0) return;
        Log.d(FlutterCandiesJPushPlugin.TAG, callback.first + " error:" + jPushMessage.getErrorCode());
    }

    @Override // 自定义消息回调
    public void onMessage(Context context, CustomMessage customMessage) {
        super.onMessage(context, customMessage);
        if (plugin == null) return;
        Gson gson = new Gson();
        Map<String, Object> msg = new HashMap<>();
        msg.put("messageId", customMessage.messageId);
        msg.put("title", customMessage.title);
        msg.put("message", customMessage.message);
        msg.put("extras", gson.fromJson(customMessage.extra, Map.class));
        new Handler(context.getMainLooper()).post(() -> plugin.channel.invokeMethod("onReceiveMessage", msg));
    }

    @Override // 收到通知回调
    public void onNotifyMessageArrived(Context context, NotificationMessage notificationMessage) {
        super.onNotifyMessageArrived(context, notificationMessage);
        if (plugin == null) return;
        Gson gson = new Gson();
        Map<String, Object> msg = new HashMap<>();
        msg.put("noticeId", notificationMessage.notificationId);
        msg.put("messageId", notificationMessage.msgId);
        msg.put("title", notificationMessage.notificationTitle);
        msg.put("message", notificationMessage.notificationContent);
        msg.put("extras", gson.fromJson(notificationMessage.notificationExtras, Map.class));
        new Handler(context.getMainLooper()).post(() -> plugin.channel.invokeMethod("onReceiveNotification", msg));
    }

    @Override // 点击通知回调
    public void onNotifyMessageOpened(Context context, NotificationMessage notificationMessage) {
        super.onNotifyMessageOpened(context, notificationMessage);
        JPushInterface.reportNotificationOpened(context, notificationMessage.msgId);
        if (plugin == null) return;
        Gson gson = new Gson();
        Map<String, Object> msg = new HashMap<>();
        msg.put("noticeId", notificationMessage.notificationId);
        msg.put("messageId", notificationMessage.msgId);
        msg.put("title", notificationMessage.notificationTitle);
        msg.put("message", notificationMessage.notificationContent);
        msg.put("extras", gson.fromJson(notificationMessage.notificationExtras, Map.class));
        new Handler(context.getMainLooper()).post(() -> plugin.channel.invokeMethod("onOpenNotification", msg));
        Intent launch = context.getPackageManager().getLaunchIntentForPackage(context.getPackageName());
        if (launch == null) return;
        launch.addCategory(Intent.CATEGORY_LAUNCHER);
        launch.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_SINGLE_TOP);
        context.startActivity(launch);
    }

    @Override // 通知未展示回调
    public void onNotifyMessageUnShow(Context context, NotificationMessage notificationMessage) {
        super.onNotifyMessageUnShow(context, notificationMessage);
    }

    @Override // 清除通知回调
    public void onNotifyMessageDismiss(Context context, NotificationMessage notificationMessage) {
        super.onNotifyMessageDismiss(context, notificationMessage);
    }
}

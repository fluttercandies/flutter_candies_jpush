package com.fluttercandies.flutter_candies_jpush;

import android.app.Activity;
import android.content.Context;
import android.util.Log;
import android.util.Pair;

import androidx.annotation.NonNull;

import org.json.JSONObject;

import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.concurrent.atomic.AtomicInteger;

import cn.jiguang.api.utils.JCollectionAuth;
import cn.jpush.android.api.JPushInterface;
import cn.jpush.android.data.JPushLocalNotification;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/**
 * FlutterCandiesJPushPlugin
 */
public class FlutterCandiesJPushPlugin implements FlutterPlugin, MethodCallHandler, ActivityAware {
    private Activity activity;
    private MethodChannel channel;
    private Context applicationContext;
    protected static final String TAG = "JPushPlugin";
    private final AtomicInteger callbackSequence = new AtomicInteger(0);


    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "jpush");
        applicationContext = flutterPluginBinding.getApplicationContext();
        channel.setMethodCallHandler(this);
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        switch (call.method) {
            case "getPlatformVersion":
                result.success("Android " + android.os.Build.VERSION.RELEASE);
                break;
            case "setAuth":
                setAuth(call, result);
                break;
            case "setup":
                setup(call, result);
                break;
            case "getRegistrationId":
                getRegistrationId(result);
                break;
            case "getConnectionState":
                getConnectionState(result);
                break;
            case "isNotificationEnabled":
                isNotificationEnabled(call, result);
                break;
            case "openSettingsForNotification":
                openSettingsForNotification(call, result);
                break;
            case "addLocalNotification":
                addLocalNotification(call, result);
                break;
            case "removeLocalNotification":
                removeLocalNotification(call, result);
                break;
            case "clearNotification":
                clearNotification(call, result);
                break;
            case "clearAllNotifications":
                clearAllNotifications(call, result);
                break;
            case "getLaunchAppNotification":
                getLaunchAppNotification(call, result);
                break;
            case "stopPush":
                stopPush(call, result);
                break;
            case "resumePush":
                resumePush(call, result);
                break;
            case "setBadge":
                setBadge(call, result);
                break;
            case "setMobileNumber":
                setMobileNumber(call, result);
                break;
            case "setAlias":
                setAlias(call, result);
                break;
            case "deleteAlias":
                deleteAlias(call, result);
                break;
            case "getAlias":
                getAlias(call, result);
                break;
            case "filterValidTags":
                filterValidTags(call, result);
                break;
            case "setTags":
                setTags(call, result);
                break;
            case "addTags":
                addTags(call, result);
                break;
            case "deleteTags":
                deleteTags(call, result);
                break;
            case "cleanTags":
                cleanTags(call, result);
                break;
            case "getAllTags":
                getAllTags(call, result);
                break;
            case "checkTagBindState":
                checkTagBindState(call, result);
                break;
            default:
                result.notImplemented();
        }
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
        applicationContext = null;
    }

    @SuppressWarnings({"ConstantConditions"})
    private void setAuth(MethodCall call, Result result) {
        Log.d(TAG, "setAuth: " + call.arguments.toString());
        JCollectionAuth.setAuth(applicationContext, call.arguments());
        result.success(null);
    }

    @SuppressWarnings({"ConstantConditions"})
    private void setup(MethodCall call, Result result) {
        Log.d(TAG, "setup: " + call.arguments.toString());
        Boolean debug = call.argument("debug");
        JPushInterface.setDebugMode(debug);
        JPushInterface.init(applicationContext);
        String channel = call.argument("channel");
        JPushInterface.setChannel(applicationContext, channel);
        result.success(null);
    }

    private void getRegistrationId(Result result) {
        Log.d(TAG, "getRegistrationId");
        String registrationID = JPushInterface.getRegistrationID(applicationContext);
        if (registrationID.isEmpty()) {
            JPushEventReceiver.obtainRidCache.add(result);
        } else {
            result.success(registrationID);
        }
    }

    private void getConnectionState(Result result) {
        Log.d(TAG, "getConnectionState");
        boolean connectionState = JPushInterface.getConnectionState(applicationContext);
        result.success(connectionState);
    }

    private void isNotificationEnabled(MethodCall call, Result result) {
        Log.d(TAG, "isNotificationEnabled");
        int enabledState = JPushInterface.isNotificationEnabled(applicationContext);
        result.success(enabledState == 1);
    }

    private void openSettingsForNotification(MethodCall call, Result result) {
        Log.d(TAG, "openSettingsForNotification");
        JPushInterface.goToAppNotificationSettings(applicationContext);
        result.success(null);
    }

    @SuppressWarnings({"ConstantConditions"})
    private void addLocalNotification(MethodCall call, Result result) {
        Log.d(TAG, "addLocalNotification: " + call.arguments.toString());
        Long buildId = call.argument("buildId");
        Long notificationId = call.argument("id");
        String title = call.argument("title");
        String content = call.argument("content");

        JPushLocalNotification localNotification = new JPushLocalNotification();
        localNotification.setBuilderId(buildId);
        localNotification.setNotificationId(notificationId);
        localNotification.setTitle(title);
        localNotification.setContent(content);
        if (call.hasArgument("fireTime") && (Long) call.argument("fireTime") > 0) {
            Long fireTime = call.argument("fireTime");
            localNotification.setBroadcastTime(fireTime);
        }
        HashMap<String, Object> extras = call.argument("extras");
        if (extras != null) {
            JSONObject json = new JSONObject(extras);
            localNotification.setExtras(json.toString());
        }
        JPushInterface.addLocalNotification(applicationContext, localNotification);
        result.success(null);
    }

    @SuppressWarnings({"ConstantConditions"})
    private void removeLocalNotification(MethodCall call, Result result) {
        Log.d(TAG, "removeLocalNotification: " + call.arguments.toString());
        Integer id = call.arguments();
        JPushInterface.removeLocalNotification(applicationContext, id);
        result.success(null);
    }

    @SuppressWarnings({"ConstantConditions"})
    private void clearNotification(MethodCall call, Result result) {
        Log.d(TAG, "clearNotification: " + call.arguments.toString());
        Integer id = call.arguments();
        JPushInterface.clearNotificationById(applicationContext, id);
        result.success(null);
    }

    private void clearAllNotifications(MethodCall call, Result result) {
        Log.d(TAG, "clearAllNotifications");
        JPushInterface.clearAllNotifications(applicationContext);
        result.success(null);
    }

    private void getLaunchAppNotification(MethodCall call, Result result) {
        Log.d(TAG, "getLaunchAppNotification"); /// IOS
        result.success(null);
    }

    private void stopPush(MethodCall call, Result result) {
        Log.d(TAG, "stopPush");
        JPushInterface.stopPush(applicationContext);
        result.success(null);
    }

    private void resumePush(MethodCall call, Result result) {
        Log.d(TAG, "resumePush");
        JPushInterface.resumePush(applicationContext);
        result.success(null);
    }

    @SuppressWarnings({"ConstantConditions"})
    private void setBadge(MethodCall call, Result result) {
        Log.d(TAG, "setBadge: " + call.arguments.toString());
        Integer badge = call.arguments();
        JPushInterface.setBadgeNumber(applicationContext, badge);
        result.success(null);
    }

    private void setMobileNumber(MethodCall call, Result result) {
        Log.d(TAG, "setMobileNumber: " + call.arguments.toString());
        String mobileNumber = call.arguments();
        int sequence = callbackSequence.incrementAndGet();
        JPushInterface.setMobileNumber(applicationContext, sequence, mobileNumber);
    }

    private void setAlias(MethodCall call, Result result) {
        Log.d(TAG, "setAlias: " + call.arguments.toString());
        String alias = call.arguments();
        int sequence = callbackSequence.incrementAndGet();
        JPushInterface.setAlias(applicationContext, sequence, alias);
        JPushEventReceiver.callbacks.put(sequence, new Pair<>("setAlias", result));
    }

    private void deleteAlias(MethodCall call, Result result) {
        Log.d(TAG, "deleteAlias");
        int sequence = callbackSequence.incrementAndGet();
        JPushInterface.deleteAlias(applicationContext, sequence);
        JPushEventReceiver.callbacks.put(sequence, new Pair<>("deleteAlias", result));
    }

    private void getAlias(MethodCall call, Result result) {
        Log.d(TAG, "getAlias");
        int sequence = callbackSequence.incrementAndGet();
        JPushInterface.getAlias(applicationContext, sequence);
        JPushEventReceiver.callbacks.put(sequence, new Pair<>("getAlias", result));
    }

    @SuppressWarnings({"ConstantConditions"})
    private void filterValidTags(MethodCall call, Result result) {
        Log.d(TAG, "filterValidTags" + call.arguments.toString());
        List<String> tags = call.arguments();
        result.success(JPushInterface.filterValidTags(new HashSet<>(tags)).toArray());
    }

    private void setTags(MethodCall call, Result result) {
        Log.d(TAG, "setTags: " + call.arguments.toString());
        List<String> tags = call.arguments();
        assert tags != null;
        int sequence = callbackSequence.incrementAndGet();
        JPushInterface.setTags(applicationContext, sequence, new HashSet<>(tags));
        JPushEventReceiver.callbacks.put(sequence, new Pair<>("setTags", result));
    }

    private void addTags(MethodCall call, Result result) {
        Log.d(TAG, "addTags: " + call.arguments.toString());
        List<String> tags = call.arguments();
        assert tags != null;
        int sequence = callbackSequence.incrementAndGet();
        JPushInterface.setTags(applicationContext, sequence, new HashSet<>(tags));
        JPushEventReceiver.callbacks.put(sequence, new Pair<>("addTags", result));
    }

    @SuppressWarnings({"ConstantConditions"})
    private void deleteTags(MethodCall call, Result result) {
        Log.d(TAG, "deleteTags: " + call.arguments.toString());
        List<String> tags = call.arguments();
        int sequence = callbackSequence.incrementAndGet();
        JPushInterface.deleteTags(applicationContext, sequence, new HashSet<>(tags));
        JPushEventReceiver.callbacks.put(sequence, new Pair<>("deleteTags", result));
    }

    private void cleanTags(MethodCall call, Result result) {
        Log.d(TAG, "cleanTags");
        int sequence = callbackSequence.incrementAndGet();
        JPushInterface.cleanTags(applicationContext, sequence);
        JPushEventReceiver.callbacks.put(sequence, new Pair<>("cleanTags", result));
    }

    private void getAllTags(MethodCall call, Result result) {
        Log.d(TAG, "getAllTags");
        int sequence = callbackSequence.incrementAndGet();
        JPushInterface.getAllTags(applicationContext, sequence);
        JPushEventReceiver.callbacks.put(sequence, new Pair<>("getAllTags", result));
    }

    private void checkTagBindState(MethodCall call, Result result) {
        Log.d(TAG, "checkTagBindState: " + call.arguments.toString());
        String tag = call.arguments();
        int sequence = callbackSequence.incrementAndGet();
        JPushInterface.checkTagBindState(applicationContext, sequence, tag);
        JPushEventReceiver.callbacks.put(sequence, new Pair<>("checkTagBindState", result));
    }

    @Override
    public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
        activity = binding.getActivity();
        JPushInterface.onResume(activity);
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {
        JPushInterface.onPause(activity);
        activity = null;
    }

    @Override
    public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
        activity = binding.getActivity();
        JPushInterface.onResume(activity);
    }

    @Override
    public void onDetachedFromActivity() {
        JPushInterface.onPause(activity);
        activity = null;
    }
}

#import <JCore/JGInforCollectionAuth.h>
#import "FlutterCandiesJPushPlugin.h"
#import "JPUSHService.h"

#ifdef NSFoundationVersionNumber_iOS_9_x_Max

#import <UserNotifications/UserNotifications.h>

#endif

#if defined(__IPHONE_10_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0

@interface FlutterCandiesJPushPlugin () <JPUSHRegisterDelegate>
@end

#endif

@implementation FlutterCandiesJPushPlugin {
    NSDictionary *_launchNotification;
    NSDictionary *_completeLaunchNotification;
    BOOL _isJPushDidLogin;
    JPAuthorizationOptions notificationTypes;
}

- (id)init {
    self = [super init];
    notificationTypes = JPAuthorizationOptionNone;
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];

    [defaultCenter removeObserver:self];

    [defaultCenter addObserver:self
                      selector:@selector(networkConnecting:)
                          name:kJPFNetworkIsConnectingNotification
                        object:nil];

    [defaultCenter addObserver:self
                      selector:@selector(networkRegister:)
                          name:kJPFNetworkDidRegisterNotification
                        object:nil];

    [defaultCenter addObserver:self
                      selector:@selector(networkDidSetup:)
                          name:kJPFNetworkDidSetupNotification
                        object:nil];
    [defaultCenter addObserver:self
                      selector:@selector(networkDidClose:)
                          name:kJPFNetworkDidCloseNotification
                        object:nil];
    [defaultCenter addObserver:self
                      selector:@selector(networkDidLogin:)
                          name:kJPFNetworkDidLoginNotification
                        object:nil];
    [defaultCenter addObserver:self
                      selector:@selector(networkDidReceiveMessage:)
                          name:kJPFNetworkDidReceiveMessageNotification
                        object:nil];
    return self;
}

- (void)networkConnecting:(NSNotification *)notification {
    _isJPushDidLogin = false;
}

- (void)networkRegister:(NSNotification *)notification {
    _isJPushDidLogin = false;
}

- (void)networkDidSetup:(NSNotification *)notification {
    _isJPushDidLogin = false;
}

- (void)networkDidClose:(NSNotification *)notification {
    _isJPushDidLogin = false;
}

- (void)networkDidLogin:(NSNotification *)notification {
    _isJPushDidLogin = YES;
}

- (void)networkDidReceiveMessage:(NSNotification *)notification {
    NSDictionary *msg = @{@"messageId": notification.userInfo[@"_j_msgid"], @"title": notification.name,
            @"message": notification.userInfo[@"content"], @"extras": notification.userInfo[@"extras"]};
    [_channel invokeMethod:@"onReceiveMessage" arguments:msg];
}

- (void)dealloc {
    _isJPushDidLogin = NO;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

///
+ (void)registerWithRegistrar:(NSObject <FlutterPluginRegistrar> *)registrar {
    FlutterCandiesJPushPlugin *instance = [[FlutterCandiesJPushPlugin alloc] init];
    instance.channel = [FlutterMethodChannel methodChannelWithName:@"flutter_candies_jpush" binaryMessenger:[registrar messenger]];
    [registrar addApplicationDelegate:instance];
    [registrar addMethodCallDelegate:instance channel:instance.channel];
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
    if ([@"getPlatformVersion" isEqualToString:call.method]) {
        result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
    } else if ([@"setAuth" isEqualToString:call.method]) {
        [self setAuth:call result:result];
    } else if ([@"setup" isEqualToString:call.method]) {
        [self setup:call result:result];
    } else if ([@"applyPushAuthority" isEqualToString:call.method]) {
        [self applyPushAuthority:call result:result];
    } else if ([@"getRegistrationId" isEqualToString:call.method]) {
        [self getRegistrationId:call result:result];
    } else if ([@"getConnectionState" isEqualToString:call.method]) {
        [self getConnectionState:call result:result];
    } else if ([@"isNotificationEnabled" isEqualToString:call.method]) {
        [self isNotificationEnabled:call result:result];
    } else if ([@"openSettingsForNotification" isEqualToString:call.method]) {
        [self openSettingsForNotification:call result:result];
    } else if ([@"addLocalNotification" isEqualToString:call.method]) {
        [self addLocalNotification:call result:result];
    } else if ([@"removeLocalNotification" isEqualToString:call.method]) {
        [self removeLocalNotification:call result:result];
    } else if ([@"clearLocalNotifications" isEqualToString:call.method]) {
        [self clearLocalNotifications:call result:result];
    } else if ([@"clearAllNotifications" isEqualToString:call.method]) {
        [self clearAllNotifications:call result:result];
    } else if ([@"getLaunchAppNotification" isEqualToString:call.method]) {
        [self getLaunchAppNotification:call result:result];
    } else if ([@"stopPush" isEqualToString:call.method]) {
        [self stopPush:call result:result];
    } else if ([@"resumePush" isEqualToString:call.method]) {
        [self resumePush:call result:result];
    } else if ([@"setBadge" isEqualToString:call.method]) {
        [self setBadge:call result:result];
    } else if ([@"setMobileNumber" isEqualToString:call.method]) {
        [self setMobileNumber:call result:result];
    } else if ([@"setAlias" isEqualToString:call.method]) {
        [self setAlias:call result:result];
    } else if ([@"deleteAlias" isEqualToString:call.method]) {
        [self deleteAlias:call result:result];
    } else if ([@"filterValidTags" isEqualToString:call.method]) {
        [self filterValidTags:call result:result];
    } else if ([@"setTags" isEqualToString:call.method]) {
        [self setTags:call result:result];
    } else if ([@"addTags" isEqualToString:call.method]) {
        [self addTags:call result:result];
    } else if ([@"deleteTags" isEqualToString:call.method]) {
        [self deleteTags:call result:result];
    } else if ([@"cleanTags" isEqualToString:call.method]) {
        [self cleanTags:call result:result];
    } else if ([@"getAllTags" isEqualToString:call.method]) {
        [self getAllTags:call result:result];
    } else if ([@"checkTagBindState" isEqualToString:call.method]) {
        [self checkTagBindState:call result:result];
    } else {
        [JPUSHService crashLogON];
        result(FlutterMethodNotImplemented);
    }
}

- (void)setAuth:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSLog(@"setAuth：%@", call.arguments);
    NSNumber *auth = call.arguments;
    [JGInforCollectionAuth JCollectionAuth:^(JGInforCollectionAuthItems *_Nonnull authInfo) {
        authInfo.isAuth = [auth boolValue];
    }];
    result(nil);
}

- (void)setup:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSLog(@"setup：%@", call.arguments);
    NSDictionary *arguments = call.arguments;
    NSNumber *debug = arguments[@"debug"];
    NSString *appKey = arguments[@"appKey"];
    NSString *channel = arguments[@"channel"];
    NSNumber *production = arguments[@"production"];
    if ([debug boolValue]) {
        [JPUSHService setDebugMode];
    } else {
        [JPUSHService setLogOFF];
    }
    [JPUSHService setupWithOption:_completeLaunchNotification appKey:appKey channel:channel
                 apsForProduction:[production boolValue] advertisingIdentifier:nil];
    result(nil);
}

- (void)applyPushAuthority:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSLog(@"applyPushAuthority:%@", call.arguments);
    notificationTypes = JPAuthorizationOptionNone;
    NSDictionary *arguments = call.arguments;
    if ([arguments[@"sound"] boolValue]) {
        notificationTypes |= JPAuthorizationOptionSound;
    }
    if ([arguments[@"alert"] boolValue]) {
        notificationTypes |= JPAuthorizationOptionAlert;
    }
    if ([arguments[@"badge"] boolValue]) {
        notificationTypes |= JPAuthorizationOptionBadge;
    }
    JPUSHRegisterEntity *entity = [[JPUSHRegisterEntity alloc] init];
    entity.types = notificationTypes;
    [JPUSHService registerForRemoteNotificationConfig:entity delegate:self];
    result(nil);
}

- (void)getRegistrationId:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSLog(@"getRegistrationID:");
    [JPUSHService registrationIDCompletionHandler:^(int resCode, NSString *registrationID) {
        if (resCode == 1011) {
            NSLog(@"simulator can not get registrationId");
        }
        registrationID = registrationID ? registrationID : @"";
        result(registrationID);
    }];
}

- (void)getConnectionState:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSLog(@"getConnectionState:");
    result(@(_isJPushDidLogin));
}

- (void)isNotificationEnabled:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSLog(@"isNotificationEnabled:");
    [JPUSHService requestNotificationAuthorization:^(JPAuthorizationStatus status) {
        result(@(status == JPAuthorizationStatusAuthorized));
//        dispatch_async(dispatch_get_main_queue(), ^{
//            result(@(status == JPAuthorizationStatusAuthorized));
//        });
    }];
}

- (void)openSettingsForNotification:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSLog(@"openSettingsForNotification:");
    [JPUSHService openSettingsForNotification:^(BOOL success) {
    }];
}

- (void)addLocalNotification:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSLog(@"addLocalNotification:%@", call.arguments);
    JPushNotificationRequest *request = [[JPushNotificationRequest alloc] init];
    JPushNotificationContent *content = [[JPushNotificationContent alloc] init];
    request.content = content;
    NSDictionary *params = call.arguments;
    if (params[@"id"]) {
        NSNumber *identify = params[@"id"];
        request.requestIdentifier = [identify stringValue];
    }
    if (params[@"title"]) request.content.title = params[@"title"];
    if (params[@"subtitle"] && ![params[@"subtitle"] isEqualToString:@"<null>"]) {
        request.content.subtitle = params[@"subtitle"];
    }
    if (params[@"content"]) request.content.body = params[@"content"];
    if (params[@"fireTime"] && ![params[@"fireTime"] isEqualToNumber:@0]) {
        NSNumber *date = params[@"fireTime"];
        JPushNotificationTrigger *trigger = [[JPushNotificationTrigger alloc] init];
        request.trigger = trigger;
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 10.0) {
            NSTimeInterval currentInterval = [[NSDate date] timeIntervalSince1970];
            NSTimeInterval interval = [date doubleValue] / 1000 - currentInterval;
            interval = interval > 0 ? interval : 0;
            request.trigger.timeInterval = interval;
        } else {
            request.trigger.fireDate = [NSDate dateWithTimeIntervalSince1970:[date doubleValue] / 1000];
        }
    }
    if ([params[@"extra"] isKindOfClass:[NSDictionary class]]) {
        request.content.userInfo = params[@"extra"];
    }
    request.completionHandler = ^(id result) {
        NSLog(@"结果返回：%@", result);
    };
    [JPUSHService addNotification:request];
    result(nil);
}

- (void)removeLocalNotification:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSLog(@"removeLocalNotification:%@", call.arguments);
    JPushNotificationIdentifier *identifier = [[JPushNotificationIdentifier alloc] init];
    identifier.identifiers = @[call.arguments];
    identifier.delivered = YES;
    [JPUSHService removeNotification:identifier];
}

- (void)clearLocalNotifications:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSLog(@"clearLocalNotifications:");
    JPushNotificationIdentifier *identifier = [[JPushNotificationIdentifier alloc] init];
    identifier.identifiers = nil;
    identifier.delivered = YES;
    [JPUSHService removeNotification:identifier];
}

- (void)clearAllNotifications:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSLog(@"clearAllNotifications:");
    JPushNotificationIdentifier *identifier = [[JPushNotificationIdentifier alloc] init];
    identifier.identifiers = nil;
    identifier.delivered = YES;
    [JPUSHService removeNotification:identifier];
}

- (void)getLaunchAppNotification:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSLog(@"getLaunchAppNotification:");
    result(_launchNotification == nil ? @{} : _launchNotification);
}

- (void)stopPush:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSLog(@"stopPush:");
    [[UIApplication sharedApplication] unregisterForRemoteNotifications];
}

- (void)resumePush:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSLog(@"resumePush:");
    [[UIApplication sharedApplication] registerForRemoteNotifications];
}

- (void)setBadge:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSLog(@"setBadge:%@", call.arguments);
    NSInteger badge = [call.arguments[@"badge"] integerValue];
    if (badge < 0) badge = 0;
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:badge];
    [JPUSHService setBadge:badge];
}

- (void)setMobileNumber:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSLog(@"setMobileNumber:%@", call.arguments);
    NSString *mobileNumber = call.arguments;
    [JPUSHService setMobileNumber:mobileNumber completion:^(NSError *error) {
        result(@(@(error == nil).boolValue));
        if (error) NSLog(@"setMobileNumber error:%@", error.description);
    }];
}

- (void)setAlias:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSLog(@"setAlias:%@", call.arguments);
    NSString *alias = call.arguments;
    [JPUSHService setAlias:alias completion:^(NSInteger iResCode, NSString *iAlias, NSInteger seq) {
        result(@(@(iResCode == 0).boolValue));
        if (iResCode != 0) NSLog(@"setAlias error:%@", @(iResCode));
    }                  seq:0];
}

- (void)deleteAlias:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSLog(@"deleteAlias:%@", call.arguments);
    [JPUSHService deleteAlias:^(NSInteger iResCode, NSString *iAlias, NSInteger seq) {
        result(@(@(iResCode == 0).boolValue));
        if (iResCode != 0) NSLog(@"setAlias error:%@", @(iResCode));
    }                     seq:0];
}

- (void)filterValidTags:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSLog(@"filterValidTags:%@", call.arguments);
    NSSet *tags = [NSSet setWithArray:call.arguments];
    tags = [JPUSHService filterValidTags:tags.copy];
    result(tags ? [tags allObjects] : @[]);
}

- (void)setTags:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSLog(@"setTags:%@", call.arguments);
    NSSet *tagSet;
    if (call.arguments != NULL) tagSet = [NSSet setWithArray:call.arguments];
    [JPUSHService setTags:tagSet completion:^(NSInteger iResCode, NSSet *iTags, NSInteger seq) {
                result(@(@(iResCode == 0).boolValue));
                if (iResCode != 0) NSLog(@"setTags error:%@", @(iResCode));
            }
                      seq:0];
}

- (void)addTags:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSLog(@"addTags:%@", call.arguments);
    NSSet *tagSet;
    if (call.arguments != NULL) tagSet = [NSSet setWithArray:call.arguments];
    [JPUSHService addTags:tagSet completion:^(NSInteger iResCode, NSSet *iTags, NSInteger seq) {
                result(@(@(iResCode == 0).boolValue));
                if (iResCode != 0) NSLog(@"addTags error:%@", @(iResCode));
            }
                      seq:0];
}

- (void)deleteTags:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSLog(@"deleteTags:%@", call.arguments);
    NSSet *tagSet;
    if (call.arguments != NULL) tagSet = [NSSet setWithArray:call.arguments];
    [JPUSHService deleteTags:tagSet completion:^(NSInteger iResCode, NSSet *iTags, NSInteger seq) {
                result(@(@(iResCode == 0).boolValue));
                if (iResCode != 0) NSLog(@"deleteTags error:%@", @(iResCode));
            }
                         seq:0];
}

- (void)cleanTags:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSLog(@"cleanTags:");
    [JPUSHService cleanTags:^(NSInteger iResCode, NSSet *iTags, NSInteger seq) {
                result(@(@(iResCode == 0).boolValue));
                if (iResCode != 0) NSLog(@"cleanTags error:%@", @(iResCode));
            }
                        seq:0];
}

- (void)getAllTags:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSLog(@"getAllTags:");
    [JPUSHService getAllTags:^(NSInteger iResCode, NSSet *iTags, NSInteger seq) {
                result(iTags ? [iTags allObjects] : @[]);
                if (iResCode != 0) NSLog(@"getAllTags error:%@", @(iResCode));
            }
                         seq:0];
}

- (void)checkTagBindState:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSLog(@"checkTagBindState:");
    NSString *tag = call.arguments;
    [JPUSHService validTag:tag completion:^(NSInteger iResCode, NSSet *iTags, NSInteger seq, BOOL isBind) {
        result(@(isBind));
        if (iResCode != 0) NSLog(@"checkTagBindState error:%@", @(iResCode));
    }                  seq:0];
}


#pragma mark - AppDelegate

// 如果 App 状态为未运行，此函数将被调用
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    _completeLaunchNotification = launchOptions;
    if (launchOptions == nil) return YES;
    if (launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey]) {
        NSDictionary *userInfo = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
        NSMutableDictionary *msg = [self jpushFormatAPNSDic:userInfo];
        if (userInfo[@"aps"] && userInfo[@"aps"][@"alert"]) {
            NSDictionary *alert = userInfo[@"aps"][@"alert"];
            msg[@"title"] = alert[@"title"];
            msg[@"message"] = alert[@"body"];
        }
        msg[@"title"] = msg[@"title"] ? msg[@"title"] : @"";
        msg[@"message"] = msg[@"message"] ? msg[@"message"] : @"";
        _launchNotification = msg.copy;
    }

    if (launchOptions[UIApplicationLaunchOptionsLocalNotificationKey]) {
        UILocalNotification *localNotification = launchOptions[UIApplicationLaunchOptionsLocalNotificationKey];
        NSMutableDictionary *msg = [self jpushFormatAPNSDic:localNotification.userInfo];
        msg[@"message"] = localNotification.alertBody;
        if (@available(iOS 8.2, *)) msg[@"title"] = localNotification.alertTitle;
        _launchNotification = msg.copy;
    }
    //[self performSelector:@selector(addNotificationWithDateTrigger) withObject:nil afterDelay:2];
    return YES;
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    //  _resumingFromBackground = YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    //  application.applicationIconBadgeNumber = 1;
    //  application.applicationIconBadgeNumber = 0;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [JPUSHService registerDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    NSDictionary *settingsDictionary = @{
            @"sound": @(notificationSettings.types & UIUserNotificationTypeSound),
            @"badge": @(notificationSettings.types & UIUserNotificationTypeBadge),
            @"alert": @(notificationSettings.types & UIUserNotificationTypeAlert),
    };
    [_channel invokeMethod:@"onIosSettingsRegistered" arguments:settingsDictionary];
}


// iOS 10 以下 接到通知
- (BOOL)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    NSLog(@"application:didReceiveRemoteNotification:fetchCompletionHandler");
    [JPUSHService handleRemoteNotification:userInfo];
    NSMutableDictionary *msg = [self jpushFormatAPNSDic:userInfo];
    if (userInfo[@"aps"] && userInfo[@"aps"][@"alert"]) {
        NSDictionary *alert = userInfo[@"aps"][@"alert"];
        msg[@"title"] = alert[@"title"];
        msg[@"message"] = alert[@"body"];
    }
    msg[@"title"] = msg[@"title"] ? msg[@"title"] : @"";
    msg[@"message"] = msg[@"message"] ? msg[@"message"] : @"";
    [_channel invokeMethod:@"onReceiveNotification" arguments:msg];
    completionHandler(UIBackgroundFetchResultNewData);
    return YES;
}

// iOS 10 以下点击本地通知
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    NSLog(@"application:didReceiveLocalNotification:");
    NSMutableDictionary *msg = [self jpushFormatAPNSDic:notification.userInfo];
    msg[@"title"] = notification.alertTitle;
    msg[@"message"] = notification.alertBody;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.channel invokeMethod:@"onOpenNotification" arguments:msg];
    });
}


// iOS 10以及以上 收到通知
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(NSInteger))completionHandler  API_AVAILABLE(ios(10.0)) {
    NSLog(@"jpushNotificationCenter:willPresentNotification:: ");
    NSDictionary *userInfo = notification.request.content.userInfo;
    if ([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        /// 收到的是远程通知
        [JPUSHService handleRemoteNotification:userInfo];
        NSMutableDictionary *msg = [self jpushFormatAPNSDic:userInfo];
        msg[@"title"] = notification.request.content.title;
        msg[@"message"] = notification.request.content.body;
        [_channel invokeMethod:@"onReceiveNotification" arguments:msg];
    } else {
        /// 收到的是本地通知, 就不需要做任何操作了
    }
    completionHandler(notificationTypes);
}

// iOS 10以及以上 点击通知
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler  API_AVAILABLE(ios(10.0)) {
    NSLog(@"jpushNotificationCenter:didReceiveNotificationResponse::");
    NSDictionary *userInfo = response.notification.request.content.userInfo;
    NSMutableDictionary *msg = [self jpushFormatAPNSDic:userInfo];
    msg[@"title"] = response.notification.request.content.title;
    msg[@"message"] = response.notification.request.content.body;
    if ([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        // iOS 10 以上点击远程通知
        [JPUSHService handleRemoteNotification:userInfo];
//        [_channel invokeMethod:@"onOpenNotification" arguments:msg];
    } else {
        // iOS 10 以上点击本地通知
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [self.channel invokeMethod:@"onOpenNotification" arguments:msg];
//        });
    }
    [_channel invokeMethod:@"onOpenNotification" arguments:msg];
    completionHandler();
}

//iOS 12 开始支持
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center openSettingsForNotification:(UNNotification *)notification {
    if (notification) {
        //从通知界面直接进入应用
    } else {
        //从通知设置界面进入应用
    }
}

- (void)jpushNotificationAuthorization:(JPAuthorizationStatus)status withInfo:(NSDictionary *)info {
    BOOL isEnabled = status == JPAuthorizationStatusAuthorized;
    NSDictionary *dict = @{@"isEnabled": @(isEnabled)};
    __weak typeof(self) weakself = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong typeof(self) strongself = weakself;
        [strongself.channel invokeMethod:@"onReceiveNotificationAuthorization" arguments:dict];
    });
}

- (NSMutableDictionary *)jpushFormatAPNSDic:(NSDictionary *)dic {
    NSMutableDictionary *extras = [NSMutableDictionary new];
    NSMutableDictionary *formatDic = [NSMutableDictionary new];
    for (NSString *key in dic) {
        if ([key isEqualToString:@"_j_msgid"]) {
            formatDic[@"messageId"] = dic[@"_j_msgid"];
            continue;
        }
        if ([key isEqualToString:@"_j_data_"] || [key isEqualToString:@"_j_business"] || [key isEqualToString:@"_j_uid"] ||
                [key isEqualToString:@"actionIdentifier"] || [key isEqualToString:@"aps"]) {
            continue;
        }
        extras[key] = dic[key];
    }
    formatDic[@"extras"] = extras;
    return formatDic;
}

@end

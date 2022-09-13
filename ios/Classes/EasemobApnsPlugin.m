#import "EasemobApnsPlugin.h"

@interface EasemobApnsPlugin ()
{
    NSDictionary *_launch;
}
@property (nonatomic, strong) FlutterMethodChannel *channel;

@end

@implementation EasemobApnsPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {

  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"easemob_apns"
            binaryMessenger:[registrar messenger]];

  EasemobApnsPlugin* instance = [[EasemobApnsPlugin alloc] init];
  instance.channel = channel;
  [registrar addMethodCallDelegate:instance channel:channel];
  [registrar addApplicationDelegate:instance];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"requestAuthorization" isEqualToString:call.method]) {
      [self requestAuthorization:call.arguments
                          result:result];
  } else if ([@"registerDeviceToken" isEqualToString:call.method]) {
      [self registerDeviceToken];
  } else if ([@"unregisterDeviceToken" isEqualToString:call.method]) {
      [self unregisterDeviceToken];
  } else if ([@"initPlugin" isEqualToString:call.method]) {
      [self initPlugin];
  }
  else {
    result(FlutterMethodNotImplemented);
  }
}

- (void)requestAuthorization:(id)arguments
                      result:(FlutterResult)result {
    NSArray *list = (NSArray *)arguments;
    UNAuthorizationOptions option = 0;
    for (NSNumber *value in list) {
        int intValue = value.intValue;
        if (intValue == 0) {
            option |= UNAuthorizationOptionBadge;
        }else if (intValue == 1) {
            option |= UNAuthorizationOptionSound;
        }else if (intValue == 2) {
            option |= UNAuthorizationOptionAlert;
        }
    }
    [[UNUserNotificationCenter currentNotificationCenter] requestAuthorizationWithOptions:option
                                                                        completionHandler:^(BOOL granted, NSError * _Nullable error)
     {
        result(@(granted));
    }];
}

- (void)registerDeviceToken {
    [[UIApplication sharedApplication] registerForRemoteNotifications];
}

- (void)unregisterDeviceToken {
    [[UIApplication sharedApplication] unregisterForRemoteNotifications];
}

- (BOOL)application:(UIApplication*)application didFinishLaunchingWithOptions:(NSDictionary*)launchOptions {
    _launch = launchOptions;
    return YES;
}

- (void)initPlugin {
    [self.channel invokeMethod:@"onLaunch" arguments:_launch];
    _launch = nil;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSString *token = [self getHexStringForData:deviceToken];
    [self.channel invokeMethod:@"onToken" arguments:token];
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error {
    [self.channel invokeMethod:@"onTokenFail" arguments:error.description];
}

- (BOOL)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    [self.channel invokeMethod:@"onMessage" arguments:userInfo[@"aps"]];
    return YES;
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler {
    
}

- (NSString *)getHexStringForData:(NSData *)data
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 13) {
        
        if (![data isKindOfClass:[NSData class]]) {
            return @"";
        }
        NSUInteger len = [data length];
        char *chars = (char *)[data bytes];
        NSMutableString *hexString = [[NSMutableString alloc]init];
        for (NSUInteger i=0; i<len; i++) {
            [hexString appendString:[NSString stringWithFormat:@"%0.2hhx" , chars[i]]];
        }
        return hexString;
    } else {
         NSString *myToken = [[data description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
        myToken = [myToken stringByReplacingOccurrencesOfString:@" " withString:@""];
        return myToken;
    }
}



@end

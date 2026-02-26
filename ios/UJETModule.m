#import "UJETModule.h"
#import <React/RCTLog.h>
@import UJETKit;

@interface UJETModule() <UJETDelegate>

@property (nonatomic, assign) BOOL hasObserver;
@property (nonatomic, assign) BOOL didRegisterEventNotifications;
@property (nonatomic, copy) void (^signPayloadAuthSuccessBlock)(NSString *);
@property (nonatomic, copy) void (^signPayloadAuthFailureBlock)(NSError *);
@property (nonatomic, copy) void (^signPayloadCustomDataSuccessBlock)(NSString *);
@property (nonatomic, copy) void (^signPayloadCustomDataFailureBlock)(NSError *);

@end

@implementation UJETModule

- (dispatch_queue_t)methodQueue {
    return dispatch_get_main_queue();
}

RCT_EXPORT_MODULE();

RCT_EXPORT_METHOD(initialize:(NSDictionary *)options) {
    NSString *key = options[@"key"];
    if (!key) {
        RCTLogError(@"[UJET] Failed to intiialize: Company Key is required");
        return;
    }

    NSString *subdomain = options[@"subdomain"];
    NSString *baseUrl = options[@"baseUrl"];
    if (baseUrl) {
        [UJET initialize:key baseUrl:baseUrl delegate:self];
    } else if (subdomain) {
        [UJET initialize:key subdomain:subdomain delegate:self];
    } else {
        RCTLogError(@"[UJET] Failed to intiialize: Either the subdomain or the baseUrl should exist");
    }

    if (!_didRegisterEventNotifications) {
        _didRegisterEventNotifications = YES;
        [self registerEventNotifications];
    }
}

RCT_EXPORT_METHOD(start:(NSDictionary *)options) {
    UJETStartOptions *startOptions = nil;

    NSString *menuKey = options[@"menuKey"];
    NSString *ivrNumber = options[@"ivrNumber"];
    
    if (menuKey) {
        startOptions = [[UJETStartOptions alloc] initWithMenuKey:menuKey];
    } else if (ivrNumber) {
        startOptions = [[UJETStartOptions alloc] initWithIvrNumber:ivrNumber];
    } else {
        startOptions = UJETStartOptions.new;
    }

    NSDictionary *customData = options[@"unsignedCustomData"];
    if (customData) {
        startOptions.unsignedCustomData = [[UJETCustomData alloc] initWithData:customData];
    }

    NSString *ticketId = options[@"ticketId"];
    if (ticketId) {
        startOptions.ticketId = ticketId;
    }

    NSNumber *skipSplashScreen = options[@"skipSplashScreen"];
    if ([skipSplashScreen boolValue]) {
        startOptions.skipSplashScreen = skipSplashScreen;
    }

    NSString *preferredChannel = [options[@"preferredChannel"] lowercaseString];
    NSArray *availableChannels = @[@"call", @"chat"];
    if (preferredChannel && [availableChannels containsObject:preferredChannel]) {
        if ([preferredChannel isEqualToString:@"call"]) {
            startOptions.preferredChannel = UjetPreferredChannelTypeCall;
        } else if ([preferredChannel isEqualToString:@"chat"]) {
            startOptions.preferredChannel = UjetPreferredChannelTypeChat;
        } else {
            RCTLogWarn(@"[UJET] Unsupported preferred channel type: %@", preferredChannel);
        }
    }

  dispatch_async(dispatch_get_main_queue(), ^{
    [UJET startWithOptions:startOptions];
  });
}

RCT_EXPORT_METHOD(clearUserData) {
    [UJET clearUserData];
}

RCT_EXPORT_METHOD(setLogLevel:(NSString *)level) {
    NSArray *logLevels = @[
        @"all", @"verbose", @"debug", @"info", @"warn", @"error"
    ];

    if (![logLevels containsObject:level.lowercaseString]) {
        RCTLogWarn(@"[UJET] Unsupported log level: %@", level);
        return;
    }

    if ([level isEqualToString:@"all"]) [UJET setLogLevel:UjetLogLevelAll];
    else if ([level isEqualToString:@"verbose"]) [UJET setLogLevel:UjetLogLevelVerbose];
    else if ([level isEqualToString:@"debug"]) [UJET setLogLevel:UjetLogLevelDebug];
    else if ([level isEqualToString:@"info"]) [UJET setLogLevel:UjetLogLevelInfo];
    else if ([level isEqualToString:@"warn"]) [UJET setLogLevel:UjetLogLevelWarn];
    else if ([level isEqualToString:@"error"]) [UJET setLogLevel:UjetLogLevelError];
}

RCT_EXPORT_METHOD(setGlobalTheme:(NSDictionary *)theme) {
    UJETGlobalTheme *globalTheme = nil;
    globalTheme = UJETGlobalTheme.new;
    [globalTheme setDefaultTheme];

    NSString *companyImageName = theme[@"companyImage"];
    if (companyImageName.length > 0) {
        globalTheme.companyImage = [UIImage imageNamed:companyImageName];
    }

    NSString *fontName = theme[@"fontName"];
    NSNumber *fontSize = theme[@"fontSize"];
    if (fontName.length > 0 && fontSize != nil) {
        globalTheme.font = [UIFont fontWithName:fontName size:[fontSize floatValue]];
    }

    NSString *lightFontName = theme[@"lightFontName"];
    NSNumber *lightFontSize = theme[@"lightFontSize"];
    if (lightFontName.length > 0 && lightFontSize != nil) {
        globalTheme.lightFont = [UIFont fontWithName:lightFontName size:[lightFontSize floatValue]];
    }

    NSString *boldFontName = theme[@"boldFontName"];
    NSNumber *boldFontSize = theme[@"boldFontSize"];
    if (boldFontName.length > 0 && boldFontSize != nil) {
        globalTheme.boldFont = [UIFont fontWithName:boldFontName size:[boldFontSize floatValue]];
    }

    NSString *tintColorString = theme[@"tintColor"];
    if (tintColorString.length > 0) {
        globalTheme.tintColor = [self colorWithHexString:tintColorString];
    }

    NSString *tintColorForDarkModeString = theme[@"tintColorForDarkMode"];
    if (tintColorForDarkModeString.length > 0) {
        globalTheme.tintColorForDarkMode = [self colorWithHexString:tintColorForDarkModeString];
    }

    NSString *defaultAgentImageName = theme[@"defaultAgentImage"];
    if (defaultAgentImageName.length > 0) {
        globalTheme.defaultAgentImage = [UIImage imageNamed:defaultAgentImageName];
    }

    NSNumber *supportTitleLabelFontSize = theme[@"supportTitleLabelFontSize"];
    if (supportTitleLabelFontSize != nil) {
        globalTheme.supportTitleLabelFontSize = [supportTitleLabelFontSize floatValue];
    }

    NSNumber *supportDescriptionLabelFontSize = theme[@"supportDescriptionLabelFontSize"];
    if (supportDescriptionLabelFontSize != nil) {
        globalTheme.supportDescriptionLabelFontSize = [supportDescriptionLabelFontSize floatValue];
    }

    NSNumber *supportPickerViewFontSize = theme[@"supportPickerViewFontSize"];
    if (supportPickerViewFontSize != nil) {
        globalTheme.supportPickerViewFontSize = [supportPickerViewFontSize floatValue];
    }

    NSNumber *staticFontSizeInSupportPickerViewNumber = theme[@"staticFontSizeInSupportPickerView"];
    if (staticFontSizeInSupportPickerViewNumber != nil) {
        globalTheme.staticFontSizeInSupportPickerView = [staticFontSizeInSupportPickerViewNumber boolValue];
    }

    NSString *backgroundColorString = theme[@"backgroundColor"];
    if (backgroundColorString.length > 0) {
        globalTheme.backgroundColor = [self colorWithHexString:backgroundColorString];
    }

    NSString *backgroundColorForDarkModeString = theme[@"backgroundColorForDarkMode"];
    if (backgroundColorForDarkModeString.length > 0) {
        globalTheme.backgroundColorForDarkMode = [self colorWithHexString:backgroundColorForDarkModeString];
    }

    NSNumber *forceToUseWhiteTextForTintedBackgroundColorNumber = theme[@"forceToUseWhiteTextForTintedBackgroundColor"];
    if (forceToUseWhiteTextForTintedBackgroundColorNumber != nil) {
        globalTheme.forceToUseWhiteTextForTintedBackgroundColor = [forceToUseWhiteTextForTintedBackgroundColorNumber boolValue];
    }

    NSNumber *forceToUseBlackTextForTintedBackgroundColorNumber = theme[@"forceToUseBlackTextForTintedBackgroundColor"];
    if (forceToUseBlackTextForTintedBackgroundColorNumber != nil) {
        globalTheme.forceToUseBlackTextForTintedBackgroundColor = [forceToUseBlackTextForTintedBackgroundColorNumber boolValue];
    }

    NSString *customChatThemeJSON = theme[@"customChatThemeJSON"];
    if (customChatThemeJSON.length > 0) {
        globalTheme.chatTheme = [[UJETChatTheme alloc] initWithJSONString:customChatThemeJSON];
    }

    [UJET setGlobalTheme:globalTheme];
}

RCT_EXPORT_METHOD(setGlobalOptions:(NSDictionary *)options) {
    UJETGlobalOptions *globalOptions = UJETGlobalOptions.new;

    NSString *fallbackPhoneNumber = options[@"fallbackPhoneNumber"];
    if (fallbackPhoneNumber.length > 0) {
        globalOptions.fallbackPhoneNumber = fallbackPhoneNumber;
    }

    NSString *preferredLanguage = options[@"preferredLanguage"];
    if (preferredLanguage.length > 0) {
        globalOptions.preferredLanguage = preferredLanguage;
    }

    NSNumber *pstnFallbackSensitivity = options[@"pstnFallbackSensitivity"];
    if (pstnFallbackSensitivity != nil) {
        globalOptions.pstnFallbackSensitivity = [pstnFallbackSensitivity floatValue];
    }

    NSNumber *showSingleChannelNumber = options[@"showSingleChannel"];
    if (showSingleChannelNumber != nil) {
        globalOptions.showSingleChannel = [showSingleChannelNumber boolValue];
    }

    NSNumber *statusBarNotificationViewAlpha = options[@"statusBarNotificationViewAlpha"];
    if (statusBarNotificationViewAlpha != nil) {
        globalOptions.statusBarNotificationViewAlpha = [statusBarNotificationViewAlpha floatValue];
    }

    NSNumber *ignoreDarkModeNumber = options[@"ignoreDarkMode"];
    if (ignoreDarkModeNumber != nil) {
        globalOptions.ignoreDarkMode = [ignoreDarkModeNumber boolValue];
    }

    NSNumber *autoMinimizeCallWaitingNumber = options[@"autoMinimizeCallWaiting"];
    if (autoMinimizeCallWaitingNumber != nil) {
        globalOptions.autoMinimizeCallWaiting = [autoMinimizeCallWaitingNumber boolValue];
    }

    NSNumber *agentImageWithoutBorderAndRoundingNumber = options[@"agentImageWithoutBorderAndRounding"];
    if (agentImageWithoutBorderAndRoundingNumber != nil) {
        globalOptions.agentImageWithoutBorderAndRounding = [agentImageWithoutBorderAndRoundingNumber boolValue];
    }

    NSNumber *hideMediaAttachmentInChatNumber = options[@"hideMediaAttachmentInChat"];
    if (hideMediaAttachmentInChatNumber != nil) {
        globalOptions.hideMediaAttachmentInChat = [hideMediaAttachmentInChatNumber boolValue];
    }

    NSString *cobrowseKey = options[@"cobrowseKey"];
    if (cobrowseKey.length > 0) {
        globalOptions.cobrowseKey = cobrowseKey;
    }

    NSString *cobrowseApi = options[@"cobrowseApi"];
    if (cobrowseApi.length > 0) {
        globalOptions.cobrowseApi = cobrowseApi;
    }

    NSNumber *blockChatTerminationByEndUserNumber = options[@"blockChatTerminationByEndUser"];
    if (blockChatTerminationByEndUserNumber != nil) {
        globalOptions.blockChatTerminationByEndUser = [blockChatTerminationByEndUserNumber boolValue];
    }

    NSNumber *hideStatusBarNumber = options[@"hideStatusBar"];
    if (hideStatusBarNumber != nil) {
        globalOptions.hideStatusBar = [hideStatusBarNumber boolValue];
    }
    
    [UJET setGlobalOptions:globalOptions];
}

RCT_EXPORT_METHOD(notifySignPayloadResult:(NSDictionary *)result) {
    NSString *type = result[@"type"];
    NSString *error = result[@"error"];

    if ([type isEqualToString:@"authToken"]) {
        if (error) {
            _signPayloadAuthFailureBlock([NSError errorWithDomain:@"UJET" code:-1 userInfo:@{NSLocalizedDescriptionKey: error}]);
        } else {
            _signPayloadAuthSuccessBlock(result[@"token"]);
        }
    } else if ([type isEqualToString:@"customData"]) {
        if (error) {
            _signPayloadCustomDataFailureBlock([NSError errorWithDomain:@"UJET" code:-1 userInfo:@{NSLocalizedDescriptionKey: error}]);
        } else {
            _signPayloadCustomDataSuccessBlock(result[@"token"]);
        }
    }
}

RCT_EXPORT_METHOD(getStatus:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject) {
    UjetStatus ujetStatus = [UJET getStatus];
    NSDictionary *statusMap = @{@(UjetStatusInChat) : @"chat",
                                @(UjetStatusInVoiceCall) : @"voip-call",
                                @(UjetStatusActionOnlyCall) : @"pstn-call",
                                @(UjetStatusNone) : @"none"};

    NSString *status = statusMap[@(ujetStatus)];
    if (!status) {
        status = @"none";
    }
    if (resolve) resolve(status);
}

RCT_EXPORT_METHOD(disconnect:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject) {
    [UJET disconnect:^{
        if (resolve) resolve(nil);
    }];
}

RCT_EXPORT_METHOD(minimize:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject) {
    [UJET minimize:^{
        if (resolve) resolve(nil);
    }];
}

RCT_EXPORT_METHOD(updatePushToken:(NSString *)token) {
    [UJET updatePushToken:[token dataUsingEncoding:NSUTF8StringEncoding] type:UjetPushTypeAPN];
}

RCT_EXPORT_METHOD(updateVoipToken:(NSString *)token) {
    [UJET updatePushToken:[token dataUsingEncoding:NSUTF8StringEncoding] type:UjetPushTypeVoIP];
}

RCT_EXPORT_METHOD(handlePushNotification:(NSDictionary *)payload resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject) {
    if (payload[@"ujet"] == nil) {
        resolve(@NO);
    }

    [UJET receivedNotification:payload[@"ujet"] completion:^{
        resolve(@YES);
    }];
}

#pragma mark - UJETDelegate

- (void)signPayload:(NSDictionary *)payload payloadType:(UjetPayloadType)payloadType success:(void (^)(NSString *))success failure:(void (^)(NSError *))failure {
    if (payloadType == UjetPayloadAuthToken) {
        [self sendEventWithName:@"onSignPayloadRequest" body: @{
            @"type": @"authToken",
            @"data": payload
        }];
        _signPayloadAuthSuccessBlock = success;
        _signPayloadAuthFailureBlock = failure;
    } else if (payloadType == UjetPayloadCustomData) {
        [self sendEventWithName:@"onSignPayloadRequest" body: @{
            @"type": @"customData",
            @"data": payload
        }];
        _signPayloadCustomDataSuccessBlock = success;
        _signPayloadCustomDataFailureBlock = failure;
    }
}

#pragma mark - Sending Events to JS

- (NSArray<NSString*> *)supportedEvents {
    return @[@"onSignPayloadRequest", @"onSdkEvent"];
}

// Will be called when this module's first listener is added.
- (void)startObserving {
    RCTLogInfo(@"[UJET] Start observing");
    _hasObserver = YES;
    // Set up any upstream listeners or background tasks as necessary
}

// Will be called when this module's last listener is removed, or on dealloc.
- (void)stopObserving {
    RCTLogInfo(@"[UJET] Stop observing");
    _hasObserver = NO;
    // Remove upstream listeners, stop unnecessary background tasks
}

// Override so we can check the event observer before emitting events
- (void)sendEventWithName:(NSString *)eventName body:(id)body {
    if (_hasObserver) {
        [super sendEventWithName:eventName body:body];
    } else {
        RCTLogInfo(@"[UJET] No event observer registered yet. event: %@, body: %@", eventName, body);
    }
}

#pragma mark - Private

- (UIColor *)colorWithHexString:(NSString *)hexString {
    hexString = [hexString stringByReplacingOccurrencesOfString:@"#" withString:@""];
    NSScanner *scanner = [NSScanner scannerWithString: hexString];
    unsigned int hexValue = 0;
    [scanner scanHexInt:&hexValue];

    CGFloat red = ((hexValue & 0xFF0000) >> 16) / 255.0;
    CGFloat green = ((hexValue & 0x00FF00) >> 8) / 255.0;
    CGFloat blue = (hexValue & 0x0000FF) / 255.0;
    UIColor *color = [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
    return color;
}

- (void)registerEventNotifications {
    NSNotificationCenter *notiCenter = [NSNotificationCenter defaultCenter];
    NSArray<NSString*> *events = @[UJETEventEmailDidClick, UJETEventEmailDidSubmit,
                                   UJETEventSessionViewDidAppear, UJETEventSessionViewDidDisappear,
                                   UJETEventSessionDidCreate, UJETEventSessionDidEnd,
                                   UJETEventSdkDidTerminate, UJETEventContentCardDidClick];

    for (NSString *event in events) {
        [notiCenter addObserver:self selector:@selector(eventDidReceive:) name:event object:nil];
    }
}

- (void)eventDidReceive:(NSNotification *)noti {
    NSMutableDictionary *body = [[noti userInfo] mutableCopy];
    body[@"event_name"] = [self eventNameFromNotificationName:noti.name];
    [self sendEventWithName:@"onSdkEvent" body:body];
}

- (NSString *)eventNameFromNotificationName:(NSString *)name {
    if ([name isEqualToString:UJETEventEmailDidClick]) {
        return @"Email Clicked";
    } else if ([name isEqualToString:UJETEventEmailDidSubmit]) {
        return @"Email Submitted";
    } else if ([name isEqualToString:UJETEventSessionDidCreate]) {
        return @"Session Created";
    } else if ([name isEqualToString:UJETEventSessionViewDidAppear]) {
        return @"Session Resumed";
    } else if ([name isEqualToString:UJETEventSessionViewDidDisappear]) {
        return @"Session Paused";
    } else if ([name isEqualToString:UJETEventSessionDidEnd]) {
        return @"Session Ended";
    } else if ([name isEqualToString:UJETEventSdkDidTerminate]) {
        return @"Sdk Terminated";
    } else if ([name isEqualToString:UJETEventContentCardDidClick]) {
        return @"Content Card Clicked";
    } else {
        return @"";
    }
}

@end

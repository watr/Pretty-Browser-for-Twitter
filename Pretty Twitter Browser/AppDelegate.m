//
//  AppDelegate.m
//  Pretty Twitter Browser
//
//  Created by HASHIMOTO Wataru on 2013/02/08.
//  Copyright (c) 2013年 HASHIMOTO Wataru. All rights reserved.
//

#import "AppDelegate.h"

@interface DummyWebView : WebView
@end

@implementation DummyWebView
@end

@interface AppDelegate ()
@property (strong) NSTimer *intervalTimer;
@property (copy) NSString *lastTab;
@property (strong) NSMutableDictionary *updatedDateDictionary;
- (void)startIntervalTimer;
- (void)invalidateIntervalTimer;
- (void)check;
- (void)setLastUpdatedDate:(NSDate *)updatedDate forTab:(NSString *)tabString;
@end

@implementation AppDelegate

- (void)awakeFromNib
{
    self.webView.customUserAgent =
    @"Mozilla/5.0"
    @" "
    @"(iPhone; CPU iPhone OS 6_0 like Mac OS X)"
    @" "
    @"AppleWebKit/536.26"
    @" "
    @"(KHTML, like Gecko)"
    @" "
    @"Version/6.0"
    @" "
    @"Mobile/10A5376e"
    @" "
    @"Safari/8536.25";
    
    self.dummyWebView = [[DummyWebView alloc] init];
    self.dummyWebView.resourceLoadDelegate = self;
    self.dummyWebView.policyDelegate = self;
    
    NSString *const twitterURLString = @"https://www.twitter.com";
    [self.webView.mainFrame loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:twitterURLString]]];
}

- (id)init
{
    self = [super init];
    if (self) {
        self.updatedDateDictionary = [NSMutableDictionary dictionary];
        self.updateInterval = 1.0 * 60.0;
    }
    return self;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [self startIntervalTimer];
}

- (void)applicationWillBecomeActive:(NSNotification *)notification
{
    ;
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication hasVisibleWindows:(BOOL)flag
{
    if (!([self.window isVisible])) {
        [self.window makeKeyAndOrderFront:self];
    }
    return YES;
}

#pragma mark WebUIDelegate

- (WebView *)webView:(WebView *)sender createWebViewWithRequest:(NSURLRequest *)request
{
    return self.dummyWebView;
}

- (void)webView:(WebView *)sender runOpenPanelForFileButtonWithResultListener:(id<WebOpenPanelResultListener>)resultListener allowMultipleFiles:(BOOL)allowMultipleFiles
{
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    openPanel.allowsMultipleSelection = YES;
    NSInteger const result = [[NSApplication sharedApplication] runModalForWindow:openPanel];
    switch (result) {
        case NSOKButton:
        {
            NSArray *urls = openPanel.URLs;
            for (NSURL *const aURL in urls) {
                NSString *path = [aURL relativePath];
                [resultListener chooseFilename:path];
            }
        }
            break;
        case NSCancelButton:
        default:
        {
            [resultListener cancel];
        }
            break;
    }
}

#pragma mark WebPolicyDelegate

- (void)webView:(WebView *)webView decidePolicyForMIMEType:(NSString *)type request:(NSURLRequest *)request frame:(WebFrame *)frame decisionListener:(id < WebPolicyDecisionListener >)listener
{
    if (webView == self.dummyWebView) {
        [listener ignore];
        [[NSWorkspace sharedWorkspace] openURL:request.URL];
    }
}

#pragma mark WebFrameLoadDelegate

- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame {
    ;
}

#pragma mark -

- (void)startIntervalTimer
{
    if (self.intervalTimer == nil) {
        NSTimer *intervalTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                                  target:self
                                                                selector:@selector(check)
                                                                userInfo:nil
                                                                 repeats:YES];
        self.intervalTimer = intervalTimer;
    }
}

- (void)invalidateIntervalTimer
{
    if (self.intervalTimer != nil) {
        [self.intervalTimer invalidate];
        self.intervalTimer = nil;
    }
}

- (void)check
{
    if (self.webView.isLoading) {
        return;
    }
        
    NSDate *checkDate = [NSDate date];
    NSString *activeTab = nil;
    NSString *href = nil;
    [self getActiveTab:&activeTab
         rootURLString:&href];    
    if (self.lastTab == nil || [self.lastTab caseInsensitiveCompare:activeTab] != NSOrderedSame) {
        self.lastTab = activeTab;
        [self setLastUpdatedDate:checkDate
                          forTab:activeTab];
    }
    else {
        NSAssert(checkDate != nil, @"check date is nil");
        NSAssert(self.updateInterval > 0, @"update interval is smaller than 0");
        
        NSString *relativePath = [[NSURL URLWithString:self.webView.mainFrameURL] relativePath];
        NSDate *lastUpdatedDate = [self.updatedDateDictionary objectForKey:activeTab];
        if ([href caseInsensitiveCompare:relativePath] == NSOrderedSame &&
            [checkDate timeIntervalSinceDate:lastUpdatedDate] > self.updateInterval)
        {
            NSInteger yOffset = [[self.webView stringByEvaluatingJavaScriptFromString:@"pageYOffset"] integerValue];
            if (yOffset <= 0) {
                [self.webView stringByEvaluatingJavaScriptFromString:[self javaScriptStringForDisplayActiveTab]];
                [self setLastUpdatedDate:checkDate
                                  forTab:activeTab];
            }
        }
    }
}

- (void)setLastUpdatedDate:(NSDate *)updatedDate forTab:(NSString *)tabString
{
    NSAssert(self.updatedDateDictionary != nil, @"updated dictionary must NOT be nil");
    [self.updatedDateDictionary setObject:updatedDate
                                   forKey:tabString];
}

@end

@implementation AppDelegate (Twitter)

- (NSString *)javaScriptStringForActiveTabAttribute:(NSString *)attributeKey
{
    NSString *activeTabClassString = @"navItem active";
    return [NSString stringWithFormat:
            @"document.getElementsByClassName('%@')[0].getAttribute('%@')",
            activeTabClassString, attributeKey];
}

- (void)getActiveTab:(NSString **)tabString rootURLString:(NSString **)rootURLString
{
    if (tabString != nil) {
        NSString *tab = [self.webView stringByEvaluatingJavaScriptFromString:
                               [self javaScriptStringForActiveTabAttribute:@"tab"]];
        *tabString = tab;
    }
    if (rootURLString != nil) {
        NSString *href = [self.webView stringByEvaluatingJavaScriptFromString:
                             [self javaScriptStringForActiveTabAttribute:@"href"]];
        *rootURLString = href;
    }
}

- (NSString *)javaScriptStringForDisplayActiveTab
{
    return
    @"var event = document.createEvent('MouseEvents');"
    @"event.initMouseEvent( 'click', true, true, window, 0, 0, 0, 0, 0, false, false, false, false, 0, null);"
    @"document.getElementsByClassName('navItem active')[0].dispatchEvent( event );";
}

@end

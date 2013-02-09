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
    NSString *const twitterURLString = @"https://www.twitter.com";
    [self.webView setMainFrameURL:twitterURLString];
    
    self.dummyWebView = [[DummyWebView alloc] init];
    self.dummyWebView.resourceLoadDelegate = self;
    self.dummyWebView.policyDelegate = self;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{

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

#pragma mark -

@end

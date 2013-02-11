//
//  AppDelegate.h
//  Pretty Twitter Browser
//
//  Created by HASHIMOTO Wataru on 2013/02/08.
//  Copyright (c) 2013年 HASHIMOTO Wataru. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (weak)   IBOutlet NSWindow *window;
@property (weak)   IBOutlet WebView *webView;
@property (strong) WebView *dummyWebView;
@property (assign) NSTimeInterval updateInterval;
@property (assign) BOOL bounces;

@end

@interface AppDelegate (Twitter)

- (NSString *)javaScriptStringForActiveTabAttribute:(NSString *)attributeKey;
- (void)getActiveTab:(NSString **)tabString rootURLString:(NSString **)rootURLString;

- (NSString *)javaScriptStringForDisplayActiveTab;
@end
#line 1 "Tweak.xm"







#import <UIKit/UIKit.h>
#import "libcolorpicker.h"

@interface SBLockScreenViewControllerBase : UIViewController
@end

@interface SBHomeScreenViewController : UIViewController
@end




static bool twIsEnabled = NO;
static int twWhichScreenChoice = 0;

static NSString *twTextLabel = @"default text";
static int twFramePosChoice = 1;
static CGFloat twFrameX = 0;
static CGFloat twFrameY = 0;
static CGFloat frameX = 0;
static CGFloat frameY = 0;
static CGFloat twFrameW = 100;
static CGFloat twFrameH = 20;



static bool twIsBackgroundEnabled = YES;
static CGFloat twFontSize = 14;
static NSString *twFontColor = @"#000000";
static NSString *twBackgroundColor = @"#ffffff";
static NSString *twFontColorDefault = @"#000000";
static NSString *twBackgroundColorDefault = @"#ffffff";

static void loadPrefs() {

	NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.leroy.AlwaysRemindMePref.plist"];
    if(prefs){
		twIsEnabled				= ([prefs objectForKey:@"pfTweakIsEnabled"] ? [[prefs objectForKey:@"pfTweakIsEnabled"] boolValue] : twIsEnabled);
		twWhichScreenChoice 	= ([prefs objectForKey:@"pfWhichScreenChoice"] ? [[prefs objectForKey:@"pfWhichScreenChoice"] intValue] : twWhichScreenChoice);
		twTextLabel				= ([prefs objectForKey:@"pfTextLabel"] ? [[prefs objectForKey:@"pfTextLabel"] stringValue] : twTextLabel);

		twFramePosChoice		= ([prefs objectForKey:@"pfFramePosChoice"] ? [[prefs objectForKey:@"pfFramePosChoice"] intValue] : twFramePosChoice);
		twFrameX				= ([prefs objectForKey:@"pfFrameX"] ? [[prefs objectForKey:@"pfFrameX"] floatValue] : twFrameX);
		twFrameY				= ([prefs objectForKey:@"pfFrameY"] ? [[prefs objectForKey:@"pfFrameY"] floatValue] : twFrameY);
		twFrameH				= ([prefs objectForKey:@"pfFrameH"] ? [[prefs objectForKey:@"pfFrameH"] floatValue] : twFrameH);
		twFrameW				= ([prefs objectForKey:@"pfFrameW"] ? [[prefs objectForKey:@"pfFrameW"] floatValue] : twFrameW);

		twIsBackgroundEnabled	= ([prefs objectForKey:@"pfIsBackgroundEnabled"] ? [[prefs objectForKey:@"pfIsBackgroundEnabled"] boolValue] : twIsBackgroundEnabled);
		twBackgroundColor		= ([prefs objectForKey:@"pfBackgroundColor"] ? [[prefs objectForKey:@"pfBackgroundColor"] stringValue] : twBackgroundColor);
		twFontColor				= ([prefs objectForKey:@"pfFontColor"] ? [[prefs objectForKey:@"pfFontColor"] stringValue] : twFontColor);
		twFontSize				= ([prefs objectForKey:@"pfFontSize"] ? [[prefs objectForKey:@"pfFontSize"] floatValue] : twFontSize);
    }
	NSLog(@"AlwaysRemindMe LOG: prefs: %@", prefs);
    [prefs release];
}

static void drawAlwaysRemindMe(double screenHeight, double screenWidth, UIView *currentView) {
	switch (twFramePosChoice) {
		case 1:
			twFrameX = (screenWidth/2) - (twFrameW/2);
			twFrameY = 20;
			break;
		case 2:
			twFrameX = (screenWidth/2) - (twFrameW/2);
			twFrameY = screenHeight-95;
			break;
		case 25:
			
			
			break;
		default:
			NSLog(@"AlwaysRemindMe ERROR: switch -> twFramePosChoice is default");
			twFrameX = (screenWidth/2) - (twFrameW/2);
			twFrameY = 20;
			break;
	}
	
	UILabel *txtToDisplayPrefLabel = [[UILabel alloc] initWithFrame:CGRectMake(frameX, frameY, twFrameW, twFontSize+5)];
	[txtToDisplayPrefLabel setTextColor:LCPParseColorString(twFontColor, twFontColorDefault)];
	if(twIsBackgroundEnabled) {
		[txtToDisplayPrefLabel setBackgroundColor:LCPParseColorString(twBackgroundColor, twBackgroundColorDefault)];
	} else {
		[txtToDisplayPrefLabel setBackgroundColor: [UIColor clearColor]];
	}
	[txtToDisplayPrefLabel setFont:[UIFont fontWithName: @"Trebuchet MS" size: twFontSize]];
	[currentView addSubview:txtToDisplayPrefLabel];
	txtToDisplayPrefLabel.text = twTextLabel;
}




#include <substrate.h>
#if defined(__clang__)
#if __has_feature(objc_arc)
#define _LOGOS_SELF_TYPE_NORMAL __unsafe_unretained
#define _LOGOS_SELF_TYPE_INIT __attribute__((ns_consumed))
#define _LOGOS_SELF_CONST const
#define _LOGOS_RETURN_RETAINED __attribute__((ns_returns_retained))
#else
#define _LOGOS_SELF_TYPE_NORMAL
#define _LOGOS_SELF_TYPE_INIT
#define _LOGOS_SELF_CONST
#define _LOGOS_RETURN_RETAINED
#endif
#else
#define _LOGOS_SELF_TYPE_NORMAL
#define _LOGOS_SELF_TYPE_INIT
#define _LOGOS_SELF_CONST
#define _LOGOS_RETURN_RETAINED
#endif

@class SBLockScreenViewControllerBase; @class SBHomeScreenViewController; 
static void (*_logos_orig$_ungrouped$SBLockScreenViewControllerBase$viewDidLoad)(_LOGOS_SELF_TYPE_NORMAL SBLockScreenViewControllerBase* _LOGOS_SELF_CONST, SEL); static void _logos_method$_ungrouped$SBLockScreenViewControllerBase$viewDidLoad(_LOGOS_SELF_TYPE_NORMAL SBLockScreenViewControllerBase* _LOGOS_SELF_CONST, SEL); static void (*_logos_orig$_ungrouped$SBHomeScreenViewController$loadView)(_LOGOS_SELF_TYPE_NORMAL SBHomeScreenViewController* _LOGOS_SELF_CONST, SEL); static void _logos_method$_ungrouped$SBHomeScreenViewController$loadView(_LOGOS_SELF_TYPE_NORMAL SBHomeScreenViewController* _LOGOS_SELF_CONST, SEL); 

#line 99 "Tweak.xm"


	static void _logos_method$_ungrouped$SBLockScreenViewControllerBase$viewDidLoad(_LOGOS_SELF_TYPE_NORMAL SBLockScreenViewControllerBase* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd) {
		_logos_orig$_ungrouped$SBLockScreenViewControllerBase$viewDidLoad(self, _cmd);

		CGSize screenSize = [UIScreen mainScreen].bounds.size;
		double screenHeight = screenSize.height;
		double screenWidth = screenSize.width;
		NSLog(@"AlwaysRemindMe LOG: 'twIsEnabled': %d", twIsEnabled);
		if(twIsEnabled) {
			NSLog(@"AlwaysRemindMe LOG: 'twWhichScreenChoice': %d", twWhichScreenChoice);
			if ((twWhichScreenChoice == 0) || (twWhichScreenChoice == 2)) {
				UIView* selfView = self.view;
				drawAlwaysRemindMe(screenHeight, screenWidth, selfView);
			}
		}
	}





	static void _logos_method$_ungrouped$SBHomeScreenViewController$loadView(_LOGOS_SELF_TYPE_NORMAL SBHomeScreenViewController* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd) {
		_logos_orig$_ungrouped$SBHomeScreenViewController$loadView(self, _cmd);

		CGSize screenSize = [UIScreen mainScreen].bounds.size;
		double screenHeight = screenSize.height;
		double screenWidth = screenSize.width;
		NSLog(@"AlwaysRemindMe LOG: 'twIsEnabled': %d", twIsEnabled);
		if(twIsEnabled) {
			NSLog(@"AlwaysRemindMe LOG: 'twWhichScreenChoice': %d", twWhichScreenChoice);
			if ((twWhichScreenChoice == 0) || (twWhichScreenChoice == 1)) {
				UIView* selfView = self.view;
				drawAlwaysRemindMe(screenHeight, screenWidth, selfView);
			}
		}
	}


static void preferenceschanged(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    loadPrefs();
	NSLog(@"AlwaysRemindMe LOG: 'loadPrefs' called in 'preferenceschanged'");
}

static __attribute__((constructor)) void _logosLocalCtor_fe62b06b(int __unused argc, char __unused **argv, char __unused **envp) {
	@autoreleasepool {
	    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, preferenceschanged, CFSTR("com.leroy.AlwaysRemindMePref/preferenceschanged"), NULL, CFNotificationSuspensionBehaviorCoalesce);
	    loadPrefs();
		NSLog(@"AlwaysRemindMe LOG: 'loadPrefs' called in 'CFNotificationCenterAddObserver'");
	}
}
static __attribute__((constructor)) void _logosLocalInit() {
{Class _logos_class$_ungrouped$SBLockScreenViewControllerBase = objc_getClass("SBLockScreenViewControllerBase"); MSHookMessageEx(_logos_class$_ungrouped$SBLockScreenViewControllerBase, @selector(viewDidLoad), (IMP)&_logos_method$_ungrouped$SBLockScreenViewControllerBase$viewDidLoad, (IMP*)&_logos_orig$_ungrouped$SBLockScreenViewControllerBase$viewDidLoad);Class _logos_class$_ungrouped$SBHomeScreenViewController = objc_getClass("SBHomeScreenViewController"); MSHookMessageEx(_logos_class$_ungrouped$SBHomeScreenViewController, @selector(loadView), (IMP)&_logos_method$_ungrouped$SBHomeScreenViewController$loadView, (IMP*)&_logos_orig$_ungrouped$SBHomeScreenViewController$loadView);} }
#line 150 "Tweak.xm"

#line 1 "Tweak.xm"







#import <UIKit/UIKit.h>
#import "libcolorpicker.h"

@interface SBLockScreenViewControllerBase : UIViewController
@end

@interface SBHomeScreenViewController : UIViewController
@end

#define PLIST_PATH "/var/mobile/Library/Preferences/com.leroy.AlwaysRemindMePref.plist"
#define PreferencesChangedNotification "com.leroy.AlwaysRemindMe/preferencesChanged"


static NSUserDefaults *preferences;

static bool enableTweakPref = NO;
static int enableWherePref;

static NSString *txtToDisplayPref;
static CGFloat frameXPref;
static CGFloat frameYPref;
static CGFloat frameX;
static CGFloat frameY;
static bool enableBackgroundPref = NO;
static CGFloat frameWPref;
static CGFloat frameHPref;



static CGFloat fontSizePref;
static NSString *fontColorPref;
static NSString *fontBackgroundColorPref;


static void loadPreferences() {

	preferences = [[NSUserDefaults alloc] initWithSuiteName:@"com.leroy.AlwaysRemindMePref"];
	[preferences registerDefaults:@{

		@"enableTweakPref"					: @NO,
		@"enableWherePref"					: [NSNumber numberWithInteger:0],

		@"txtToDisplayPref"					: @"AlwaysRemindMe by LeroyB",
		@"enableBackgroundPref"			: @NO,

		@"frameXPref"								: [NSNumber numberWithFloat:0],
		@"frameYPref"								: [NSNumber numberWithFloat:0],
		@"frameWPref"								: [NSNumber numberWithFloat:100],
		@"frameHPref"								: [NSNumber numberWithFloat:20],

		@"fontSizePref"							: [NSNumber numberWithFloat:14],
		@"fontColorPref"						: @"",
		@"fontBackgroundColorPref"	: @"",

	}];
	NSLog(@"AlwaysRemindMe LOG: define enableWherePref: %d", enableWherePref);

	enableTweakPref 					= [preferences boolForKey:@"enableTweakPref"];
	enableWherePref 					= [preferences integerForKey:@"enableWherePref"];
	NSLog(@"AlwaysRemindMe LOG: init enableWherePref: %d", enableWherePref);

	txtToDisplayPref					= [preferences objectForKey:@"txtToDisplayPref"];
	enableBackgroundPref 			= [preferences boolForKey:@"enableBackgroundPref"];

	frameXPref								= [preferences floatForKey:@"frameXPref"];
	frameYPref								= [preferences floatForKey:@"frameYPref"];
	frameWPref								= [preferences floatForKey:@"frameWPref"];
	frameHPref								= [preferences floatForKey:@"frameHPref"];

	fontSizePref							= [preferences floatForKey:@"fontSizePref"];
	fontColorPref							= [preferences objectForKey:@"fontColorPref"];
	fontBackgroundColorPref		= [preferences objectForKey:@"fontBackgroundColorPref"];

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

#line 84 "Tweak.xm"


	static void _logos_method$_ungrouped$SBLockScreenViewControllerBase$viewDidLoad(_LOGOS_SELF_TYPE_NORMAL SBLockScreenViewControllerBase* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd) {
		_logos_orig$_ungrouped$SBLockScreenViewControllerBase$viewDidLoad(self, _cmd);
	    NSLog(@"AlwaysRemindMe LOG: orig called in SBLockScreenViewControllerBase: viewDidLoad");

		CGSize screenSize = [UIScreen mainScreen].bounds.size;
		double screenHeight = screenSize.height;
		double screenWidth = screenSize.width;

		if(enableTweakPref) {
			NSLog(@"AlwaysRemindMe LOG: befor enableWherePref: %d", enableWherePref);
			if ((enableWherePref == 0) || (enableWherePref == 2)) {
				NSLog(@"AlwaysRemindMe LOG: after enableWherePref: %d", enableWherePref);
				
				switch (enableWherePref) {
					case 1:
						frameX = (screenWidth/2) - (frameWPref/2);
						frameY = 20;
						break;
					case 2:
						frameX = (screenWidth/2) - (frameWPref/2);
						frameY = screenHeight-95;
						break;
					case 25:
						frameX = frameXPref;
						frameY = frameYPref;
						break;
					default:
						NSLog(@"AlwaysRemindMe ERROR: switch -> enableWherePref is default");
						frameX = (screenWidth/2) - (frameWPref/2);
						frameY = 20;
						break;
				}
				

				switch (enableWherePref) {
					case 1:
						frameX = screenWidth/2;
						frameY = 20;
						break;
					case 2:
						frameX = screenWidth/2;
						frameY = screenHeight-95;
						break;
					case 25:
						frameX = frameXPref;
						frameY = frameYPref;
						break;
					default:
						NSLog(@"AlwaysRemindMe ERROR: switch -> enableWherePref is default");
						frameX = screenWidth/2;
						frameY = 20;
						break;
				}
				UILabel *txtToDisplayPrefLabel = [[UILabel alloc] initWithFrame:CGRectMake(frameX, frameY, frameWPref, frameHPref)];
				[txtToDisplayPrefLabel setTextColor:LCPParseColorString(fontColorPref, nil)];
				[txtToDisplayPrefLabel setBackgroundColor:LCPParseColorString(fontBackgroundColorPref, nil)];
				[txtToDisplayPrefLabel setFont:[UIFont fontWithName: @"Trebuchet MS" size: fontSizePref]];
				[self.view addSubview:txtToDisplayPrefLabel];
				txtToDisplayPrefLabel.text = txtToDisplayPref;
			}
		}
	}





	static void _logos_method$_ungrouped$SBHomeScreenViewController$loadView(_LOGOS_SELF_TYPE_NORMAL SBHomeScreenViewController* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd) {
		_logos_orig$_ungrouped$SBHomeScreenViewController$loadView(self, _cmd);
	    NSLog(@"AlwaysRemindMe LOG: orig called in SBHomeScreenViewController: viewDidLoad");
		if(enableTweakPref) {
			NSLog(@"AlwaysRemindMe LOG: SB befor enableWherePref: %d", enableWherePref);
			if ((enableWherePref == 0) || (enableWherePref == 2)) {
				NSLog(@"AlwaysRemindMe LOG: SB after enableWherePref: %d", enableWherePref);
				UILabel *txtToDisplayPrefLabel = [[UILabel alloc] initWithFrame:CGRectMake(frameXPref, frameYPref, frameWPref, frameHPref)];
				[txtToDisplayPrefLabel setTextColor:LCPParseColorString(fontColorPref, nil)];
				[txtToDisplayPrefLabel setBackgroundColor:LCPParseColorString(fontBackgroundColorPref, nil)];
				[txtToDisplayPrefLabel setFont:[UIFont fontWithName: @"Trebuchet MS" size: fontSizePref]];
				[self.view addSubview:txtToDisplayPrefLabel];
				txtToDisplayPrefLabel.text = txtToDisplayPref;
			}
		}
	}


static __attribute__((constructor)) void _logosLocalCtor_7ee34f56(int __unused argc, char __unused **argv, char __unused **envp) {
	@autoreleasepool{
		CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
		NULL,
		(CFNotificationCallback)loadPreferences,
		CFSTR(PreferencesChangedNotification),
		NULL,
		CFNotificationSuspensionBehaviorDeliverImmediately);
		loadPreferences();
	}
}
static __attribute__((constructor)) void _logosLocalInit() {
{Class _logos_class$_ungrouped$SBLockScreenViewControllerBase = objc_getClass("SBLockScreenViewControllerBase"); MSHookMessageEx(_logos_class$_ungrouped$SBLockScreenViewControllerBase, @selector(viewDidLoad), (IMP)&_logos_method$_ungrouped$SBLockScreenViewControllerBase$viewDidLoad, (IMP*)&_logos_orig$_ungrouped$SBLockScreenViewControllerBase$viewDidLoad);Class _logos_class$_ungrouped$SBHomeScreenViewController = objc_getClass("SBHomeScreenViewController"); MSHookMessageEx(_logos_class$_ungrouped$SBHomeScreenViewController, @selector(loadView), (IMP)&_logos_method$_ungrouped$SBHomeScreenViewController$loadView, (IMP*)&_logos_orig$_ungrouped$SBHomeScreenViewController$loadView);} }
#line 182 "Tweak.xm"

/*
TODO:
	- bug: slider for font size changes color ?!?

*/

#import <UIKit/UIKit.h>
#import "libcolorpicker.h"

@interface SBLockScreenViewControllerBase : UIViewController
@end

@interface SBHomeScreenViewController : UIViewController
@end

#define PLIST_PATH "/var/mobile/Library/Preferences/com.leroy.AlwaysRemindMePref.plist"
#define PreferencesChangedNotification "com.leroy.AlwaysRemindMe/preferencesChanged"

//define var
static NSUserDefaults *preferences;

static bool enableTweakPref = NO;
static int enableWherePref;

static NSString *txtToDisplayPref;
static CGFloat frameXPref;
static CGFloat frameYPref;
static bool enableBackgroundPref = NO;
static CGFloat frameWPref;
static CGFloat frameHPref;

static CGFloat fontSizePref;
static NSString *fontColorPref;
static NSString *fontBackgroundColorPref;


static void loadPreferences() {

	preferences = [[NSUserDefaults alloc] initWithSuiteName:@"com.leroy.AlwaysRemindMePref"];
	[preferences registerDefaults:@{

		@"enableTweakPref"			: @NO,
		@"enableWherePref"			: [NSNumber numberWithInteger:0],

		@"txtToDisplayPref"			: @"AlwaysRemindMe by LeroyB",
		@"enableBackgroundPref"		: @NO,

		@"frameXPref"				: [NSNumber numberWithFloat:0],
		@"frameYPref"				: [NSNumber numberWithFloat:0],
		@"frameWPref"				: [NSNumber numberWithFloat:100],
		@"frameHPref"				: [NSNumber numberWithFloat:20],

		@"fontSizePref"				: [NSNumber numberWithFloat:14],
		@"fontColorPref"			: @"",
		@"fontBackgroundColorPref"	: @"",

	}];
	NSLog(@"AlwaysRemindMe LOG: define enableWherePref: %d", enableWherePref);

	enableTweakPref 				= [preferences boolForKey:@"enableTweakPref"];
	enableWherePref 				= [preferences integerForKey:@"enableWherePref"];
	NSLog(@"AlwaysRemindMe LOG: init enableWherePref: %d", enableWherePref);

	txtToDisplayPref				= [preferences objectForKey:@"txtToDisplayPref"];
	enableBackgroundPref 			= [preferences boolForKey:@"enableBackgroundPref"];

	frameXPref						= [preferences floatForKey:@"frameXPref"];
	frameYPref						= [preferences floatForKey:@"frameYPref"];
	frameWPref						= [preferences floatForKey:@"frameWPref"];
	frameHPref						= [preferences floatForKey:@"frameHPref"];

	fontSizePref					= [preferences floatForKey:@"fontSizePref"];
	fontColorPref					= [preferences objectForKey:@"fontColorPref"];
	fontBackgroundColorPref			= [preferences objectForKey:@"fontBackgroundColorPref"];

}

//setting text on LS
%hook SBLockScreenViewControllerBase

	-(void)viewDidLoad {
		%orig;
	    NSLog(@"AlwaysRemindMe LOG: orig called in SBLockScreenViewControllerBase: viewDidLoad");

		// CGSize screenSize = [UIScreen mainScreen].bounds.size;
		// double screenHeight = screenSize.height;
		// double screenWidth = screenSize.width;

		if(enableTweakPref) {
			NSLog(@"AlwaysRemindMe LOG: befor enableWherePref: %d", enableWherePref);
			if ((enableWherePref == 0) || (enableWherePref == 2)) {
				NSLog(@"AlwaysRemindMe LOG: after enableWherePref: %d", enableWherePref);

				UILabel *txtToDisplayPrefLabel = [[UILabel alloc] initWithFrame:CGRectMake(frameXPref, frameYPref, frameWPref, frameHPref)];
				[txtToDisplayPrefLabel setTextColor:LCPParseColorString(fontColorPref, nil)];//TODO change for colorpicker var
				[txtToDisplayPrefLabel setBackgroundColor:LCPParseColorString(fontBackgroundColorPref, nil)];//TODO change for colorpicker var
				[txtToDisplayPrefLabel setFont:[UIFont fontWithName: @"Trebuchet MS" size: fontSizePref]];
				[self.view addSubview:txtToDisplayPrefLabel];
				txtToDisplayPrefLabel.text = txtToDisplayPref;
			}
		}
	}

%end

//setting text on SB
%hook SBHomeScreenViewController
	- (void)loadView {
		%orig;
	    NSLog(@"AlwaysRemindMe LOG: orig called in SBHomeScreenViewController: viewDidLoad");
		if(enableTweakPref) {
			NSLog(@"AlwaysRemindMe LOG: SB befor enableWherePref: %d", enableWherePref);
			if ((enableWherePref == 0) || (enableWherePref == 2)) {
				NSLog(@"AlwaysRemindMe LOG: SB after enableWherePref: %d", enableWherePref);
				UILabel *txtToDisplayPrefLabel = [[UILabel alloc] initWithFrame:CGRectMake(frameXPref, frameYPref, frameWPref, frameHPref)];
				[txtToDisplayPrefLabel setTextColor:LCPParseColorString(fontColorPref, nil)];//TODO change for colorpicker var
				[txtToDisplayPrefLabel setBackgroundColor:LCPParseColorString(fontBackgroundColorPref, nil)];//TODO change for colorpicker var
				[txtToDisplayPrefLabel setFont:[UIFont fontWithName: @"Trebuchet MS" size: fontSizePref]];
				[self.view addSubview:txtToDisplayPrefLabel];
				txtToDisplayPrefLabel.text = txtToDisplayPref;
			}
		}
	}
%end

%ctor {
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

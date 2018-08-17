/*
TODO:
	- bug: slider for font size changes color ?!?
	- make everything after the orig a method for redundenz

*/

#import <UIKit/UIKit.h>
#import "libcolorpicker.h"

@interface SBLockScreenViewControllerBase : UIViewController
@end

@interface SBHomeScreenViewController : UIViewController
@end

@interface UIColor(Hexadecimal)

+ (UIColor *)colorWithHexString:(NSString *)hexString;

@end

@implementation UIColor(Hexadecimal)

+ (UIColor *)colorWithHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];

    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

@end

//define var
// static NSUserDefaults *preferences;

static bool twIsEnabled = NO;
static int twWhichScreenChoice = 0;

static NSString *twTextLabelVar = @"AlwaysRemindMe by Leroy";
static int twFramePosChoice = 1;

static CGFloat twFrameX = 0;
static CGFloat twFrameY = 20;
static CGFloat twFrameW = 200;
static CGFloat twFrameH = 20;

// static CGFloat frameX = 0;
// static CGFloat frameY = 0;
// static CGFloat frameW;
// static CGFloat frameH;

static bool twIsBackgroundEnabled = YES;
static CGFloat twFontSize = 14;
static CGFloat twFontSizeCustom = 14;

static NSString *twFontColor = @"#000000";
static NSString *twBackgroundColor = @"#ffffff";
// static NSString *twFontColorDefault = @"#000000";
// static NSString *twBackgroundColorDefault = @"#ffffff";

static void loadPrefs() {

	NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.leroy.AlwaysRemindMePref.plist"];
    if(prefs){
		twIsEnabled				= ([prefs objectForKey:@"pfTweakIsEnabled"] ? [[prefs objectForKey:@"pfTweakIsEnabled"] boolValue] : twIsEnabled);
		twWhichScreenChoice 	= ([prefs objectForKey:@"pfWhichScreenChoice"] ? [[prefs objectForKey:@"pfWhichScreenChoice"] intValue] : twWhichScreenChoice);
		twTextLabelVar				= ([prefs objectForKey:@"pfTextLabel"] ? [[prefs objectForKey:@"pfTextLabel"] stringValue] : twTextLabelVar);

		twFramePosChoice		= ([prefs objectForKey:@"pfFramePosChoice"] ? [[prefs objectForKey:@"pfFramePosChoice"] intValue] : twFramePosChoice);
		twFrameX				= ([prefs objectForKey:@"pfFrameX"] ? [[prefs objectForKey:@"pfFrameX"] floatValue] : twFrameX);
		twFrameY				= ([prefs objectForKey:@"pfFrameY"] ? [[prefs objectForKey:@"pfFrameY"] floatValue] : twFrameY);
		twFrameH				= ([prefs objectForKey:@"pfFrameH"] ? [[prefs objectForKey:@"pfFrameH"] floatValue] : twFrameH);
		twFrameW				= ([prefs objectForKey:@"pfFrameW"] ? [[prefs objectForKey:@"pfFrameW"] floatValue] : twFrameW);

		twIsBackgroundEnabled	= ([prefs objectForKey:@"pfIsBackgroundEnabled"] ? [[prefs objectForKey:@"pfIsBackgroundEnabled"] boolValue] : twIsBackgroundEnabled);
		twBackgroundColor		= ([prefs objectForKey:@"pfBackgroundColor"] ? [[prefs objectForKey:@"pfBackgroundColor"] stringValue] : twBackgroundColor);
		twFontColor				= ([prefs objectForKey:@"pfFontColor"] ? [[prefs objectForKey:@"pfFontColor"] stringValue] : twFontColor);
		twFontSize				= ([prefs objectForKey:@"pfFontSize"] ? [[prefs objectForKey:@"pfFontSize"] floatValue] : twFontSize);
		twFontSizeCustom		= ([prefs objectForKey:@"pfFontSizeCustom"] ? [[prefs objectForKey:@"pfFontSizeCustom"] floatValue] : twFontSizeCustom);
    }
	NSLog(@"AlwaysRemindMe LOG: prefs: %@", prefs);
    [prefs release];
}


static void drawAlwaysRemindMe(double screenHeight, double screenWidth, UIView *currentView) {
	switch (twFramePosChoice) {
		case 1://below StatusBar
			twFrameX = (screenWidth/2) - (twFrameW/2);
			twFrameY = 20;
			break;
		case 2://above dock
			twFrameX = (screenWidth/2) - (twFrameW/2);
			twFrameY = screenHeight-95;
			break;
		case -999:// custom
			// twFrameX = pfFrameX;
			// twFrameY = pfFrameY;
			break;
		default:
			NSLog(@"AlwaysRemindMe ERROR: switch -> twFramePosChoice is default");
			twFrameX = (screenWidth/2) - (twFrameW/2);
			twFrameY = 20;
			break;
	}
	//switch position end
	UILabel *twTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(twFrameX, twFrameY, twFrameW, twFontSize+5)];
	[twTextLabel setTextColor:[UIColor blackColor]];
	if(twIsBackgroundEnabled) {
		[twTextLabel setBackgroundColor: [UIColor colorWithHexString:twBackgroundColor]];
	} else {
		[twTextLabel setBackgroundColor: [UIColor clearColor]];
	}
	if(twFontSize == -999) {
		[twTextLabel setFont:[UIFont fontWithName: @"Trebuchet MS" size: twFontSizeCustom]];
	} else {
		[twTextLabel setFont:[UIFont fontWithName: @"Trebuchet MS" size: twFontSize]];
	}
	[currentView addSubview:twTextLabel];
	twTextLabel.text = twTextLabelVar;
}


//setting text on LS
%hook SBLockScreenViewControllerBase

	-(void)viewDidLoad {
		%orig;

		CGSize screenSize = [UIScreen mainScreen].bounds.size;
		double screenHeight = screenSize.height;
		double screenWidth = screenSize.width;

		NSLog(@"AlwaysRemindMe LOG: LS 'twIsEnabled': %d", twIsEnabled);
		if(twIsEnabled) {
			NSLog(@"AlwaysRemindMe LOG: LS 'twWhichScreenChoice': %d", twWhichScreenChoice);
			if ((twWhichScreenChoice == 0) || (twWhichScreenChoice == 2)) {
				UIView* selfView = self.view;
				drawAlwaysRemindMe(screenHeight, screenWidth, selfView);
			}
		}
	}

%end

//setting text on SB
%hook SBHomeScreenViewController

	- (void)loadView {
		%orig;

		CGSize screenSize = [UIScreen mainScreen].bounds.size;
		double screenHeight = screenSize.height;
		double screenWidth = screenSize.width;

		NSLog(@"AlwaysRemindMe LOG: SB 'twIsEnabled': %d", twIsEnabled);
		if(twIsEnabled) {
			NSLog(@"AlwaysRemindMe LOG: SB 'twWhichScreenChoice': %d", twWhichScreenChoice);
			if ((twWhichScreenChoice == 0) || (twWhichScreenChoice == 1)) {
				UIView* selfView = self.view;
				drawAlwaysRemindMe(screenHeight, screenWidth, selfView);
			}
		}
	}

%end

static void preferenceschanged(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    loadPrefs();
	NSLog(@"AlwaysRemindMe LOG: 'loadPrefs' called in 'preferenceschanged'");
}

%ctor {
	@autoreleasepool {
	    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, preferenceschanged, CFSTR("com.leroy.AlwaysRemindMePref/preferenceschanged"), NULL, CFNotificationSuspensionBehaviorCoalesce);
	    loadPrefs();
		NSLog(@"AlwaysRemindMe LOG: 'loadPrefs' called in 'CFNotificationCenterAddObserver'");
	}
}

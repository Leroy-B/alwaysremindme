#line 1 "Tweak.xm"






#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#define M_PI   3.14159265358979323846264338327950288   
#define DEGREES_TO_RADIANS(angle) (angle / 180.0 * M_PI)

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
    [scanner setScanLocation:1]; 
    [scanner scanHexInt:&rgbValue];

    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

@end


static bool twIsEnabled = NO;
static int twWhichScreenChoice = 0;

static NSString *twTextLabelVar = @"This is a placeholder text";
static int twFramePosChoice = 1;

static CGFloat twFrameX = 0;
static CGFloat twFrameY = 20;
static CGFloat twFrameW = 260;
static CGFloat twFrameH = 20;

static bool twIsBackgroundEnabled = YES;
static CGFloat twFontSize = 14;
static CGFloat twFontSizeCustom = 14;

static NSString *twFontColor = @"#000000";
static NSString *twFontColorCustom = @"#000000";
static NSString *twBackgroundColor = @"#ffffff";
static NSString *twBackgroundColorCustom = @"#ffffff";

static bool twIsRotationEnabled = NO;
static CGFloat twRotationSpeed = 2;

static void loadPrefs() {

	NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.leroy.AlwaysRemindMePref.plist"];
    if(prefs){
		twIsEnabled				= ([prefs objectForKey:@"pfTweakIsEnabled"] ? [[prefs objectForKey:@"pfTweakIsEnabled"] boolValue] : twIsEnabled);
		twWhichScreenChoice 	= ([prefs objectForKey:@"pfWhichScreenChoice"] ? [[prefs objectForKey:@"pfWhichScreenChoice"] intValue] : twWhichScreenChoice);
		twTextLabelVar			= ([prefs objectForKey:@"pfTextLabel"] ? [[prefs objectForKey:@"pfTextLabel"] stringValue] : twTextLabelVar);
        NSLog(@"AlwaysRemindMe LOG: twTextLabelVar emoji: twTextLabelVar: %@ ; pfTextLabel: %@", twTextLabelVar, [prefs objectForKey:@"pfTextLabel"]);

		twFramePosChoice		= ([prefs objectForKey:@"pfFramePosChoice"] ? [[prefs objectForKey:@"pfFramePosChoice"] intValue] : twFramePosChoice);
		twFrameX				= ([prefs objectForKey:@"pfFrameX"] ? [[prefs objectForKey:@"pfFrameX"] floatValue] : twFrameX);
		twFrameY				= ([prefs objectForKey:@"pfFrameY"] ? [[prefs objectForKey:@"pfFrameY"] floatValue] : twFrameY);
		twFrameH				= ([prefs objectForKey:@"pfFrameH"] ? [[prefs objectForKey:@"pfFrameH"] floatValue] : twFrameH);
		twFrameW				= ([prefs objectForKey:@"pfFrameW"] ? [[prefs objectForKey:@"pfFrameW"] floatValue] : twFrameW);

		twIsBackgroundEnabled	= ([prefs objectForKey:@"pfIsBackgroundEnabled"] ? [[prefs objectForKey:@"pfIsBackgroundEnabled"] boolValue] : twIsBackgroundEnabled);
		twBackgroundColor		= ([prefs objectForKey:@"pfBackgroundColor"] ? [[prefs objectForKey:@"pfBackgroundColor"] stringValue] : twBackgroundColor);
        twBackgroundColorCustom	= ([prefs objectForKey:@"pfBackgroundColorCustom"] ? [[prefs objectForKey:@"pfBackgroundColorCustom"] stringValue] : twBackgroundColorCustom);

        twFontColor				= ([prefs objectForKey:@"pfFontColor"] ? [[prefs objectForKey:@"pfFontColor"] stringValue] : twFontColor);
        twFontColorCustom		= ([prefs objectForKey:@"pfFontColorCustom"] ? [[prefs objectForKey:@"pfFontColorCustom"] stringValue] : twFontColorCustom);
		twFontSize				= ([prefs objectForKey:@"pfFontSize"] ? [[prefs objectForKey:@"pfFontSize"] floatValue] : twFontSize);
		twFontSizeCustom		= ([prefs objectForKey:@"pfFontSizeCustom"] ? [[prefs objectForKey:@"pfFontSizeCustom"] floatValue] : twFontSizeCustom);

        twIsRotationEnabled		= ([prefs objectForKey:@"pfIsRotationEnabled"] ? [[prefs objectForKey:@"pfIsRotationEnabled"] boolValue] : twIsRotationEnabled);
        twRotationSpeed			= ([prefs objectForKey:@"pfRotationSpeed"] ? [[prefs objectForKey:@"pfRotationSpeed"] floatValue] : twRotationSpeed);
    }
	NSLog(@"AlwaysRemindMe LOG: prefs: %@", prefs);
    [prefs release];
}

static void performRotationAnimated(UILabel *twTextLabel, double speed){

	[UIView animateWithDuration:(speed/2)
                          delay:0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         twTextLabel.transform = CGAffineTransformMakeRotation(M_PI);
                     }
                     completion:^(BOOL finished){
                         [UIView animateWithDuration:(speed/2)
                                               delay:0
                                             options:UIViewAnimationOptionCurveLinear
                                          animations:^{
                                              twTextLabel.transform = CGAffineTransformMakeRotation(0);
                                          }
                                          completion:^(BOOL finished){
                                              performRotationAnimated(twTextLabel, twRotationSpeed);
                                          }];
                     }];
}

static void pulse(UIView *currentView, double value, double duration) {
    CABasicAnimation *pulseAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    pulseAnimation.duration = duration;
    pulseAnimation.toValue = [NSNumber numberWithFloat:value];
    pulseAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    pulseAnimation.autoreverses = YES;
    pulseAnimation.repeatCount = 999;

    [currentView.layer addAnimation:pulseAnimation forKey:nil];
}


static void drawAlwaysRemindMe(double screenHeight, double screenWidth, UIView *currentView) {
	switch (twFramePosChoice) {
		case 1:
			twFrameX = (screenWidth/2) - (twFrameW/2);
			twFrameY = 20;
			break;
		case 2:
			twFrameX = (screenWidth/2) - (twFrameW/2);
			twFrameY = screenHeight-100;
			break;
		case -999:
			
			
			break;
		default:
			NSLog(@"AlwaysRemindMe ERROR: switch -> twFramePosChoice is default");
			twFrameX = (screenWidth/2) - (twFrameW/2);
			twFrameY = 20;
			break;
	}
	

    
	UILabel *twTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(twFrameX, twFrameY, twFrameW, twFontSize+5)];

    
    if([twFontColor isEqualToString:@"Custom"]) {
        [twTextLabel setTextColor: [UIColor colorWithHexString: twFontColorCustom]];
    } else {
        [twTextLabel setTextColor: [UIColor colorWithHexString: twFontColor]];
    }

    if(twFontSize == -999) {
		[twTextLabel setFont:[UIFont fontWithName: @"Trebuchet MS" size: twFontSizeCustom]];
	} else {
		[twTextLabel setFont:[UIFont fontWithName: @"Trebuchet MS" size: twFontSize]];
	}

    
	if(twIsBackgroundEnabled) {
        if([twBackgroundColor isEqualToString:@"Custom"]) {
            [twTextLabel setBackgroundColor: [UIColor colorWithHexString: twBackgroundColorCustom]];
        } else {
            [twTextLabel setBackgroundColor: [UIColor colorWithHexString: twBackgroundColor]];
        }
	} else {
		[twTextLabel setBackgroundColor: [UIColor clearColor]];
	}

	[currentView addSubview:twTextLabel];
	twTextLabel.text = [NSString stringWithFormat:@"%@",twTextLabelVar];

    
    if(twIsRotationEnabled) {
        performRotationAnimated(twTextLabel, twRotationSpeed);
    }

    pulse(twTextLabel, 2, 1);

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

@class SBHomeScreenViewController; @class SBLockScreenViewControllerBase; 
static void (*_logos_orig$_ungrouped$SBLockScreenViewControllerBase$viewDidLoad)(_LOGOS_SELF_TYPE_NORMAL SBLockScreenViewControllerBase* _LOGOS_SELF_CONST, SEL); static void _logos_method$_ungrouped$SBLockScreenViewControllerBase$viewDidLoad(_LOGOS_SELF_TYPE_NORMAL SBLockScreenViewControllerBase* _LOGOS_SELF_CONST, SEL); static void (*_logos_orig$_ungrouped$SBHomeScreenViewController$loadView)(_LOGOS_SELF_TYPE_NORMAL SBHomeScreenViewController* _LOGOS_SELF_CONST, SEL); static void _logos_method$_ungrouped$SBHomeScreenViewController$loadView(_LOGOS_SELF_TYPE_NORMAL SBHomeScreenViewController* _LOGOS_SELF_CONST, SEL); 

#line 189 "Tweak.xm"


	static void _logos_method$_ungrouped$SBLockScreenViewControllerBase$viewDidLoad(_LOGOS_SELF_TYPE_NORMAL SBLockScreenViewControllerBase* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd) {
		_logos_orig$_ungrouped$SBLockScreenViewControllerBase$viewDidLoad(self, _cmd);

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






	static void _logos_method$_ungrouped$SBHomeScreenViewController$loadView(_LOGOS_SELF_TYPE_NORMAL SBHomeScreenViewController* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd) {
		_logos_orig$_ungrouped$SBHomeScreenViewController$loadView(self, _cmd);

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



static void preferenceschanged(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    loadPrefs();
	NSLog(@"AlwaysRemindMe LOG: 'loadPrefs' called in 'preferenceschanged'");
}

static __attribute__((constructor)) void _logosLocalCtor_d1105d9c(int __unused argc, char __unused **argv, char __unused **envp) {
	@autoreleasepool {
	    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, preferenceschanged, CFSTR("com.leroy.AlwaysRemindMePref/preferenceschanged"), NULL, CFNotificationSuspensionBehaviorCoalesce);
	    loadPrefs();
		NSLog(@"AlwaysRemindMe LOG: 'loadPrefs' called in 'CFNotificationCenterAddObserver'");
	}
}
static __attribute__((constructor)) void _logosLocalInit() {
{Class _logos_class$_ungrouped$SBLockScreenViewControllerBase = objc_getClass("SBLockScreenViewControllerBase"); MSHookMessageEx(_logos_class$_ungrouped$SBLockScreenViewControllerBase, @selector(viewDidLoad), (IMP)&_logos_method$_ungrouped$SBLockScreenViewControllerBase$viewDidLoad, (IMP*)&_logos_orig$_ungrouped$SBLockScreenViewControllerBase$viewDidLoad);Class _logos_class$_ungrouped$SBHomeScreenViewController = objc_getClass("SBHomeScreenViewController"); MSHookMessageEx(_logos_class$_ungrouped$SBHomeScreenViewController, @selector(loadView), (IMP)&_logos_method$_ungrouped$SBHomeScreenViewController$loadView, (IMP*)&_logos_orig$_ungrouped$SBHomeScreenViewController$loadView);} }
#line 244 "Tweak.xm"

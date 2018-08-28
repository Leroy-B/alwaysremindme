#line 1 "Tweak.xm"



















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

static NSString *twTextLabelVar = @"Thank you for downloading :)";

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
static int twRotationSpeedChoice = 1;
static CGFloat twRotationSpeed = 2;

static bool twIsBlinkingEnabled = NO;
static int twBlinkingSpeedChoice = 1;
static CGFloat twBlinkingSpeed = 2;

static bool twIsPulseEnabled = NO;
static int twPulseSpeedChoice = 1;
static CGFloat twPulseSpeed = 1;
static int twPulseSizeChoice = 1;
static CGFloat twPulseSize = 2;



static void loadPrefs() {

	NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.leroy.AlwaysRemindMePref.plist"];
    if(prefs){
		twIsEnabled				= ([prefs objectForKey:@"pfTweakIsEnabled"] ? [[prefs objectForKey:@"pfTweakIsEnabled"] boolValue] : twIsEnabled);
		twWhichScreenChoice 	= ([prefs objectForKey:@"pfWhichScreenChoice"] ? [[prefs objectForKey:@"pfWhichScreenChoice"] intValue] : twWhichScreenChoice);

        NSMutableArray *array = [NSMutableArray array];
        for (int i = 0; i < [[[prefs objectForKey:@"pfTextLabel"] description] length]; i++) {
            [array addObject:[NSString stringWithFormat:@"%C", [[[prefs objectForKey:@"pfTextLabel"] description] characterAtIndex:i]]];
        }

        NSMutableString *result = [[NSMutableString alloc] init];
        for (NSObject *obj in array){
            [result appendString:[obj description]];
        }

        twTextLabelVar = result;

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
        twRotationSpeedChoice 	= ([prefs objectForKey:@"pfRotationSpeedChoice"] ? [[prefs objectForKey:@"pfRotationSpeedChoice"] intValue] : twRotationSpeedChoice);
        twRotationSpeed			= ([prefs objectForKey:@"pfRotationSpeed"] ? [[prefs objectForKey:@"pfRotationSpeed"] floatValue] : twRotationSpeed);

        twIsBlinkingEnabled		= ([prefs objectForKey:@"pfIsBlinkingEnabled"] ? [[prefs objectForKey:@"pfIsBlinkingEnabled"] boolValue] : twIsBlinkingEnabled);
        twBlinkingSpeedChoice 	= ([prefs objectForKey:@"pfBlinkingSpeedChoice"] ? [[prefs objectForKey:@"pfBlinkingSpeedChoice"] intValue] : twBlinkingSpeedChoice);
        twBlinkingSpeed			= ([prefs objectForKey:@"pfBlinkingSpeed"] ? [[prefs objectForKey:@"pfBlinkingSpeed"] floatValue] : twBlinkingSpeed);

        twIsPulseEnabled		= ([prefs objectForKey:@"pfIsPulseEnabled"] ? [[prefs objectForKey:@"pfIsPulseEnabled"] boolValue] : twIsPulseEnabled);
        twPulseSpeedChoice 	    = ([prefs objectForKey:@"pfPulseSpeedChoice"] ? [[prefs objectForKey:@"pfPulseSpeedChoice"] intValue] : twPulseSpeedChoice);
        twPulseSpeed			= ([prefs objectForKey:@"pfPulseSpeed"] ? [[prefs objectForKey:@"pfPulseSpeed"] floatValue] : twPulseSpeed);
        twPulseSizeChoice 	    = ([prefs objectForKey:@"pfPulseSizeChoice"] ? [[prefs objectForKey:@"pfPulseSizeChoice"] intValue] : twPulseSizeChoice);
        twPulseSize 			= ([prefs objectForKey:@"pfPulseSize"] ? [[prefs objectForKey:@"pfPulseSize"] floatValue] : twPulseSize);
    }
	NSLog(@"AlwaysRemindMe LOG: prefs: %@", prefs);
    [prefs release];
}

static void performRotationAnimated(UILabel *twTextLabel, double speed) {

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

static void performPulseAnimated(UIView *currentView, double size, double duration) {

    CABasicAnimation *pulseAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    pulseAnimation.duration = duration;
    pulseAnimation.toValue = [NSNumber numberWithFloat:size];
    pulseAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    pulseAnimation.autoreverses = YES;
    pulseAnimation.repeatCount = HUGE_VALF;
    [currentView.layer addAnimation:pulseAnimation forKey:nil];

}
















static void performBlinkingAnimated(UIView *currentView, double duration) {

    currentView.alpha = 1;
    [UIView animateWithDuration:duration delay:0.5 options:UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse animations:^{
        currentView.alpha = 0;
    } completion:nil];

}

static void drawAlwaysRemindMe(double screenHeight, double screenWidth, UIView *currentView) {
    double varFrameX, varFrameY = 0;
	switch (twFramePosChoice) {
		case 1:
			varFrameX = (screenWidth/2) - (twFrameW/2);
			varFrameY = 20;
			break;
		case 2:
			varFrameX = (screenWidth/2) - (twFrameW/2);
			varFrameY = screenHeight-100;
			break;
		case -999:
			varFrameX = twFrameX;
			varFrameY = twFrameY;
			break;
		default:
			NSLog(@"AlwaysRemindMe ERROR: switch -> twFramePosChoice is default");
			varFrameX = (screenWidth/2) - (twFrameW/2);
			varFrameY = 20;
			break;
	}
	
    twFrameX = varFrameX;
    twFrameY = varFrameY;

    

    
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
	twTextLabel.text = twTextLabelVar;

    
    if(twIsRotationEnabled) {
        performRotationAnimated(twTextLabel, twRotationSpeed);
    }

    double varPulseSize, varPulseSpeed = 0;
    if(twIsPulseEnabled) {
        switch (twPulseSizeChoice) {
    		case 1:
    			varPulseSize = 2;
    			break;
    		case 2:
    			varPulseSize = 1;
    			break;
            case 3:
    			varPulseSize = 4;
    			break;
    		case -999:
    			varPulseSize = twPulseSize;
    			break;
    		default:
    			NSLog(@"AlwaysRemindMe ERROR: switch -> twPulseSizeChoice is default");
                varPulseSize = 2;
    			break;
    	}
    	
        switch (twPulseSpeedChoice) {
    		case 1:
    			varPulseSpeed = 1;
    			break;
    		case 2:
    			varPulseSpeed = 0.5;
    			break;
            case 3:
    			varPulseSpeed = 2;
    			break;
    		case -999:
    			varPulseSpeed = twPulseSpeed;
    			break;
    		default:
    			NSLog(@"AlwaysRemindMe ERROR: switch -> twPulseSpeedChoice is default");
                varPulseSpeed = 1;
    			break;
    	}
    	
        performPulseAnimated(twTextLabel, varPulseSize, varPulseSpeed);
    }

    double varBlinkingSpeed = 0.5;
    if(twIsBlinkingEnabled) {
        switch (twBlinkingSpeedChoice) {
    		case 1:
    			varBlinkingSpeed = 0.5;
    			break;
    		case 2:
    			varBlinkingSpeed = 0.25;
    			break;
            case 3:
    			varBlinkingSpeed = 1;
    			break;
    		case -999:
    			varPulseSize = twPulseSize;
    			break;
    		default:
    			NSLog(@"AlwaysRemindMe ERROR: switch -> twBlinkingSpeedChoice is default");
                varBlinkingSpeed = 0.5;
    			break;
    	}
    	
        performBlinkingAnimated(twTextLabel, varBlinkingSpeed);
    }

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    

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
static void (*_logos_orig$_ungrouped$SBLockScreenViewControllerBase$viewDidAppear$)(_LOGOS_SELF_TYPE_NORMAL SBLockScreenViewControllerBase* _LOGOS_SELF_CONST, SEL, BOOL); static void _logos_method$_ungrouped$SBLockScreenViewControllerBase$viewDidAppear$(_LOGOS_SELF_TYPE_NORMAL SBLockScreenViewControllerBase* _LOGOS_SELF_CONST, SEL, BOOL); static void (*_logos_orig$_ungrouped$SBHomeScreenViewController$viewDidAppear$)(_LOGOS_SELF_TYPE_NORMAL SBHomeScreenViewController* _LOGOS_SELF_CONST, SEL, BOOL); static void _logos_method$_ungrouped$SBHomeScreenViewController$viewDidAppear$(_LOGOS_SELF_TYPE_NORMAL SBHomeScreenViewController* _LOGOS_SELF_CONST, SEL, BOOL); 

#line 347 "Tweak.xm"


	static void _logos_method$_ungrouped$SBLockScreenViewControllerBase$viewDidAppear$(_LOGOS_SELF_TYPE_NORMAL SBLockScreenViewControllerBase* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd, BOOL arg1) {
        _logos_orig$_ungrouped$SBLockScreenViewControllerBase$viewDidAppear$(self, _cmd, arg1);
        NSLog(@"AlwaysRemindMe LOG: LS 'BOOL arg1': %d", arg1);

		CGSize screenSize = [UIScreen mainScreen].bounds.size;
		double screenHeight = screenSize.height;
		double screenWidth = screenSize.width;

		NSLog(@"AlwaysRemindMe LOG: LS 'twIsEnabled': %d", twIsEnabled);
		if(twIsEnabled) {
			NSLog(@"AlwaysRemindMe LOG: LS 'twWhichScreenChoice': %d", twWhichScreenChoice);
			if ((twWhichScreenChoice == 0) || (twWhichScreenChoice == 2)) {
				UIView* selfView = self.view;
				drawAlwaysRemindMe(screenHeight, screenWidth, selfView);
                NSLog(@"AlwaysRemindMe LOG: LS 'drawAlwaysRemindMe' got called");
			}
		}
	}






	static void _logos_method$_ungrouped$SBHomeScreenViewController$viewDidAppear$(_LOGOS_SELF_TYPE_NORMAL SBHomeScreenViewController* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd, BOOL arg1) {
        _logos_orig$_ungrouped$SBHomeScreenViewController$viewDidAppear$(self, _cmd, arg1);

		CGSize screenSize = [UIScreen mainScreen].bounds.size;
		double screenHeight = screenSize.height;
		double screenWidth = screenSize.width;

		if(twIsEnabled) {
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

static __attribute__((constructor)) void _logosLocalCtor_708bdd42(int __unused argc, char __unused **argv, char __unused **envp) {
	@autoreleasepool {
        loadPrefs();
	    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, preferenceschanged, CFSTR("com.leroy.AlwaysRemindMePref/preferenceschanged"), NULL, CFNotificationSuspensionBehaviorCoalesce);
		NSLog(@"AlwaysRemindMe LOG: 'loadPrefs' called in 'CFNotificationCenterAddObserver'");
	}
}
static __attribute__((constructor)) void _logosLocalInit() {
{Class _logos_class$_ungrouped$SBLockScreenViewControllerBase = objc_getClass("SBLockScreenViewControllerBase"); MSHookMessageEx(_logos_class$_ungrouped$SBLockScreenViewControllerBase, @selector(viewDidAppear:), (IMP)&_logos_method$_ungrouped$SBLockScreenViewControllerBase$viewDidAppear$, (IMP*)&_logos_orig$_ungrouped$SBLockScreenViewControllerBase$viewDidAppear$);Class _logos_class$_ungrouped$SBHomeScreenViewController = objc_getClass("SBHomeScreenViewController"); MSHookMessageEx(_logos_class$_ungrouped$SBHomeScreenViewController, @selector(viewDidAppear:), (IMP)&_logos_method$_ungrouped$SBHomeScreenViewController$viewDidAppear$, (IMP*)&_logos_orig$_ungrouped$SBHomeScreenViewController$viewDidAppear$);} }
#line 402 "Tweak.xm"

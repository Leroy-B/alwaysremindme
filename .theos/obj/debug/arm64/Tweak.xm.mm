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


static SBHomeScreenViewController *myself;



static bool twIsEnabled = NO;
static bool twIsViewPresented = NO;
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

static int twFontColorChoice = 1;
static NSString *twFontColorCustom = @"#000000";
static int twBackgroundColorChoice = 1;
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


static bool twShouldDelete = NO;

static void dealloc(UIView *currentView) {
    [currentView release], currentView = nil;
}

static void showAlertChangeInSettings(NSString *msg) {

    UIAlertController * alert = [UIAlertController
                alertControllerWithTitle:@"AlwaysRemindMe: ERROR"
                                 message:msg
                          preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* okButton = [UIAlertAction
                         actionWithTitle:@"OK"
                                   style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action) {
                                                    
                                 }];
    UIAlertAction* changeButton = [UIAlertAction
                         actionWithTitle:@"Change in settings"
                                   style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action) {
                                     [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=AlwaysRemindMe"] options:@{} completionHandler:nil];
                                 }];
    [alert addAction:changeButton];
    [alert addAction:okButton];
    [(SBHomeScreenViewController*)myself presentViewController:alert animated:YES completion:nil];

}

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
		twBackgroundColorChoice	= ([prefs objectForKey:@"pfBackgroundColorChoice"] ? [[prefs objectForKey:@"pfBackgroundColorChoice"] intValue] : twBackgroundColorChoice);
        twBackgroundColorCustom	= ([prefs objectForKey:@"pfBackgroundColorCustom"] ? [[prefs objectForKey:@"pfBackgroundColorCustom"] stringValue] : twBackgroundColorCustom);

        twFontColorChoice		= ([prefs objectForKey:@"pfFontColorChoice"] ? [[prefs objectForKey:@"pfFontColorChoice"] intValue] : twFontColorChoice);
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

    UILabel *twTextLabel = [[UILabel alloc] init];
    twTextLabel.text = twTextLabelVar;

    CGSize labelSize = twTextLabel.attributedText.size;
    CGFloat absolutCenter = (screenWidth/2) - (labelSize.width/2);
    NSLog(@"AlwaysRemindMe LOG: absolutCenter; %f", absolutCenter);

    double varFrameX, varFrameY = 0;
	switch (twFramePosChoice) {
		case 1:
			varFrameX = absolutCenter;
			varFrameY = 20;
			break;
		case 2:
			varFrameX = absolutCenter;
			varFrameY = screenHeight-110;
			break;
		case -999:
            if([[[NSNumber numberWithFloat:twFrameX] stringValue] isEqualToString:@""] && [[[NSNumber numberWithFloat:twFrameY] stringValue] isEqualToString:@""]){
                varFrameX = absolutCenter;
                varFrameY = screenHeight/2;
            } else if([[[NSNumber numberWithFloat:twFrameX] stringValue] isEqualToString:@""]){
                varFrameX = absolutCenter;
                varFrameY = twFrameY;
            } else if([[[NSNumber numberWithFloat:twFrameY] stringValue] isEqualToString:@""]){
                varFrameX = twFrameX;
                varFrameY = screenHeight/2;
            } else {
                varFrameX = twFrameX;
    			varFrameY = twFrameY;
            }
			break;
		default:
			NSLog(@"AlwaysRemindMe ERROR: switch -> twFramePosChoice is default");
			varFrameX = (screenWidth/2) - (twFrameW/2);
			varFrameY = 20;
			break;
	}
	
    twFrameX = varFrameX;
    twFrameY = varFrameY;

    twTextLabel.frame = CGRectMake(twFrameX, twFrameY, twTextLabel.intrinsicContentSize.width, twFontSize+5);

	
    
    NSString *varFontColor = @"#000000";
    switch (twFontColorChoice) {
        case 1:
            varFontColor = @"#000000";
            break;
        case 2:
            varFontColor = @"#FFFFFF";
            break;
        case 3:
            varFontColor = @"#FFA500";
            break;
        case -999:
            if([twFontColorCustom isEqualToString:@""]){
                varFontColor = @"#000000";
                showAlertChangeInSettings(@"Your custom background color value is invalid!");
            } else if([twBackgroundColorCustom isEqualToString:@"#"]){
                varFontColor = @"#000000";
                showAlertChangeInSettings(@"Your custom background color value is invalid!");
            } else {
                varFontColor = twFontColorCustom;
            }
            break;
        default:
            NSLog(@"AlwaysRemindMe ERROR: switch -> twFontColorChoice is default");
            varFontColor = @"#000000";
            break;
    }
    [twTextLabel setTextColor: [UIColor colorWithHexString: varFontColor]];

    if(twFontSize == -999) {
		[twTextLabel setFont:[UIFont fontWithName: @"Trebuchet MS" size: twFontSizeCustom]];
	} else {
		[twTextLabel setFont:[UIFont fontWithName: @"Trebuchet MS" size: twFontSize]];
	}

    
	if(twIsBackgroundEnabled) {
        NSString *varBackgroundColor = @"#FFFFFF";
        switch (twBackgroundColorChoice) {
    		case 1:
                varBackgroundColor = @"#FFFFFF";
    			break;
    		case 2:
                varBackgroundColor = @"#000000";
    			break;
            case 3:
                varBackgroundColor = @"#FFA500";
    			break;
    		case -999:
                if([twBackgroundColorCustom isEqualToString:@""]){
                    varBackgroundColor = @"#FFFFFF";
                    showAlertChangeInSettings(@"Your custom background color value is invalid!");
                } else if([twBackgroundColorCustom isEqualToString:@"#"]){
                    varBackgroundColor = @"#FFFFFF";
                    showAlertChangeInSettings(@"Your custom background color value is invalid!");
                } else {
                    varBackgroundColor = twBackgroundColorCustom;
                }
    			break;
    		default:
    			NSLog(@"AlwaysRemindMe ERROR: switch -> twBackgroundColorChoice is default");
    			varBackgroundColor = @"#FFFFFF";
    			break;
    	}
        [twTextLabel setBackgroundColor: [UIColor colorWithHexString: varBackgroundColor]];
	} else {
		[twTextLabel setBackgroundColor: [UIColor clearColor]];
    }

	[currentView addSubview:twTextLabel];


    
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
static void (*_logos_orig$_ungrouped$SBLockScreenViewControllerBase$viewDidAppear$)(_LOGOS_SELF_TYPE_NORMAL SBLockScreenViewControllerBase* _LOGOS_SELF_CONST, SEL, BOOL); static void _logos_method$_ungrouped$SBLockScreenViewControllerBase$viewDidAppear$(_LOGOS_SELF_TYPE_NORMAL SBLockScreenViewControllerBase* _LOGOS_SELF_CONST, SEL, BOOL); static void (*_logos_orig$_ungrouped$SBHomeScreenViewController$viewDidLayoutSubviews)(_LOGOS_SELF_TYPE_NORMAL SBHomeScreenViewController* _LOGOS_SELF_CONST, SEL); static void _logos_method$_ungrouped$SBHomeScreenViewController$viewDidLayoutSubviews(_LOGOS_SELF_TYPE_NORMAL SBHomeScreenViewController* _LOGOS_SELF_CONST, SEL); 

#line 440 "Tweak.xm"


	static void _logos_method$_ungrouped$SBLockScreenViewControllerBase$viewDidAppear$(_LOGOS_SELF_TYPE_NORMAL SBLockScreenViewControllerBase* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd, BOOL arg1) {
        _logos_orig$_ungrouped$SBLockScreenViewControllerBase$viewDidAppear$(self, _cmd, arg1);

        CGSize screenSize = [UIScreen mainScreen].bounds.size;
		double screenHeight = screenSize.height;
		double screenWidth = screenSize.width;

        UIView* selfView = self.view;
        

		if(twIsEnabled && !twIsViewPresented) {
			if ((twWhichScreenChoice == 0) || (twWhichScreenChoice == 1)) {
				drawAlwaysRemindMe(screenHeight, screenWidth, selfView);
                twIsViewPresented = YES;
			}
		}
        if(twShouldDelete){
            dealloc(selfView);
        }
	}






	static void _logos_method$_ungrouped$SBHomeScreenViewController$viewDidLayoutSubviews(_LOGOS_SELF_TYPE_NORMAL SBHomeScreenViewController* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd) {
        _logos_orig$_ungrouped$SBHomeScreenViewController$viewDidLayoutSubviews(self, _cmd);

		CGSize screenSize = [UIScreen mainScreen].bounds.size;
		double screenHeight = screenSize.height;
		double screenWidth = screenSize.width;

        UIView* selfView = self.view;
        myself = self;
        NSLog(@"AlwaysRemindMe LOG: 'myself' is: %@", myself);

		if(twIsEnabled && !twIsViewPresented) {
			if ((twWhichScreenChoice == 0) || (twWhichScreenChoice == 1)) {
				drawAlwaysRemindMe(screenHeight, screenWidth, selfView);
                twIsViewPresented = YES;
			}
		}
        if(twShouldDelete){
            dealloc(selfView);
        }

	}




static void preferenceschanged(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    loadPrefs();
	NSLog(@"AlwaysRemindMe LOG: 'loadPrefs' called in 'preferenceschanged'");
}

static __attribute__((constructor)) void _logosLocalCtor_952e7dc1(int __unused argc, char __unused **argv, char __unused **envp) {
	@autoreleasepool {
        loadPrefs();
	    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, preferenceschanged, CFSTR("com.leroy.AlwaysRemindMePref/preferenceschanged"), NULL, CFNotificationSuspensionBehaviorCoalesce);
		NSLog(@"AlwaysRemindMe LOG: 'loadPrefs' called in 'CFNotificationCenterAddObserver'");
	}
}
static __attribute__((constructor)) void _logosLocalInit() {
{Class _logos_class$_ungrouped$SBLockScreenViewControllerBase = objc_getClass("SBLockScreenViewControllerBase"); MSHookMessageEx(_logos_class$_ungrouped$SBLockScreenViewControllerBase, @selector(viewDidAppear:), (IMP)&_logos_method$_ungrouped$SBLockScreenViewControllerBase$viewDidAppear$, (IMP*)&_logos_orig$_ungrouped$SBLockScreenViewControllerBase$viewDidAppear$);Class _logos_class$_ungrouped$SBHomeScreenViewController = objc_getClass("SBHomeScreenViewController"); MSHookMessageEx(_logos_class$_ungrouped$SBHomeScreenViewController, @selector(viewDidLayoutSubviews), (IMP)&_logos_method$_ungrouped$SBHomeScreenViewController$viewDidLayoutSubviews, (IMP*)&_logos_orig$_ungrouped$SBHomeScreenViewController$viewDidLayoutSubviews);} }
#line 506 "Tweak.xm"

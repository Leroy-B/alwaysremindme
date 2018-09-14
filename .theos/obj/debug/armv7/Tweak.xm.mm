#line 1 "Tweak.xm"













@interface SpringBoard
@end

@interface SBLockScreenViewControllerBase : UIViewController
@end

@interface SBHomeScreenViewController : UIViewController
@end

@interface UIColor(Hexadecimal)

+ (UIColor *)colorFromHex:(NSString *)hexString;

@end

@implementation UIColor(Hexadecimal)

+ (UIColor *)colorFromHex:(NSString *)hexString {
    unsigned rgbValue = 0;
    if ([hexString hasPrefix:@"#"]) {
		hexString = [hexString substringFromIndex:1];
	}
    if (hexString) {
	    NSScanner *scanner = [NSScanner scannerWithString:hexString];
	    [scanner setScanLocation:0]; 
	    [scanner scanHexInt:&rgbValue];
	    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
    } else {
		return [UIColor grayColor];
	}
}

@end

@interface PCSimpleTimer : NSObject
@property BOOL disableSystemWaking;
- (BOOL)disableSystemWaking;
- (id)initWithFireDate:(id)arg1 serviceIdentifier:(id)arg2 target:(id)arg3 selector:(SEL)arg4 userInfo:(id)arg5;
- (id)initWithTimeInterval:(double)arg1 serviceIdentifier:(id)arg2 target:(id)arg3 selector:(SEL)arg4 userInfo:(id)arg5;
- (void)invalidate;
- (BOOL)isValid;
- (void)scheduleInRunLoop:(id)arg1;
- (void)setDisableSystemWaking:(BOOL)arg1;
- (id)userInfo;
@end


#define PLIST_PATH @"/var/mobile/Library/Preferences/com.leroy.AlwaysRemindMePref.plist"


static SBHomeScreenViewController *myself;


static bool twIsEnabled = NO;

static int twWhichScreenChoice = 0;

static NSString *twTextLabelVar = @"Thank you for downloading :)";
static NSString *twTextLabelVar1 = @"";




static bool twIsTimerEnabled = NO;
static NSString *twTime24 = @"12:00";
static NSString *twTimerCustom = @"12";
static int twTimerChoice = 1;



static int twFramePosChoice = 1;
static CGFloat twFrameX = 0;
static CGFloat twFrameY = 20;
static CGFloat twFrameW = 260;
static CGFloat twFrameH = 20;

static bool twIsBackgroundEnabled = YES;
static CGFloat twFontSize = 14;
static CGFloat twFontSizeCustom = 14;
static NSString *twFontCustom = @"Trebuchet MS";

static int twFontColorChoice = 1;
static NSString *twFontColorCustom = @"#000000";
static int twBackgroundColorChoice = 1;
static NSString *twBackgroundColorCustom = @"#ffffff";

static bool twIsRainbowEnabled = NO;
static CGFloat twRainbowDelay = 0;

static bool twIsRotationEnabled = NO;
static int twRotationSpeedChoice = 1;
static CGFloat twRotationSpeed = 2;
static CGFloat twRotationDelay = 0;

static bool twIsBlinkEnabled = NO;
static int twBlinkSpeedChoice = 1;
static CGFloat twBlinkSpeed = 2;

static bool twIsShakeEnabled = NO;
static int twShakeDurationChoice = 1;
static CGFloat twShakeDuration = 1;
static CGFloat twShakeXAmount = 10;
static CGFloat twShakeYAmount = 0;

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
                                     [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"App-Prefs:root="] options:@{} completionHandler:nil];
                                 }];
    [alert addAction:changeButton];
    [alert addAction:okButton];
    [(SBHomeScreenViewController*)myself presentViewController:alert animated:YES completion:nil];

}

static void loadPrefs() {

	NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:PLIST_PATH];
    if(prefs){
		twIsEnabled				= ([prefs objectForKey:@"pfIsTweakEnabled"] ? [[prefs objectForKey:@"pfIsTweakEnabled"] boolValue] : twIsEnabled);
		twWhichScreenChoice 	= ([prefs objectForKey:@"pfWhichScreenChoice"] ? [[prefs objectForKey:@"pfWhichScreenChoice"] intValue] : twWhichScreenChoice);

        twIsTimerEnabled		= ([prefs objectForKey:@"pfIsTimerEnabled"] ? [[prefs objectForKey:@"pfIsTimerEnabled"] boolValue] : twIsTimerEnabled);
        twTime24        		= ([prefs objectForKey:@"pfTime24"] ? [[prefs objectForKey:@"pfTime24"] description] : twTime24);
        twTimerChoice           = ([prefs objectForKey:@"pfTimerChoice"] ? [[prefs objectForKey:@"pfTimerChoice"] intValue] : twTimerChoice);
        twTimerCustom        	= ([prefs objectForKey:@"pfTimerCustom"] ? [[prefs objectForKey:@"pfTimerCustom"] description] : twTimerCustom);

        
        NSMutableArray *array = [NSMutableArray array];
        for (int i = 0; i < [[[prefs objectForKey:@"pfTextLabel"] description] length]; i++) {
            [array addObject:[NSString stringWithFormat:@"%C", [[[prefs objectForKey:@"pfTextLabel"] description] characterAtIndex:i]]];
        }

        NSMutableString *result = [[NSMutableString alloc] init];
        for (NSObject *obj in array){
            [result appendString:[obj description]];
        }
        twTextLabelVar = result;

        NSMutableArray *array1 = [NSMutableArray array];
        for (int i = 0; i < [[[prefs objectForKey:@"pfTextLabel1"] description] length]; i++) {
            [array1 addObject:[NSString stringWithFormat:@"%C", [[[prefs objectForKey:@"pfTextLabel1"] description] characterAtIndex:i]]];
        }

        NSMutableString *result1 = [[NSMutableString alloc] init];
        for (NSObject *obj1 in array1){
            [result1 appendString:[obj1 description]];
        }
        twTextLabelVar1 = result1;

		twFramePosChoice		= ([prefs objectForKey:@"pfFramePosChoice"] ? [[prefs objectForKey:@"pfFramePosChoice"] intValue] : twFramePosChoice);
		twFrameX				= ([prefs objectForKey:@"pfFrameX"] ? [[prefs objectForKey:@"pfFrameX"] floatValue] : twFrameX);
		twFrameY				= ([prefs objectForKey:@"pfFrameY"] ? [[prefs objectForKey:@"pfFrameY"] floatValue] : twFrameY);
		twFrameH				= ([prefs objectForKey:@"pfFrameH"] ? [[prefs objectForKey:@"pfFrameH"] floatValue] : twFrameH);
		twFrameW				= ([prefs objectForKey:@"pfFrameW"] ? [[prefs objectForKey:@"pfFrameW"] floatValue] : twFrameW);

		twIsBackgroundEnabled	= ([prefs objectForKey:@"pfIsBackgroundEnabled"] ? [[prefs objectForKey:@"pfIsBackgroundEnabled"] boolValue] : twIsBackgroundEnabled);
		twBackgroundColorChoice	= ([prefs objectForKey:@"pfBackgroundColorChoice"] ? [[prefs objectForKey:@"pfBackgroundColorChoice"] intValue] : twBackgroundColorChoice);
        twBackgroundColorCustom	= ([prefs objectForKey:@"pfBackgroundColorCustom"] ? [[prefs objectForKey:@"pfBackgroundColorCustom"] description] : twBackgroundColorCustom);

        twIsRainbowEnabled		= ([prefs objectForKey:@"pfIsRainbowEnabled"] ? [[prefs objectForKey:@"pfIsRainbowEnabled"] boolValue] : twIsRainbowEnabled);
        twRainbowDelay			= ([prefs objectForKey:@"pfRainbowDelay"] ? [[prefs objectForKey:@"pfRainbowDelay"] floatValue] : twRainbowDelay);

        twFontColorChoice		= ([prefs objectForKey:@"pfFontColorChoice"] ? [[prefs objectForKey:@"pfFontColorChoice"] intValue] : twFontColorChoice);
        twFontColorCustom		= ([prefs objectForKey:@"pfFontColorCustom"] ? [[prefs objectForKey:@"pfFontColorCustom"] description] : twFontColorCustom);
		twFontSize				= ([prefs objectForKey:@"pfFontSize"] ? [[prefs objectForKey:@"pfFontSize"] floatValue] : twFontSize);
		twFontSizeCustom		= ([prefs objectForKey:@"pfFontSizeCustom"] ? [[prefs objectForKey:@"pfFontSizeCustom"] floatValue] : twFontSizeCustom);
        twFontCustom    		= ([prefs objectForKey:@"pfFontCustom"] ? [[prefs objectForKey:@"pfFontCustom"] description] : twFontCustom);

        twIsRotationEnabled		= ([prefs objectForKey:@"pfIsRotationEnabled"] ? [[prefs objectForKey:@"pfIsRotationEnabled"] boolValue] : twIsRotationEnabled);
        twRotationSpeedChoice 	= ([prefs objectForKey:@"pfRotationSpeedChoice"] ? [[prefs objectForKey:@"pfRotationSpeedChoice"] intValue] : twRotationSpeedChoice);
        twRotationSpeed			= ([prefs objectForKey:@"pfRotationSpeed"] ? [[prefs objectForKey:@"pfRotationSpeed"] floatValue] : twRotationSpeed);
        twRotationDelay			= ([prefs objectForKey:@"pfRotationDelay"] ? [[prefs objectForKey:@"pfRotationDelay"] floatValue] : twRotationDelay);

        twIsBlinkEnabled		= ([prefs objectForKey:@"pfIsBlinkEnabled"] ? [[prefs objectForKey:@"pfIsBlinkEnabled"] boolValue] : twIsBlinkEnabled);
        twBlinkSpeedChoice      = ([prefs objectForKey:@"pfBlinkSpeedChoice"] ? [[prefs objectForKey:@"pfBlinkSpeedChoice"] intValue] : twBlinkSpeedChoice);
        twBlinkSpeed			= ([prefs objectForKey:@"pfBlinkSpeed"] ? [[prefs objectForKey:@"pfBlinkSpeed"] floatValue] : twBlinkSpeed);

        twIsPulseEnabled		= ([prefs objectForKey:@"pfIsPulseEnabled"] ? [[prefs objectForKey:@"pfIsPulseEnabled"] boolValue] : twIsPulseEnabled);
        twPulseSpeedChoice 	    = ([prefs objectForKey:@"pfPulseSpeedChoice"] ? [[prefs objectForKey:@"pfPulseSpeedChoice"] intValue] : twPulseSpeedChoice);
        twPulseSpeed			= ([prefs objectForKey:@"pfPulseSpeed"] ? [[prefs objectForKey:@"pfPulseSpeed"] floatValue] : twPulseSpeed);
        twPulseSizeChoice 	    = ([prefs objectForKey:@"pfPulseSizeChoice"] ? [[prefs objectForKey:@"pfPulseSizeChoice"] intValue] : twPulseSizeChoice);
        twPulseSize 			= ([prefs objectForKey:@"pfPulseSize"] ? [[prefs objectForKey:@"pfPulseSize"] floatValue] : twPulseSize);

        twIsShakeEnabled		= ([prefs objectForKey:@"pfIsShakeEnabled"] ? [[prefs objectForKey:@"pfIsShakeEnabled"] boolValue] : twIsShakeEnabled);
        twShakeDurationChoice 	= ([prefs objectForKey:@"pfShakeDurationChoice"] ? [[prefs objectForKey:@"pfShakeDurationChoice"] intValue] : twShakeDurationChoice);
        twShakeDuration			= ([prefs objectForKey:@"pfShakeDuration"] ? [[prefs objectForKey:@"pfShakeDuration"] floatValue] : twShakeDuration);
        twShakeXAmount			= ([prefs objectForKey:@"pfShakeXAmount"] ? [[prefs objectForKey:@"pfShakeXAmount"] floatValue] : twShakeXAmount);
        twShakeYAmount 			= ([prefs objectForKey:@"pfShakeYAmount"] ? [[prefs objectForKey:@"pfShakeYAmount"] floatValue] : twShakeYAmount);
    }
	NSLog(@"AlwaysRemindMe LOG: prefs: %@", prefs);
    [prefs release];
}



static void performRotationAnimated(UILabel *twTextLabel, CGFloat speed, CGFloat delay) {

	[UIView animateWithDuration:(speed/2)
                          delay:delay
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
                                              performRotationAnimated(twTextLabel, twRotationSpeed, twRotationDelay);
                                          }];
                     }];

 }

static void performPulseAnimated(UIView *currentView, CGFloat size, CGFloat duration) {

    CABasicAnimation *pulseAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    pulseAnimation.duration = duration;
    pulseAnimation.toValue = [NSNumber numberWithFloat:size];
    pulseAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    pulseAnimation.autoreverses = YES;
    pulseAnimation.repeatCount = HUGE_VALF;
    [currentView.layer addAnimation:pulseAnimation forKey:nil];

}

static void performShakeAnimated(UIView *currentView, CGFloat duration, CGFloat xAmount, CGFloat yAmount) {

    CABasicAnimation *shakeAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
    shakeAnimation.duration = duration;

    shakeAnimation.fromValue = [NSValue valueWithCGPoint:CGPointMake([currentView center].x - xAmount, [currentView center].y - yAmount)];
    shakeAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake([currentView center].x + xAmount, [currentView center].y + yAmount)];

    shakeAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    shakeAnimation.autoreverses = YES;
    shakeAnimation.repeatCount = HUGE_VALF;
    [currentView.layer addAnimation:shakeAnimation forKey:@"position"];

}

static void performBlinkAnimated(UIView *currentView, CGFloat duration) {

    currentView.alpha = 1;
    [UIView animateWithDuration:duration delay:0.5 options:UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse animations:^{
        currentView.alpha = 0;
    } completion:nil];

}

static void performRainbowAnimated(UIView *currentView, CGFloat delay) {

    [UIView animateWithDuration:0.01 delay:0 options:UIViewAnimationOptionTransitionNone animations:^{
        currentView.backgroundColor = [UIColor colorWithHue:drand48() saturation:1.0 brightness:1.0 alpha:1.0];
    } completion:^(BOOL finished) {
        double delayInSeconds = delay;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            performRainbowAnimated(currentView, delay);
        });
    }];

}





static void drawAlwaysRemindMe(CGFloat screenHeight, CGFloat screenWidth, UIView *currentView) {

    UILabel *twTextLabel = [[UILabel alloc] init];
    twTextLabel.numberOfLines=0;
    if ([twTextLabelVar1 isEqualToString:@""]) {
        twTextLabel.text = twTextLabelVar;
    } else {
        twTextLabel.text = [NSString stringWithFormat:@"%@\r%@", twTextLabelVar,twTextLabelVar1];
    }
    [twTextLabel sizeToFit];

    if(twFontSize == -999) {
		[twTextLabel setFont:[UIFont fontWithName: twFontCustom size: twFontSizeCustom]];
	} else {
		[twTextLabel setFont:[UIFont fontWithName: twFontCustom size: twFontSize]];
	}

    
    CGSize textSize = [twTextLabel.text sizeWithAttributes:@{NSFontAttributeName:[twTextLabel font]}];
    CGFloat absolutCenter = (screenWidth/2) - (textSize.width/2);
    CGFloat varFrameX, varFrameY = 0;

	switch (twFramePosChoice) {
		case 1:
			varFrameX = absolutCenter;
			varFrameY = 20;
			break;
		case 2:
			varFrameX = absolutCenter;
			varFrameY = screenHeight-110;
			break;
        case 3:
			varFrameX = absolutCenter;
			varFrameY = screenHeight/2;
			break;
		case -999:
            if(twFrameX != twFrameX && twFrameY != twFrameY){
                varFrameX = absolutCenter;
                varFrameY = screenHeight/2;
                showAlertChangeInSettings(@"Your custom 'position' values are invalid!");
            } else if(twFrameX != twFrameX){
                varFrameX = absolutCenter;
                varFrameY = twFrameY;
                showAlertChangeInSettings(@"Your custom 'X position' value is invalid!");
            } else if(twFrameY != twFrameY){
                varFrameX = twFrameX;
                varFrameY = screenHeight/2;
                showAlertChangeInSettings(@"Your custom 'Y position' value is invalid!");
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
	

    twTextLabel.frame = CGRectMake(varFrameX, varFrameY, twTextLabel.intrinsicContentSize.width, twTextLabel.intrinsicContentSize.height);

    
    NSString *varFontColor = @"#000000";
    switch (twFontColorChoice) {
        case 1:
            varFontColor = @"#000000";
            break;
        case 2:
            varFontColor = @"#FFFFFF";
            break;
        case -999:
            if([twFontColorCustom isEqualToString:@""]){
                varFontColor = @"#000000";
                showAlertChangeInSettings(@"Your custom 'font color' value is invalid!");
            } else if([twFontColorCustom isEqualToString:@"#"]){
                varFontColor = @"#000000";
                showAlertChangeInSettings(@"Your custom font 'color value' is invalid!");
            } else {
                varFontColor = twFontColorCustom;
            }
            break;
        default:
            NSLog(@"AlwaysRemindMe ERROR: switch -> twFontColorChoice is default");
            varFontColor = @"#000000";
            break;
    }
    [twTextLabel setTextColor: [UIColor colorFromHex: varFontColor]];

    
	if(twIsBackgroundEnabled) {
        NSString *varBackgroundColor = @"#FFFFFF";
        switch (twBackgroundColorChoice) {
    		case 1:
                varBackgroundColor = @"#000000";
    			break;
    		case 2:
                varBackgroundColor = @"#FFFFFF";
    			break;
    		case -999:
                if([twBackgroundColorCustom isEqualToString:@""]){
                    varBackgroundColor = @"#FFFFFF";
                    showAlertChangeInSettings(@"Your custom 'background color' value is invalid!");
                } else if([twBackgroundColorCustom isEqualToString:@"#"]){
                    varBackgroundColor = @"#FFFFFF";
                    showAlertChangeInSettings(@"Your custom 'background color' value is invalid!");
                } else {
                    varBackgroundColor = twBackgroundColorCustom;
                }
    			break;
    		default:
    			NSLog(@"AlwaysRemindMe ERROR: switch -> twBackgroundColorChoice is default");
    			varBackgroundColor = @"#FFFFFF";
    			break;
    	}
        [twTextLabel setBackgroundColor: [UIColor colorFromHex: varBackgroundColor]];
	} else {
		[twTextLabel setBackgroundColor: [UIColor clearColor]];
    }

	[currentView addSubview:twTextLabel];

    
    CGFloat varRainbowDelay = 0;
    if(twIsRainbowEnabled) {
    	
        if(twRainbowDelay != twRainbowDelay){
            varRainbowDelay = 1;
            showAlertChangeInSettings(@"Your custom 'rainbow delay' value is invalid!");
        } else {
            varRainbowDelay = twRainbowDelay;
        }
        performRainbowAnimated(twTextLabel, varRainbowDelay);
    }

    
    CGFloat varRotationDelay, varRotationSpeed = 0;
    if(twIsRotationEnabled) {
        switch (twRotationSpeedChoice) {
    		case 1:
                varRotationSpeed = 2;
    			break;
    		case 2:
                varRotationSpeed = 0.5;
    			break;
            case 3:
                varRotationSpeed = 4;
    			break;
    		case -999:
                if(twRotationSpeed != twRotationSpeed){
                    varRotationSpeed = 2;
                    showAlertChangeInSettings(@"Your custom 'rotation speed' value is invalid!");
                } else {
                    varRotationSpeed = twRotationSpeed;
                }
    			break;
    		default:
    			NSLog(@"AlwaysRemindMe ERROR: switch -> twRotationSpeedChoice is default");
    			break;
    	}
    	
        if(twRotationDelay != twRotationDelay){
            varRotationDelay = 2;
            showAlertChangeInSettings(@"Your custom 'rotation delay' value is invalid!");
        } else {
            varRotationDelay = twRotationDelay;
        }
        performRotationAnimated(twTextLabel, varRotationSpeed, varRotationDelay);
    }

    CGFloat varPulseSize, varPulseSpeed = 0;
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
                if(twPulseSize != twPulseSize){
                    varPulseSize = 2;
                    showAlertChangeInSettings(@"Your custom 'pulse size' value is invalid!");
                } else {
                    varPulseSize = twPulseSize;
                }
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
                if(twPulseSpeed != twPulseSpeed){
                    varPulseSpeed = 1;
                    showAlertChangeInSettings(@"Your custom 'pulse speed' value is invalid!");
                } else {
                    varPulseSpeed = twPulseSpeed;
                }
    			break;
    		default:
    			NSLog(@"AlwaysRemindMe ERROR: switch -> twPulseSpeedChoice is default");
                varPulseSpeed = 1;
    			break;
    	}
    	
        performPulseAnimated(twTextLabel, varPulseSize, varPulseSpeed);
    }

    CGFloat varBlinkSpeed = 0.5;
    if(twIsBlinkEnabled) {
        switch (twBlinkSpeedChoice) {
    		case 1:
    			varBlinkSpeed = 0.5;
    			break;
    		case 2:
    			varBlinkSpeed = 0.25;
    			break;
            case 3:
    			varBlinkSpeed = 1;
    			break;
    		case -999:
                if(twBlinkSpeed != twBlinkSpeed){
                    varBlinkSpeed = 0.5;
                    showAlertChangeInSettings(@"Your custom 'blink speed' value is invalid!");
                } else {
                    varBlinkSpeed = twBlinkSpeed;
                }
    			break;
    		default:
    			NSLog(@"AlwaysRemindMe ERROR: switch -> twBlinkSpeedChoice is default");
                varBlinkSpeed = 0.5;
    			break;
    	}
    	
        performBlinkAnimated(twTextLabel, varBlinkSpeed);
    }

    CGFloat varShakeDuration = 1;
    CGFloat varShakeXAmount = 10;
    CGFloat varShakeYAmount = 0;
    if(twIsShakeEnabled) {
        switch (twShakeDurationChoice) {
    		case 1:
                varShakeDuration = 1;
    			break;
    		case 2:
                varShakeDuration = 4;
    			break;
            case 3:
                varShakeDuration = 0.5;
    			break;
    		case -999:
                if(twShakeDuration != twShakeDuration){
                    varShakeDuration = 1;
                    showAlertChangeInSettings(@"Your custom 'shake duration' value is invalid!");
                } else {
                    varShakeDuration = twShakeDuration;
                }
    			break;
    		default:
    			NSLog(@"AlwaysRemindMe ERROR: switch -> twShakeDurationChoice is default");
                twShakeXAmount = 10;
                twShakeYAmount = 0;
    			break;
    	}
    	
        if(twShakeXAmount != twShakeXAmount && twShakeYAmount != twShakeYAmount){
            varShakeXAmount = 10;
            varShakeYAmount = 0;
            showAlertChangeInSettings(@"Your custom 'shake position' value is invalid!");
        } else if(twShakeXAmount != twShakeXAmount){
            varShakeXAmount = 0;
            varShakeYAmount = twShakeYAmount;
            showAlertChangeInSettings(@"Your custom 'X shake' value is invalid!");
        } else if(twShakeYAmount != twShakeYAmount){
            varShakeXAmount = twShakeXAmount;
            varShakeYAmount = 0;
            showAlertChangeInSettings(@"Your custom 'Y shake' value is invalid!");
        } else {
            varShakeXAmount = twShakeXAmount;
            varShakeYAmount = twShakeYAmount;
        }
        performShakeAnimated(twTextLabel, varShakeDuration, varShakeXAmount, varShakeYAmount);
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
static void (*_logos_orig$_ungrouped$SBLockScreenViewControllerBase$viewDidLoad)(_LOGOS_SELF_TYPE_NORMAL SBLockScreenViewControllerBase* _LOGOS_SELF_CONST, SEL); static void _logos_method$_ungrouped$SBLockScreenViewControllerBase$viewDidLoad(_LOGOS_SELF_TYPE_NORMAL SBLockScreenViewControllerBase* _LOGOS_SELF_CONST, SEL); static void (*_logos_orig$_ungrouped$SBHomeScreenViewController$viewDidLoad)(_LOGOS_SELF_TYPE_NORMAL SBHomeScreenViewController* _LOGOS_SELF_CONST, SEL); static void _logos_method$_ungrouped$SBHomeScreenViewController$viewDidLoad(_LOGOS_SELF_TYPE_NORMAL SBHomeScreenViewController* _LOGOS_SELF_CONST, SEL); 

#line 657 "Tweak.xm"


	static void _logos_method$_ungrouped$SBLockScreenViewControllerBase$viewDidLoad(_LOGOS_SELF_TYPE_NORMAL SBLockScreenViewControllerBase* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd) {
        _logos_orig$_ungrouped$SBLockScreenViewControllerBase$viewDidLoad(self, _cmd);

        CGSize screenSize = [UIScreen mainScreen].bounds.size;
		CGFloat screenHeight = screenSize.height;
		CGFloat screenWidth = screenSize.width;
        UIView* selfView = self.view;

		if(twIsEnabled) {
			if ((twWhichScreenChoice == 0) || (twWhichScreenChoice == 2)) {
				drawAlwaysRemindMe(screenHeight, screenWidth, selfView);
                
			}
		}
        if(twShouldDelete){
            dealloc(selfView);
        }
	}






	static void _logos_method$_ungrouped$SBHomeScreenViewController$viewDidLoad(_LOGOS_SELF_TYPE_NORMAL SBHomeScreenViewController* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd) {
        _logos_orig$_ungrouped$SBHomeScreenViewController$viewDidLoad(self, _cmd);
        NSLog(@"AlwaysRemindMe DEBUG LOG: 1");

		CGSize screenSize = [UIScreen mainScreen].bounds.size;
		CGFloat screenHeight = screenSize.height;
		CGFloat screenWidth = screenSize.width;
        UIView* selfView = self.view;

		if(twIsEnabled) {
			if ((twWhichScreenChoice == 0) || (twWhichScreenChoice == 1)) {
				drawAlwaysRemindMe(screenHeight, screenWidth, selfView);
                
                
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

static __attribute__((constructor)) void _logosLocalCtor_b76e75d7(int __unused argc, char __unused **argv, char __unused **envp) {
	@autoreleasepool {
	    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, preferenceschanged, CFSTR("com.leroy.AlwaysRemindMePref/preferenceschanged"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
        loadPrefs();
	}
}
static __attribute__((constructor)) void _logosLocalInit() {
{Class _logos_class$_ungrouped$SBLockScreenViewControllerBase = objc_getClass("SBLockScreenViewControllerBase"); MSHookMessageEx(_logos_class$_ungrouped$SBLockScreenViewControllerBase, @selector(viewDidLoad), (IMP)&_logos_method$_ungrouped$SBLockScreenViewControllerBase$viewDidLoad, (IMP*)&_logos_orig$_ungrouped$SBLockScreenViewControllerBase$viewDidLoad);Class _logos_class$_ungrouped$SBHomeScreenViewController = objc_getClass("SBHomeScreenViewController"); MSHookMessageEx(_logos_class$_ungrouped$SBHomeScreenViewController, @selector(viewDidLoad), (IMP)&_logos_method$_ungrouped$SBHomeScreenViewController$viewDidLoad, (IMP*)&_logos_orig$_ungrouped$SBHomeScreenViewController$viewDidLoad);} }
#line 718 "Tweak.xm"

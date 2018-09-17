/*
TODO:
    - combine all switch() into one func
    - can copy pref panel text -> fix me
    - combine all show func in Root Controller into one func
    - share button iN corner top right or/and in info section -> sends link to add repo and show package -> current package
*/

/*
features:
    - multiable textViews: in settings.app specific subViewController based on rootViewController listView selected value
    - time based (example code as pic on phone) -> how long?(0.5h,1h,6h,custom)
*/

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
	    [scanner setScanLocation:0]; // bypass '#' character
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


#define PLIST_PATH @"/var/mobile/Library/Preferences/ch.leroyb.AlwaysRemindMePref.plist"

//define var and assign default values
static SBHomeScreenViewController *myself;


static bool twIsEnabled = NO;
//static bool twIsViewPresented = NO;
static int twWhichScreenChoice = 0;

static NSString *twTextLabelVar = @"";
static NSString *twTextLabelVar1 = @"";

// NSMutableArray *twTextLabelVar = [[NSMutableArray alloc] init];
// [twTextLabelVar addObject:@"Thank you for downloading :)"];

static bool twIsTimerEnabled = NO;
static NSString *twTime24 = @"12:00";
static NSString *twTimerCustom = @"12";
static int twTimerChoice = 1;
static PCSimpleTimer *activeTimer = nil;


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

void TimerExampleLoadTimer();

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
                                                    //
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
    NSLog(@"AlwaysRemindMe LOG: before prefs: %@", prefs);
    if(prefs){
		twIsEnabled				= ([prefs objectForKey:@"pfIsTweakEnabled"] ? [[prefs objectForKey:@"pfIsTweakEnabled"] boolValue] : twIsEnabled);
		twWhichScreenChoice 	= ([prefs objectForKey:@"pfWhichScreenChoice"] ? [[prefs objectForKey:@"pfWhichScreenChoice"] intValue] : twWhichScreenChoice);

        twIsTimerEnabled		= ([prefs objectForKey:@"pfIsTimerEnabled"] ? [[prefs objectForKey:@"pfIsTimerEnabled"] boolValue] : twIsTimerEnabled);
        twTime24        		= ([prefs objectForKey:@"pfTime24"] ? [[prefs objectForKey:@"pfTime24"] description] : twTime24);
        twTimerChoice           = ([prefs objectForKey:@"pfTimerChoice"] ? [[prefs objectForKey:@"pfTimerChoice"] intValue] : twTimerChoice);
        twTimerCustom        	= ([prefs objectForKey:@"pfTimerCustom"] ? [[prefs objectForKey:@"pfTimerCustom"] description] : twTimerCustom);

        // all of this is necessary because if the string gets to long it will crash the SpringBoard
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
	NSLog(@"AlwaysRemindMe LOG: after prefs: %@", prefs);
    [prefs release];
}

// ############################# ANIMATIONS ### START ####################################

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

}// Pulse func end

static void performShakeAnimated(UIView *currentView, CGFloat duration, CGFloat xAmount, CGFloat yAmount) {

    CABasicAnimation *shakeAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
    shakeAnimation.duration = duration;

    shakeAnimation.fromValue = [NSValue valueWithCGPoint:CGPointMake([currentView center].x - xAmount, [currentView center].y - yAmount)];
    shakeAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake([currentView center].x + xAmount, [currentView center].y + yAmount)];

    shakeAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    shakeAnimation.autoreverses = YES;
    shakeAnimation.repeatCount = HUGE_VALF;
    [currentView.layer addAnimation:shakeAnimation forKey:@"position"];

}// shake func end

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

}// shake rainbow end

// ############################# ANIMATIONS ### END ####################################

// ############################# DRAW LABEL ### START ####################################

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

    //gets text size
    CGSize textSize = [twTextLabel.text sizeWithAttributes:@{NSFontAttributeName:[twTextLabel font]}];
    CGFloat absolutCenter = (screenWidth/2) - (textSize.width/2);
    CGFloat varFrameX, varFrameY = 0;

	switch (twFramePosChoice) {
		case 1://below StatusBar
			varFrameX = absolutCenter;
			varFrameY = 20;
			break;
		case 2://above dock
			varFrameX = absolutCenter;
			varFrameY = screenHeight-110;
			break;
        case 3://center
			varFrameX = absolutCenter;
			varFrameY = screenHeight/2;
			break;
		case -999:// custom
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
	//switch position end

    twTextLabel.frame = CGRectMake(varFrameX, varFrameY, twTextLabel.intrinsicContentSize.width, twTextLabel.intrinsicContentSize.height);

    //fontColor
    NSString *varFontColor = @"#000000";
    switch (twFontColorChoice) {
        case 1://black
            varFontColor = @"#000000";
            break;
        case 2://white
            varFontColor = @"#FFFFFF";
            break;
        case -999:// custom
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

    //backgroundColor
	if(twIsBackgroundEnabled) {
        NSString *varBackgroundColor = @"#FFFFFF";
        switch (twBackgroundColorChoice) {
    		case 1://black
                varBackgroundColor = @"#000000";
    			break;
    		case 2://white
                varBackgroundColor = @"#FFFFFF";
    			break;
    		case -999:// custom
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

    //rainbow
    CGFloat varRainbowDelay = 0;
    if(twIsRainbowEnabled) {
    	//switch twRainbowDurationChoice end
        if(twRainbowDelay != twRainbowDelay){
            varRainbowDelay = 1;
            showAlertChangeInSettings(@"Your custom 'rainbow delay' value is invalid!");
        } else {
            varRainbowDelay = twRainbowDelay;
        }
        performRainbowAnimated(twTextLabel, varRainbowDelay);
    }

    //rotation
    CGFloat varRotationDelay, varRotationSpeed = 0;
    if(twIsRotationEnabled) {
        switch (twRotationSpeedChoice) {
    		case 1://default
                varRotationSpeed = 2;
    			break;
    		case 2://slow
                varRotationSpeed = 0.5;
    			break;
            case 3://fast
                varRotationSpeed = 4;
    			break;
    		case -999:// custom
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
    	//switch twPulseSpeed end
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
    		case 1://default
    			varPulseSize = 2;
    			break;
    		case 2://half
    			varPulseSize = 1;
    			break;
            case 3://half
    			varPulseSize = 4;
    			break;
    		case -999:// custom
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
    	//switch twPulseSize end
        switch (twPulseSpeedChoice) {
    		case 1://default
    			varPulseSpeed = 1;
    			break;
    		case 2:// fast
    			varPulseSpeed = 0.5;
    			break;
            case 3:// slow
    			varPulseSpeed = 2;
    			break;
    		case -999:// custom
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
    	//switch twPulseSpeed end
        performPulseAnimated(twTextLabel, varPulseSize, varPulseSpeed);
    }

    CGFloat varBlinkSpeed = 0.5;
    if(twIsBlinkEnabled) {
        switch (twBlinkSpeedChoice) {
    		case 1://default
    			varBlinkSpeed = 0.5;
    			break;
    		case 2://half
    			varBlinkSpeed = 0.25;
    			break;
            case 3://half
    			varBlinkSpeed = 1;
    			break;
    		case -999:// custom
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
    	//switch twBlinkSpeedChoice end
        performBlinkAnimated(twTextLabel, varBlinkSpeed);
    }

    CGFloat varShakeDuration = 1;
    CGFloat varShakeXAmount = 10;
    CGFloat varShakeYAmount = 0;
    if(twIsShakeEnabled) {
        switch (twShakeDurationChoice) {
    		case 1://default
                varShakeDuration = 1;
    			break;
    		case 2://slow
                varShakeDuration = 4;
    			break;
            case 3://fast
                varShakeDuration = 0.5;
    			break;
    		case -999:// custom
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
    	//switch twShakeDurationChoice end
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

}// draw func end

// ############################# DRAW LABEL ### END ####################################

%hook SpringBoard
-(void)applicationDidFinishLaunching:(id)application
{
	%orig;

	NSLog(@"[TimerExample] SpringBoard applicationDidFinishLaunching");
	TimerExampleLoadTimer();
}
%end

%hook SBClockDataProvider

%new
- (void)TimerExampleFired
{
	NSLog(@"[TimerExample] TimerExampleFired");
}
%end //hook SBClockDataProvider


//setting text on LS
%hook SBLockScreenViewControllerBase

	-(void)viewDidLoad {
        %orig;

        CGSize screenSize = [UIScreen mainScreen].bounds.size;
		CGFloat screenHeight = screenSize.height;
		CGFloat screenWidth = screenSize.width;
        UIView* selfView = self.view;

		if(twIsEnabled) {
			if ((twWhichScreenChoice == 0) || (twWhichScreenChoice == 2)) {
				drawAlwaysRemindMe(screenHeight, screenWidth, selfView);
                //twIsViewPresented = YES;
			}
		}
        if(twShouldDelete){
            dealloc(selfView);
        }
	}

%end

//setting text on SB
%hook SBHomeScreenViewController

	-(void)viewDidLoad {
        %orig;
        NSLog(@"AlwaysRemindMe DEBUG LOG: 1");

		CGSize screenSize = [UIScreen mainScreen].bounds.size;
		CGFloat screenHeight = screenSize.height;
		CGFloat screenWidth = screenSize.width;
        UIView* selfView = self.view;

		if(twIsEnabled) {
			if ((twWhichScreenChoice == 0) || (twWhichScreenChoice == 1)) {
				drawAlwaysRemindMe(screenHeight, screenWidth, selfView);
                //drawAlwaysRemindMe(screenHeight/2, screenWidth/2, selfView);
                //twIsViewPresented = YES;
			}
		}
        if(twShouldDelete){
            dealloc(selfView);
        }
	}

%end

void TimerExampleLoadTimer() {
	NSDictionary *userInfoDictionary = nil;

	userInfoDictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:PLIST_PATH];

	if (!userInfoDictionary) {
		return;
	}
	NSDate *fireDate = [userInfoDictionary objectForKey:@"pfTime24"];

	if (!fireDate || [[NSDate date] compare:fireDate] == NSOrderedDescending) {
		NSLog(@"AlwaysRemindMe LOG: TimerExampleLoadTimer - invalid or in the past");
		return;
	}

	NSMutableDictionary *data = [[NSMutableDictionary alloc] init];

	activeTimer = [[%c(PCSimpleTimer) alloc] initWithFireDate:fireDate serviceIdentifier:@"ch.leroyb.AlwaysRemindMePref" target:[%c(SBClockDataProvider) self] selector:@selector(TimerExampleFired) userInfo:data];

	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
	[formatter setTimeZone:[NSTimeZone defaultTimeZone]];
	NSLog(@"AlwaysRemindMe LOG: Added Timer %@", [formatter stringFromDate:fireDate]);

}

static void TimerExampleNotified(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {

	NSLog(@"AlwaysRemindMe LOG: received CFNotificationCenterPostNotification");

	// kill old timer
	if (activeTimer) {
		[activeTimer invalidate];
		activeTimer = nil;
	}

	TimerExampleLoadTimer();
}

static void preferencesChanged(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    loadPrefs();
	NSLog(@"AlwaysRemindMe LOG: 'loadPrefs' called in 'preferencesChanged'");
}

%ctor {
	@autoreleasepool {
		loadPrefs();
		// listen for changes to settings
		CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
			NULL,
			(CFNotificationCallback)preferencesChanged,
			CFSTR("ch.leroyb.AlwaysRemindMePref.preferencesChanged"),
			NULL,
			CFNotificationSuspensionBehaviorDeliverImmediately
		);
        // listen for changes to timer
        CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
			NULL,
			(CFNotificationCallback)TimerExampleNotified,
			CFSTR("ch.leroyb.AlwaysRemindMePref.timerChanged"),
			NULL,
			CFNotificationSuspensionBehaviorDeliverImmediately
		);
	}
}

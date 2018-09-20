/*
TODO:
    - combine all switch() into one func
    - can copy pref panel text -> fix me
    - combine all show func in Root Controller into one func
    - default text and background color are both black
    - switch 2 background colors custom speed
*/

/*
features:
    - touch on label [open action sheet(show all and share sheet), open pref panel, select time to be reminded at]
    - multiable textViews: in settings.app specific subViewController based on rootViewController listView selected value
    - time based (example code as pic on phone) -> how long?(0.5h,1h,6h,custom)
*/

// Defining all needed interfaces
@interface SpringBoard
@end

@interface SBLockScreenViewControllerBase : UIViewController
-(void)showCustomHasIssueAlert;
@end

@interface SBHomeScreenViewController : UIViewController
@end

@interface UIColor(Hexadecimal)

+ (UIColor *)colorFromHex:(NSString *)hexString;

@end

@implementation UIColor(Hexadecimal)

+ (UIColor *)colorFromHex:(NSString *)hexString{
    unsigned rgbValue = 0;
    if ([hexString hasPrefix:@"#"]){
		hexString = [hexString substringFromIndex:1];
	}
    if (hexString){
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


//define var and assign default or nil values

#define PLIST_PATH @"/var/mobile/Library/Preferences/ch.leroyb.AlwaysRemindMePref.plist"

static bool twIsEnabled = NO;
//static bool twIsViewPresented = NO;
static NSNumber *twWhichScreenChoice = @0;
static NSString *twTextLabelVar, *twTextLabelVar1 = @"";

static bool twIsTimerEnabled = NO;
static NSString *twTime24 = @"12:00";
static NSString *twTimerCustom = @"12";
static NSNumber *twTimerChoice = @1;
static PCSimpleTimer *activeTimer = nil;

static NSNumber *twFramePosChoice = @1;
static NSNumber *twFrameX, *twFrameY, *twFrameW, *twFrameH = nil;

static bool twIsBackgroundEnabled = YES;
static NSNumber *twFontSize, *twFontSizeCustom = @14;
static NSString *twFontCustom = @"Trebuchet MS";

static NSNumber *twFontColorChoice = @1;
static NSString *twFontColorCustom = @"#000000";
static NSNumber *twBackgroundColorChoice = @1;
static NSString *twBackgroundColorCustom = @"#ffffff";

static bool twIsRainbowEnabled = NO;
static NSNumber *twRainbowDelay = nil;

static bool twIsRotationEnabled = NO;
static NSNumber *twRotationSpeedChoice = @1;
static NSNumber *twRotationSpeed, *twRotationDelay = nil;

static bool twIsBlinkEnabled = NO;
static NSNumber *twBlinkSpeedChoice = @1;
static NSNumber *twBlinkSpeed = nil;

static bool twIsShakeEnabled = NO;
static NSNumber *twShakeDurationChoice = @1;
static NSNumber *twShakeDuration, *twShakeXAmount, *twShakeYAmount = nil;

static bool twIsPulseEnabled = NO;
static NSNumber *twPulseSpeedChoice = @1;
static NSNumber *twPulseSizeChoice, *twPulseSpeed, *twPulseSize = nil;

static bool twShouldDelete = NO;
static bool customHasIssue = NO;
static NSString *customHasIssueText = @"";
static bool isAlertShowing = NO;

void TimerExampleLoadTimer();

// function for loading values from the tweak's plist
static void loadPrefs(){
    // storing in a key and value fashon for easy access
	NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:PLIST_PATH];
    if(prefs){
		twIsEnabled				= ([prefs objectForKey:@"pfIsTweakEnabled"] ? [[prefs objectForKey:@"pfIsTweakEnabled"] boolValue] : twIsEnabled);
		twWhichScreenChoice 	= ([prefs objectForKey:@"pfWhichScreenChoice"] ? [prefs objectForKey:@"pfWhichScreenChoice"] : twWhichScreenChoice);

        twIsTimerEnabled		= ([prefs objectForKey:@"pfIsTimerEnabled"] ? [[prefs objectForKey:@"pfIsTimerEnabled"] boolValue] : twIsTimerEnabled);
        twTime24        		= ([prefs objectForKey:@"pfTime24"] ? [[prefs objectForKey:@"pfTime24"] description] : twTime24);
        twTimerChoice           = ([prefs objectForKey:@"pfTimerChoice"] ? [prefs objectForKey:@"pfTimerChoice"] : twTimerChoice);
        twTimerCustom        	= ([prefs objectForKey:@"pfTimerCustom"] ? [[prefs objectForKey:@"pfTimerCustom"] description] : twTimerCustom);

        // all of this is necessary because if the string gets to long it will crash the SpringBoard
        NSMutableArray *array = [NSMutableArray array];
        NSMutableString *result = [[NSMutableString alloc] init];
        // for the length of the 'pfTextLabel' string, save char at loop position to array
        for (int i = 0; i < [[[prefs objectForKey:@"pfTextLabel"] description] length]; i++){
            [array addObject:[NSString stringWithFormat:@"%C", [[[prefs objectForKey:@"pfTextLabel"] description] characterAtIndex:i]]];
        }
        for (NSObject *obj in array){
            [result appendString:[obj description]];
        }
        twTextLabelVar = result;
        [array removeAllObjects];
        result = nil;

        // same for the second string
        for (int i = 0; i < [[[prefs objectForKey:@"pfTextLabel1"] description] length]; i++){
            [array addObject:[NSString stringWithFormat:@"%C", [[[prefs objectForKey:@"pfTextLabel1"] description] characterAtIndex:i]]];
        }
        for (NSObject *obj1 in array){
            [result appendString:[obj1 description]];
        }
        twTextLabelVar1 = result;

		twFramePosChoice		= ([prefs objectForKey:@"pfFramePosChoice"] ? [prefs objectForKey:@"pfFramePosChoice"] : twFramePosChoice);
		twFrameX				= ([prefs objectForKey:@"pfFrameX"] ? [prefs objectForKey:@"pfFrameX"] : twFrameX);
		twFrameY				= ([prefs objectForKey:@"pfFrameY"] ? [prefs objectForKey:@"pfFrameY"] : twFrameY);
		twFrameH				= ([prefs objectForKey:@"pfFrameH"] ? [prefs objectForKey:@"pfFrameH"] : twFrameH);
		twFrameW				= ([prefs objectForKey:@"pfFrameW"] ? [prefs objectForKey:@"pfFrameW"] : twFrameW);

		twIsBackgroundEnabled	= ([prefs objectForKey:@"pfIsBackgroundEnabled"] ? [[prefs objectForKey:@"pfIsBackgroundEnabled"] boolValue] : twIsBackgroundEnabled);
		twBackgroundColorChoice	= ([prefs objectForKey:@"pfBackgroundColorChoice"] ? [prefs objectForKey:@"pfBackgroundColorChoice"] : twBackgroundColorChoice);
        twBackgroundColorCustom	= ([prefs objectForKey:@"pfBackgroundColorCustom"] ? [[prefs objectForKey:@"pfBackgroundColorCustom"] description] : twBackgroundColorCustom);

        twIsRainbowEnabled		= ([prefs objectForKey:@"pfIsRainbowEnabled"] ? [[prefs objectForKey:@"pfIsRainbowEnabled"] boolValue] : twIsRainbowEnabled);
        twRainbowDelay			= ([prefs objectForKey:@"pfRainbowDelay"] ? [prefs objectForKey:@"pfRainbowDelay"] : twRainbowDelay);

        twFontColorChoice		= ([prefs objectForKey:@"pfFontColorChoice"] ? [prefs objectForKey:@"pfFontColorChoice"] : twFontColorChoice);
        twFontColorCustom		= ([prefs objectForKey:@"pfFontColorCustom"] ? [[prefs objectForKey:@"pfFontColorCustom"] description] : twFontColorCustom);
		twFontSize				= ([prefs objectForKey:@"pfFontSize"] ? [prefs objectForKey:@"pfFontSize"] : twFontSize);
		twFontSizeCustom		= ([prefs objectForKey:@"pfFontSizeCustom"] ? [prefs objectForKey:@"pfFontSizeCustom"] : twFontSizeCustom);
        twFontCustom    		= ([prefs objectForKey:@"pfFontCustom"] ? [[prefs objectForKey:@"pfFontCustom"] description] : twFontCustom);

        twIsRotationEnabled		= ([prefs objectForKey:@"pfIsRotationEnabled"] ? [[prefs objectForKey:@"pfIsRotationEnabled"] boolValue] : twIsRotationEnabled);
        twRotationSpeedChoice 	= ([prefs objectForKey:@"pfRotationSpeedChoice"] ? [prefs objectForKey:@"pfRotationSpeedChoice"] : twRotationSpeedChoice);
        twRotationSpeed			= ([prefs objectForKey:@"pfRotationSpeed"] ? [prefs objectForKey:@"pfRotationSpeed"] : twRotationSpeed);
        twRotationDelay			= ([prefs objectForKey:@"pfRotationDelay"] ? [prefs objectForKey:@"pfRotationDelay"] : twRotationDelay);

        twIsBlinkEnabled		= ([prefs objectForKey:@"pfIsBlinkEnabled"] ? [[prefs objectForKey:@"pfIsBlinkEnabled"] boolValue] : twIsBlinkEnabled);
        twBlinkSpeedChoice      = ([prefs objectForKey:@"pfBlinkSpeedChoice"] ? [prefs objectForKey:@"pfBlinkSpeedChoice"] : twBlinkSpeedChoice);
        twBlinkSpeed			= ([prefs objectForKey:@"pfBlinkSpeed"] ? [prefs objectForKey:@"pfBlinkSpeed"] : twBlinkSpeed);

        twIsPulseEnabled		= ([prefs objectForKey:@"pfIsPulseEnabled"] ? [[prefs objectForKey:@"pfIsPulseEnabled"] boolValue] : twIsPulseEnabled);
        twPulseSpeedChoice 	    = ([prefs objectForKey:@"pfPulseSpeedChoice"] ? [prefs objectForKey:@"pfPulseSpeedChoice"] : twPulseSpeedChoice);
        twPulseSpeed			= ([prefs objectForKey:@"pfPulseSpeed"] ? [prefs objectForKey:@"pfPulseSpeed"] : twPulseSpeed);
        twPulseSizeChoice 	    = ([prefs objectForKey:@"pfPulseSizeChoice"] ? [prefs objectForKey:@"pfPulseSizeChoice"] : twPulseSizeChoice);
        twPulseSize 			= ([prefs objectForKey:@"pfPulseSize"] ? [prefs objectForKey:@"pfPulseSize"] : twPulseSize);

        twIsShakeEnabled		= ([prefs objectForKey:@"pfIsShakeEnabled"] ? [[prefs objectForKey:@"pfIsShakeEnabled"] boolValue] : twIsShakeEnabled);
        twShakeDurationChoice 	= ([prefs objectForKey:@"pfShakeDurationChoice"] ? [prefs objectForKey:@"pfShakeDurationChoice"] : twShakeDurationChoice);
        twShakeDuration			= ([prefs objectForKey:@"pfShakeDuration"] ? [prefs objectForKey:@"pfShakeDuration"] : twShakeDuration);
        twShakeXAmount			= ([prefs objectForKey:@"pfShakeXAmount"] ? [prefs objectForKey:@"pfShakeXAmount"] : twShakeXAmount);
        twShakeYAmount 			= ([prefs objectForKey:@"pfShakeYAmount"] ? [prefs objectForKey:@"pfShakeYAmount"] : twShakeYAmount);
    }
	NSLog(@"AlwaysRemindMe LOG: after prefs: %@", prefs);
    [prefs release];
}

// ############################# GENERAL FUNC ### START ####################################

static void dealloc(UIView *currentView){
    [currentView release], currentView = nil;
}

// ############################# GENERAL FUNC ### END ####################################

// ############################# ANIMATIONS ### START ####################################

static void performRotationAnimated(UILabel *twTextLabel, NSNumber *speed, NSNumber *delay){

	[UIView animateWithDuration:([speed intValue]/2)
                          delay:[delay floatValue]
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         twTextLabel.transform = CGAffineTransformMakeRotation(M_PI);
                     }
                     completion:^(BOOL finished){
                         [UIView animateWithDuration:([speed intValue]/2)
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

static void performPulseAnimated(UIView *currentView, NSNumber *size, NSNumber *duration){

    CABasicAnimation *pulseAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    pulseAnimation.duration = [duration floatValue];
    pulseAnimation.toValue = size;
    pulseAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    pulseAnimation.autoreverses = YES;
    pulseAnimation.repeatCount = HUGE_VALF;
    [currentView.layer addAnimation:pulseAnimation forKey:nil];

}// Pulse func end

static void performShakeAnimated(UIView *currentView, NSNumber *duration, NSNumber *xAmount, NSNumber *yAmount){

    CABasicAnimation *shakeAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
    shakeAnimation.duration = [duration floatValue];

    shakeAnimation.fromValue = [NSValue valueWithCGPoint:CGPointMake([currentView center].x - [xAmount floatValue], [currentView center].y - [yAmount floatValue])];
    shakeAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake([currentView center].x + [xAmount floatValue], [currentView center].y + [yAmount floatValue])];

    shakeAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    shakeAnimation.autoreverses = YES;
    shakeAnimation.repeatCount = HUGE_VALF;
    [currentView.layer addAnimation:shakeAnimation forKey:@"position"];

}// shake func end

static void performBlinkAnimated(UIView *currentView, NSNumber *duration){

    currentView.alpha = 1;
    [UIView animateWithDuration:[duration floatValue] delay:0.5 options:UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse animations:^{
        currentView.alpha = 0;
    } completion:nil];

}

static void performRainbowAnimated(UIView *currentView, NSNumber *delay){

    [UIView animateWithDuration:0.01 delay:0 options:UIViewAnimationOptionTransitionNone animations:^{
        currentView.backgroundColor = [UIColor colorWithHue:drand48() saturation:1.0 brightness:1.0 alpha:1.0];
    } completion:^(BOOL finished){
        double delayInSeconds = [delay floatValue];
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            performRainbowAnimated(currentView, delay);
        });
    }];

}// shake rainbow end

// ############################# ANIMATIONS ### END ####################################

// ############################# DRAW LABEL ### START ####################################

static void drawAlwaysRemindMe(CGFloat screenHeight, CGFloat screenWidth, UIView *currentView){

    UILabel *twTextLabel = [[UILabel alloc] init];
    twTextLabel.numberOfLines=0;
    if ([twTextLabelVar1 isEqualToString:@""]){
        twTextLabel.text = twTextLabelVar;
    } else {
        twTextLabel.text = [NSString stringWithFormat:@"%@\r%@", twTextLabelVar,twTextLabelVar1];
    }
    [twTextLabel sizeToFit];

    if([twFontSize intValue] == -999){
		[twTextLabel setFont:[UIFont fontWithName: twFontCustom size: [twFontSizeCustom floatValue]]];
	} else {
		[twTextLabel setFont:[UIFont fontWithName: twFontCustom size: [twFontSize floatValue]]];
	}

    //gets text size
    CGSize textSize = [twTextLabel.text sizeWithAttributes:@{NSFontAttributeName:[twTextLabel font]}];
    CGFloat absolutCenter = (screenWidth/2) - (textSize.width/2);
    CGFloat varFrameX, varFrameY = 0;

	switch ([twFramePosChoice intValue]){
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
            if(!twFrameX && !twFrameY){
                varFrameX = absolutCenter;
                varFrameY = screenHeight/2;
                customHasIssue = YES;
                customHasIssueText = @"Your custom 'position' values are invalid!";
            } else if(!twFrameX){
                varFrameX = absolutCenter;
                varFrameY = [twFrameY floatValue];
                customHasIssue = YES;
                customHasIssueText = @"Your custom 'X position' value is invalid!";
            } else if(!twFrameY){
                varFrameX = [twFrameX floatValue];;
                varFrameY = screenHeight/2;
                customHasIssue = YES;
                customHasIssueText = @"Your custom 'Y position' value is invalid!";
            } else {
                varFrameX = [twFrameX floatValue];;
    			varFrameY = [twFrameY floatValue];;
            }
			break;
		default:
			NSLog(@"AlwaysRemindMe ERROR: switch -> twFramePosChoice is default");
			varFrameX = (screenWidth/2) - ([twFrameW intValue]/2);
			varFrameY = 20;
			break;
	}
	//switch position end

    twTextLabel.frame = CGRectMake(varFrameX, varFrameY, twTextLabel.intrinsicContentSize.width, twTextLabel.intrinsicContentSize.height);

    //fontColor
    NSString *varFontColor = @"#000000";
    switch ([twFontColorChoice intValue]){
        case 1://black
            varFontColor = @"#000000";
            break;
        case 2://white
            varFontColor = @"#FFFFFF";
            break;
        case -999:// custom
            if([twFontColorCustom isEqualToString:@""]){
                varFontColor = @"#000000";
                customHasIssue = YES;
                customHasIssueText = @"Your custom 'font color' value is invalid!";
            } else if([twFontColorCustom isEqualToString:@"#"]){
                varFontColor = @"#000000";
                customHasIssue = YES;
                customHasIssueText = @"Your custom font 'color value' is invalid!";
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
	if(twIsBackgroundEnabled){
        NSString *varBackgroundColor = @"#FFFFFF";
        switch ([twBackgroundColorChoice intValue]){
    		case 1://white
                varBackgroundColor = @"#FFFFFF";
    			break;
    		case 2://black
                varBackgroundColor = @"#000000";
    			break;
    		case -999:// custom
                if([twBackgroundColorCustom isEqualToString:@""]){
                    varBackgroundColor = @"#FFFFFF";
                    customHasIssue = YES;
                    customHasIssueText = @"Your custom 'background color' value is invalid!";
                } else if([twBackgroundColorCustom isEqualToString:@"#"]){
                    varBackgroundColor = @"#FFFFFF";
                    customHasIssue = YES;
                    customHasIssueText = @"Your custom 'background color' value is invalid!";
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
    NSNumber *varRainbowDelay = nil;
    if(twIsRainbowEnabled){
    	//switch twRainbowDurationChoice end
        if(!twRainbowDelay){
            varRainbowDelay = @1;
            customHasIssue = YES;
            customHasIssueText = @"Your custom 'rainbow delay' value is invalid!";
        } else {
            varRainbowDelay = twRainbowDelay;
        }
        performRainbowAnimated(twTextLabel, varRainbowDelay);
    }

    //rotation
    NSNumber *varRotationDelay, *varRotationSpeed = 0;
    if(twIsRotationEnabled){
        switch ([twRotationSpeedChoice intValue]){
    		case 1://default
                varRotationSpeed = @2;
    			break;
    		case 2://slow
                varRotationSpeed = @0.5;
    			break;
            case 3://fast
                varRotationSpeed = @4;
    			break;
    		case -999:// custom
                if(!twRotationSpeed){
                    varRotationSpeed = @2;
                    customHasIssue = YES;
                    customHasIssueText = @"Your custom 'rotation speed' value is invalid!";
                } else {
                    varRotationSpeed = twRotationSpeed;
                }
    			break;
    		default:
                varRotationSpeed = @2;
    			NSLog(@"AlwaysRemindMe ERROR: switch -> twRotationSpeedChoice is default");
    			break;
    	}
    	//switch twPulseSpeed end
        if(!twRotationDelay){
            varRotationDelay = @2;
            customHasIssue = YES;
            customHasIssueText = @"Your custom 'rotation delay' value is invalid!";
        } else {
            varRotationDelay = twRotationDelay;
        }
        performRotationAnimated(twTextLabel, varRotationSpeed, varRotationDelay);
    }

    NSNumber *varPulseSize, *varPulseSpeed = nil;
    if(twIsPulseEnabled){
        switch ([twPulseSizeChoice intValue]){
    		case 1://default
    			varPulseSize = @2;
    			break;
    		case 2://half
    			varPulseSize = @1;
    			break;
            case 3://half
    			varPulseSize = @4;
    			break;
    		case -999:// custom
                if(!twPulseSize){
                    varPulseSize = @2;
                    customHasIssue = YES;
                    customHasIssueText = @"Your custom 'pulse size' value is invalid!";
                } else {
                    varPulseSize = twPulseSize;
                }
    			break;
    		default:
    			NSLog(@"AlwaysRemindMe ERROR: switch -> twPulseSizeChoice is default");
                varPulseSize = @2;
    			break;
    	}
    	//switch twPulseSize end
        switch ([twPulseSpeedChoice intValue]){
    		case 1://default
    			varPulseSpeed = @1;
    			break;
    		case 2:// fast
    			varPulseSpeed = @0.5;
    			break;
            case 3:// slow
    			varPulseSpeed = @2;
    			break;
    		case -999:// custom
                if(!twPulseSpeed){
                    varPulseSpeed = @1;
                    customHasIssue = YES;
                    customHasIssueText = @"Your custom 'pulse speed' value is invalid!";
                } else {
                    varPulseSpeed = twPulseSpeed;
                }
    			break;
    		default:
    			NSLog(@"AlwaysRemindMe ERROR: switch -> twPulseSpeedChoice is default");
                varPulseSpeed = @1;
    			break;
    	}
    	//switch twPulseSpeed end
        performPulseAnimated(twTextLabel, varPulseSize, varPulseSpeed);
    }

    NSNumber *varBlinkSpeed = nil;
    if(twIsBlinkEnabled){
        switch ([twBlinkSpeedChoice intValue]){
    		case 1://default
    			varBlinkSpeed = @0.5;
    			break;
    		case 2://half
    			varBlinkSpeed = @0.25;
    			break;
            case 3://half
    			varBlinkSpeed = @1;
    			break;
    		case -999:// custom
                if(!twBlinkSpeed){
                    varBlinkSpeed = @0.5;
                    customHasIssue = YES;
                    customHasIssueText = @"Your custom 'blink speed' value is invalid!";
                } else {
                    varBlinkSpeed = twBlinkSpeed;
                }
    			break;
    		default:
    			NSLog(@"AlwaysRemindMe ERROR: switch -> twBlinkSpeedChoice is default");
                varBlinkSpeed = @0.5;
    			break;
    	}//switch twBlinkSpeedChoice end
        performBlinkAnimated(twTextLabel, varBlinkSpeed);
    }

    NSNumber *varShakeDuration = nil, *varShakeXAmount = nil, *varShakeYAmount = nil;
    if(twIsShakeEnabled){
        switch ([twShakeDurationChoice intValue]){
    		case 1://default
                varShakeDuration = @1;
    			break;
    		case 2://slow
                varShakeDuration = @4;
    			break;
            case 3://fast
                varShakeDuration = @0.5;
    			break;
    		case -999:// custom
                if(!twShakeDuration && twShakeDuration == nil){
                    NSLog(@"AlwaysRemindMe LOG: twShakeDuration if");
                    varShakeDuration = @1;
                    customHasIssue = YES;
                    customHasIssueText = @"Your custom 'shake duration' value is invalid!";
                } else {
                    NSLog(@"AlwaysRemindMe LOG: twShakeDuration else");
                    varShakeDuration = twShakeDuration;
                }
    			break;
    		default:
    			NSLog(@"AlwaysRemindMe ERROR: switch -> twShakeDurationChoice is default");
                twShakeXAmount = @10;
                twShakeYAmount = @0;
    			break;
    	}
    	//switch twShakeDurationChoice end
        if(!twShakeXAmount && !twShakeYAmount){
            varShakeXAmount = @10;
            varShakeYAmount = @0;
            customHasIssue = YES;
            customHasIssueText = @"Your custom 'shake position' values is invalid!";
            NSLog(@"AlwaysRemindMe LOG: twShakeXAmount if");
        } else if(!twShakeXAmount && twShakeXAmount != 0){
            varShakeXAmount = @0;
            varShakeYAmount = twShakeYAmount;
            customHasIssue = YES;
            customHasIssueText = @"Your custom 'X shake' value is invalid!";
            NSLog(@"AlwaysRemindMe LOG: twShakeXAmount else if 1");
        } else if(!twShakeYAmount && twShakeYAmount != 0){
            varShakeXAmount = twShakeXAmount;
            varShakeYAmount = @0;
            customHasIssue = YES;
            customHasIssueText = @"Your custom 'Y shake' value is invalid!";
            NSLog(@"AlwaysRemindMe LOG: twShakeXAmount else if 2");
        } else {
            varShakeXAmount = twShakeXAmount;
            varShakeYAmount = twShakeYAmount;
            NSLog(@"AlwaysRemindMe LOG: twShakeXAmount else");
        }
        performShakeAnimated(twTextLabel, varShakeDuration, varShakeXAmount, varShakeYAmount);
    }

}// draw func end

// ############################# DRAW LABEL ### END ####################################

%hook SpringBoard
-(void) applicationDidFinishLaunching:(id)application{
	%orig(application);

	NSLog(@"AlwaysRemindMe DEBUG LOG: SpringBoard applicationDidFinishLaunching / calling TimerExampleLoadTimer");
	TimerExampleLoadTimer();
}
%end

%hook SBClockDataProvider

%new
- (void)TimerExampleFired{
	NSLog(@"AlwaysRemindMe DEBUG LOG: TimerExampleFired");
}
%end //hook SBClockDataProvider

//setting text on SB
%hook SBHomeScreenViewController

	-(void)viewDidLoad{
        %orig;
        //NSLog(@"AlwaysRemindMe DEBUG LOG: 1");

		CGSize screenSize = [UIScreen mainScreen].bounds.size;
		CGFloat screenHeight = screenSize.height;
		CGFloat screenWidth = screenSize.width;
        UIView* selfView = self.view;

		if(twIsEnabled){
			if (([twWhichScreenChoice intValue] == 0) || ([twWhichScreenChoice intValue] == 1)){
				drawAlwaysRemindMe(screenHeight, screenWidth, selfView);
                //drawAlwaysRemindMe(screenHeight/2, screenWidth/2, selfView);
                //twIsViewPresented = YES;
			}
		}
        if(twShouldDelete){
            dealloc(selfView);
        }
	}

    %new
    -(void)showCustomHasIssueAlert{

        UIAlertController * alert = [UIAlertController
                    alertControllerWithTitle:@"AlwaysRemindMe: ISSUE"
                                     message:customHasIssueText
                              preferredStyle:UIAlertControllerStyleActionSheet];//UIAlertControllerStyleAlert];
        UIAlertAction* okButton = [UIAlertAction
                             actionWithTitle:@"Ignore"
                                       style:UIAlertActionStyleDefault
                                     handler:^(UIAlertAction * _Nonnull action){
                                         isAlertShowing = NO;
                                     }];
        UIAlertAction* changeButton = [UIAlertAction
                             actionWithTitle:@"Change in settings"
                                       style:UIAlertActionStyleDefault
                                     handler:^(UIAlertAction * _Nonnull action){
                                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"Prefs:root=AlwaysRemindMe"]];
                                        //[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"Prefs:root=AlwaysRemindMe"] options:@{} completionHandler:nil];
                                     }];
        if(!isAlertShowing){
            isAlertShowing = YES;
            [alert addAction:okButton];
            [alert addAction:changeButton];
            [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:alert animated:YES completion:nil];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(7.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [alert dismissViewControllerAnimated:YES completion:^{}];
                isAlertShowing = NO;
            });
        } else {
            isAlertShowing = NO;
            [alert dismissViewControllerAnimated:YES completion:^{}];
        }
        NSLog(@"AlwaysRemindMe ISSUE: customHasIssue -> %@ ", customHasIssueText);
    }

%end

//setting text on LS
%hook SBLockScreenViewControllerBase

	-(void)viewDidLoad{
        %orig;

        CGSize screenSize = [UIScreen mainScreen].bounds.size;
		CGFloat screenHeight = screenSize.height;
		CGFloat screenWidth = screenSize.width;
        UIView* selfView = self.view;

		if(twIsEnabled){
			if (([twWhichScreenChoice intValue] == 0) || ([twWhichScreenChoice intValue] == 2)){
				drawAlwaysRemindMe(screenHeight, screenWidth, selfView);
                //twIsViewPresented = YES;
			}
		}
        if(twShouldDelete){
            dealloc(selfView);
        }
	}

    -(void)viewDidDisappear:(BOOL)arg1{
        %orig(arg1);
        if(customHasIssue){
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [[%c(SBHomeScreenViewController) alloc] showCustomHasIssueAlert];
                //[%c(SBHomeScreenViewController) showCustomHasIssueAlert];
            });

        }
    }

%end

void TimerExampleLoadTimer(){
	NSDictionary *userInfoDictionary = nil;
	userInfoDictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:PLIST_PATH];
	if (!userInfoDictionary){
		return;
	}

	NSDate *fireDate = [userInfoDictionary objectForKey:@"pfTime24"];
    NSLog(@"AlwaysRemindMe LOG: pfTime24: %@", [userInfoDictionary objectForKey:@"pfTime24"]);
    NSLog(@"AlwaysRemindMe LOG: fireDate: %@", fireDate);
    NSLog(@"AlwaysRemindMe LOG: %@", [NSDate date]);
	if (!fireDate || [[NSDate date] compare:fireDate] == NSOrderedDescending){
		NSLog(@"AlwaysRemindMe LOG: TimerExampleLoadTimer - invalid or in the past");
		return;
	}

	//NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
	activeTimer = [[%c(PCSimpleTimer) alloc] initWithFireDate:fireDate serviceIdentifier:@"ch.leroyb.AlwaysRemindMePref" target:[%c(SBClockDataProvider) self] selector:@selector(TimerExampleFired) userInfo:nil];

	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
	[formatter setTimeZone:[NSTimeZone defaultTimeZone]];
	NSLog(@"AlwaysRemindMe LOG: Added Timer %@", [formatter stringFromDate:fireDate]);

}

static void TimerExampleNotified(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo){

	NSLog(@"AlwaysRemindMe LOG: received CFNotificationCenterPostNotification");
	// kill old timer
	if (activeTimer){
		[activeTimer invalidate];
		activeTimer = nil;
	}
    NSLog(@"AlwaysRemindMe LOG: 'TimerExampleLoadTimer' called in 'TimerExampleNotified'");
	TimerExampleLoadTimer();
}

static void preferencesChanged(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo){
    loadPrefs();
	NSLog(@"AlwaysRemindMe LOG: 'loadPrefs' called in 'preferencesChanged'");
}

%ctor{
	@autoreleasepool{
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

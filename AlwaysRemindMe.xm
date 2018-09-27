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
    - batman wirbel (phil fragen)
    - animation for n times?
    - touch on label [open action sheet(show all and share sheet), open pref panel, select time to be reminded at]
    - multiable textViews: in settings.app specific subViewController based on rootViewController listView selected value
    - time based (example code as pic on phone) -> how long?(0.5h,1h,6h,custom)
*/

@interface SpringBoard
@end

@interface SBLockScreenViewControllerBase : UIViewController
    -(void)showCustomHasIssueAlert;
@end

@interface SBHomeScreenViewController : UIViewController
@end

@interface SBClockDataProvider : NSObject
    +(id)sharedInstance;
@end

@interface UIColor(Hexadecimal)

    +(UIColor *)colorFromHex:(NSString *)hexString;

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

static bool twShouldNotShowReminder = YES;
static bool twIsEnabled = NO;
static bool twIsViewPresented = NO;
CGSize screenSize;
UIView* selfViewHomescreen;
UIView* selfViewLockscreen;

static NSNumber *twWhichScreenChoice = nil;
static NSString *twTextLabelVar = @"";
static NSString *twTextLabelVar1 = @"";

static bool twIsTimerEnabled = NO;
static NSString *twTime24 = @"12:00";
static NSString *twTimeCurrent = @"";
static NSNumber *twTimerCustom = nil;
static NSNumber *twTimerChoice = nil;
static PCSimpleTimer *activateTimer = nil;
static PCSimpleTimer *durationTimer = nil;

static NSNumber *twFramePosChoice = nil;
static NSNumber *twFrameX = nil;
static NSNumber *twFrameY = nil;
static NSNumber *twFrameW = nil;
static NSNumber *twFrameH = nil;

static bool twIsBackgroundEnabled = YES;
static NSNumber *twFontSizeCustom = @14;
static NSNumber *twFontSize = @14;
static NSString *twFontCustom = @"Trebuchet MS";

static NSNumber *twFontColorChoice = nil;
static NSString *twFontColorCustom = @"#000000";
static NSNumber *twBackgroundColorChoice = nil;
static NSString *twBackgroundColorCustom = @"#ffffff";

static bool twIsRainbowEnabled = NO;
static NSNumber *twRainbowDelay = nil;

static bool twIsRotationEnabled = NO;
static NSNumber *twRotationSpeedChoice = nil;
static NSNumber *twRotationSpeed = nil;
static NSNumber *twRotationDelay = nil;
static NSNumber *twRotationCount = nil;
static NSInteger countInLoop = 1;

static bool twIsBlinkEnabled = NO;
static NSNumber *twBlinkSpeedChoice = nil;
static NSNumber *twBlinkSpeed = nil;
static NSNumber *twBlinkCount = nil;

static bool twIsShakeEnabled = NO;
static NSNumber *twShakeDurationChoice = nil;
static NSNumber *twShakeDuration = nil;
static NSNumber *twShakeXAmount = nil;
static NSNumber *twShakeYAmount = nil;
static NSNumber *twShakeCount = nil;

static bool twIsPulseEnabled = NO;
static NSNumber *twPulseSpeedChoice = nil;
static NSNumber *twPulseSizeChoice = nil;
static NSNumber *twPulseSpeed = nil;
static NSNumber *twPulseSize = nil;
static NSNumber *twPulseCount = nil;

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
        // all of this is necessary because if the string gets to long it will crash the SpringBoard
        NSMutableArray *array = [[[NSMutableArray alloc] init] autorelease];
        NSMutableString *result = [[NSMutableString alloc] init];
        NSMutableString *result1 = [[NSMutableString alloc] init];
        // for the length of the 'pfTextLabel' string, save char at loop position to array
        for (int i = 0; i < [[[prefs objectForKey:@"pfTextLabel"] description] length]; i++){
            [array addObject:[NSString stringWithFormat:@"%C", [[[prefs objectForKey:@"pfTextLabel"] description] characterAtIndex:i]]];
        }
        // for each obj in the previously created array append the current obj to the mutable string
        for (NSObject *obj in array){
            [result appendString:[obj description]];
        }
        twTextLabelVar = result;
        [array removeAllObjects];

        // same for the second string
        for (int i = 0; i < [[[prefs objectForKey:@"pfTextLabel1"] description] length]; i++){
            [array addObject:[NSString stringWithFormat:@"%C", [[[prefs objectForKey:@"pfTextLabel1"] description] characterAtIndex:i]]];
        }
        for (NSObject *obj1 in array){
            [result1 appendString:[obj1 description]];
        }
        twTextLabelVar1 = result1;

        result = nil;
        result1 = nil;

        // each var checks if the object for its key exists, if so it uses the key's value else it uses the default/nil value
        twIsEnabled				= ([prefs objectForKey:@"pfIsTweakEnabled"] ? [[prefs objectForKey:@"pfIsTweakEnabled"] boolValue] : twIsEnabled);
		twWhichScreenChoice 	= ([prefs objectForKey:@"pfWhichScreenChoice"] ? [prefs objectForKey:@"pfWhichScreenChoice"] : twWhichScreenChoice);

        twIsTimerEnabled		= ([prefs objectForKey:@"pfIsTimerEnabled"] ? [[prefs objectForKey:@"pfIsTimerEnabled"] boolValue] : twIsTimerEnabled);
        twTime24        		= ([prefs objectForKey:@"pfTime24"] ? [[prefs objectForKey:@"pfTime24"] description] : twTime24);
        twTimeCurrent      		= ([prefs objectForKey:@"pfTimeCurrent"] ? [[prefs objectForKey:@"pfTimeCurrent"] description] : twTimeCurrent);
        twTimerChoice           = ([prefs objectForKey:@"pfTimerChoice"] ? [prefs objectForKey:@"pfTimerChoice"] : twTimerChoice);
        twTimerCustom        	= ([prefs objectForKey:@"pfTimerCustom"] ? [prefs objectForKey:@"pfTimerCustom"] : twTimerCustom);

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
        twRotationCount			= ([prefs objectForKey:@"pfRotationCount"] ? [prefs objectForKey:@"pfRotationCount"] : twRotationCount);

        twIsBlinkEnabled		= ([prefs objectForKey:@"pfIsBlinkEnabled"] ? [[prefs objectForKey:@"pfIsBlinkEnabled"] boolValue] : twIsBlinkEnabled);
        twBlinkSpeedChoice      = ([prefs objectForKey:@"pfBlinkSpeedChoice"] ? [prefs objectForKey:@"pfBlinkSpeedChoice"] : twBlinkSpeedChoice);
        twBlinkSpeed			= ([prefs objectForKey:@"pfBlinkSpeed"] ? [prefs objectForKey:@"pfBlinkSpeed"] : twBlinkSpeed);
        twBlinkCount			= ([prefs objectForKey:@"pfBlinkCount"] ? [prefs objectForKey:@"pfBlinkCount"] : twBlinkCount);

        twIsPulseEnabled		= ([prefs objectForKey:@"pfIsPulseEnabled"] ? [[prefs objectForKey:@"pfIsPulseEnabled"] boolValue] : twIsPulseEnabled);
        twPulseSpeedChoice 	    = ([prefs objectForKey:@"pfPulseSpeedChoice"] ? [prefs objectForKey:@"pfPulseSpeedChoice"] : twPulseSpeedChoice);
        twPulseSpeed			= ([prefs objectForKey:@"pfPulseSpeed"] ? [prefs objectForKey:@"pfPulseSpeed"] : twPulseSpeed);
        twPulseSizeChoice 	    = ([prefs objectForKey:@"pfPulseSizeChoice"] ? [prefs objectForKey:@"pfPulseSizeChoice"] : twPulseSizeChoice);
        twPulseSize 			= ([prefs objectForKey:@"pfPulseSize"] ? [prefs objectForKey:@"pfPulseSize"] : twPulseSize);
        twPulseCount			= ([prefs objectForKey:@"pfPulseCount"] ? [prefs objectForKey:@"pfPulseCount"] : twPulseCount);

        twIsShakeEnabled		= ([prefs objectForKey:@"pfIsShakeEnabled"] ? [[prefs objectForKey:@"pfIsShakeEnabled"] boolValue] : twIsShakeEnabled);
        twShakeDurationChoice 	= ([prefs objectForKey:@"pfShakeDurationChoice"] ? [prefs objectForKey:@"pfShakeDurationChoice"] : twShakeDurationChoice);
        twShakeDuration			= ([prefs objectForKey:@"pfShakeDuration"] ? [prefs objectForKey:@"pfShakeDuration"] : twShakeDuration);
        twShakeXAmount			= ([prefs objectForKey:@"pfShakeXAmount"] ? [prefs objectForKey:@"pfShakeXAmount"] : twShakeXAmount);
        twShakeYAmount 			= ([prefs objectForKey:@"pfShakeYAmount"] ? [prefs objectForKey:@"pfShakeYAmount"] : twShakeYAmount);
        twShakeCount			= ([prefs objectForKey:@"pfShakeCount"] ? [prefs objectForKey:@"pfShakeCount"] : twShakeCount);
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

// takes 'UIView' and changes the backgroundColor with delay after each change
static void performRainbowAnimated(UIView *currentView, NSNumber *delay){

    // CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
    // animationGroup.duration = [delay floatValue];
    // animationGroup.repeatCount = HUGE_VALF;
    //
    // CABasicAnimation* rainbowAnimation = [CABasicAnimation animationWithKeyPath:@"backgroundColor"];
    // rainbowAnimation.fromValue = (id)[UIColor whiteColor].CGColor;
    // rainbowAnimation.toValue = [UIColor colorWithHue:drand48() saturation:1.0 brightness:1.0 alpha:1.0];
    // rainbowAnimation.autoreverses = NO;
    // rainbowAnimation.repeatCount = HUGE_VALF;
    //
    // animationGroup.animations = @[rainbowAnimation];
    // [currentView.layer addAnimation:rainbowAnimation forKey:nil];

    [UIView animateWithDuration:0.01 delay:0 options:UIViewAnimationOptionTransitionNone animations:^{
        currentView.backgroundColor = [UIColor colorWithHue:drand48() saturation:1.0 brightness:1.0 alpha:1.0];
    } completion:^(BOOL finished){
        // executes block after delay has passed
        double delayInSeconds = [delay floatValue];
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            performRainbowAnimated(currentView, delay);
        });
    }];

}// shake rainbow end

// takes a 'UILabel' and roatates it by the given speed, delays by given value after completion before redoing it indefinitely
static void performRotationAnimated(UILabel *twTextLabel, NSNumber *speed, NSNumber *delay, NSNumber *count){

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
                                              if([count intValue] == 0){
                                                  performRotationAnimated(twTextLabel, speed, delay, count);
                                              } else if(countInLoop <= [count intValue]){ // maybe this will show one to little ?
                                                  performRotationAnimated(twTextLabel, speed, delay, count);
                                                  countInLoop++;
                                              }
                                          }];
                     }];

 }
// // takes a 'UIView' and roatates it by the given speed, delays by given value after completion before redoing it indefinitely
// static void performRotationAnimated(UIView *currentView, NSNumber *duration, NSNumber *delay, NSNumber *count){
//
//     CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
//     animationGroup.duration = [delay floatValue] + [duration floatValue];
//     if([count intValue] == 0){
//         animationGroup.repeatCount = HUGE_VALF;
//     } else {
//         animationGroup.repeatCount = [count floatValue];
//     }
//
//     CAMediaTimingFunction *easeOut = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
//
//     CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
//     rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 * [duration floatValue]];
//     rotationAnimation.duration = [duration floatValue];
//     rotationAnimation.timingFunction = easeOut;
//     if([count intValue] == 0){
//         animationGroup.repeatCount = HUGE_VALF;
//     } else {
//         animationGroup.repeatCount = [count floatValue];
//     }
//
//     animationGroup.animations = @[rotationAnimation];
//     [currentView.layer addAnimation:rotationAnimation forKey:nil];
//
//
//
//     // CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
//     // NSLog(@"AlwaysRemindMe DEBUG LOG: duration: %f", [duration floatValue]);
//     // NSLog(@"AlwaysRemindMe DEBUG LOG: delay: %f", [delay floatValue]);
//     // animationGroup.duration = [delay floatValue] + [duration floatValue];
//     // NSLog(@"AlwaysRemindMe DEBUG LOG: animationGroup.duration: %f", animationGroup.duration);
//     // animationGroup.repeatCount = HUGE_VALF;
//     //
//     // CABasicAnimation* rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
//     // rotationAnimation.beginTime = [delay floatValue];
//     // rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 * [duration floatValue]];
//     // rotationAnimation.duration = [duration floatValue];
//     // rotationAnimation.cumulative = YES;
//     // if([count intValue] == 0){
//     //     rotationAnimation.repeatCount = HUGE_VALF;
//     // } else {
//     //     rotationAnimation.repeatCount = [count floatValue];
//     // }
//     //
//     // animationGroup.animations = @[rotationAnimation];
//     // [currentView.layer addAnimation:rotationAnimation forKey:nil];
// }// rotate func end

// takes a 'UIView' and moves (x and or y or one one of thoes) it over time,
static void performShakeAnimated(UIView *currentView, NSNumber *duration, NSNumber *xAmount, NSNumber *yAmount, NSNumber *count){

    CABasicAnimation *shakeAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
    shakeAnimation.duration = [duration floatValue];
    shakeAnimation.fromValue = [NSValue valueWithCGPoint:CGPointMake([currentView center].x - [xAmount floatValue], [currentView center].y - [yAmount floatValue])];
    shakeAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake([currentView center].x + [xAmount floatValue], [currentView center].y + [yAmount floatValue])];

    shakeAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    shakeAnimation.autoreverses = YES;
    if([count intValue] == 0){
        shakeAnimation.repeatCount = HUGE_VALF;
    } else {
        shakeAnimation.repeatCount = [count floatValue];
    }
    [currentView.layer addAnimation:shakeAnimation forKey:nil];

}// shake func end

// takes a 'UIView' and pulsates it to given size, duration of the animation can also be given
static void performPulseAnimated(UIView *currentView, NSNumber *size, NSNumber *duration, NSNumber *count){

    CABasicAnimation *pulseAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    pulseAnimation.duration = [duration floatValue];
    pulseAnimation.toValue = size;
    pulseAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    pulseAnimation.autoreverses = YES;
    if([count intValue] == 0){
        pulseAnimation.repeatCount = HUGE_VALF;
    } else {
        pulseAnimation.repeatCount = [count floatValue];
    }
    [currentView.layer addAnimation:pulseAnimation forKey:nil];

}// Pulse func end

// takes 'UIView' and fades it over time and back
static void performBlinkAnimated(UIView *currentView, NSNumber *duration, NSNumber *count){

    CABasicAnimation *shakeAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    shakeAnimation.duration = [duration floatValue];
    shakeAnimation.fromValue = [NSNumber numberWithFloat: 1];
    shakeAnimation.toValue = [NSNumber numberWithFloat: 0];

    shakeAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    shakeAnimation.autoreverses = YES;
    if([count intValue] == 0){
        shakeAnimation.repeatCount = HUGE_VALF;
    } else {
        shakeAnimation.repeatCount = [count floatValue];
    }
    [currentView.layer addAnimation:shakeAnimation forKey:nil];

}// blink func end

// ############################# ANIMATIONS ### END ####################################

// ############################# DRAW LABEL ### START ####################################

// creates 'UILabel' on the selected screen
static void drawAlwaysRemindMe(CGFloat screenHeight, CGFloat screenWidth, UIView *currentView){

    UILabel *twTextLabel = [[[UILabel alloc] init] autorelease];
    twTextLabel.numberOfLines=0;
    if ([twTextLabelVar1 isEqualToString:@""]){
        twTextLabel.text = twTextLabelVar;
    } else {
        twTextLabel.text = [NSString stringWithFormat:@"%@\r%@", twTextLabelVar,twTextLabelVar1];
    }

    [twTextLabel sizeToFit];
    if([twFontSize intValue] == 999){
		[twTextLabel setFont:[UIFont fontWithName:twFontCustom size:[twFontSizeCustom floatValue]]];
	} else {
		[twTextLabel setFont:[UIFont fontWithName:twFontCustom size:[twFontSize floatValue]]];
	}

    //gets text size
    CGSize textSize = [twTextLabel.text sizeWithAttributes:@{NSFontAttributeName:[twTextLabel font]}];
    CGFloat absolutCenter = (screenWidth/2) - (textSize.width/2);
    CGFloat varFrameX = 0;
    CGFloat varFrameY = 0;

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
		case 999:// custom

        // ************************ this need working *******************************
            if(!twFrameX && !twFrameY){
                varFrameX = absolutCenter;
                varFrameY = (screenHeight/2)-twTextLabel.intrinsicContentSize.height;
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
			NSLog(@"AlwaysRemindMe ISSUE: switch -> twFramePosChoice is default");
			varFrameX = (screenWidth/2) - (textSize.width/2);
			varFrameY = 20;
			break;
	}//switch position end
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
        case 999:// custom
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
            NSLog(@"AlwaysRemindMe ISSUE: switch -> twFontColorChoice is default");
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
    		case 999:// custom
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
    			NSLog(@"AlwaysRemindMe ISSUE: switch -> twBackgroundColorChoice is default");
    			varBackgroundColor = @"#FFFFFF";
    			break;
    	}
        [twTextLabel setBackgroundColor: [UIColor colorFromHex: varBackgroundColor]];
	} else {
		[twTextLabel setBackgroundColor: [UIColor clearColor]];
    }

	[currentView addSubview:twTextLabel];

    //rainbow
    if(twIsRainbowEnabled){
        NSNumber *varRainbowDelay = nil;
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
    if(twIsRotationEnabled){
        NSNumber *varRotationDelay = nil;
        NSNumber *varRotationSpeed = nil;
        NSNumber *varRotationCount = nil;
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
    		case 999:// custom
                if([twRotationSpeed isKindOfClass:[NSNull class]]){
                //if(twRotationSpeed == nil){
                    varRotationSpeed = @2;
                    customHasIssue = YES;
                    customHasIssueText = @"Your custom 'rotation speed' value is invalid!";
                } else {
                    varRotationSpeed = twRotationSpeed;
                }
    			break;
    		default:
                varRotationSpeed = @2;
    			NSLog(@"AlwaysRemindMe ISSUE: switch -> twRotationSpeedChoice is default");
    			break;
    	}//switch twRotationSpeedChoice end
        if(!twRotationDelay){
            varRotationDelay = @2;
            customHasIssue = YES;
            customHasIssueText = @"Your custom 'rotation delay' value is invalid!";
        } else {
            varRotationDelay = twRotationDelay;
        }
        if([twRotationCount isKindOfClass:[NSNull class]]){
            varRotationCount = @0;
            customHasIssue = YES;
            customHasIssueText = @"Your custom 'rotation count' value is invalid!";
        } else if(twRotationCount == 0){
            varRotationCount = @0;
        } else {
            varRotationCount = twRotationCount;
        }
        //twRotationCount
        countInLoop = 1;
        performRotationAnimated(twTextLabel, varRotationSpeed, varRotationDelay, varRotationCount);
    }

    if(twIsPulseEnabled){
        NSNumber *varPulseSize = nil;
        NSNumber *varPulseSpeed = nil;
        NSNumber *varPulseCount = nil;
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
    		case 999:// custom
                if(!twPulseSize){
                    varPulseSize = @2;
                    customHasIssue = YES;
                    customHasIssueText = @"Your custom 'pulse size' value is invalid!";
                } else {
                    varPulseSize = twPulseSize;
                }
    			break;
    		default:
    			NSLog(@"AlwaysRemindMe ISSUE: switch -> twPulseSizeChoice is default");
                varPulseSize = @2;
    			break;
    	}//switch twPulseSize end
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
    		case 999:// custom
                if(!twPulseSpeed){
                    varPulseSpeed = @1;
                    customHasIssue = YES;
                    customHasIssueText = @"Your custom 'pulse speed' value is invalid!";
                } else {
                    varPulseSpeed = twPulseSpeed;
                }
    			break;
    		default:
    			NSLog(@"AlwaysRemindMe ISSUE: switch -> twPulseSpeedChoice is default");
                varPulseSpeed = @1;
    			break;
    	}
        if([twPulseCount isKindOfClass:[NSNull class]]){
            varPulseCount = @0;
            customHasIssue = YES;
            customHasIssueText = @"Your custom 'pulse count' value is invalid!";
        } else if(twPulseCount == 0){
            varPulseCount = @0;
        } else {
            varPulseCount = twPulseCount;
        }
    	//switch twPulseSpeed end
        performPulseAnimated(twTextLabel, varPulseSize, varPulseSpeed, varPulseCount);
    }

    if(twIsShakeEnabled){
        NSNumber *varShakeDuration = nil;
        NSNumber *varShakeXAmount = nil;
        NSNumber *varShakeYAmount = nil;
        NSNumber *varShakeCount = nil;
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
    		case 999:// custom
                if(!twShakeDuration && twShakeDuration == nil){
                    varShakeDuration = @1;
                    customHasIssue = YES;
                    customHasIssueText = @"Your custom 'shake duration' value is invalid!";
                } else {
                    varShakeDuration = twShakeDuration;
                }
    			break;
    		default:
    			NSLog(@"AlwaysRemindMe ISSUE: switch -> twShakeDurationChoice is default");
                twShakeXAmount = @10;
                twShakeYAmount = @0;
    			break;
    	}//switch twShakeDurationChoice end

        // NSLog(@"AlwaysRemindMe LOG: twShakeXAmount: %@", twShakeXAmount);
        // NSLog(@"AlwaysRemindMe LOG: twShakeYAmount: %@", twShakeYAmount);
        if(!twShakeXAmount && !twShakeYAmount){
            varShakeXAmount = @10;
            varShakeYAmount = @0;
            customHasIssue = YES;
            customHasIssueText = @"Your custom 'shake position' values is invalid!";
        } else if(!twShakeXAmount && twShakeXAmount != 0){
            varShakeXAmount = @0;
            varShakeYAmount = twShakeYAmount;
            customHasIssue = YES;
            customHasIssueText = @"Your custom 'X shake' value is invalid!";
        } else if(!twShakeYAmount && twShakeYAmount != 0){
            varShakeXAmount = twShakeXAmount;
            varShakeYAmount = @0;
            customHasIssue = YES;
            customHasIssueText = @"Your custom 'Y shake' value is invalid!";
        } else {
            varShakeXAmount = twShakeXAmount;
            varShakeYAmount = twShakeYAmount;

        }
        if([twShakeCount isKindOfClass:[NSNull class]]){
            varShakeCount = @0;
            customHasIssue = YES;
            customHasIssueText = @"Your custom 'shake count' value is invalid!";
        } else if(twPulseCount == 0){
            varShakeCount = @0;
        } else {
            varShakeCount = twShakeCount;
        }
        performShakeAnimated(twTextLabel, varShakeDuration, varShakeXAmount, varShakeYAmount, varShakeCount);
    }

    if(twIsBlinkEnabled){
        NSNumber *varBlinkSpeed = nil;
        NSNumber *varBlinkCount = nil;
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
    		case 999:// custom
                if(!twBlinkSpeed){
                    varBlinkSpeed = @0.5;
                    customHasIssue = YES;
                    customHasIssueText = @"Your custom 'blink speed' value is invalid!";
                } else {
                    varBlinkSpeed = twBlinkSpeed;
                }
    			break;
    		default:
    			NSLog(@"AlwaysRemindMe ISSUE: switch -> twBlinkSpeedChoice is default");
                varBlinkSpeed = @0.5;
    			break;
    	}//switch twBlinkSpeedChoice end
        if([twBlinkCount isKindOfClass:[NSNull class]]){
            varBlinkCount = @0;
            customHasIssue = YES;
            customHasIssueText = @"Your custom 'blink count' value is invalid!";
        } else if(twPulseCount == 0){
            varBlinkCount = @0;
        } else {
            varBlinkCount = twShakeCount;
        }
        performBlinkAnimated(twTextLabel, varBlinkSpeed, varBlinkCount);
    }

}// draw func end

// ############################# DRAW LABEL ### END ####################################

%hook SpringBoard
-(void) applicationDidFinishLaunching:(id)application{
	%orig(application);

	NSLog(@"AlwaysRemindMe DEBUG LOG: SpringBoard applicationDidFinishLaunching / calling TimerExampleLoadTimer");
	TimerExampleLoadTimer();
}
%end //hook SpringBoard

//setting text on SB
%hook SBHomeScreenViewController

	-(void)viewDidLoad{
        // gets the current screen size and view
		screenSize = [UIScreen mainScreen].bounds.size;
        selfViewHomescreen = self.view;

        if(twShouldDelete){
            NSLog(@"AlwaysRemindMe DEBUG LOG: *************************** twShouldDelete %d", twShouldDelete);
            twShouldDelete = NO;
            dealloc(selfViewHomescreen);
        }

        %orig;

        if(twIsEnabled){
            NSLog(@"AlwaysRemindMe DEBUG LOG: 1 twIsEnabled %d", twIsEnabled);
            if(twIsTimerEnabled){
                NSLog(@"AlwaysRemindMe DEBUG LOG: 2 twIsTimerEnabled %d", twIsTimerEnabled);
                if(!twShouldNotShowReminder){
                    NSLog(@"AlwaysRemindMe DEBUG LOG: 3 twShouldNotShowReminder %d", twShouldNotShowReminder);
                    return;
                } else {
                    // if screen choice is ether 'Both' or 'Homescreen'
        			if (([twWhichScreenChoice intValue] == 0) || ([twWhichScreenChoice intValue] == 1)){
                        NSLog(@"AlwaysRemindMe DEBUG LOG: 4 twWhichScreenChoice");
        				drawAlwaysRemindMe(screenSize.height, screenSize.width, selfViewHomescreen);
                        twIsViewPresented = YES;
        			}
                }
            } else {
                // if screen choice is ether 'Both' or 'Homescreen'
    			if (([twWhichScreenChoice intValue] == 0) || ([twWhichScreenChoice intValue] == 1)){
                    NSLog(@"AlwaysRemindMe DEBUG LOG: 4 twWhichScreenChoice");
    				drawAlwaysRemindMe(screenSize.height, screenSize.width, selfViewHomescreen);
                    twIsViewPresented = YES;
    			}
            }
        }
	}

    %new
    -(void)drawAlwaysRemindMeView{

    }

    // new 'SBHomeScreenViewController' methode to show an alert if one or more user defined values are invalid
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
                                         // opens the settings.app to the tweak location
                                         //[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"Prefs:root=AlwaysRemindMe"]];
                                         [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"Prefs:root=AlwaysRemindMe"] options:@{} completionHandler:nil];
                                     }];
        // if the issue alert is not showing
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

%end //hook SBHomeScreenViewController

//setting text on LS
%hook SBLockScreenViewControllerBase

	-(void)viewDidLoad{
        %orig;
        UIView* selfView = self.view;

		if(twIsEnabled){
            if(twIsTimerEnabled){
                if(!twShouldNotShowReminder){
                    return;
                }
            }
            // if screen choice is ether 'Both' or 'Lockscreen'
			if (([twWhichScreenChoice intValue] == 0) || ([twWhichScreenChoice intValue] == 2)){
				drawAlwaysRemindMe(screenSize.height, screenSize.width, selfView);
                twIsViewPresented = YES;
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
            });

        }
    }

%end//hook SBLockScreenViewControllerBase

%hook SBClockDataProvider

    %new
    -(void)TimerExampleFired1{
        NSLog(@"AlwaysRemindMe DEBUG LOG: ############### TimerExampleFired1 ##################");
        twShouldNotShowReminder = YES;
        [[%c(SBHomeScreenViewController) alloc] viewDidLoad];
    }

    %new - (void)TimerExampleFired{
    	NSLog(@"AlwaysRemindMe DEBUG LOG: ############### TimerExampleFired ##################");
        twShouldNotShowReminder = NO;
        [[%c(SBHomeScreenViewController) alloc] viewDidLoad];
        NSNumber *varTimerCustom = nil;
        switch ([twTimerChoice intValue]){
    		case 1://5min
    			varTimerCustom = @5;
    			break;
    		case 2://15min
    			varTimerCustom = @15;
    			break;
            case 3://30min
    			varTimerCustom = @30;
    			break;
            case 4://60min
    			varTimerCustom = @60;
    			break;
    		case 999://Custom
                if([twTimerCustom isKindOfClass:[NSNull class]]){
                    varTimerCustom = @60;
                    customHasIssue = YES;
                    customHasIssueText = @"Your custom 'timer' value is invalid!";
                } else {
                    varTimerCustom = twTimerCustom;
                }
    			break;
    		default:
    			NSLog(@"AlwaysRemindMe ISSUE: switch -> twTimerChoice is default");
                varTimerCustom = @60;
    			break;
    	}//switch twPulseSize end
        durationTimer = [[%c(PCSimpleTimer) alloc] initWithTimeInterval:[varTimerCustom doubleValue] serviceIdentifier:@"ch.leroyb.AlwaysRemindMePref" target:[%c(SBClockDataProvider) sharedInstance] selector:@selector(TimerExampleFired1) userInfo:nil];
        [durationTimer scheduleInRunLoop:[NSRunLoop mainRunLoop]];

        // draw reminder and show for choise lenght
        // make timer for repeat
    }

%end //hook SBClockDataProvider

void TimerExampleLoadTimer(){
	NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:PLIST_PATH];
	if (!prefs){
		return;
	}
	NSDate *fireDate = [prefs objectForKey:@"pfTime24"];
    NSDate *currentDateTime = [NSDate date];

    [prefs setValue:currentDateTime forKey:@"pfTimeCurrent"];
    NSDate *fireDateCurrent = [prefs objectForKey:@"pfTimeCurrent"];

	if (!fireDate || [fireDateCurrent compare:fireDate] == NSOrderedDescending){
		NSLog(@"AlwaysRemindMe LOG: TimerExampleLoadTimer - invalid or in the past");
		return;
	}
    activateTimer = [[%c(PCSimpleTimer) alloc] initWithFireDate:fireDate serviceIdentifier:@"ch.leroyb.AlwaysRemindMePref" target:[%c(SBClockDataProvider) sharedInstance] selector:@selector(TimerExampleFired) userInfo:nil];
    [activateTimer scheduleInRunLoop:[NSRunLoop mainRunLoop]];

}

static void TimerExampleNotified(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo){

	// kill old timer
	if (activateTimer){
		[activateTimer invalidate];
		activateTimer = nil;
	}
	TimerExampleLoadTimer();
}

static void preferencesChanged(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo){
    loadPrefs();
	NSLog(@"AlwaysRemindMe LOG: 'loadPrefs' called in 'preferencesChanged'");
    // twShouldDelete = YES;
    // [[%c(SBHomeScreenViewController) alloc] viewDidLoad];
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

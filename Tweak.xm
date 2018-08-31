/*
TODO:
    - blinking: set speed
    - shake: set speed and Size
    - X/Y pos: set correct position on custom select

*/

/*
features:
	- width full screen
    - multiable textViews: in settings.app specific subViewController based on rootViewController listView selected value

*/

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

//define var and assign default values
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
                                                    //
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
//
// static void performShakeAnimated(UIView *currentView, double duration, double xAmount, double yAmount) {
//
//     CABasicAnimation *shakeAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
//     shakeAnimation.duration = duration;
//
//     shakeAnimation.fromValue = [NSValue valueWithCGPoint:CGPointMake([currentView center].x - xAmount, [currentView center].y - yAmount)];
//     shakeAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake([currentView center].x + xAmount, [currentView center].y + yAmount)];
//
//     shakeAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
//     shakeAnimation.autoreverses = YES;
//     shakeAnimation.repeatCount = HUGE_VALF;
//     [currentView.layer addAnimation:shakeAnimation forKey:@"position"];
//
// }

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
		case 1://below StatusBar
			varFrameX = absolutCenter;
			varFrameY = 20;
			break;
		case 2://above dock
			varFrameX = absolutCenter;
			varFrameY = screenHeight-110;
			break;
		case -999:// custom
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
	//switch position end
    twFrameX = varFrameX;
    twFrameY = varFrameY;

    twTextLabel.frame = CGRectMake(twFrameX, twFrameY, twTextLabel.intrinsicContentSize.width, twFontSize+5);

	//UILabel *twTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(twFrameX, twFrameY, twFrameW, twFontSize+5)];
    //fontColor
    NSString *varFontColor = @"#000000";
    switch (twFontColorChoice) {
        case 1://black
            varFontColor = @"#000000";
            break;
        case 2://white
            varFontColor = @"#FFFFFF";
            break;
        case 3://orange
            varFontColor = @"#FFA500";
            break;
        case -999:// custom
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

    //backgroundColor
	if(twIsBackgroundEnabled) {
        NSString *varBackgroundColor = @"#FFFFFF";
        switch (twBackgroundColorChoice) {
    		case 1://white
                varBackgroundColor = @"#FFFFFF";
    			break;
    		case 2://black
                varBackgroundColor = @"#000000";
    			break;
            case 3://orange
                varBackgroundColor = @"#FFA500";
    			break;
    		case -999:// custom
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


    //rotation
    if(twIsRotationEnabled) {
        performRotationAnimated(twTextLabel, twRotationSpeed);
    }

    double varPulseSize, varPulseSpeed = 0;
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
    			varPulseSize = twPulseSize;
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
    			varPulseSpeed = twPulseSpeed;
    			break;
    		default:
    			NSLog(@"AlwaysRemindMe ERROR: switch -> twPulseSpeedChoice is default");
                varPulseSpeed = 1;
    			break;
    	}
    	//switch twPulseSpeed end
        performPulseAnimated(twTextLabel, varPulseSize, varPulseSpeed);
    }

    double varBlinkingSpeed = 0.5;
    if(twIsBlinkingEnabled) {
        switch (twBlinkingSpeedChoice) {
    		case 1://default
    			varBlinkingSpeed = 0.5;
    			break;
    		case 2://half
    			varBlinkingSpeed = 0.25;
    			break;
            case 3://half
    			varBlinkingSpeed = 1;
    			break;
    		case -999:// custom
    			varPulseSize = twPulseSize;
    			break;
    		default:
    			NSLog(@"AlwaysRemindMe ERROR: switch -> twBlinkingSpeedChoice is default");
                varBlinkingSpeed = 0.5;
    			break;
    	}
    	//switch twPulseSize end
        performBlinkingAnimated(twTextLabel, varBlinkingSpeed);
    }

    // double varBlinkingSpeed = 0.5;
    // if(twIsBlinkingEnabled) {
    //     switch (twBlinkingSpeedChoice) {
    // 		case 1://default
    // 			varBlinkingSpeed = 0.5;
    // 			break;
    // 		case 2://half
    // 			varBlinkingSpeed = 1;
    // 			break;
    //         case 3://half
    // 			varBlinkingSpeed = 4;
    // 			break;
    // 		case -999:// custom
    // 			varPulseSize = twPulseSize;
    // 			break;
    // 		default:
    // 			NSLog(@"AlwaysRemindMe ERROR: switch -> twBlinkingSpeedChoice is default");
    //             varBlinkingSpeed = 0.5;
    // 			break;
    // 	}
    // 	//switch twPulseSize end
    //     performShakeAnimated(twTextLabel, 0.5, 0, 50);
    // }

}


//setting text on LS
%hook SBLockScreenViewControllerBase

	-(void)viewDidAppear:(BOOL)arg1 {
        %orig;

        CGSize screenSize = [UIScreen mainScreen].bounds.size;
		double screenHeight = screenSize.height;
		double screenWidth = screenSize.width;

        UIView* selfView = self.view;
        // myself = self;

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

%end

//setting text on SB
%hook SBHomeScreenViewController

	-(void)viewDidLoad {
        %orig;

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

        if(YES){
            showAlertChangeInSettings(@"Your custom background color value is invalid!");
        }

	}

%end


static void preferenceschanged(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    loadPrefs();
	NSLog(@"AlwaysRemindMe LOG: 'loadPrefs' called in 'preferenceschanged'");
}

%ctor {
	@autoreleasepool {
        loadPrefs();
	    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, preferenceschanged, CFSTR("com.leroy.AlwaysRemindMePref/preferenceschanged"), NULL, CFNotificationSuspensionBehaviorCoalesce);
		NSLog(@"AlwaysRemindMe LOG: 'loadPrefs' called in 'CFNotificationCenterAddObserver'");
	}
}

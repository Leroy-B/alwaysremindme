/*
TODO:
    - (✔) show drawAlwaysRemindMeView opon respring
    - combine all switch() into one func
    - can copy pref panel text -> fix me
    - combine all show func in Root Controller into one func
    - (✔) default text and background color are both black
    - switch 2 background colors custom speed
*/

/*
features TODO:
	- Animation: glow background/radius example in the beginig of drawFunc
    - touch on label [open action sheet(show all and share sheet), open pref panel, select time to be reminded at]
    - multiable textViews: in settings.app specific subViewController based on rootViewController listView selected value
    - time based (example code as pic on phone) -> how long?(0.5h,1h,6h,custom)
		-> repeat time (every day, once a week)
	- location based
*/

/*
Current features:
	- Create a label with max 2 rows
	- Choose a onscreen location [ Homescreen, Lockscreen, Both, AboveAll ]
	- Show label at a timestamp for n min
	- Choose a onscreen position [ Below StatusBar, Above the Dock, Center, Custom ]
	- Custom font [ familie, size, color ]
	- Custom background color or rainbow (changes background every n seconds)

	- Animations:
		- Rotation [ speed, delay, count ]
		- Shake/Move [ x and y position, duration, count ]
		- Blinking [ speed ]
		- Pulsing [ speed, size, count ]
*/

/*
Idea credits:
	- u/RapingTheWilling [changing the animations and adding more precision settings]
	- u/brkr1 [scheduling the appearance of the label]
*/

#include "AlwaysRemindMe.h"
#include "animations.xm"

// function for loading values from the tweak's plist
static void loadPrefs() {
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
	//NSLog(@"AlwaysRemindMe LOG: after prefs: %@", prefs);
    [prefs release];
}

void TimerLoadTimer() {
	NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:PLIST_PATH];
	if (!prefs){
		return;
	}
	NSDate *fireDate = [prefs objectForKey:@"pfTime24"];
    NSDate *currentDateTime = [NSDate date];

    [prefs setValue:currentDateTime forKey:@"pfTimeCurrent"];
    NSDate *fireDateCurrent = [prefs objectForKey:@"pfTimeCurrent"];

	if (!fireDate || [fireDateCurrent compare:fireDate] == NSOrderedDescending){
		NSLog(@"AlwaysRemindMe LOG: TimerLoadTimer - invalid or in the past");
		return;
	}

	twShouldShowReminder = NO;
	[[%c(SBHomeScreenViewController) alloc] drawAlwaysRemindMeView];
	[[%c(SBLockScreenViewControllerBase) alloc] drawAlwaysRemindMeView];

    activateTimer = [[%c(PCSimpleTimer) alloc] initWithFireDate:fireDate serviceIdentifier:@"ch.leroyb.AlwaysRemindMePref" target:[%c(SBClockDataProvider) sharedInstance] selector:@selector(TimerFired) userInfo:nil];
    [activateTimer scheduleInRunLoop:[NSRunLoop mainRunLoop]];

}

static void removeAllLabelSubviews(UIView *parentView) {
	for (UIView *subView in parentView.subviews) {
		if ([subView isKindOfClass:[UILabel class]]) {
			[subView removeFromSuperview];
		}
	}
}

// ############################# DRAW LABEL ### START ####################################

// creates 'UILabel' on the selected screen
static void drawAlwaysRemindMe(CGFloat screenHeight, CGFloat screenWidth, UIView *currentView){

	if([twWhichScreenChoice intValue] == 0) {
		if(shouldRemoveLabel) {
			removeAllLabelSubviews(selfViewHomescreen);
			removeAllLabelSubviews(selfViewLockscreen);
			removeAllLabelSubviews(selfViewAboveAll);
			shouldRemoveLabel = NO;
		} else {
			shouldRemoveLabel = YES;
		}
	} else {
		removeAllLabelSubviews(selfViewHomescreen);
		removeAllLabelSubviews(selfViewLockscreen);
		removeAllLabelSubviews(selfViewAboveAll);
	}

	// if the timer is enabled but the reminder should not show -> return
	if(twIsTimerEnabled) {
	    if(!twShouldShowReminder) {
	        return;
	    }
	}

    if(twIsEnabled) {
        twTextLabel = [[UILabel alloc] init];
        twTextLabel.numberOfLines = 0;

		// UIColor *color = [UIColor colorWithRed:(255/255.0) green:(0/255.0) blue:(0/255.0) alpha:(255/255.0)];
		// twTextLabel.layer.shadowColor = [color CGColor];
	    // twTextLabel.layer.shadowRadius = 100.0f;
	    // twTextLabel.layer.shadowOpacity = .9;
	    // twTextLabel.layer.shadowOffset = CGSizeZero;
	    // twTextLabel.layer.masksToBounds = NO;


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
        	case 999://custom
                if([twFrameX isKindOfClass:[NSNull class]] && [twFrameY isKindOfClass:[NSNull class]]){
                    varFrameX = absolutCenter;
                    varFrameY = (screenHeight/2)-twTextLabel.intrinsicContentSize.height;
                    customHasIssue = YES;
                    customHasIssueText = @"Your custom 'position' values are invalid!";
                } else if([twFrameX isKindOfClass:[NSNull class]]){
                    varFrameX = absolutCenter;
                    varFrameY = [twFrameY floatValue];
                    customHasIssue = YES;
                    customHasIssueText = @"Your custom 'X position' value is invalid!";
                } else if([twFrameY isKindOfClass:[NSNull class]]){
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
        		//NSLog(@"AlwaysRemindMe ISSUE: switch -> twFramePosChoice is default");
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
                //NSLog(@"AlwaysRemindMe ISSUE: switch -> twFontColorChoice is default");
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
        			//NSLog(@"AlwaysRemindMe ISSUE: switch -> twBackgroundColorChoice is default");
        			varBackgroundColor = @"#FFFFFF";
        			break;
        	}
            [twTextLabel setBackgroundColor: [UIColor colorFromHex: varBackgroundColor]];
        } else {
        	[twTextLabel setBackgroundColor: [UIColor clearColor]];
        }
        // add the label view to the superView
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
                    varRotationSpeed = @4;
        			break;
                case 3://fast
                    varRotationSpeed = @1;
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
        			//NSLog(@"AlwaysRemindMe ISSUE: switch -> twRotationSpeedChoice is default");
        			break;
        	}//switch twRotationSpeedChoice end
            if([twRotationDelay isKindOfClass:[NSNull class]]){
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
            switch ([twPulseSizeChoice intValue]) {
        		case 1://default
        			varPulseSize = @2;
        			break;
        		case 2://half
        			varPulseSize = @0.5;
        			break;
                case 3://half
        			varPulseSize = @4;
        			break;
        		case 999:// custom
                    if([twPulseSize isKindOfClass:[NSNull class]]) {
                        varPulseSize = @2;
                        customHasIssue = YES;
                        customHasIssueText = @"Your custom 'pulse size' value is invalid!";
                    } else {
                        varPulseSize = twPulseSize;
                    }
        			break;
        		default:
        			//NSLog(@"AlwaysRemindMe ISSUE: switch -> twPulseSizeChoice is default");
                    varPulseSize = @2;
        			break;
        	}//switch twPulseSize end
            switch ([twPulseSpeedChoice intValue]) {
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
                    if([twPulseSpeed isKindOfClass:[NSNull class]]) {
                        varPulseSpeed = @1;
                        customHasIssue = YES;
                        customHasIssueText = @"Your custom 'pulse speed' value is invalid!";
                    } else {
                        varPulseSpeed = twPulseSpeed;
                    }
        			break;
        		default:
        			//NSLog(@"AlwaysRemindMe ISSUE: switch -> twPulseSpeedChoice is default");
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
                    if([twShakeDuration isKindOfClass:[NSNull class]]){
                        varShakeDuration = @1;
                        customHasIssue = YES;
                        customHasIssueText = @"Your custom 'shake duration' value is invalid!";
                    } else {
                        varShakeDuration = twShakeDuration;
                    }
        			break;
        		default:
        			//NSLog(@"AlwaysRemindMe ISSUE: switch -> twShakeDurationChoice is default");
                    twShakeXAmount = @10;
                    twShakeYAmount = @0;
        			break;
        	}//switch twShakeDurationChoice end

            if([twShakeXAmount isKindOfClass:[NSNull class]] && [twShakeYAmount isKindOfClass:[NSNull class]]){
                varShakeXAmount = @10;
                varShakeYAmount = @0;
                customHasIssue = YES;
                customHasIssueText = @"Your custom 'shake position' values is invalid!";
            } else if([twShakeXAmount isKindOfClass:[NSNull class]] && twShakeXAmount != 0){
                varShakeXAmount = @0;
                varShakeYAmount = twShakeYAmount;
                customHasIssue = YES;
                customHasIssueText = @"Your custom 'X shake' value is invalid!";
            } else if([twShakeYAmount isKindOfClass:[NSNull class]] && twShakeYAmount != 0){
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
                    if([twBlinkSpeed isKindOfClass:[NSNull class]]){
                        varBlinkSpeed = @0.5;
                        customHasIssue = YES;
                        customHasIssueText = @"Your custom 'blink speed' value is invalid!";
                    } else {
                        varBlinkSpeed = twBlinkSpeed;
                    }
        			break;
        		default:
        			//NSLog(@"AlwaysRemindMe ISSUE: switch -> twBlinkSpeedChoice is default");
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
    }

}// draw func end

// ############################# DRAW LABEL ### END ####################################

// ############################# HOOKS ### START ####################################

%hook SpringBoard
-(void) applicationDidFinishLaunching:(id)application{
	%orig(application);

	TimerLoadTimer();
}
%end //hook SpringBoard

//setting text on SB
%hook SBHomeScreenViewController

	-(void)viewDidLoad {
        // gets the current screen size and view
		screenSize = [UIScreen mainScreen].bounds.size;
        selfViewHomescreen = self.view;
        %orig;
        [self drawAlwaysRemindMeView];
	}

	// new 'SBHomeScreenViewController' methode to call the draw func
    %new
    -(void)drawAlwaysRemindMeView {
		if(([twWhichScreenChoice intValue] == 0) || ([twWhichScreenChoice intValue] == 1)) {
			drawAlwaysRemindMe(screenSize.height, screenSize.width, selfViewHomescreen);
			twIsViewPresented = YES;
		} else if([twWhichScreenChoice intValue] == 3) {
			drawAlwaysRemindMe(screenSize.height, screenSize.width, selfViewAboveAll);
			twIsViewPresented = YES;
		}
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
            [alert release];
        }
    }

%end //hook SBHomeScreenViewController


//setting text on LS
%hook SBLockScreenViewControllerBase

	-(void)viewDidLoad {
        // gets the current screen size and view
		screenSize = [UIScreen mainScreen].bounds.size;
        selfViewLockscreen = self.view;
        %orig;

		// creates a UIWindow; assigns a high level; makes it secure, this is needed to show it on the Lockscreen
		selfViewAboveAll = [[UIWindow alloc] initWithFrame: [[UIScreen mainScreen] bounds]];
		selfViewAboveAll.windowLevel = UIWindowLevelStatusBar + 100;
    	selfViewAboveAll.hidden = NO;
		selfViewAboveAll.userInteractionEnabled = NO;
		selfViewAboveAll._secure = YES;

        [self drawAlwaysRemindMeView];
	}

	%new
    -(void)drawAlwaysRemindMeView {
		if(([twWhichScreenChoice intValue] == 0) || ([twWhichScreenChoice intValue] == 2)) {
			drawAlwaysRemindMe(screenSize.height, screenSize.width, selfViewLockscreen);
			twIsViewPresented = YES;
		} else if([twWhichScreenChoice intValue] == 3){
			drawAlwaysRemindMe(screenSize.height, screenSize.width, selfViewAboveAll);
			twIsViewPresented = YES;
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
    -(void)TimerFired {
        twShouldShowReminder = YES;
		[[%c(SBHomeScreenViewController) alloc] drawAlwaysRemindMeView];
        [[%c(SBLockScreenViewControllerBase) alloc] drawAlwaysRemindMeView];
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
                    customHasIssueText = @"Your custom 'timer duration' value is invalid!";
                } else {
                    varTimerCustom = twTimerCustom;
                }
    			break;
    		default:
    			//NSLog(@"AlwaysRemindMe ISSUE: switch -> twTimerChoice is default");
                varTimerCustom = @60;
    			break;
    	}//switch twTimerChoice end
        durationTimer = [[%c(PCSimpleTimer) alloc] initWithTimeInterval:[varTimerCustom doubleValue] * 60 serviceIdentifier:@"ch.leroyb.AlwaysRemindMePref" target:[%c(SBClockDataProvider) sharedInstance] selector:@selector(TimerOverFired) userInfo:nil];
        [durationTimer scheduleInRunLoop:[NSRunLoop mainRunLoop]];

    }

	%new
    -(void)TimerOverFired {
        twShouldShowReminder = NO;
		[[%c(SBHomeScreenViewController) alloc] drawAlwaysRemindMeView];
        [[%c(SBLockScreenViewControllerBase) alloc] drawAlwaysRemindMeView];
    }

%end //hook SBClockDataProvider

// ############################# HOOKS ### END ####################################

// ############################# CONSTRUCTOR ### START ####################################

static void TimerChanged(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo){

	// remove the old timer
	if (activateTimer){
		[activateTimer invalidate];
		activateTimer = nil;
	}

	TimerLoadTimer();
}

static void preferencesChanged(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo){
    loadPrefs();
	NSLog(@"AlwaysRemindMe LOG: 'loadPrefs' called in 'preferencesChanged'");
    [[%c(SBLockScreenViewControllerBase) alloc] drawAlwaysRemindMeView];
	[[%c(SBHomeScreenViewController) alloc] drawAlwaysRemindMeView];
}

%ctor {
	@autoreleasepool {
		// load the saved preferences from the plist
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
			(CFNotificationCallback)TimerChanged,
			CFSTR("ch.leroyb.AlwaysRemindMePref.timerChanged"),
			NULL,
			CFNotificationSuspensionBehaviorDeliverImmediately
		);
	}
}

// ############################# CONSTRUCTOR ### END ####################################

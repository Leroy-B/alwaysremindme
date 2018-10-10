@interface SpringBoard
@end

@interface SBLockScreenViewControllerBase : UIViewController
    -(void)showCustomHasIssueAlert;
    -(void)drawAlwaysRemindMeView;
@end

@interface SBHomeScreenViewController : UIViewController
    -(void)drawAlwaysRemindMeView;
@end

@interface SBClockDataProvider : NSObject
    +(id)sharedInstance;
    -(void)TimerExampleFired;
@end

@interface UIWindow (Private)
	@property (getter=_isSecure, setter=_setSecure:) BOOL _secure;
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

static bool twShouldShowReminder = YES;
static bool twIsEnabled = NO;
static bool twIsViewPresented = NO;
CGSize screenSize;
UIView *selfViewHomescreen;
UIView *selfViewLockscreen;
UIWindow *selfViewAboveAll;
UILabel *twTextLabel;

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

static bool customHasIssue = NO;
static NSString *customHasIssueText = @"";
static bool isAlertShowing = NO;

static NSNumber *myNum = 0;

void TimerLoadTimer();

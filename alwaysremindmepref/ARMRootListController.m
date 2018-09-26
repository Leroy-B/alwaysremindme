#include "ARMRootListController.h"
#include <spawn.h>
#include <signal.h>

#define PLIST_PATH @"/var/mobile/Library/Preferences/ch.leroyb.AlwaysRemindMePref.plist"

@implementation ARMRootListController

- (id)readPreferenceValue:(PSSpecifier *)specifier{
	NSDictionary *s = [NSDictionary dictionaryWithContentsOfFile:PLIST_PATH];
	if (!s[specifier.properties[@"key"]]){
		return specifier.properties[@"default"];
	}
	return s[specifier.properties[@"key"]];
}

- (void)setPreferenceValue:(id)value specifier:(PSSpecifier *)specifier{
	NSMutableDictionary *defaults = [NSMutableDictionary dictionary];
	[defaults addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:PLIST_PATH]];
	[defaults setObject:value forKey:specifier.properties[@"key"]];
	[defaults writeToFile:PLIST_PATH atomically:YES];
	CFStringRef toPost = (CFStringRef)specifier.properties[@"PostNotification"];
	if (toPost){
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(),
                                         toPost,
                                         NULL,
                                         NULL,
                                         YES);
  }
}

- (id)specifiers{
	if (!_specifiers){
		_specifiers = [[self loadSpecifiersFromPlistName:@"Root" target: self] retain];
	}
	return _specifiers;
}

- (void)_returnKeyPressed:(NSNotificationCenter *)notification{
    [self.view endEditing:YES];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"ch.leroyb.AlwaysRemindMePref.preferencesChanged" object:self];
}

- (void)setContentOffset:(CGPoint)value{
	[self setContentOffset:value];
}

-(void)viewDidLoad{

	UIBarButtonItem *shareButton = [[UIBarButtonItem alloc]
						   initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                           target:self
                           action:@selector(share:)];

	self.navigationItem.rightBarButtonItem = shareButton;

	[shareButton release];
	[super viewDidLoad];
	//[self setContentOffset:CGPointMake(0, 100)];
}

-(IBAction)share:(UIBarButtonItem *)sender{
	NSString *textToShare = @"Click the link below to add LeroyB's repository to Cydia!";
    NSURL *myWebsite = [NSURL URLWithString:@"cydia://url/https://cydia.saurik.com/api/share#?source=https://leroy-b.github.io/home/repo/"];
    NSArray *activityItems = @[textToShare, myWebsite];
    UIActivityViewController *activityViewControntroller = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
    activityViewControntroller.excludedActivityTypes = @[];
    [self presentViewController:activityViewControntroller animated:true completion:nil];
}

-(void)showDatePicker{

	UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:@"Choose a time to be reminded at!\n\n\n\n\n\n\n\n" preferredStyle:UIAlertControllerStyleActionSheet];
	UIView *viewDatePicker = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width,200)];
	[viewDatePicker setBackgroundColor:[UIColor clearColor]];

	CGRect pickerFrame = CGRectMake(0, 0, self.view.frame.size.width, 220);
	UIDatePicker *picker = [[UIDatePicker alloc] initWithFrame:pickerFrame];
	[picker setDatePickerMode:UIDatePickerModeTime];
	//picker.minuteInterval=1;

	[viewDatePicker addSubview:picker];
	[alertController.view addSubview:viewDatePicker];

	// NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
	// outputFormatter.dateFormat=@"yyyy/MM/dd HH:mm:ss";
	NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:PLIST_PATH];

	UIAlertAction* defaultAction = [UIAlertAction
		actionWithTitle:@"OK"
				  style:UIAlertActionStyleDefault
	            handler:^(UIAlertAction * action){
					  //[prefs setValue:[outputFormatter stringFromDate:picker.date] forKey:@"pfTime24"];
					  [prefs setValue:picker.date forKey:@"pfTime24"];
					  [prefs writeToFile:PLIST_PATH atomically:YES];
					  [prefs release];
					  // [outputFormatter release];
					  NSLog(@"AlwaysRemindMe LOG: 1 CFNotificationCenterPostNotification");
					  CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("ch.leroyb.AlwaysRemindMePref.timerChanged"), nil, nil, TRUE);
                }];

	[alertController addAction:defaultAction];
	[self presentViewController:alertController animated:YES completion:nil];

}

-(void)showTwitter{
	if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitter://"]]) [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"twitter://user?screen_name=IDEK_a_Leroy"] options:@{} completionHandler:nil];
	else [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://twitter.com/IDEK_a_Leroy"] options:@{} completionHandler:nil];
}

-(void)showReddit{
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.reddit.com/user/IDEK_a_Leroy"] options:@{} completionHandler:nil];
}

-(void)showSourceCode{
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://github.com/Leroy-B/alwaysremindme"] options:@{} completionHandler:nil];
}

-(void)showBitcoin{
	UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
	pasteboard.string = @"1EZATpr8i4N5XaR9bfCwPHAK6DB2s19uwN";
	UIAlertController * alert = [UIAlertController
			alertControllerWithTitle:@"AlwaysRemindMe: INFO"
							 message:@"My Bitcon address has been copied to your clipboard, all you have to do is paste it. Thank you for your donation! :)"
					  preferredStyle:UIAlertControllerStyleAlert];
	UIAlertAction* okButton = [UIAlertAction
				actionWithTitle:@"OK"
						  style:UIAlertActionStyleDefault
						handler:^(UIAlertAction * action){
							//
						}];
	[alert addAction:okButton];
	[self presentViewController:alert animated:YES completion:nil];
}

-(void)showMonero{
	UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
	pasteboard.string = @"42jBMo7NpyYUoPU3qdu7x6cntT3ez2da5TxKTwZVX9eZfwBA6XzeQEFcTxBukNUYyaGtgvdKtLyz72udsnRo3hFhLYPo37L";
	UIAlertController * alert = [UIAlertController
			alertControllerWithTitle:@"AlwaysRemindMe: INFO"
							 message:@"My Monero address has been copied to your clipboard, all you have to do is paste it. Thank you for your donation! :)"
					  preferredStyle:UIAlertControllerStyleAlert];
	UIAlertAction* okButton = [UIAlertAction
				actionWithTitle:@"OK"
						  style:UIAlertActionStyleDefault
						handler:^(UIAlertAction * action){
							//
						}];
	[alert addAction:okButton];
	[self presentViewController:alert animated:YES completion:nil];
}

-(void)showPayPal{
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=YFSWZBQM8V3C8"] options:@{} completionHandler:nil];
}

-(void)showFontSelection{
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://iosfonts.com"] options:@{} completionHandler:nil];
}

-(void)printInfo{
	CGSize screenSize = [UIScreen mainScreen].bounds.size;
    double screenHeight = screenSize.height;
    double screenWidth = screenSize.width;
	NSString *message = [NSString stringWithFormat:@"Your screen height is: '%.1f' and the width is: '%.1f'!\nYour resolution is: '%.1f'x'%.1f'!", screenHeight, screenWidth, screenHeight*2, screenWidth*2];

	UIAlertController * alert = [UIAlertController
            alertControllerWithTitle:@"AlwaysRemindMe: INFO"
                             message:message
                      preferredStyle:UIAlertControllerStyleAlert];
	UIAlertAction* okButton = [UIAlertAction
                    actionWithTitle:@"OK"
                              style:UIAlertActionStyleDefault
                            handler:^(UIAlertAction * action){
                            }];
	[alert addAction:okButton];
	[self presentViewController:alert animated:YES completion:nil];

}

-(void)respring{
	if ([[NSFileManager defaultManager] fileExistsAtPath:@"/var/lib/dpkg/info/ch.leroyb.alwaysremindme.list"]){
		pid_t pid;
		int status;
		const char* argv[] ={"killall", "SpringBoard", NULL};
		posix_spawn(&pid, "/usr/bin/killall", NULL, NULL, (char* const*)argv, NULL);
		waitpid(pid, &status, WEXITED);
	} else {
		UIAlertController *alert=   [UIAlertController
								alertControllerWithTitle:@"AlwaysRemindMe: PIRACY"
								message:@"Piracy hurts :(\nyou have to wait 15sec!"
								preferredStyle:UIAlertControllerStyleAlert];
								[self presentViewController:alert animated:YES completion:nil];

		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(15.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
			[alert dismissViewControllerAnimated:YES completion:^{
				pid_t pid;
				int status;
				const char* argv[] ={"killall", "SpringBoard", NULL};
				posix_spawn(&pid, "/usr/bin/killall", NULL, NULL, (char* const*)argv, NULL);
				waitpid(pid, &status, WEXITED);
			}];
		});

	}
}

@end //ARMRootListController

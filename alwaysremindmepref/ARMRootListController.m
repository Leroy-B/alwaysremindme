#include "ARMRootListController.h"
#include <spawn.h>
#include <signal.h>

@implementation ARMRootListController

	- (NSArray *)specifiers {
		if (!_specifiers) {
			_specifiers = [[self loadSpecifiersFromPlistName:@"Root" target:self] retain];
		}

		return _specifiers;
	}

	- (id)readPreferenceValue:(PSSpecifier*)specifier {
		NSString *path = [NSString stringWithFormat:@"/private/var/mobile/Library/Preferences/%@.plist", [specifier properties][@"defaults"]];
		NSMutableDictionary *settings = [NSMutableDictionary dictionary];
		[settings addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:path]];
		return (settings[[specifier properties][@"key"]]) ?: [specifier properties][@"default"];
	}

	- (void)setPreferenceValue:(id)value specifier:(PSSpecifier*)specifier {

		// if ([[specifier properties][@"key"] isEqualToString:@"posPrefY"]) {
		//
		// 	  NSScanner *scanner = [NSScanner scannerWithString:value];
		// 	  float f;
		// 	  BOOL isNumber = [scanner scanFloat:&f] && [scanner isAtEnd];
		//
		// 	  if (!isNumber && [value length]) {
		// 					UIAlertController * alert = [UIAlertController
		// 											alertControllerWithTitle:@"CustomCC: ERROR"
		// 																			 message:@"The value for your custom 'y position' has to be numeric!"
		// 																preferredStyle:UIAlertControllerStyleAlert];
		// 					UIAlertAction* okButton = [UIAlertAction
		// 													actionWithTitle:@"OK"
		// 																		style:UIAlertActionStyleDefault
		// 																	handler:^(UIAlertAction * action) {
		// 												//
		// 										  }];
		// 					[alert addAction:okButton];
		// 					[self presentViewController:alert animated:YES completion:nil];
		// 					return;
		// 	  }
		// }

		NSString *path = [NSString stringWithFormat:@"/private/var/mobile/Library/Preferences/%@.plist", [specifier properties][@"defaults"]];
		NSMutableDictionary *settings = [NSMutableDictionary dictionary];
		[settings addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:path]];
		[settings setObject:value forKey: [specifier properties][@"key"]];
		[settings writeToFile:path atomically:YES];
		CFStringRef notificationName = (CFStringRef)[specifier properties][@"PostNotification"];
		if (notificationName) {
			CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), notificationName, NULL, NULL, YES);
		}
	}

	-(void)viewDidLoad {

		//Adds GitHub button in top right of preference pane
		UIImage *dismissKB = [[UIImage alloc] initWithContentsOfFile:@"/Library/PreferenceBundles/AlwaysRemindMePref.bundle/dismissKB.png"];
		dismissKB = [dismissKB imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
		UIBarButtonItem *dismissButton = [[UIBarButtonItem alloc]
							   initWithImage:dismissKB
							   style:UIBarButtonItemStylePlain
                               target:self
                               action:@selector(dismissButtonAction)];

		self.navigationItem.rightBarButtonItem = dismissButton;
		//self.navigationItem.centerBarButtonItem = dismissButton;

		[dismissButton release];
		[super viewDidLoad];

		//Adds GitHub button in top right of preference pane
		// UIImage *dismissKB = [[UIImage alloc] initWithContentsOfFile:@"/Library/PreferenceBundles/AlwaysRemindMePref.bundle/dismissKB.png"];
		// dismissKB = [dismissKB imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
		UIBarButtonItem *repringButton = [[UIBarButtonItem alloc]
							   initWithImage:nil
							   style:UIBarButtonItemStylePlain
                               target:self
                               action:@selector(respring)];

		self.navigationItem.leftBarButtonItem = repringButton;
		//self.navigationItem.centerBarButtonItem = dismissButton;

		[repringButton release];
		[super viewDidLoad];

	}

	-(IBAction)dismissButtonAction {
		[self.view endEditing:YES];
	}

	// -(void)showDatePicker {
	// 	self.datePicker = [[UIDatePicker alloc] initWithFrame:CGRectZero];
	// 	[self.datePicker setDatePickerMode:UIDatePickerModeDate];
	// 	[self.datePicker addTarget:self action:@selector(onDatePickerValueChanged:) forControlEvents:UIControlEventValueChanged];
	// }
	//
	// - (void)onDatePickerValueChanged:(UIDatePicker *)datePicker {
	//     self.textField.text = [self.dateFormatter stringFromDate:datePicker.date];
	// }

	-(void)showTwitter {
		if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitter://"]]) [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"twitter://user?screen_name=IDEK_a_Leroy"] options:@{} completionHandler:nil];
		else [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://twitter.com/IDEK_a_Leroy"] options:@{} completionHandler:nil];
	}

	-(void)showReddit {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.reddit.com/user/IDEK_a_Leroy"] options:@{} completionHandler:nil];
	}

	-(void)showSourceCode {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://github.com/Leroy-B/alwaysremindme"] options:@{} completionHandler:nil];
	}

	-(void)showBitcoin {
		UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
		pasteboard.string = @"1EZATpr8i4N5XaR9bfCwPHAK6DB2s19uwN";
		UIAlertController * alert = [UIAlertController
				alertControllerWithTitle:@"AlwaysRemindMe: INFO"
								 message:@"My Bitcon address has been copied to your clipboard, all you have to do is paste it. Thank you for your donation! :)"
						  preferredStyle:UIAlertControllerStyleAlert];
		UIAlertAction* okButton = [UIAlertAction
					actionWithTitle:@"OK"
							  style:UIAlertActionStyleDefault
							handler:^(UIAlertAction * action) {
								//
							}];
		[alert addAction:okButton];
		[self presentViewController:alert animated:YES completion:nil];
	}

	-(void)showMonero {
		UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
		pasteboard.string = @"42jBMo7NpyYUoPU3qdu7x6cntT3ez2da5TxKTwZVX9eZfwBA6XzeQEFcTxBukNUYyaGtgvdKtLyz72udsnRo3hFhLYPo37L";
		UIAlertController * alert = [UIAlertController
				alertControllerWithTitle:@"AlwaysRemindMe: INFO"
								 message:@"My Monero address has been copied to your clipboard, all you have to do is paste it. Thank you for your donation! :)"
						  preferredStyle:UIAlertControllerStyleAlert];
		UIAlertAction* okButton = [UIAlertAction
					actionWithTitle:@"OK"
							  style:UIAlertActionStyleDefault
							handler:^(UIAlertAction * action) {
								//
							}];
		[alert addAction:okButton];
		[self presentViewController:alert animated:YES completion:nil];
	}

	-(void)showPayPal {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=YFSWZBQM8V3C8"] options:@{} completionHandler:nil];
	}

	-(void)showFontSelection {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://iosfonts.com"] options:@{} completionHandler:nil];
	}

	-(void)printInfo {
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
	                            handler:^(UIAlertAction * action) {
	                                //
	                            }];
		[alert addAction:okButton];
		[self presentViewController:alert animated:YES completion:nil];

	}

	-(void)respring {
		if ([[NSFileManager defaultManager] fileExistsAtPath:@"/var/lib/dpkg/info/com.leroy.alwaysremindme.list"]){//TODO change me
			pid_t pid;
			int status;
			const char* argv[] = {"killall", "SpringBoard", NULL};
			posix_spawn(&pid, "/usr/bin/killall", NULL, NULL, (char* const*)argv, NULL);
			waitpid(pid, &status, WEXITED);
		} else {
			UIAlertController *alert=   [UIAlertController
									alertControllerWithTitle:@"AlwaysRemindMe: PIRACY"
									message:@"it hurts :(\nyou have to wait 15sec!"
									preferredStyle:UIAlertControllerStyleAlert];
									[self presentViewController:alert animated:YES completion:nil];

			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(15.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
				[alert dismissViewControllerAnimated:YES completion:^{
					pid_t pid;
					int status;
					const char* argv[] = {"killall", "SpringBoard", NULL};
					posix_spawn(&pid, "/usr/bin/killall", NULL, NULL, (char* const*)argv, NULL);
					waitpid(pid, &status, WEXITED);
				}];
			});

		}
	}

@end

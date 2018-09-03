#include "ARMRootListController.h"
#include <spawn.h>
#include <signal.h>


@interface ARMLabelsListController : PSListController
@end

@implementation ARMLabelsListController

	- (NSMutableArray *)specifiers {
		if (!_specifiers) {
			_specifiers = [[self loadSpecifiersFromPlistName:@"Labels" target:self] retain];
		}
		return _specifiers;
	}

	-(NSArray *)labelTitles:(id)target {
		NSMutableArray *resultArray = [[NSMutableArray alloc] init];
		NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.leroy.AlwaysRemindMePref.plist"];
	    if(prefs){
			NSLog(@"AlwaysRemindMe LOG: pfTextLabel: %@", [[prefs objectForKey:@"pfTextLabel"] description]);
			[resultArray addObject:[[prefs objectForKey:@"pfTextLabel"] description]];
		}
	    return resultArray;
	}

@end //ARMLabelsListController


@interface ARMEditLabelListController : ARMRootListController
@end

@implementation ARMEditLabelListController

	- (NSMutableArray *)specifiers {
		if (!_specifiers) {
			_specifiers = [[self loadSpecifiersFromPlistName:@"EditLabel" target:self] retain];
		}

		return _specifiers;
	}

	-(void)viewDidLoad {

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


		// UIBarButtonItem *respringButton = [[UIBarButtonItem alloc]
		// 					   initWithTitle:@"Respring"
		// 					   style:UIBarButtonItemStylePlain
        //                        target:self
        //                        action:@selector(respring)];
		//
		// self.navigationItem.leftBarButtonItem = respringButton;
		// //self.navigationItem.centerBarButtonItem = dismissButton;
		//
		// [respringButton release];
		// [super viewDidLoad];

	}

	-(IBAction)dismissButtonAction {
		[self.view endEditing:YES];
	}

	-(void)showDatePicker {

		UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Choose a time to be reminded at!\n\n\n\n\n\n\n\n\n\n\n" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
		UIDatePicker *picker = [[UIDatePicker alloc] init];
		[picker setDatePickerMode:UIDatePickerModeTime];
		// [picker setDateFormat:@"HH:mm:ss"];
		[alertController.view addSubview:picker];
		[alertController addAction:({
		    UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
		        NSLog(@"%@",picker.date);
				NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
				[outputFormatter setDateFormat:@"HH:mm:ss"];
				NSString *newDateString = [outputFormatter stringFromDate:picker.date];
				NSLog(@"newDateString %@", newDateString);
				[outputFormatter release];
		    }];
		    action;
		})];
		UIPopoverPresentationController *popoverController = alertController.popoverPresentationController;
		popoverController.sourceView = self.view;
		popoverController.sourceRect = [self.view bounds];
		[self presentViewController:alertController  animated:YES completion:nil];

	}


@end //ARMEditLabelListController


@implementation ARMRootListController

	- (NSMutableArray *)specifiers {
		if (!_specifiers) {
			_specifiers = [[self loadSpecifiersFromPlistName:@"Root" target:self] retain];
		}

		return _specifiers;
	}


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
		if ([[NSFileManager defaultManager] fileExistsAtPath:@"/var/lib/dpkg/info/com.leroy.alwaysremindme.list"]){
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

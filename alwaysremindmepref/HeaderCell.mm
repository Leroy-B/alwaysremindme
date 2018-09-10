#import <AVFoundation/AVFoundation.h>
#import "HeaderCell.h"

@implementation PFHeaderCell

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

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(id)identifier specifier:(PSSpecifier *)specifier {
	self = [super initWithStyle:style reuseIdentifier:identifier specifier:specifier];

	[self prepareHeaderImage:specifier];
	[self applyHeaderImage];

	return self;
}

- (void)prepareHeaderImage:(PSSpecifier *)specifier {
	headerImageViewContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
	headerImageViewContainer.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		headerImageViewContainer.layer.cornerRadius = 5;
	}

	CGSize screenSize = [UIScreen mainScreen].bounds.size;
	CGFloat screenWidth = screenSize.width;

 	if(specifier.properties[@"image"] && specifier.properties[@"background"]) {
		NSString *stringVideoPath = [[NSBundle bundleWithPath:@"/Library/PreferenceBundles/AlwaysRemindMePref.bundle"] pathForResource:specifier.properties[@"image"] ofType:@"mp4"];
		NSURL *url = [NSURL fileURLWithPath:stringVideoPath];
		AVPlayer *player = [AVPlayer playerWithURL:url];
		AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:player];
		playerLayer.frame = CGRectMake(0,0,screenWidth,100);
		[player play];
		player.actionAtItemEnd = AVPlayerActionAtItemEndNone;

		[[NSNotificationCenter defaultCenter]
					addObserver:self
					   selector:@selector(playerItemDidReachEnd:)
						   name:AVPlayerItemDidPlayToEndTimeNotification
						 object:[player currentItem]];

		headerImageViewContainer.backgroundColor = [PFHeaderCell colorFromHex:specifier.properties[@"background"]];
		[headerImageViewContainer.layer addSublayer:playerLayer];
	}
}

- (void)applyHeaderImage {
	[self addSubview:headerImageViewContainer];
}

- (void)playerItemDidReachEnd:(NSNotification *)notification {
	    AVPlayerItem *p = [notification object];
	    [p seekToTime:kCMTimeZero completionHandler: nil];
	}

@end

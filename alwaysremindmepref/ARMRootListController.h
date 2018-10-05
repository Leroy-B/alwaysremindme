#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>

@interface ARMRootListController : PSListController
-(id)specifiers;
-(id)readPreferenceValue:(PSSpecifier *)specifier;
-(void)setPreferenceValue:(id)value specifier:(PSSpecifier *)specifier;
-(void)setContentOffset:(CGPoint)value;
@end

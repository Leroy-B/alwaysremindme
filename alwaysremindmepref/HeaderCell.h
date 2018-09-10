#import <Preferences/PSTableCell.h>
//
// @interface HeaderCell : PSTableCell{
// 	UIImageView *_background;
// }
// @end

@interface PFHeaderCell : PSTableCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(id)identifier specifier:(PSSpecifier *)specifier;

@end

@interface PSSpecifier : NSObject {
@public
	id target;
	SEL getter;
	SEL setter;
	SEL action;
	Class detailControllerClass;
	PSCellType cellType;
	Class editPaneClass;
	UIKeyboardType keyboardType;
	UITextAutocapitalizationType autoCapsType;
	UITextAutocorrectionType autoCorrectionType;
	int textFieldType;
@private
	NSString* _name;
	NSArray* _values;
	NSDictionary* _titleDict;
	NSDictionary* _shortTitleDict;
	id _userInfo;
	NSMutableDictionary* _properties;
}
@property(retain) NSMutableDictionary* properties;
@property(retain) NSString* name;
@property(retain) id userInfo;
@property(retain) id titleDictionary;
@property(retain) id shortTitleDictionary;
@property(retain) NSArray* values;
+(id)preferenceSpecifierNamed:(NSString*)title target:(id)target set:(SEL)set get:(SEL)get detail:(Class)detail cell:(PSCellType)cell edit:(Class)edit;
+(PSSpecifier*)groupSpecifierWithName:(NSString*)title;
+(PSSpecifier*)emptyGroupSpecifier;
+(UITextAutocapitalizationType)autoCapsTypeForString:(PSSpecifier*)string;
+(UITextAutocorrectionType)keyboardTypeForString:(PSSpecifier*)string;
-(id)propertyForKey:(NSString*)key;
-(void)setProperty:(id)property forKey:(NSString*)key;
-(void)removePropertyForKey:(NSString*)key;
-(void)loadValuesAndTitlesFromDataSource;
-(void)setValues:(NSArray*)values titles:(NSArray*)titles;
-(void)setValues:(NSArray*)values titles:(NSArray*)titles shortTitles:(NSArray*)shortTitles;
-(void)setupIconImageWithPath:(NSString*)path;
-(NSString*)identifier;
-(void)setTarget:(id)target;
-(void)setKeyboardType:(UIKeyboardType)type autoCaps:(UITextAutocapitalizationType)autoCaps autoCorrection:(UITextAutocorrectionType)autoCorrection;
@end


@interface PFHeaderCell()
{
	UIView *headerImageViewContainer;
	UIImageView *headerImageView;
}
- (void)prepareHeaderImage:(PSSpecifier *)specifier;
- (void)applyHeaderImage;
+ (UIColor *)colorFromHex:(NSString *)hexString;
@end

//
//  RTGridItem.h
//  RTGridView
//
//  Created by ricky on 13-9-14.
//  Copyright (c) 2013年 ricky. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const UITextAttributeBackgroundColor;

@interface RTGridItem : NSObject
@property (nonatomic, readonly, getter = isEditing) BOOL editing;
@property (nonatomic, readonly) CGSize size;
@property (nonatomic, readonly, retain) UIView *customView;

+ (id)gridItemWithTitle:(NSString*)title;
+ (id)gridItemWithTitle:(NSString *)title textAttribute:(NSDictionary*)attribute;
+ (id)gridItemWithImage:(UIImage*)image;
+ (id)gridItemWithCustomView:(UIView*)customView;

- (id)initWithTitle:(NSString*)title;
- (id)initWithTitle:(NSString *)title textAttribute:(NSDictionary*)attribute;
- (id)initWithImage:(UIImage*)image;
- (id)initWithCustomeView:(UIView*)customView;

@end

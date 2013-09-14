//
//  RTGridItem.m
//  RTGridView
//
//  Created by ricky on 13-9-14.
//  Copyright (c) 2013年 ricky. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "RTGridItem.h"

NSString *const UITextAttributeBackgroundColor = @"UITextAttributeBackgroundColor";

@implementation RTGridItem

+ (id)gridItemWithCustomView:(UIView *)customView
{
    return [[[self alloc] initWithCustomeView:customView] autorelease];
}

+ (id)gridItemWithImage:(UIImage *)image
{
    return [[[self alloc] initWithImage:image] autorelease];
}

+ (id)gridItemWithTitle:(NSString *)title
{
    return [[[self alloc] initWithTitle:title] autorelease];
}

+ (id)gridItemWithTitle:(NSString *)title textAttribute:(NSDictionary *)attribute
{
    return [[[self alloc] initWithTitle:title
                          textAttribute:attribute] autorelease];
}

- (void)dealloc
{
    [_customView release];
    [super dealloc];
}

- (id)initWithImage:(UIImage *)image
{
    UIImageView *imageView = [[[UIImageView alloc] initWithImage:image] autorelease];
    return [self initWithCustomeView:imageView];
}

- (id)initWithTitle:(NSString *)title
{
    return [self initWithTitle:title
                 textAttribute:nil];
}

- (id)initWithTitle:(NSString *)title textAttribute:(NSDictionary *)attribute
{
    UILabel *label = [[[UILabel alloc] init] autorelease];
    label.text = title;
    
    if ([attribute objectForKey:UITextAttributeTextColor])
        label.textColor = [attribute objectForKey:UITextAttributeTextColor];
    else
        label.textColor = [UIColor whiteColor];
    
    if ([attribute objectForKey:UITextAttributeFont])
        label.font = [attribute objectForKey:UITextAttributeFont];
    else
        label.font = [UIFont systemFontOfSize:14];
    
    if ([attribute objectForKey:UITextAttributeTextShadowColor])
        label.shadowColor = [attribute objectForKey:UITextAttributeTextShadowColor];
    
    if ([attribute objectForKey:UITextAttributeTextShadowOffset])
        label.shadowOffset = [[attribute objectForKey:UITextAttributeTextShadowOffset] CGSizeValue];
    
    if ([attribute objectForKey:UITextAttributeBackgroundColor])
        label.backgroundColor = [attribute objectForKey:UITextAttributeBackgroundColor];
    else
        label.backgroundColor = [UIColor colorWithRed:0.4
                                                green:0.4
                                                 blue:1.0
                                                alpha:1.0];
    label.layer.cornerRadius = 2.0f;
    label.textAlignment = NSTextAlignmentCenter;
    [label sizeToFit];
    return [self initWithCustomeView:label];
}

- (id)initWithCustomeView:(UIView *)customView
{
    self = [super init];
    if (self) {
        _customView = [customView retain];
    }
    return self;
}

- (CGSize)size
{
    return self.customView.bounds.size;
}

@end

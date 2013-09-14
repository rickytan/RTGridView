//
//  RTGridLayoutStrategy.m
//  RTGridView
//
//  Created by ricky on 13-9-14.
//  Copyright (c) 2013年 ricky. All rights reserved.
//

#import "RTGridLayoutStrategy.h"


@interface RTGridLayoutStrategyHorizontal : RTGridLayoutStrategy
@property (nonatomic, assign) CGFloat minItemMargin;
@property (nonatomic, assign) CGFloat minLineMargin;
@end

@implementation RTGridLayoutStrategyHorizontal

- (void)layoutItemsOfLine:(NSArray*)items withRect:(CGRect)rect fillLine:(BOOL)flag
{
    if (flag) {
        CGFloat h = 0.0f;
        for (RTGridItem *item in items) {
            h += item.size.height;
        }
        CGFloat margin = (rect.size.height - h) / (items.count - 1);
        CGFloat top = rect.origin.y;
        for (RTGridItem *item in items) {
            CGFloat left = rect.origin.x + (rect.size.width - item.size.width) / 2;
            item.customView.frame = (CGRect){{left, top}, item.size};
            top += item.size.height + margin;
        }
    }
    else {
        CGFloat top = rect.origin.y;
        for (RTGridItem *item in items) {
            CGFloat left = rect.origin.x + (rect.size.width - item.size.width) / 2;
            item.customView.frame = (CGRect){{left, top}, item.size};
            top += item.size.height + self.minItemMargin;
        }
    }
}

- (void)layoutGridItems:(NSArray*)gridItems
                 inRect:(CGRect)rect
             itemMargin:(CGFloat)itemMargin
             lineMargin:(CGFloat)lineMargin
            contentSize:(out CGSize *)size
{
    self.minItemMargin = itemMargin;
    self.minLineMargin = lineMargin;
    
    CGRect contentRect = rect;
    CGFloat topCap = contentRect.origin.y;
    CGFloat leftCap = contentRect.origin.x;
    CGFloat maxHeight = contentRect.size.height;
    
    CGPoint origin = CGPointMake(leftCap, topCap);
    
    CGFloat lineHeight = 0.0f;
    
    NSMutableArray *rowItems = [NSMutableArray array];
    CGSize lastSize = CGSizeZero;
    
    for (int i = 0; i < gridItems.count; ++i) {
        RTGridItem *item = [gridItems objectAtIndex:i];
        CGFloat lastHeight = lineHeight;
        lineHeight = MAX(lineHeight, item.size.width);
        
        if (i) {
            origin.y += itemMargin + lastSize.height;
            
            if (origin.y + item.size.height > maxHeight) {
                
                [self layoutItemsOfLine:rowItems
                               withRect:CGRectMake(origin.x, topCap, lastHeight, maxHeight)
                               fillLine:YES];
                [rowItems removeAllObjects];
                
                origin.y = topCap;
                origin.x += lastHeight + self.minLineMargin;
                lineHeight = item.size.width;
            }
        }
        
        [rowItems addObject:item];
        lastSize = item.size;
    }
    [self layoutItemsOfLine:rowItems
                   withRect:CGRectMake(origin.x, topCap, lineHeight, maxHeight)
                   fillLine:NO];
    [rowItems removeAllObjects];
    
    *size = CGSizeMake(origin.x + lineHeight, maxHeight);
}

- (CGRect)frameForItems:(NSArray*)gridItems atIndex:(NSUInteger)index inRect:(CGRect)rect
{
    CGRect contentRect = rect;
    CGFloat topCap = contentRect.origin.y;
    CGFloat leftCap = contentRect.origin.x;
    CGFloat maxHeight = contentRect.size.height;
    
    CGPoint origin = CGPointMake(leftCap, topCap);
    
    CGFloat lineHeight = 0.0f;
    
    CGSize lastSize = CGSizeZero;
    for (int i = 0; i <= index; ++i) {
        RTGridItem *item = [gridItems objectAtIndex:i];
        lineHeight = MAX(lineHeight, item.size.width);
        
        if (i) {
            origin.y += self.minItemMargin + lastSize.height;
            
            if (origin.y + item.size.height > maxHeight) {
                origin.y = topCap;
                origin.x += lineHeight + self.minLineMargin;
                lineHeight = item.size.width;
            }
        }
        lastSize = item.size;
    }
    origin.x += (lineHeight - lastSize.width) / 2;
    
    return (CGRect){origin, lastSize};
}
@end


@interface RTGridLayoutStrategyVertical : RTGridLayoutStrategy
@property (nonatomic, assign) CGFloat minItemMargin;
@property (nonatomic, assign) CGFloat minLineMargin;
@end

@implementation RTGridLayoutStrategyVertical

- (void)layoutItemsOfLine:(NSArray*)items withRect:(CGRect)rect fillLine:(BOOL)flag
{
    if (flag) {
        CGFloat w = 0.0f;
        for (RTGridItem *item in items) {
            w += item.size.width;
        }
        CGFloat margin = (rect.size.width - w) / (items.count - 1);
        CGFloat left = rect.origin.x;
        for (RTGridItem *item in items) {
            CGFloat top = rect.origin.y + (rect.size.height - item.size.height) / 2;
            item.customView.frame = (CGRect){{left, top}, item.size};
            left += item.size.width + margin;
        }
    }
    else {
        CGFloat left = rect.origin.x;
        for (RTGridItem *item in items) {
            CGFloat top = rect.origin.y + (rect.size.height - item.size.height) / 2;
            item.customView.frame = (CGRect){{left, top}, item.size};
            left += item.size.width + self.minItemMargin;
        }
    }
}

- (void)layoutGridItems:(NSArray*)gridItems
                 inRect:(CGRect)rect
             itemMargin:(CGFloat)itemMargin
             lineMargin:(CGFloat)lineMargin
            contentSize:(out CGSize *)size
{
    self.minItemMargin = itemMargin;
    self.minLineMargin = lineMargin;
    
    CGRect contentRect = rect;
    CGFloat topCap = contentRect.origin.y;
    CGFloat leftCap = contentRect.origin.x;
    CGFloat maxWidth = contentRect.size.width;
    
    CGPoint origin = CGPointMake(leftCap, topCap);
    
    CGFloat lineHeight = 0.0f;
    
    NSMutableArray *rowItems = [NSMutableArray array];
    CGSize lastSize = CGSizeZero;
    
    for (int i = 0; i < gridItems.count; ++i) {
        RTGridItem *item = [gridItems objectAtIndex:i];
        CGFloat lastHeight = lineHeight;
        lineHeight = MAX(lineHeight, item.size.height);
        
        if (i) {
            origin.x += self.minItemMargin + lastSize.width;
            
            if (origin.x + item.size.width > maxWidth) {
                
                [self layoutItemsOfLine:rowItems
                               withRect:CGRectMake(leftCap, origin.y, maxWidth, lastHeight)
                               fillLine:YES];
                [rowItems removeAllObjects];
                
                origin.x = leftCap;
                origin.y += lastHeight + self.minLineMargin;
                lineHeight = item.size.height;
            }
        }
        
        [rowItems addObject:item];
        lastSize = item.size;
    }
    
    [self layoutItemsOfLine:rowItems
                   withRect:CGRectMake(leftCap, origin.y, maxWidth, lineHeight)
                   fillLine:NO];
    [rowItems removeAllObjects];
    
    *size = CGSizeMake(maxWidth, origin.y + lineHeight);
}

- (CGRect)frameForItems:(NSArray*)gridItems
                atIndex:(NSUInteger)index
                 inRect:(CGRect)rect
{
    CGRect contentRect = rect;
    CGFloat topCap = contentRect.origin.y;
    CGFloat leftCap = contentRect.origin.x;
    CGFloat maxWidth = contentRect.size.width;
    
    CGPoint origin = CGPointMake(leftCap, topCap);
    
    CGFloat lineHeight = 0.0f;
    
    CGSize lastSize = CGSizeZero;
    for (int i = 0; i <= index; ++i) {
        RTGridItem *item = [gridItems objectAtIndex:i];
        lineHeight = MAX(lineHeight, item.size.height);
        
        if (i) {
            origin.x += self.minItemMargin + lastSize.width;
            
            if (origin.x + item.size.width > maxWidth) {
                origin.x = leftCap;
                origin.y += lineHeight + self.minLineMargin;
                lineHeight = item.size.height;
            }
        }
        lastSize = item.size;
    }
    origin.y += (lineHeight - lastSize.height) / 2;
    
    return (CGRect){origin, lastSize};
}

@end



@implementation RTGridLayoutStrategy

+ (id)gridLayoutStrategyWithLayoutType:(RTGridViewLayoutType)type
{
    if (type == RTGridViewLayoutTypeHorizontal)
        return [[RTGridLayoutStrategyHorizontal class] gridLayoutStrategy];
    else if (type == RTGridViewLayoutTypeVertical)
        return [[RTGridLayoutStrategyVertical class] gridLayoutStrategy];
    return nil;
}

+ (id)gridLayoutStrategy
{
    return [[[self alloc] init] autorelease];
}

- (void)layoutGridItems:(NSArray *)gridItems inRect:(CGRect)rect itemMargin:(CGFloat)itemMargin lineMargin:(CGFloat)lineMargin contentSize:(out CGSize *)size
{
    NSAssert(NO, @"Override me !!!");
}

- (CGRect)frameForItems:(NSArray *)gridItems atIndex:(NSUInteger)index inRect:(CGRect)rect
{
    NSAssert(NO, @"Override me !!!");
    return CGRectNull;
}

@end
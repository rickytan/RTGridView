//
//  RTGridLayoutStrategy.m
//  RTGridView
//
//  Created by ricky on 13-9-14.
//  Copyright (c) 2013年 ricky. All rights reserved.
//

#import "RTGridLayoutStrategy.h"


static CGRect CGRectMakeWithCenterAndSize(CGPoint center, CGSize size)
{
    return CGRectMake(center.x - size.width / 2, center.y - size.height / 2, size.width, size.height);
}


@interface RTGridLayoutStrategyHorizontalTight : RTGridLayoutStrategy
@end


@interface RTGridLayoutStrategyVerticalTight : RTGridLayoutStrategy
@end


@interface RTGridLayoutStrategyHorizontalEven : RTGridLayoutStrategy
@end

@interface RTGridLayoutStrategyVerticalEven : RTGridLayoutStrategy
@end

@implementation RTGridLayoutStrategyHorizontalTight

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
            contentSize:(out CGSize *)size
{
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
            origin.y += self.minItemMargin + lastSize.height;
            
            if (origin.y + item.size.height > maxHeight) {
                
                [self layoutItemsOfLine:rowItems
                               withRect:CGRectMake(origin.x, topCap, lastHeight, maxHeight)
                               fillLine:YES];
                [rowItems removeAllObjects];
                
                origin.y = topCap;
                origin.x += lastHeight + self.lineMargin;
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
                origin.x += lineHeight + self.lineMargin;
                lineHeight = item.size.width;
            }
        }
        lastSize = item.size;
    }
    origin.x += (lineHeight - lastSize.width) / 2;
    
    return (CGRect){origin, lastSize};
}
@end



@implementation RTGridLayoutStrategyVerticalTight

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
            contentSize:(out CGSize *)size
{
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
                origin.y += lastHeight + self.lineMargin;
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
                origin.y += lineHeight + self.lineMargin;
                lineHeight = item.size.height;
            }
        }
        lastSize = item.size;
    }
    origin.y += (lineHeight - lastSize.height) / 2;
    
    return (CGRect){origin, lastSize};
}

@end


@implementation RTGridLayoutStrategyHorizontalEven

- (void)layoutGridItems:(NSArray *)gridItems inRect:(CGRect)rect contentSize:(out CGSize *)size
{
    CGRect contentRect = rect;
    CGFloat topCap = contentRect.origin.y;
    CGFloat leftCap = contentRect.origin.x;
    CGFloat maxHeight = contentRect.size.height;
    
    
    NSInteger rowsPerCol = (NSInteger)floorf((maxHeight - self.itemSize.height) / (self.minItemMargin + self.itemSize.height)) + 1;

    CGFloat margin = (maxHeight - self.itemSize.height) / (rowsPerCol - 1) - self.itemSize.height;
    
    
    for (int i = 0; i < gridItems.count; ++i) {
        NSInteger col = i / rowsPerCol;
        NSInteger row = i % rowsPerCol;

        CGPoint origin = CGPointMake(leftCap + col * (self.itemSize.width + self.lineMargin),
                                     topCap + row * (self.itemSize.height + margin));
        RTGridItem *item = [gridItems objectAtIndex:i];
        item.customView.frame = (CGRect){origin, self.itemSize};
    }
    
    *size = CGSizeMake(leftCap + self.itemSize.width + (gridItems.count - 1) / rowsPerCol * (self.itemSize.width + self.lineMargin), maxHeight);
}

- (CGRect)frameForItems:(NSArray *)gridItems
                atIndex:(NSUInteger)index
                 inRect:(CGRect)rect
{
    CGRect contentRect = rect;
    CGFloat topCap = contentRect.origin.y;
    CGFloat leftCap = contentRect.origin.x;
    CGFloat maxHeight = contentRect.size.height;
    
    
    NSInteger rowsPerCol = (NSInteger)floorf((maxHeight - self.itemSize.height) / (self.minItemMargin + self.itemSize.height)) + 1;
    CGFloat margin = (maxHeight - self.itemSize.height) / (rowsPerCol - 1) - self.itemSize.height;
    NSInteger col = index / rowsPerCol;
    NSInteger row = index % rowsPerCol;
    
    CGPoint origin = CGPointMake(leftCap + col * (self.itemSize.width + self.lineMargin),
                                 topCap + row * (self.itemSize.height + margin));
    
    return (CGRect){origin, self.itemSize};
}

@end

@implementation RTGridLayoutStrategyVerticalEven

- (void)layoutGridItems:(NSArray *)gridItems inRect:(CGRect)rect contentSize:(out CGSize *)size
{
    CGRect contentRect = rect;
    CGFloat topCap = contentRect.origin.y;
    CGFloat leftCap = contentRect.origin.x;
    CGFloat maxWidth = contentRect.size.width;
    
    
    NSInteger colsPerRow = (NSInteger)floorf((maxWidth - self.itemSize.width) / (self.minItemMargin + self.itemSize.width)) + 1;
    CGFloat margin = (maxWidth - self.itemSize.width) / (colsPerRow - 1) - self.itemSize.width;
    
    
    for (int i = 0; i < gridItems.count; ++i) {
        NSInteger col = i % colsPerRow;
        NSInteger row = i / colsPerRow;
        
        CGPoint origin = CGPointMake(leftCap + col * (self.itemSize.width + margin),
                                     topCap + row * (self.itemSize.height + self.lineMargin));
        RTGridItem *item = [gridItems objectAtIndex:i];
        item.customView.frame = (CGRect){origin, self.itemSize};
    }
    
    *size = CGSizeMake(maxWidth, topCap + self.itemSize.height + (gridItems.count - 1) / colsPerRow * (self.itemSize.height + self.lineMargin));
}

- (CGRect)frameForItems:(NSArray *)gridItems
                atIndex:(NSUInteger)index
                 inRect:(CGRect)rect
{
    CGRect contentRect = rect;
    CGFloat topCap = contentRect.origin.y;
    CGFloat leftCap = contentRect.origin.x;
    CGFloat maxWidth = contentRect.size.width;
    
    
    NSInteger colsPerRow = (NSInteger)floorf((maxWidth - self.itemSize.width) / (self.minItemMargin + self.itemSize.width)) + 1;
    CGFloat margin = (maxWidth - self.itemSize.height) / (colsPerRow - 1) - self.itemSize.width;
    NSInteger col = index % colsPerRow;
    NSInteger row = index / colsPerRow;
    
    CGPoint origin = CGPointMake(leftCap + col * (self.itemSize.width + margin),
                                 topCap + row * (self.itemSize.height + self.lineMargin));
    
    return (CGRect){origin, self.itemSize};
}

@end

@implementation RTGridLayoutStrategy

+ (id)gridLayoutStrategyWithLayoutType:(RTGridViewLayoutType)type
{
    switch (type) {
        case RTGridViewLayoutTypeHorizontalTight:
            return [[RTGridLayoutStrategyHorizontalTight class] gridLayoutStrategy];
        case RTGridViewLayoutTypeVerticalTight:
            return [[RTGridLayoutStrategyVerticalTight class] gridLayoutStrategy];
        case RTGridViewLayoutTypeHorizontalEven:
            return [[RTGridLayoutStrategyHorizontalEven class] gridLayoutStrategy];
        case RTGridViewLayoutTypeVerticalEven:
            return [[RTGridLayoutStrategyVerticalEven class] gridLayoutStrategy];
    }
    return nil;
}

+ (id)gridLayoutStrategy
{
    return [[[self alloc] init] autorelease];
}

- (void)layoutGridItems:(NSArray *)gridItems
                 inRect:(CGRect)rect
            contentSize:(out CGSize *)size
{
    NSAssert(NO, @"Override me !!!");
}

- (CGRect)frameForItems:(NSArray *)gridItems atIndex:(NSUInteger)index inRect:(CGRect)rect
{
    NSAssert(NO, @"Override me !!!");
    return CGRectNull;
}

@end
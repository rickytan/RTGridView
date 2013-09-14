//
//  RTGridLayoutStrategy.m
//  RTGridView
//
//  Created by ricky on 13-9-14.
//  Copyright (c) 2013年 ricky. All rights reserved.
//

#import "RTGridLayoutStrategy.h"
#import "RTGridView.h"

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

- (void)layoutItemsOfLine:(NSArray*)items
                 withRect:(CGRect)rect
                 gridView:(RTGridView*)gridView
                 fillLine:(BOOL)flag
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
            top += item.size.height + gridView.minItemMargin;
        }
    }
}

- (NSArray*)layoutGridItems:(NSArray*)gridItems
               withGridView:(RTGridView *)gridView
{
    CGRect contentRect = UIEdgeInsetsInsetRect(CGRectMake(0, 0, gridView.bounds.size.width, gridView.bounds.size.height), gridView.itemInset);
    CGFloat topCap = contentRect.origin.y;
    CGFloat leftCap = contentRect.origin.x;
    CGFloat maxHeight = contentRect.size.height;
    
    CGPoint origin = CGPointMake(leftCap, topCap);
    
    CGFloat lineHeight = 0.0f;
    
    NSMutableArray *rowItems = [NSMutableArray array];
    CGSize lastSize = CGSizeZero;
    
    NSMutableArray *visibleItems = [NSMutableArray array];
    for (int i = 0; i < gridItems.count; ++i) {
        RTGridItem *item = [gridItems objectAtIndex:i];
        CGFloat lastHeight = lineHeight;
        lineHeight = MAX(lineHeight, item.size.width);
        
        if (i) {
            origin.y += gridView.minItemMargin + lastSize.height;
            
            if (origin.y + item.size.height > maxHeight) {
                CGRect constraintRect = CGRectMake(origin.x, topCap, lastHeight, maxHeight);
                CGRect visibleRect = (CGRect){gridView.contentOffset, gridView.bounds.size};
                if (CGRectContainsRect(visibleRect, constraintRect) ||
                    CGRectIntersectsRect(visibleRect, constraintRect))
                    [visibleItems addObjectsFromArray:rowItems];
                
                [self layoutItemsOfLine:rowItems
                               withRect:constraintRect
                               gridView:gridView
                               fillLine:YES];
                [rowItems removeAllObjects];
                
                origin.y = topCap;
                origin.x += lastHeight + gridView.lineMargin;
                lineHeight = item.size.width;
            }
        }
        
        [rowItems addObject:item];
        lastSize = item.size;
    }
    
    CGRect constraintRect = CGRectMake(origin.x, topCap, lineHeight, maxHeight);
    CGRect visibleRect = (CGRect){gridView.contentOffset, gridView.bounds.size};
    if (CGRectContainsRect(visibleRect, constraintRect) ||
        CGRectIntersectsRect(visibleRect, constraintRect))
        [visibleItems addObjectsFromArray:rowItems];
    
    [self layoutItemsOfLine:rowItems
                   withRect:constraintRect
                   gridView:gridView
                   fillLine:NO];
    [rowItems removeAllObjects];
    
    gridView.contentSize = CGSizeMake(origin.x + lineHeight + gridView.itemInset.right, maxHeight + gridView.itemInset.bottom);
    return [NSArray arrayWithArray:visibleItems];
}

- (CGRect)frameForItems:(NSArray*)gridItems
                atIndex:(NSUInteger)index
           withGridView:(RTGridView *)gridView
{
    CGRect contentRect = UIEdgeInsetsInsetRect(CGRectMake(0, 0, gridView.bounds.size.width, gridView.bounds.size.height), gridView.itemInset);
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
            origin.y += gridView.minItemMargin + lastSize.height;
            
            if (origin.y + item.size.height > maxHeight) {
                origin.y = topCap;
                origin.x += lineHeight + gridView.lineMargin;
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

- (void)layoutItemsOfLine:(NSArray*)items
                 withRect:(CGRect)rect
                 gridView:(RTGridView *)gridView
                 fillLine:(BOOL)flag
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
            left += item.size.width + gridView.minItemMargin;
        }
    }
}

- (NSArray*)layoutGridItems:(NSArray*)gridItems
               withGridView:(RTGridView *)gridView
{
    CGRect contentRect = UIEdgeInsetsInsetRect(CGRectMake(0, 0, gridView.bounds.size.width, gridView.bounds.size.height), gridView.itemInset);
    CGFloat topCap = contentRect.origin.y;
    CGFloat leftCap = contentRect.origin.x;
    CGFloat maxWidth = contentRect.size.width;
    
    CGPoint origin = CGPointMake(leftCap, topCap);
    
    CGFloat lineHeight = 0.0f;
    
    NSMutableArray *rowItems = [NSMutableArray array];
    CGSize lastSize = CGSizeZero;
    
    NSMutableArray *visibleItems = [NSMutableArray array];
    for (int i = 0; i < gridItems.count; ++i) {
        RTGridItem *item = [gridItems objectAtIndex:i];
        CGFloat lastHeight = lineHeight;
        lineHeight = MAX(lineHeight, item.size.height);
        
        if (i) {
            origin.x += gridView.minItemMargin + lastSize.width;
            
            if (origin.x + item.size.width > maxWidth) {
                CGRect constraintRect = CGRectMake(leftCap, origin.y, maxWidth, lastHeight);
                CGRect visibleRect = (CGRect){gridView.contentOffset, gridView.bounds.size};
                if (CGRectContainsRect(visibleRect, constraintRect) ||
                    CGRectIntersectsRect(visibleRect, constraintRect))
                    [visibleItems addObjectsFromArray:rowItems];
                
                [self layoutItemsOfLine:rowItems
                               withRect:constraintRect
                               gridView:gridView
                               fillLine:YES];
                [rowItems removeAllObjects];
                
                origin.x = leftCap;
                origin.y += lastHeight + gridView.lineMargin;
                lineHeight = item.size.height;
            }
        }
        
        [rowItems addObject:item];
        lastSize = item.size;
    }
    
    CGRect constraintRect = CGRectMake(leftCap, origin.y, maxWidth, lineHeight);

    CGRect visibleRect = (CGRect){gridView.contentOffset, gridView.bounds.size};
    if (CGRectContainsRect(visibleRect, constraintRect) ||
        CGRectIntersectsRect(visibleRect, constraintRect))
        [visibleItems addObjectsFromArray:rowItems];
    
    [self layoutItemsOfLine:rowItems
                   withRect:constraintRect
                   gridView:gridView
                   fillLine:NO];
    [rowItems removeAllObjects];
    
    gridView.contentSize = CGSizeMake(maxWidth + gridView.itemInset.right,
                                      origin.y + lineHeight + gridView.itemInset.bottom);
    return [NSArray arrayWithArray:visibleItems];
}

- (CGRect)frameForItems:(NSArray*)gridItems
                atIndex:(NSUInteger)index
           withGridView:(RTGridView *)gridView
{
    CGRect contentRect = UIEdgeInsetsInsetRect(CGRectMake(0, 0, gridView.bounds.size.width, gridView.bounds.size.height), gridView.itemInset);
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
            origin.x += gridView.minItemMargin + lastSize.width;
            
            if (origin.x + item.size.width > maxWidth) {
                origin.x = leftCap;
                origin.y += lineHeight + gridView.lineMargin;
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

- (NSArray*)layoutGridItems:(NSArray *)gridItems
               withGridView:(RTGridView *)gridView
{
    CGRect contentRect = UIEdgeInsetsInsetRect(CGRectMake(0, 0, gridView.bounds.size.width, gridView.bounds.size.height), gridView.itemInset);
    CGFloat topCap = contentRect.origin.y;
    CGFloat leftCap = contentRect.origin.x;
    CGFloat maxHeight = contentRect.size.height;
    
    
    NSInteger rowsPerCol = (NSInteger)floorf((maxHeight - gridView.itemSize.height) / (gridView.minItemMargin + gridView.itemSize.height)) + 1;

    CGFloat margin = (maxHeight - gridView.itemSize.height) / (rowsPerCol - 1) - gridView.itemSize.height;
    
    NSMutableArray *visibleItems = [NSMutableArray array];
    for (int i = 0; i < gridItems.count; ++i) {
        NSInteger col = i / rowsPerCol;
        NSInteger row = i % rowsPerCol;

        CGPoint origin = CGPointMake(leftCap + col * (gridView.itemSize.width + gridView.lineMargin),
                                     topCap + row * (gridView.itemSize.height + margin));
        RTGridItem *item = [gridItems objectAtIndex:i];
        item.customView.frame = (CGRect){origin, gridView.itemSize};
        UIScrollView *scroll = (UIScrollView*)item.customView.superview;
        CGRect visibleRect = (CGRect){scroll.contentOffset, scroll.bounds.size};
        if (CGRectContainsRect(visibleRect, item.customView.frame) ||
            CGRectIntersectsRect(visibleRect, item.customView.frame))
            [visibleItems addObject:item];
    }
    
    gridView.contentSize = CGSizeMake(leftCap + gridView.itemSize.width + (gridItems.count - 1) / rowsPerCol * (gridView.itemSize.width + gridView.lineMargin) + gridView.itemInset.right, maxHeight + gridView.itemInset.bottom);
    return [NSArray arrayWithArray:visibleItems];
}

- (CGRect)frameForItems:(NSArray *)gridItems
                atIndex:(NSUInteger)index
           withGridView:(RTGridView *)gridView
{
    CGRect contentRect = UIEdgeInsetsInsetRect(CGRectMake(0, 0, gridView.bounds.size.width, gridView.bounds.size.height), gridView.itemInset);
    CGFloat topCap = contentRect.origin.y;
    CGFloat leftCap = contentRect.origin.x;
    CGFloat maxHeight = contentRect.size.height;
    
    
    NSInteger rowsPerCol = (NSInteger)floorf((maxHeight - gridView.itemSize.height) / (gridView.minItemMargin + gridView.itemSize.height)) + 1;
    CGFloat margin = (maxHeight - gridView.itemSize.height) / (rowsPerCol - 1) - gridView.itemSize.height;
    NSInteger col = index / rowsPerCol;
    NSInteger row = index % rowsPerCol;
    
    CGPoint origin = CGPointMake(leftCap + col * (gridView.itemSize.width + gridView.lineMargin),
                                 topCap + row * (gridView.itemSize.height + margin));
    
    return (CGRect){origin, gridView.itemSize};
}

@end

@implementation RTGridLayoutStrategyVerticalEven

- (NSArray*)layoutGridItems:(NSArray *)gridItems withGridView:(RTGridView *)gridView
{
    CGRect contentRect = UIEdgeInsetsInsetRect(CGRectMake(0, 0, gridView.bounds.size.width, gridView.bounds.size.height), gridView.itemInset);
    CGFloat topCap = contentRect.origin.y;
    CGFloat leftCap = contentRect.origin.x;
    CGFloat maxWidth = contentRect.size.width;
    
    
    NSInteger colsPerRow = (NSInteger)floorf((maxWidth - gridView.itemSize.width) / (gridView.minItemMargin + gridView.itemSize.width)) + 1;
    CGFloat margin = (maxWidth - gridView.itemSize.width) / (colsPerRow - 1) - gridView.itemSize.width;
    
    NSMutableArray *visibleItems = [NSMutableArray array];
    for (int i = 0; i < gridItems.count; ++i) {
        NSInteger col = i % colsPerRow;
        NSInteger row = i / colsPerRow;
        
        CGPoint origin = CGPointMake(leftCap + col * (gridView.itemSize.width + margin),
                                     topCap + row * (gridView.itemSize.height + gridView.lineMargin));
        RTGridItem *item = [gridItems objectAtIndex:i];
        item.customView.frame = (CGRect){origin, gridView.itemSize};
        UIScrollView *scroll = (UIScrollView*)item.customView.superview;
        CGRect visibleRect = (CGRect){scroll.contentOffset, scroll.bounds.size};
        if (CGRectContainsRect(visibleRect, item.customView.frame) ||
            CGRectIntersectsRect(visibleRect, item.customView.frame))
            [visibleItems addObject:item];
    }
    
    gridView.contentSize = CGSizeMake(maxWidth + gridView.itemInset.right, topCap + gridView.itemSize.height + (gridItems.count - 1) / colsPerRow * (gridView.itemSize.height + gridView.lineMargin) + gridView.itemInset.bottom);
    return [NSArray arrayWithArray:visibleItems];
}

- (CGRect)frameForItems:(NSArray *)gridItems
                atIndex:(NSUInteger)index
           withGridView:(RTGridView *)gridView
{
    CGRect contentRect = UIEdgeInsetsInsetRect(CGRectMake(0, 0, gridView.bounds.size.width, gridView.bounds.size.height), gridView.itemInset);
    CGFloat topCap = contentRect.origin.y;
    CGFloat leftCap = contentRect.origin.x;
    CGFloat maxWidth = contentRect.size.width;
    
    
    NSInteger colsPerRow = (NSInteger)floorf((maxWidth - gridView.itemSize.width) / (gridView.minItemMargin + gridView.itemSize.width)) + 1;
    CGFloat margin = (maxWidth - gridView.itemSize.height) / (colsPerRow - 1) - gridView.itemSize.width;
    NSInteger col = index % colsPerRow;
    NSInteger row = index / colsPerRow;
    
    CGPoint origin = CGPointMake(leftCap + col * (gridView.itemSize.width + margin),
                                 topCap + row * (gridView.itemSize.height + gridView.lineMargin));
    
    return (CGRect){origin, gridView.itemSize};
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

- (NSArray*)layoutGridItems:(NSArray *)gridItems
               withGridView:(RTGridView *)gridView
{
    NSAssert(NO, @"Override me !!!");
    return nil;
}

- (CGRect)frameForItems:(NSArray *)gridItems atIndex:(NSUInteger)index withGridView:(RTGridView *)gridView
{
    NSAssert(NO, @"Override me !!!");
    return CGRectNull;
}

- (RTGridItem*)itemOfGridItems:(NSArray *)gridItems
                    atLocation:(CGPoint)location
              nearistItemIndex:(out NSUInteger *)index
{
    for (RTGridItem *item in gridItems) {
        if (CGRectContainsPoint(item.customView.frame, location) && item.isEditing) {
            return item;
        }
    }
    return nil;
}

@end
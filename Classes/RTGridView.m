//
//  RTGridView.m
//  RTGridView
//
//  Created by ricky on 13-9-14.
//  Copyright (c) 2013年 ricky. All rights reserved.
//

#import "RTGridView.h"

static CGRect CGRectMakeWithCenterAndSize(CGPoint center, CGSize size)
{
    return CGRectMake(center.x - size.width / 2, center.y - size.height / 2, size.width, size.height);
}

@interface RTGridView () <UIGestureRecognizerDelegate>
{
    NSMutableArray          * _gridItems;
}
@property (nonatomic, retain) NSMutableArray *gridItems;
@end

@implementation RTGridView
@synthesize gridItems = _gridItems;

- (void)dealloc
{
    [_gridItems release];
    [super dealloc];
}

- (void)commonInit
{
    _gridItems = [[NSMutableArray alloc] init];
    
    self.itemSize = CGSizeZero;
    self.minItemMargin = 10.0f;
    self.minLineMargin = 10.0f;
    self.itemInset = UIEdgeInsetsMake(10, 10, 10, 10);
    self.pagingEnabled = NO;
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                                            action:@selector(onLongPress:)];
    [self addGestureRecognizer:longPress];
    [longPress release];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self commonInit];
    }
    return self;
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self layoutItems];
}

#pragma mark - Private Methods

- (void)layoutItemsAfterIndex:(NSUInteger)index
{
    [self layoutItemsInRange:NSMakeRange(index, self.gridItems.count - index)];
}

- (void)layoutItemsBeforeIndex:(NSUInteger)index
{
    [self layoutItemsInRange:NSMakeRange(0, index)];
}

- (void)layoutItemsInRange:(NSRange)range
{
    NSArray *arr = [self.gridItems subarrayWithRange:range];
    
    CGRect contentRect = UIEdgeInsetsInsetRect(self.bounds, self.itemInset);
    CGFloat topCap = contentRect.origin.y;
    CGFloat leftCap = contentRect.origin.x;
    CGFloat maxWidth = contentRect.size.width;
    CGFloat maxHeight = contentRect.size.height;
    
    CGPoint origin;
    NSUInteger row, col;
    if (range.location == 0) {
        origin = contentRect.origin;
        row = 0;col = 0;
    }
    else {
        RTGridItem *item = (RTGridItem*)[self.gridItems objectAtIndex:range.location - 1];
        UIView *view = item.customView;
        origin = view.frame.origin;
    }
    CGFloat x = origin.x, y = origin.y;
    
    
}

- (void)layoutItems
{
    CGRect contentRect = UIEdgeInsetsInsetRect(CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height), self.itemInset);
    CGFloat topCap = contentRect.origin.y;
    CGFloat leftCap = contentRect.origin.x;
    CGFloat maxWidth = contentRect.size.width;
    CGFloat maxHeight = contentRect.size.height;
    
    CGPoint origin = CGPointMake(leftCap, topCap);
    
    CGFloat lineHeight = 0.0f;
    
    NSMutableArray *rowItems = [NSMutableArray array];
    CGSize lastSize = CGSizeZero;
    
    if (self.layoutType == RTGridViewLayoutTypeVertical) {
        for (int i = 0; i < self.gridItems.count; ++i) {
            RTGridItem *item = [self.gridItems objectAtIndex:i];
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
                    origin.y += lineHeight + self.minLineMargin;
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
        
        self.contentSize = CGSizeMake(self.bounds.size.width, origin.y + lineHeight + self.itemInset.bottom);
    }
    else {
        for (int i = 0; i < self.gridItems.count; ++i) {
            RTGridItem *item = [self.gridItems objectAtIndex:i];
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
                    origin.x += lineHeight + self.minLineMargin;
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
        
        self.contentSize = CGSizeMake(origin.x + lineHeight + self.itemInset.right, self.bounds.size.height);
    }
    
}

- (void)layoutItemsOfLine:(NSArray*)items withRect:(CGRect)rect fillLine:(BOOL)flag
{
    if (self.layoutType == RTGridViewLayoutTypeVertical) {
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
    else {
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
}

- (CGRect)frameForItemAtIndex:(NSUInteger)index
{
    CGRect contentRect = UIEdgeInsetsInsetRect(self.bounds, self.itemInset);
    CGFloat topCap = contentRect.origin.y;
    CGFloat leftCap = contentRect.origin.x;
    CGFloat maxWidth = contentRect.size.width;
    CGFloat maxHeight = contentRect.size.height;
    
    CGPoint origin = CGPointMake(leftCap, topCap);
    
    CGFloat lineHeight = 0.0f;
    
    CGSize lastSize = CGSizeZero;
    if (self.layoutType == RTGridViewLayoutTypeVertical) {
        for (int i = 0; i <= index; ++i) {
            RTGridItem *item = [self.gridItems objectAtIndex:i];
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
    }
    else {
        for (int i = 0; i <= index; ++i) {
            RTGridItem *item = [self.gridItems objectAtIndex:i];
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
    }
    
    return (CGRect){origin, lastSize};
}

#pragma mark - Public Methods

- (void)setMinItemMargin:(CGFloat)minItemMargin
{
    [self setMinItemMargin:minItemMargin animated:NO];
}

- (void)setMinItemMargin:(CGFloat)minItemMargin animated:(BOOL)animated
{
    if (_minItemMargin != minItemMargin) {
        _minItemMargin = minItemMargin;
        
        if (animated) {
            [UIView beginAnimations:@"Relayout" context:nil];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
            [UIView setAnimationDuration:0.35];
            [UIView setAnimationBeginsFromCurrentState:YES];
        }
        
        [self layoutItems];
        
        if (animated) {
            [UIView commitAnimations];
        }
    }
}

- (void)setMinLineMargin:(CGFloat)minLineMargin
{
    [self setMinLineMargin:minLineMargin animated:NO];
}

- (void)setMinLineMargin:(CGFloat)minLineMargin animated:(BOOL)animated
{
    if (_minLineMargin != minLineMargin) {
        _minLineMargin = minLineMargin;
        
        if (animated) {
            [UIView beginAnimations:@"Relayout" context:nil];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
            [UIView setAnimationDuration:0.35];
            [UIView setAnimationBeginsFromCurrentState:YES];
        }
        
        [self layoutItems];
        
        if (animated) {
            [UIView commitAnimations];
        }
    }
}

- (void)setItemInset:(UIEdgeInsets)itemInset
{
    [self setItemInset:itemInset animated:NO];
}

- (void)setItemInset:(UIEdgeInsets)itemInset animated:(BOOL)animated
{
    if (!UIEdgeInsetsEqualToEdgeInsets(_itemInset, itemInset)) {
        _itemInset = itemInset;
        
        if (animated) {
            [UIView beginAnimations:@"Relayout" context:nil];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
            [UIView setAnimationDuration:0.35];
            [UIView setAnimationBeginsFromCurrentState:YES];
        }
        
        [self layoutItems];
        
        if (animated) {
            [UIView commitAnimations];
        }
    }
}

- (void)setItemSize:(CGSize)itemSize
{
    
}

- (void)setLayoutType:(RTGridViewLayoutType)layoutType
{
    [self setLayoutType:layoutType animated:NO];
}

- (void)setLayoutType:(RTGridViewLayoutType)layoutType animated:(BOOL)animated
{
    if (_layoutType != layoutType) {
        _layoutType = layoutType;
        
        if (animated) {
            [UIView beginAnimations:@"Relayout" context:nil];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
            [UIView setAnimationDuration:0.35];
            [UIView setAnimationBeginsFromCurrentState:YES];
        }
        
        [self layoutItems];
        
        if (animated) {
            [UIView commitAnimations];
        }
    }
}

- (void)insertItem:(RTGridItem *)item atIndex:(NSUInteger)index
{
    NSAssert([item isKindOfClass:[RTGridItem class]], @"You can only add RTGridItem!");
    
    if (self.layoutType == RTGridViewLayoutTypeVertical)
        NSAssert(self.bounds.size.width >= self.itemInset.left + self.itemInset.right + item.size.width, @"The item width is out of range!");
    else
        NSAssert(self.bounds.size.height >= self.itemInset.top + self.itemInset.bottom + item.size.height, @"The item height is out of range!");
    
    [self.gridItems insertObject:item atIndex:index];
    [self insertSubview:item.customView atIndex:index];
    
    item.customView.frame = [self frameForItemAtIndex:index];
    item.customView.transform = CGAffineTransformMakeScale(CGFLOAT_MIN, CGFLOAT_MIN);
    
    [UIView animateWithDuration:0.35
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         item.customView.transform = CGAffineTransformIdentity;
                         [self layoutItems];
                     }
                     completion:^(BOOL finished) {
                         
                     }];
    
}

- (void)addItem:(RTGridItem *)item
{
    [self insertItem:item atIndex:self.gridItems.count];
}

- (void)removeItem:(RTGridItem *)item
{
    [self.gridItems removeObject:item];
    __block UIView *view = item.customView;
    [UIView animateWithDuration:0.35
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         [self layoutItems];
                         view.transform = CGAffineTransformMakeScale(CGFLOAT_MIN, CGFLOAT_MIN);
                     }
                     completion:^(BOOL finished) {
                         [view removeFromSuperview];
                     }];
}

- (void)removeItemAtIndex:(NSUInteger)index
{
    if (index == NSNotFound)
        return;
    
    [self removeItem:[self.gridItems objectAtIndex:index]];
}

- (void)removeLastItem
{
    if (self.gridItems.count > 0)
        [self removeItemAtIndex:self.gridItems.count - 1];
}

- (void)exchangeItem:(RTGridItem *)oneItem withItem:(RTGridItem *)otherItem
{
    [self exchangeItemAtIndex:[self.gridItems indexOfObject:oneItem]
              withItemAtIndex:[self.gridItems indexOfObject:otherItem]];
}

- (void)exchangeItemAtIndex:(NSUInteger)oneIndex withItemAtIndex:(NSUInteger)otherIndex
{
    if (oneIndex == NSNotFound || otherIndex == NSNotFound)
        return;
    
    [self exchangeSubviewAtIndex:oneIndex withSubviewAtIndex:otherIndex];
}

@end

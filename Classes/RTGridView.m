//
//  RTGridView.m
//  RTGridView
//
//  Created by ricky on 13-9-14.
//  Copyright (c) 2013年 ricky. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "RTGridView.h"

@interface RTGridItem (RT)
@property (nonatomic, assign, getter = isEditing) BOOL editing;
@end


@interface RTGridView () <UIGestureRecognizerDelegate>
{
    UILongPressGestureRecognizer    * _longPressGesture;
}
@property (nonatomic, retain) NSMutableArray *gridItems;
@property (nonatomic, retain) NSArray *visibleItems;
@property (nonatomic, retain) RTGridItem *selectedItem;
@property (nonatomic, assign, getter = isExchanging) BOOL exchanging;
@end



@implementation RTGridView

- (void)dealloc
{
    self.gridItems = nil;
    self.visibleItems = nil;
    self.selectedItem = nil;
    
    [super dealloc];
}

- (void)commonInit
{
    _gridItems = [[NSMutableArray alloc] init];
    
    self.itemSize = CGSizeZero;
    self.minItemMargin = 10.0f;
    self.lineMargin = 10.0f;
    self.itemSize = CGSizeMake(64, 64);
    self.itemInset = UIEdgeInsetsMake(10, 10, 10, 10);
    self.layoutType = RTGridViewLayoutTypeVerticalTight;
    self.allowEditing = YES;
    
    self.pagingEnabled = NO;
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                                            action:@selector(onLongPress:)];
    longPress.delegate = self;
    [self addGestureRecognizer:longPress];
    _longPressGesture = longPress;
    [longPress release];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(onTap:)];
    tap.delegate = self;
    [self addGestureRecognizer:tap];
    [tap release];
    
    [tap requireGestureRecognizerToFail:longPress];
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

- (void)layoutSubviews
{
    [super layoutSubviews];
    if (!self.isEditing)
        [self layoutItems];
    else {
        self.selectedItem.customView.center = [_longPressGesture locationInView:self];
    }
}

#pragma mark - UIGestureDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
       shouldReceiveTouch:(UITouch *)touch
{
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if (([gestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]] && [otherGestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) ||
        ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]] && [otherGestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]]))
        return NO;
    else if (([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]] && [otherGestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) ||
                 ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]] && [otherGestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]))
        return NO;
    
    return YES;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]]) {
        if (!self.allowEditing)
            return NO;
        RTGridItem *item = [self.customLayout itemOfGridItems:self.visibleItems
                                                   atLocation:[gestureRecognizer locationInView:self]
                                                  excludeItem:nil];
        if (!item)
            return NO;
    }
    return YES;
}

#pragma mark - Private Methods

- (void)scrollAsNeedWithLocation
{
    CGPoint location = [_longPressGesture locationInView:self];
    
    CGRect visibleRect = (CGRect){self.contentOffset, self.bounds.size};
    CGRect rect = UIEdgeInsetsInsetRect(visibleRect, UIEdgeInsetsMake(36, 36, 36, 36));
    if (location.y > CGRectGetMaxY(rect) &&
        self.contentSize.height > CGRectGetMaxY(visibleRect)) {
        visibleRect.origin.y += self.bounds.size.height / 2;
    }
    else if (location.y < rect.origin.y && self.contentOffset.y > 0) {
        visibleRect.origin.y -= self.bounds.size.height / 2;
    }
    else if (location.x > CGRectGetMaxX(rect) &&
             self.contentSize.width > CGRectGetMaxX(visibleRect)) {
        visibleRect.origin.x += self.bounds.size.width / 2;
    }
    else if (location.x < rect.origin.x && self.contentOffset.x > 0) {
        visibleRect.origin.x -= self.bounds.size.width / 2;
    }
    
    [UIView animateWithDuration:0.25
                          delay:0.0
                        options:0
                     animations:^{
//                         self.contentOffset = visibleRect.origin;
                         [self scrollRectToVisible:visibleRect animated:NO];
                         self.selectedItem.customView.center = [_longPressGesture locationInView:self];
                     }
                     completion:^(BOOL finished) {
                         self.selectedItem.customView.transform = CGAffineTransformIdentity;
                         [self layoutItems];
                         self.selectedItem.customView.transform = CGAffineTransformMakeScale(1.2, 1.2);
                         self.selectedItem.customView.center = [_longPressGesture locationInView:self];
                     }];
    
    [self performSelector:@selector(scrollAsNeedWithLocation)
               withObject:nil
               afterDelay:0.5];
}

- (void)onTap:(UITapGestureRecognizer*)tap
{
    switch (tap.state) {
        case UIGestureRecognizerStateEnded:
        {
            RTGridItem *item = [self.customLayout itemOfGridItems:self.visibleItems
                                                       atLocation:[tap locationInView:self]
                                                      excludeItem:nil];
            if (!item)
                break;
            
            if ([self.delegate respondsToSelector:@selector(gridView:didTapOnItem:)])
                [self.delegate gridView:self didTapOnItem:item];
            
            NSUInteger index = [self.gridItems indexOfObject:item];
            if ([self.delegate respondsToSelector:@selector(gridView:didTapOnItemAtIndex:)])
                [self.delegate gridView:self didTapOnItemAtIndex:index];
        }
            break;
            
        default:
            break;
    }
}

- (void)onLongPress:(UILongPressGestureRecognizer*)longPress
{
    static CGPoint beginLocation = {0, 0};
    switch (longPress.state) {
        case UIGestureRecognizerStateBegan:
        {
            self.editing = YES;
            
            beginLocation = [longPress locationInView:self];
            
            self.selectedItem = [self.customLayout itemOfGridItems:self.gridItems
                                                        atLocation:beginLocation
                                                       excludeItem:nil];
            self.selectedItem.editing = NO;
            [self bringSubviewToFront:self.selectedItem.customView];
            
            [UIView beginAnimations:@"StartEditing"
                            context:nil];
            [UIView setAnimationBeginsFromCurrentState:YES];
            [UIView setAnimationDuration:0.15];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
            
            [self layoutItems];
            self.selectedItem.customView.center = beginLocation;
            self.selectedItem.customView.transform = CGAffineTransformMakeScale(1.2, 1.2);
            self.selectedItem.customView.alpha = 0.8;
            
            [UIView commitAnimations];
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            [NSObject cancelPreviousPerformRequestsWithTarget:self];
            
            if (!self.selectedItem)
                break;
            
            CGPoint location = [longPress locationInView:self];
            if (!self.isExchanging) {
                RTGridItem *swapItem = [self.customLayout itemOfGridItems:self.visibleItems
                                                               atLocation:location
                                                              excludeItem:self.selectedItem];
                if (swapItem) {
                    self.selectedItem.customView.transform = CGAffineTransformIdentity;
                    [self exchangeItem:swapItem withItem:self.selectedItem];
                    [self.selectedItem.customView.layer removeAllAnimations];
                    self.selectedItem.customView.transform = CGAffineTransformMakeScale(1.2, 1.2);
                    [self bringSubviewToFront:self.selectedItem.customView];
                }

            }
            self.selectedItem.customView.center = location;
            
            [self performSelector:@selector(scrollAsNeedWithLocation)
                       withObject:nil
                       afterDelay:0.6];
        }
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateFailed:
        case UIGestureRecognizerStateCancelled:
        {
            [NSObject cancelPreviousPerformRequestsWithTarget:self];
            
            self.editing = NO;
            
            [UIView beginAnimations:@"EndEditing"
                            context:nil];
            [UIView setAnimationBeginsFromCurrentState:YES];
            [UIView setAnimationDuration:0.15];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
            
            self.selectedItem.customView.transform = CGAffineTransformIdentity;
            self.selectedItem.customView.alpha = 1.0;
            self.selectedItem.customView.userInteractionEnabled = YES;
            [self layoutItems];
            
            [UIView commitAnimations];
            
            self.selectedItem = nil;
        }
            break;
            
        default:
            break;
    }
}

- (void)onPan:(UIPanGestureRecognizer*)pan
{
    NSLog(@"pan");
    switch (pan.state) {
        case UIGestureRecognizerStateEnded:
            
            break;
            
        default:
            break;
    }
}

- (void)layoutItems
{
    if (self.gridItems.count == 0)
        return;
    
    self.visibleItems = [self.customLayout layoutGridItems:self.gridItems
                                              withGridView:self];
}

- (CGRect)frameForItemAtIndex:(NSUInteger)index
{
    return [self.customLayout frameForItems:self.gridItems
                                    atIndex:index
                               withGridView:self];
}

#pragma mark - Public Methods

- (void)setAllowEditing:(BOOL)allowEditing
{
    if (_allowEditing != allowEditing) {
        _allowEditing = allowEditing;
        _longPressGesture.enabled = _allowEditing;
        if (!_allowEditing)
            self.editing = NO;
    }
}

- (void)setEditing:(BOOL)editing
{
    if (_editing != editing) {
        _editing = editing;
        [self.gridItems makeObjectsPerformSelector:@selector(setEditing:)
                                        withObject:(id)editing];
        if (_editing) {
            if ([self.delegate respondsToSelector:@selector(gridViewDidBeginEditing:)])
                [self.delegate gridViewDidBeginEditing:self];
        }
        else {
            if ([self.delegate respondsToSelector:@selector(gridViewDidEndEditing:)])
                [self.delegate gridViewDidEndEditing:self];
        }
    }
}

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

- (void)setLineMargin:(CGFloat)lineMargin
{
    [self setLineMargin:lineMargin animated:NO];
}

- (void)setLineMargin:(CGFloat)lineMargin animated:(BOOL)animated
{
    if (_lineMargin != lineMargin) {
        _lineMargin = lineMargin;
        
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
    [self setItemSize:itemSize animated:NO];
}

- (void)setItemSize:(CGSize)itemSize animated:(BOOL)animated
{
    if (!CGSizeEqualToSize(_itemSize, itemSize)) {
        _itemSize = itemSize;
        
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

- (void)setLayoutType:(RTGridViewLayoutType)layoutType
{
    [self setLayoutType:layoutType animated:NO];
}

- (void)setLayoutType:(RTGridViewLayoutType)layoutType animated:(BOOL)animated
{
    if (_layoutType != layoutType || !self.customLayout) {
        _layoutType = layoutType;
        [self setCustomLayout:[RTGridLayoutStrategy gridLayoutStrategyWithLayoutType:_layoutType]
                     animated:animated];
    }
}

- (void)setCustomLayout:(id<RTGridLayoutStrategy>)customLayout
{
    [self setCustomLayout:customLayout animated:NO];
}

- (void)setCustomLayout:(id<RTGridLayoutStrategy>)customLayout animated:(BOOL)animated
{
    if (_customLayout != customLayout) {
        [_customLayout release];
        _customLayout = [customLayout retain];
        
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
        [self flashScrollIndicators];
    }
}

- (void)insertItem:(RTGridItem *)item atIndex:(NSUInteger)index
{
    NSAssert([item isKindOfClass:[RTGridItem class]], @"You can only add RTGridItem!");
    
    if (self.layoutType == RTGridViewLayoutTypeVerticalTight)
        NSAssert(self.bounds.size.width >= self.itemInset.left + self.itemInset.right + item.size.width, @"The item width is out of range!");
    else
        NSAssert(self.bounds.size.height >= self.itemInset.top + self.itemInset.bottom + item.size.height, @"The item height is out of range!");
    
    [self.gridItems insertObject:item atIndex:index];
    [self insertSubview:item.customView atIndex:index];
    
    item.customView.frame = [self frameForItemAtIndex:index];
    item.customView.transform = CGAffineTransformMakeScale(CGFLOAT_MIN, CGFLOAT_MIN);
    item.customView.userInteractionEnabled = YES;
    item.editing = self.isEditing;
    
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
                         [self sendSubviewToBack:view];
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
    
    self.exchanging = YES;
    
    [self.gridItems exchangeObjectAtIndex:oneIndex withObjectAtIndex:otherIndex];
    [self exchangeSubviewAtIndex:oneIndex withSubviewAtIndex:otherIndex];
    
    [UIView animateWithDuration:0.35
                     animations:^{
                         [self layoutItems];
                     }
                     completion:^(BOOL finished) {
                         self.exchanging = NO;
                     }];
}



@end

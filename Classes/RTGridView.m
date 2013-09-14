//
//  RTGridView.m
//  RTGridView
//
//  Created by ricky on 13-9-14.
//  Copyright (c) 2013年 ricky. All rights reserved.
//

#import "RTGridView.h"

@interface RTGridItem (RTGridView)
@property (nonatomic, assign, getter = isEditing) BOOL editing;
@end



@interface RTGridView () <UIGestureRecognizerDelegate>
{
    NSMutableArray          * _gridItems;
}
@property (nonatomic, retain) NSMutableArray *gridItems;
@property (nonatomic, retain) RTGridItem *selectedItem;
@end



@implementation RTGridView
@synthesize gridItems = _gridItems;

- (void)dealloc
{
    [_gridItems release];
    self.selectedItem = nil;
    
    [super dealloc];
}

- (void)commonInit
{
    _gridItems = [[NSMutableArray alloc] init];
    
    self.itemSize = CGSizeZero;
    self.minItemMargin = 10.0f;
    self.minLineMargin = 10.0f;
    self.itemSize = CGSizeMake(64, 64);
    self.itemInset = UIEdgeInsetsMake(10, 10, 10, 10);
    self.layoutType = RTGridViewLayoutTypeVerticalTight;
    
    self.pagingEnabled = NO;
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                                            action:@selector(onLongPress:)];
    longPress.delegate = self;
    [self addGestureRecognizer:longPress];
    [longPress release];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(onTap:)];
    tap.delegate = self;
    [self addGestureRecognizer:tap];
    [tap release];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(onPan:)];
    pan.delegate = self;
    //[self addGestureRecognizer:pan];
    [pan release];
    
    //[pan requireGestureRecognizerToFail:longPress];
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
    [self layoutItems];
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
    
    return YES;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{

    return YES;
}

#pragma mark - Private Methods

- (void)onTap:(UITapGestureRecognizer*)tap
{
    NSLog(@"tap");
    switch (tap.state) {
        case UIGestureRecognizerStateEnded:
            
            break;
            
        default:
            break;
    }
}

- (void)onLongPress:(UILongPressGestureRecognizer*)longPress
{
    NSLog(@"long press");
    switch (longPress.state) {
        case UIGestureRecognizerStateBegan:
        {
            self.editing = YES;
        }
            break;
        case UIGestureRecognizerStateCancelled:
            
            break;
        case UIGestureRecognizerStateEnded:
            
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
    
    CGRect contentRect = UIEdgeInsetsInsetRect(CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height), self.itemInset);
    CGSize size = CGSizeZero;
    [self.customLayout layoutGridItems:self.gridItems
                                inRect:contentRect
                           contentSize:&size];
    size.width += self.itemInset.right;
    size.height += self.itemInset.bottom;
    self.contentSize = size; 
}

- (CGRect)frameForItemAtIndex:(NSUInteger)index
{
    CGRect contentRect = UIEdgeInsetsInsetRect(CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height), self.itemInset);
    return [self.customLayout frameForItems:self.gridItems
                                    atIndex:index
                                     inRect:contentRect];
}

#pragma mark - Public Methods

- (void)setEditing:(BOOL)editing
{
    _editing = editing;
    [self.gridItems makeObjectsPerformSelector:@selector(setEditing:)
                                    withObject:(id)editing];
}

- (void)setMinItemMargin:(CGFloat)minItemMargin
{
    [self setMinItemMargin:minItemMargin animated:NO];
}

- (void)setMinItemMargin:(CGFloat)minItemMargin animated:(BOOL)animated
{
    if (_minItemMargin != minItemMargin) {
        _minItemMargin = minItemMargin;
        self.customLayout.minItemMargin = self.minItemMargin;

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
        self.customLayout.lineMargin = self.minLineMargin;

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
        self.customLayout.itemSize = self.itemSize;
        
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
        self.customLayout = [RTGridLayoutStrategy gridLayoutStrategyWithLayoutType:_layoutType];
        self.customLayout.minItemMargin = self.minItemMargin;
        self.customLayout.lineMargin = self.minLineMargin;
        self.customLayout.itemSize = self.itemSize;
        
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
    
    if (self.layoutType == RTGridViewLayoutTypeVerticalTight)
        NSAssert(self.bounds.size.width >= self.itemInset.left + self.itemInset.right + item.size.width, @"The item width is out of range!");
    else
        NSAssert(self.bounds.size.height >= self.itemInset.top + self.itemInset.bottom + item.size.height, @"The item height is out of range!");
    
    [self.gridItems insertObject:item atIndex:index];
    [self insertSubview:item.customView atIndex:index];
    
    item.customView.frame = [self frameForItemAtIndex:index];
    item.customView.transform = CGAffineTransformMakeScale(CGFLOAT_MIN, CGFLOAT_MIN);
    item.customView.userInteractionEnabled = YES;
    
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
    
    [self.gridItems exchangeObjectAtIndex:otherIndex withObjectAtIndex:otherIndex];
    [self exchangeSubviewAtIndex:oneIndex withSubviewAtIndex:otherIndex];
}



@end

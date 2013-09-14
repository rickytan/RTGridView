//
//  RTGridView.h
//  RTGridView
//
//  Created by ricky on 13-9-14.
//  Copyright (c) 2013年 ricky. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RTGridItem.h"

@class RTGridView;

@protocol RTGridViewDelegate <NSObject>
@optional
- (void)gridViewDidTapOnItemAtIndex:(NSUInteger)index;

@end

typedef enum {
    RTGridViewLayoutTypeVertical    = 0,
    RTGridViewLayoutTypeHorizontal  = 1,
} RTGridViewLayoutType;


@interface RTGridView : UIScrollView
@property (nonatomic, assign) CGFloat minItemMargin;    // Default 10
@property (nonatomic, assign) CGFloat minLineMargin;    // Defalut 10
@property (nonatomic, assign) RTGridViewLayoutType layoutType;  // Default Vertical
@property (nonatomic, assign) UIEdgeInsets itemInset;   // Defalut 10, 10, 10, 10
@property (nonatomic, assign) CGSize itemSize;      // Default CGSizeZero, will use flexible size of each item, if set all item will be the fixed size !

@property (nonatomic, assign, getter = isEditing) BOOL editing;

- (void)setMinItemMargin:(CGFloat)minItemMargin animated:(BOOL)animated;
- (void)setMinLineMargin:(CGFloat)minLineMargin animated:(BOOL)animated;
- (void)setItemInset:(UIEdgeInsets)itemInset animated:(BOOL)animated;
- (void)setItemSize:(CGSize)itemSize animated:(BOOL)animated;
- (void)setLayoutType:(RTGridViewLayoutType)layoutType animated:(BOOL)animated;

- (void)insertItem:(RTGridItem*)item atIndex:(NSUInteger)index;
- (void)addItem:(RTGridItem*)item;
- (void)removeItem:(RTGridItem*)item;
- (void)removeItemAtIndex:(NSUInteger)index;
- (void)removeLastItem;
- (void)exchangeItemAtIndex:(NSUInteger)oneIndex withItemAtIndex:(NSUInteger)otherIndex;
- (void)exchangeItem:(RTGridItem*)oneItem withItem:(RTGridItem*)otherItem;

@end

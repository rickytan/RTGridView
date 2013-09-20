//
//  RTGridView.h
//  RTGridView
//
//  Created by ricky on 13-9-14.
//  Copyright (c) 2013年 ricky. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RTGridItem.h"
#import "RTGridLayoutStrategy.h"

@class RTGridView;

@protocol RTGridViewDelegate <NSObject>
@optional
- (void)gridViewDidBeginEditing:(RTGridView*)gridView;
- (void)gridViewDidEndEditing:(RTGridView *)gridView;
- (void)gridView:(RTGridView*)grdiView didTapOnItemAtIndex:(NSUInteger)index;
- (void)gridView:(RTGridView *)grdiView didTapOnItem:(RTGridItem*)item;

@end


@interface RTGridView : UIScrollView
@property (nonatomic, assign) CGFloat minItemMargin;    // Default 10
@property (nonatomic, assign) CGFloat lineMargin;    // Defalut 10
@property (nonatomic, assign) RTGridViewLayoutType layoutType;  // Default Vertical
@property (nonatomic, retain) id<RTGridLayoutStrategy> customLayout;
@property (nonatomic, assign) UIEdgeInsets itemInset;   // Defalut 10, 10, 10, 10
@property (nonatomic, assign) CGSize itemSize;          // Default {64, 64}
@property (nonatomic, assign) BOOL allowEditing;        // Defalut YES
@property (nonatomic, assign) IBOutlet id<RTGridViewDelegate, UIScrollViewDelegate> delegate;

@property (nonatomic, readonly, retain) NSArray *gridItems;
@property (nonatomic, readonly, retain) NSArray *visibleItems;
@property (nonatomic, readonly, getter = isEditing) BOOL editing;

- (void)setMinItemMargin:(CGFloat)minItemMargin animated:(BOOL)animated;
- (void)setLineMargin:(CGFloat)minLineMargin animated:(BOOL)animated;
- (void)setItemInset:(UIEdgeInsets)itemInset animated:(BOOL)animated;
- (void)setItemSize:(CGSize)itemSize animated:(BOOL)animated;
- (void)setLayoutType:(RTGridViewLayoutType)layoutType animated:(BOOL)animated;

- (void)insertItem:(RTGridItem*)item atIndex:(NSUInteger)index;
- (void)insertItem:(RTGridItem*)item atIndex:(NSUInteger)index animated:(BOOL)animated;
- (void)addItem:(RTGridItem*)item;
- (void)addItem:(RTGridItem*)item animated:(BOOL)animated;
- (void)removeItem:(RTGridItem*)item;
- (void)removeItem:(RTGridItem*)item animated:(BOOL)animated;
- (void)removeItemAtIndex:(NSUInteger)index;
- (void)removeItemAtIndex:(NSUInteger)index animated:(BOOL)animated;
- (void)removeLastItem;
- (void)removeLastItemAnimated:(BOOL)animated;
- (void)exchangeItemAtIndex:(NSUInteger)oneIndex withItemAtIndex:(NSUInteger)otherIndex;
- (void)exchangeItemAtIndex:(NSUInteger)oneIndex withItemAtIndex:(NSUInteger)otherIndex animated:(BOOL)animated;
- (void)exchangeItem:(RTGridItem*)oneItem withItem:(RTGridItem*)otherItem;
- (void)exchangeItem:(RTGridItem*)oneItem withItem:(RTGridItem*)otherItem animated:(BOOL)animated;

@end

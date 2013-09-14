//
//  RTGridLayoutStrategy.h
//  RTGridView
//
//  Created by ricky on 13-9-14.
//  Copyright (c) 2013年 ricky. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RTGridItem.h"


@protocol RTGridLayoutStrategy <NSObject>
@required
- (NSArray*)layoutGridItems:(NSArray*)gridItems
                     inRect:(CGRect)rect
                contentSize:(out CGSize*)size;      // Return visible items;

- (CGRect)frameForItems:(NSArray*)gridItems
                atIndex:(NSUInteger)index
                 inRect:(CGRect)rect;

- (RTGridItem*)itemOfGridItems:(NSArray*)gridItems
                    atLocation:(CGPoint)location
              nearistItemIndex:(out NSUInteger*)index;

@optional
@property (nonatomic, assign) CGFloat minItemMargin;
@property (nonatomic, assign) CGFloat lineMargin;
@property (nonatomic, assign) CGSize itemSize;

@end

typedef enum {
    RTGridViewLayoutTypeVerticalTight    = 0,
    RTGridViewLayoutTypeHorizontalTight  = 1,
    RTGridViewLayoutTypeVerticalEven     = 2,
    RTGridViewLayoutTypeHorizontalEven   = 3,
} RTGridViewLayoutType;


@interface RTGridLayoutStrategy : NSObject <RTGridLayoutStrategy>
@property (nonatomic, assign) CGFloat minItemMargin;
@property (nonatomic, assign) CGFloat lineMargin;
@property (nonatomic, assign) CGSize itemSize;
+ (id)gridLayoutStrategyWithLayoutType:(RTGridViewLayoutType)type;
+ (id)gridLayoutStrategy;
@end



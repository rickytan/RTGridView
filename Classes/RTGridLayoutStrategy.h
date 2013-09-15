//
//  RTGridLayoutStrategy.h
//  RTGridView
//
//  Created by ricky on 13-9-14.
//  Copyright (c) 2013年 ricky. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RTGridItem.h"

@class RTGridView;

@protocol RTGridLayoutStrategy <NSObject>
@required
- (NSArray*)layoutGridItems:(NSArray*)gridItems
               withGridView:(RTGridView*)gridView;  // Return visible items;

- (CGRect)frameForItems:(NSArray*)gridItems
                atIndex:(NSUInteger)index
           withGridView:(RTGridView*)gridView;

- (RTGridItem*)itemOfGridItems:(NSArray*)gridItems
                    atLocation:(CGPoint)location
                   excludeItem:(RTGridItem*)item;

@end

typedef enum {
    RTGridViewLayoutTypeVerticalTight    = 0,
    RTGridViewLayoutTypeHorizontalTight  = 1,
    RTGridViewLayoutTypeVerticalEven     = 2,
    RTGridViewLayoutTypeHorizontalEven   = 3,
} RTGridViewLayoutType;


@interface RTGridLayoutStrategy : NSObject <RTGridLayoutStrategy>
+ (id)gridLayoutStrategyWithLayoutType:(RTGridViewLayoutType)type;
+ (id)gridLayoutStrategy;
@end



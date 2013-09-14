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
- (void)layoutGridItems:(NSArray*)gridItems
                 inRect:(CGRect)rect
             itemMargin:(CGFloat)itemMargin
             lineMargin:(CGFloat)lineMargin
            contentSize:(out CGSize*)size;
- (CGRect)frameForItems:(NSArray*)gridItems
                atIndex:(NSUInteger)index
                 inRect:(CGRect)rect;
@end

typedef enum {
    RTGridViewLayoutTypeVertical    = 0,
    RTGridViewLayoutTypeHorizontal  = 1,
} RTGridViewLayoutType;


@interface RTGridLayoutStrategy : NSObject <RTGridLayoutStrategy>
+ (id)gridLayoutStrategyWithLayoutType:(RTGridViewLayoutType)type;
+ (id)gridLayoutStrategy;
@end

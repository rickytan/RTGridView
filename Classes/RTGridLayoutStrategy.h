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
            contentSize:(out CGSize*)size;

- (CGRect)frameForItems:(NSArray*)gridItems
                atIndex:(NSUInteger)index
                 inRect:(CGRect)rect;
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



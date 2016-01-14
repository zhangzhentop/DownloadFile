//
//  CustomLabel.h
//  mobilely
//
//  Created by Victoria on 15/2/26.
//  Copyright (c) 2015年 ylx. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef enum
{
    ///顶端对齐
    VerticalAlignmentTop = 0, // default
    ///垂直对齐
    VerticalAlignmentMiddle,
    ///底部对齐
    VerticalAlignmentBottom,
} VerticalAlignment;

@interface CustomLabel : UILabel
{
//@private
    VerticalAlignment _verticalAlignment;
}
/**
 *  设置对齐方式
 */
@property (nonatomic) VerticalAlignment verticalAlignment; 
@end

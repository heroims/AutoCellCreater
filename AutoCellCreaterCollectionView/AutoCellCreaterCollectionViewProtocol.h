//
//  AutoCellCreaterCollectionViewProtocol.h
//  AutoCellCreaterDemo
//
//  Created by Zhao Yiqi on 2017/10/16.
//  Copyright © 2017年 admin. All rights reserved.
//

#pragma mark - 插cell写法必须实现该协议  定义数据绑定对cell的赋值，可作为通用协议使用
@protocol AutoCellCreaterCollectionViewOrderProtocol <NSObject>

@required
-(void)accc_setBindModel:(id)bindModel indexPath:(NSIndexPath*)indexPath;
+(CGSize)accc_getCellSizeWithModel:(id)model indexPath:(NSIndexPath*)indexPath;

@end


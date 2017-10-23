//
//  AutoCellCreaterCollectionView.h
//  xgoods
//
//  Created by admin on 2017/1/18.
//  Copyright © 2017年 admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AutoCellCreaterCollectionViewProtocol.h"

@interface UICollectionReusableView (AutoCellCreaterCollectionView)

@property(nonatomic,strong)id accc_bindModel;
@property(nonatomic,strong)NSIndexPath *accc_indexPath;

-(CGSize)accc_getCellSize;

@end

typedef enum AutoCellCreaterCollectionViewType:NSInteger{
    AutoCellCreaterCollectionViewType_Order,//按手动顺序依次创建header cell footer
    AutoCellCreaterCollectionViewType_Disorder//按逻辑创建
}AutoCellCreaterCollectionViewType;

#pragma mark - 相当于cellForItemAtIndexPath的回调，这里做了拆分为了更加明确实现 区分cell和设置cell
/**
 区分cell类型 根据具体情况实现过滤条件返回
 */
typedef BOOL  (^accc_createFilter)(UICollectionView *collectionView,NSIndexPath *indexPath);

/**
 设置cell自定义扩展处理
 */
typedef void  (^accc_customSetCell)(UICollectionView *collectionView,UICollectionReusableView *collectionViewCell,NSIndexPath *indexPath);

#pragma mark - 常用回调Block封装 需要其他回调直接继承扩展即可
typedef void  (^accc_collectionViewDidSelectRowAtIndexPath)(UICollectionView *collectionView,NSIndexPath *indexPath);

typedef CGSize  (^accc_sizeForItemAtIndexPath)(UICollectionView *collectionView,UICollectionViewLayout *collectionViewLayout,NSIndexPath *indexPath);

typedef NSInteger  (^accc_numberOfSectionsInCollectionView)(UICollectionView *collectionView);
typedef NSInteger  (^accc_numberOfRowsInSection)(UICollectionView *collectionView,NSInteger section);

typedef void  (^accc_scrollViewDidScroll)(UIScrollView *scrollView);

#pragma mark -

@interface AutoCellCreaterCollectionView : UICollectionView

@property(nonatomic,assign)AutoCellCreaterCollectionViewType createrType;

@property(nonatomic,copy)accc_collectionViewDidSelectRowAtIndexPath accc_collectionViewDidSelectRowAtIndexPathBlock;
-(void)setAccc_collectionViewDidSelectRowAtIndexPathBlock:(accc_collectionViewDidSelectRowAtIndexPath)accc_collectionViewDidSelectRowAtIndexPathBlock;

@property(nonatomic,copy)accc_numberOfSectionsInCollectionView accc_numberOfSectionsInCollectionViewBlock;
-(void)setAccc_numberOfSectionsInCollectionViewBlock:(accc_numberOfSectionsInCollectionView)accc_numberOfSectionsInCollectionViewBlock;

@property(nonatomic,copy)accc_numberOfRowsInSection accc_numberOfRowsInSectionBlock;
-(void)setAccc_numberOfRowsInSectionBlock:(accc_numberOfRowsInSection)accc_numberOfRowsInSectionBlock;

@property(nonatomic,copy)accc_scrollViewDidScroll accc_scrollViewDidScrollBlock;
-(void)setAccc_scrollViewDidScrollBlock:(accc_scrollViewDidScroll)accc_scrollViewDidScrollBlock;

#pragma mark - 通用模式调用
-(void)addHeaderInSection:(NSInteger)section headerClass:(Class)headerClass bindModel:(id)bindModel;
-(void)replaceHeaderInSection:(NSInteger)section headerClass:(Class)headerClass bindModel:(id)bindModel;
-(void)removeHeaderInSection:(NSInteger)section;

-(void)addFooterInSection:(NSInteger)section footerClass:(Class)footerClass bindModel:(id)bindModel;
-(void)replaceFooterInSection:(NSInteger)section footerClass:(Class)footerClass bindModel:(id)bindModel;
-(void)removeFooterInSection:(NSInteger)section;

#pragma mark -    仅支持AutoCellCreaterType_Order模式调用  插Cell形式，根据代码添加顺序插入
-(void)addHeaderWithHeaderClass:(Class)headerClass bindModel:(id)bindModel;
-(void)addFooterWithFooterClass:(Class)footerClass bindModel:(id)bindModel;
-(void)addCellWithClass:(Class)cellClass bindModel:(id)bindModel;
-(void)addCellWithClass:(Class)cellClass bindModel:(id)bindModel customSetCellBlock:(accc_customSetCell)customSetCellBlock;
-(void)addCellWithClass:(Class)cellClass bindModel:(id)bindModel indexPath:(NSIndexPath*)indexPath;
-(void)addCellWithClass:(Class)cellClass bindModel:(id)bindModel indexPath:(NSIndexPath*)indexPath customSetCellBlock:(accc_customSetCell)customSetCellBlock;
-(void)replaceCellWithClass:(Class)cellClass bindModel:(id)bindModel indexPath:(NSIndexPath*)indexPath;
-(void)replaceCellWithClass:(Class)cellClass bindModel:(id)bindModel indexPath:(NSIndexPath*)indexPath customSetCellBlock:(accc_customSetCell)customSetCellBlock;
-(void)removeCellWithIndexPath:(NSIndexPath*)indexPath;
-(void)removeCellsWithSection:(NSInteger)section;

//链式语法 collectionView.accc_addCell(cellClass,model,indexPath).accc_reloadData();
- (AutoCellCreaterCollectionView * (^)(Class cellClass,id bindModel,NSIndexPath *indexPath,accc_customSetCell customSetCellBlock))accc_addCell;
- (AutoCellCreaterCollectionView * (^)(Class cellClass,id bindModel,NSIndexPath *indexPath,accc_customSetCell customSetCellBlock))accc_replaceCell;
- (AutoCellCreaterCollectionView * (^)(NSIndexPath *indexPath))accc_removeCell;

- (void (^)(void))accc_reloadData;

#pragma mark - 仅支持AutoCellCreaterType_Disorder模式调用  Block形式
-(void)addCellWithClass:(Class)cellClass sizeForItemAtIndexPathBlock:(accc_sizeForItemAtIndexPath)sizeForItemAtIndexPathBlock;
-(void)addCellWithClass:(Class)cellClass createFilterBlock:(accc_createFilter)filterBlock sizeForItemAtIndexPathBlock:(accc_sizeForItemAtIndexPath)sizeForItemAtIndexPathBlock;
-(void)addCellWithClass:(Class)cellClass customSetCellBlock:(accc_customSetCell)customSetCellBlock sizeForItemAtIndexPathBlock:(accc_sizeForItemAtIndexPath)sizeForItemAtIndexPathBlock;
-(void)addCellWithClass:(Class)cellClass createFilterBlock:(accc_createFilter)filterBlock customSetCellBlock:(accc_customSetCell)customSetCellBlock sizeForItemAtIndexPathBlock:(accc_sizeForItemAtIndexPath)sizeForItemAtIndexPathBlock;

-(void)addHeaderWithClass:(Class)cellClass createFilterBlock:(accc_createFilter)filterBlock customSetCellBlock:(accc_customSetCell)customSetCellBlock sizeForItemAtIndexPathBlock:(accc_sizeForItemAtIndexPath)sizeForItemAtIndexPathBlock;
-(void)addFooterWithClass:(Class)cellClass createFilterBlock:(accc_createFilter)filterBlock customSetCellBlock:(accc_customSetCell)customSetCellBlock sizeForItemAtIndexPathBlock:(accc_sizeForItemAtIndexPath)sizeForItemAtIndexPathBlock;

@end

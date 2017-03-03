//
//  AutoCellCreaterCollectionView.h
//  xgoods
//
//  Created by admin on 2017/1/18.
//  Copyright © 2017年 admin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UICollectionReusableView (AutoCellCreaterCollectionView)

@property(nonatomic,strong)id accc_bindModel;
@property(nonatomic,strong)NSIndexPath *accc_indexPath;

-(CGSize)accc_getCellSize;

@end

typedef enum AutoCellCreaterCollectionViewType:NSInteger{
    AutoCellCreaterCollectionViewType_Order,//按手动顺序依次创建header cell footer
    AutoCellCreaterCollectionViewType_Disorder//按逻辑创建
}AutoCellCreaterCollectionViewType;

@protocol AutoCellCreaterCollectionViewOrderProtocol <NSObject>

@required
-(void)accc_setBindModel:(id)bindModel indexPath:(NSIndexPath*)indexPath;
+(CGSize)accc_getCellSizeWithModel:(id)model indexPath:(NSIndexPath*)indexPath;

@end

@interface AutoCellCreaterCollectionView : UICollectionView

typedef BOOL  (^accc_createFilter)(UICollectionView *collectionView,NSIndexPath *indexPath);
typedef void  (^accc_customSetCell)(UICollectionView *collectionView,UICollectionViewCell *collectionViewCell,NSIndexPath *indexPath);

typedef void  (^accc_collectionViewDidSelectRowAtIndexPath)(UICollectionView *collectionView,NSIndexPath *indexPath);

typedef CGSize  (^accc_sizeForItemAtIndexPath)(UICollectionView *collectionView,UICollectionViewLayout *collectionViewLayout,NSIndexPath *indexPath);

typedef UICollectionReusableView *  (^accc_viewForFooterInSection)(UICollectionView *collectionView,NSInteger section);
typedef UICollectionReusableView *  (^accc_viewForHeaderInSection)(UICollectionView *collectionView,NSInteger section);
typedef CGSize  (^accc_referenceSizeForFooterInSection)(UICollectionView *collectionView,UICollectionViewLayout *collectionViewLayout,NSInteger section);
typedef CGSize  (^accc_referenceSizeForHeaderInSection)(UICollectionView *collectionView,UICollectionViewLayout *collectionViewLayout,NSInteger section);
typedef NSInteger  (^accc_numberOfSectionsInCollectionView)(UICollectionView *collectionView);
typedef NSInteger  (^accc_numberOfRowsInSection)(UICollectionView *collectionView,NSInteger section);

@property(nonatomic,assign)AutoCellCreaterCollectionViewType createrType;

@property(nonatomic,copy)accc_collectionViewDidSelectRowAtIndexPath accc_collectionViewDidSelectRowAtIndexPathBlock;
-(void)setAccc_collectionViewDidSelectRowAtIndexPathBlock:(accc_collectionViewDidSelectRowAtIndexPath)accc_collectionViewDidSelectRowAtIndexPathBlock;

@property(nonatomic,copy)accc_numberOfSectionsInCollectionView accc_numberOfSectionsInCollectionViewBlock;
-(void)setAccc_numberOfSectionsInCollectionViewBlock:(accc_numberOfSectionsInCollectionView)accc_numberOfSectionsInCollectionViewBlock;

@property(nonatomic,copy)accc_numberOfRowsInSection accc_numberOfRowsInSectionBlock;
-(void)setAccc_numberOfRowsInSectionBlock:(accc_numberOfRowsInSection)accc_numberOfRowsInSectionBlock;

//通用模式调用
-(void)addHeaderInSection:(NSInteger)section headerClass:(Class)headerClass bindModel:(id)bindModel;
-(void)replaceHeaderInSection:(NSInteger)section headerClass:(Class)headerClass bindModel:(id)bindModel;
-(void)removeHeaderInSection:(NSInteger)section;

-(void)addFooterInSection:(NSInteger)section footerClass:(Class)footerClass bindModel:(id)bindModel;
-(void)replaceFooterInSection:(NSInteger)section footerClass:(Class)footerClass bindModel:(id)bindModel;
-(void)removeFooterInSection:(NSInteger)section;

-(void)accc_setViewForHeaderInSectionBlock:(accc_viewForHeaderInSection)viewBlock sizeForHeaderInSection:(accc_referenceSizeForHeaderInSection)sizeBlock;
-(void)accc_setViewForFooterInSectionBlock:(accc_viewForFooterInSection)viewBlock sizeForFooterInSection:(accc_referenceSizeForFooterInSection)sizeBlock;

//begin   仅支持AutoCellCreaterType_Order模式调用
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

- (void (^)())accc_reloadData;
//end

//仅支持AutoCellCreaterType_Disorder模式调用
-(void)addCellWithClass:(Class)cellClass sizeForItemAtIndexPathBlock:(accc_sizeForItemAtIndexPath)sizeForItemAtIndexPathBlock;
-(void)addCellWithClass:(Class)cellClass createFilterBlock:(accc_createFilter)filterBlock sizeForItemAtIndexPathBlock:(accc_sizeForItemAtIndexPath)sizeForItemAtIndexPathBlock;
-(void)addCellWithClass:(Class)cellClass customSetCellBlock:(accc_customSetCell)customSetCellBlock sizeForItemAtIndexPathBlock:(accc_sizeForItemAtIndexPath)sizeForItemAtIndexPathBlock;
-(void)addCellWithClass:(Class)cellClass createFilterBlock:(accc_createFilter)filterBlock customSetCellBlock:(accc_customSetCell)customSetCellBlock sizeForItemAtIndexPathBlock:(accc_sizeForItemAtIndexPath)sizeForItemAtIndexPathBlock;

@end

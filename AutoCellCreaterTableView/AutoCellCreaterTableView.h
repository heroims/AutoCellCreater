//
//  AutoCellCreaterTableView.h
//  xgoods
//
//  Created by admin on 2017/1/17.
//  Copyright © 2017年 admin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITableViewCell (AutoCellCreaterTableView)

@property(nonatomic,strong)id acct_bindModel;
@property(nonatomic,strong)NSIndexPath *acct_indexPath;

-(CGFloat)acct_getCellHeight;

@end

typedef enum AutoCellCreaterTableViewType:NSInteger{
    AutoCellCreaterTableViewType_Order,//按手动顺序依次创建header cell footer
    AutoCellCreaterTableViewType_Disorder//按逻辑创建
}AutoCellCreaterTableViewType;

@protocol AutoCellCreaterTableViewOrderProtocol <NSObject>

@required
-(void)acct_setBindModel:(id)bindModel indexPath:(NSIndexPath*)indexPath;
+(CGFloat)acct_getCellHeightWithModel:(id)model indexPath:(NSIndexPath*)indexPath;

@end

@interface AutoCellCreaterTableView : UITableView

typedef BOOL  (^acct_createFilter)(UITableView *tableView,NSIndexPath *indexPath);
typedef void  (^acct_customSetCell)(UITableView *tableView,UITableViewCell *tableViewCell,NSIndexPath *indexPath);

typedef void  (^acct_tableViewDidSelectRowAtIndexPath)(UITableView *tableView,NSIndexPath *indexPath);

typedef CGFloat  (^acct_heightForRowAtIndexPath)(UITableView *tableView,NSIndexPath *indexPath);

typedef UIView *  (^acct_viewForFooterInSection)(UITableView *tableView,NSInteger section);
typedef UIView *  (^acct_viewForHeaderInSection)(UITableView *tableView,NSInteger section);
typedef CGFloat  (^acct_heightForFooterInSection)(UITableView *tableView,NSInteger section);
typedef CGFloat  (^acct_heightForHeaderInSection)(UITableView *tableView,NSInteger section);
typedef NSInteger  (^acct_numberOfSectionsInTableView)(UITableView *tableView);
typedef NSInteger  (^acct_numberOfRowsInSection)(UITableView *tableView,NSInteger section);


@property(nonatomic,assign)AutoCellCreaterTableViewType createrType;

@property(nonatomic,copy)acct_tableViewDidSelectRowAtIndexPath acct_tableViewDidSelectRowAtIndexPathBlock;
-(void)setAcct_tableViewDidSelectRowAtIndexPathBlock:(acct_tableViewDidSelectRowAtIndexPath)acct_tableViewDidSelectRowAtIndexPathBlock;

@property(nonatomic,copy)acct_numberOfSectionsInTableView acct_numberOfSectionsInTableViewBlock;
-(void)setAcct_numberOfSectionsInTableViewBlock:(acct_numberOfSectionsInTableView)acct_numberOfSectionsInTableViewBlock;

@property(nonatomic,copy)acct_numberOfRowsInSection acct_numberOfRowsInSectionBlock;
-(void)setAcct_numberOfRowsInSectionBlock:(acct_numberOfRowsInSection)acct_numberOfRowsInSectionBlock;

//通用模式调用
-(void)addHeaderInSection:(NSInteger)section headerView:(UIView*)headerView;
-(void)replaceHeaderInSection:(NSInteger)section headerView:(UIView*)headerView;
-(void)removeHeaderInSection:(NSInteger)section;

-(void)addFooterInSection:(NSInteger)section footerView:(UIView*)footerView;
-(void)replaceFooterInSection:(NSInteger)section footerView:(UIView*)footerView;
-(void)removeFooterInSection:(NSInteger)section;

-(void)acct_setViewForHeaderInSectionBlock:(acct_viewForHeaderInSection)viewBlock heightForHeaderInSection:(acct_heightForHeaderInSection)heightBlock;
-(void)acct_setViewForFooterInSectionBlock:(acct_viewForFooterInSection)viewBlock heightForFooterInSection:(acct_heightForFooterInSection)heightBlock;

//begin   仅支持AutoCellCreaterType_Order模式调用
-(void)addHeaderWithHeaderView:(UIView*)headerView;
-(void)addFooterWithFooterView:(UIView*)footerView;
-(void)addCellWithClass:(Class)cellClass bindModel:(id)bindModel;
-(void)addCellWithClass:(Class)cellClass bindModel:(id)bindModel customSetCellBlock:(acct_customSetCell)customSetCellBlock;
-(void)addCellWithClass:(Class)cellClass bindModel:(id)bindModel indexPath:(NSIndexPath*)indexPath;
-(void)addCellWithClass:(Class)cellClass bindModel:(id)bindModel indexPath:(NSIndexPath*)indexPath customSetCellBlock:(acct_customSetCell)customSetCellBlock;
-(void)replaceCellWithClass:(Class)cellClass bindModel:(id)bindModel indexPath:(NSIndexPath*)indexPath;
-(void)replaceCellWithClass:(Class)cellClass bindModel:(id)bindModel indexPath:(NSIndexPath*)indexPath customSetCellBlock:(acct_customSetCell)customSetCellBlock;
-(void)removeCellWithIndexPath:(NSIndexPath*)indexPath;
-(void)removeCellsWithSection:(NSInteger)section;

//链式语法 tableView.acct_addCell(cellClass,model,indexPath).acct_reloadData();
- (AutoCellCreaterTableView * (^)(Class cellClass,id bindModel,NSIndexPath *indexPath,acct_customSetCell customSetCellBlock))acct_addCell;
- (AutoCellCreaterTableView * (^)(Class cellClass,id bindModel,NSIndexPath *indexPath,acct_customSetCell customSetCellBlock))acct_replaceCell;
- (AutoCellCreaterTableView * (^)(NSIndexPath *indexPath))acct_removeCell;

- (void (^)(UITableViewRowAnimation animation))acct_reloadDataAnimation;
- (void (^)())acct_reloadData;

//end

//仅支持AutoCellCreaterType_Disorder模式调用
-(void)addCellWithClass:(Class)cellClass heightForRowAtIndexPathBlock:(acct_heightForRowAtIndexPath)heightForRowAtIndexPathBlock;
-(void)addCellWithClass:(Class)cellClass createFilterBlock:(acct_createFilter)filterBlock heightForRowAtIndexPathBlock:(acct_heightForRowAtIndexPath)heightForRowAtIndexPathBlock;
-(void)addCellWithClass:(Class)cellClass customSetCellBlock:(acct_customSetCell)customSetCellBlock heightForRowAtIndexPathBlock:(acct_heightForRowAtIndexPath)heightForRowAtIndexPathBlock;
-(void)addCellWithClass:(Class)cellClass createFilterBlock:(acct_createFilter)filterBlock customSetCellBlock:(acct_customSetCell)customSetCellBlock heightForRowAtIndexPathBlock:(acct_heightForRowAtIndexPath)heightForRowAtIndexPathBlock;



@end

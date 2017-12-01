//
//  AutoCellCreaterTableView.h
//  xgoods
//
//  Created by admin on 2017/1/17.
//  Copyright © 2017年 admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AutoCellCreaterTableViewProtocol.h"

@interface UITableViewHeaderFooterView (AutoCellCreaterTableView)

@property(nonatomic,strong)id acct_bindModel;
@property(nonatomic,strong)NSIndexPath *acct_indexPath;

-(CGFloat)acct_getCellHeight;

@end

@interface UITableViewCell (AutoCellCreaterTableView)

@property(nonatomic,strong)id acct_bindModel;
@property(nonatomic,strong)NSIndexPath *acct_indexPath;

-(CGFloat)acct_getCellHeight;

@end

typedef enum AutoCellCreaterTableViewType:NSInteger{
    AutoCellCreaterTableViewType_Order,//按手动顺序依次创建header cell footer
    AutoCellCreaterTableViewType_Disorder//按逻辑创建
}AutoCellCreaterTableViewType;

#pragma mark - 相当于cellForRowAtIndexPath的回调，这里做了拆分为了更加明确实现 区分cell和设置cell
/**
 区分cell类型 根据具体情况实现过滤条件返回
 */
typedef BOOL  (^acct_createFilter)(UITableView *tableView,NSIndexPath *indexPath);

/**
 设置cell自定义扩展处理
 */
typedef void  (^acct_customSetCell)(UITableView *tableView,UIView *tableViewCell,NSIndexPath *indexPath);

/**
 获取cell绑定Model 非持有型block
 */
typedef id  (^acct_getCellBindModel)(UITableView *tableView,NSIndexPath *indexPath);

/**
 完成cell绑定Model 非持有型block

 @param tableView tableView
 @param cellOrHeaderFooter 可能为nil也可能是UITableViewHeaderFooterView或UITableView对象，方便完成绑定后其他相关逻辑
 @param indexPath indexPath
 @return bindModel
 */
typedef id  (^acct_cellToBindModel)(UITableView *tableView,id cellOrHeaderFooter,NSIndexPath *indexPath);

#pragma mark - 常用回调Block封装 需要其他回调直接继承扩展即可
typedef void  (^acct_tableViewDidSelectRowAtIndexPath)(UITableView *tableView,NSIndexPath *indexPath);

typedef CGFloat  (^acct_heightForRowAtIndexPath)(UITableView *tableView,NSIndexPath *indexPath);

typedef UIView *  (^acct_viewForFooterInSection)(UITableView *tableView,NSInteger section);
typedef UIView *  (^acct_viewForHeaderInSection)(UITableView *tableView,NSInteger section);
typedef CGFloat  (^acct_heightForFooterInSection)(UITableView *tableView,NSInteger section);
typedef CGFloat  (^acct_heightForHeaderInSection)(UITableView *tableView,NSInteger section);
typedef NSInteger  (^acct_numberOfSectionsInTableView)(UITableView *tableView);
typedef NSInteger  (^acct_numberOfRowsInSection)(UITableView *tableView,NSInteger section);
typedef UITableViewCellEditingStyle  (^acct_editingStyleForRowAtIndexPath)(UITableView *tableView,NSIndexPath *indexPath);
typedef void  (^acct_commitEditingStyle)(UITableView *tableView,UITableViewCellEditingStyle editingStyle,NSIndexPath *indexPath);
typedef void  (^acct_scrollViewDidScroll)(UIScrollView *scrollView);

#pragma mark -

@interface AutoCellCreaterTableView : UITableView

@property(nonatomic,assign)AutoCellCreaterTableViewType createrType;

@property(nonatomic,copy)acct_tableViewDidSelectRowAtIndexPath acct_tableViewDidSelectRowAtIndexPathBlock;
-(void)setAcct_tableViewDidSelectRowAtIndexPathBlock:(acct_tableViewDidSelectRowAtIndexPath)acct_tableViewDidSelectRowAtIndexPathBlock;

@property(nonatomic,copy)acct_numberOfSectionsInTableView acct_numberOfSectionsInTableViewBlock;
-(void)setAcct_numberOfSectionsInTableViewBlock:(acct_numberOfSectionsInTableView)acct_numberOfSectionsInTableViewBlock;

@property(nonatomic,copy)acct_numberOfRowsInSection acct_numberOfRowsInSectionBlock;
-(void)setAcct_numberOfRowsInSectionBlock:(acct_numberOfRowsInSection)acct_numberOfRowsInSectionBlock;

@property(nonatomic,copy)acct_scrollViewDidScroll acct_scrollViewDidScrollBlock;
-(void)setAcct_scrollViewDidScrollBlock:(acct_scrollViewDidScroll)acct_scrollViewDidScrollBlock;

#pragma mark - 通用模式调用
-(void)addHeaderInSection:(NSInteger)section headerView:(UIView*)headerView;
-(void)replaceHeaderInSection:(NSInteger)section headerView:(UIView*)headerView;
-(void)removeHeaderInSection:(NSInteger)section;

-(void)addFooterInSection:(NSInteger)section footerView:(UIView*)footerView;
-(void)replaceFooterInSection:(NSInteger)section footerView:(UIView*)footerView;
-(void)removeFooterInSection:(NSInteger)section;

-(void)acct_setViewForHeaderInSectionBlock:(acct_viewForHeaderInSection)viewBlock heightForHeaderInSection:(acct_heightForHeaderInSection)heightBlock;
-(void)acct_setViewForFooterInSectionBlock:(acct_viewForFooterInSection)viewBlock heightForFooterInSection:(acct_heightForFooterInSection)heightBlock;

-(void)acct_setEditingStyleForRowAtIndexPathBlock:(acct_editingStyleForRowAtIndexPath)editingStyleBlock commitEditingStyleBlock:(acct_commitEditingStyle)commitBlock;

#pragma mark -  仅支持AutoCellCreaterType_Order模式调用   插Cell形式，根据代码添加顺序插入
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
- (void (^)(void))acct_reloadData;


#pragma mark - 仅支持AutoCellCreaterType_Disorder模式调用   Block形式
-(void)addCellWithClass:(Class)cellClass heightForRowAtIndexPathBlock:(acct_heightForRowAtIndexPath)heightForRowAtIndexPathBlock;
-(void)addCellWithClass:(Class)cellClass createFilterBlock:(acct_createFilter)filterBlock heightForRowAtIndexPathBlock:(acct_heightForRowAtIndexPath)heightForRowAtIndexPathBlock;
-(void)addCellWithClass:(Class)cellClass customSetCellBlock:(acct_customSetCell)customSetCellBlock heightForRowAtIndexPathBlock:(acct_heightForRowAtIndexPath)heightForRowAtIndexPathBlock;
-(void)addCellWithClass:(Class)cellClass createFilterBlock:(acct_createFilter)filterBlock customSetCellBlock:(acct_customSetCell)customSetCellBlock heightForRowAtIndexPathBlock:(acct_heightForRowAtIndexPath)heightForRowAtIndexPathBlock;

-(void)addHeaderWithClass:(Class)cellClass createFilterBlock:(acct_createFilter)filterBlock customSetCellBlock:(acct_customSetCell)customSetCellBlock heightForRowAtIndexPathBlock:(acct_heightForRowAtIndexPath)heightForRowAtIndexPathBlock;
-(void)addFooterWithClass:(Class)cellClass createFilterBlock:(acct_createFilter)filterBlock customSetCellBlock:(acct_customSetCell)customSetCellBlock heightForRowAtIndexPathBlock:(acct_heightForRowAtIndexPath)heightForRowAtIndexPathBlock;


//根据AutoCellCreaterTableViewOrderProtocol自动实现高度及数据绑定创建cell，自动完成customSetCellBlock和heightForRowAtIndexPathBlock
-(void)addCellWithClass:(Class)cellClass getCellBindModelBlock:(acct_getCellBindModel)getCellBindModelBlock;
-(void)addCellWithClass:(Class)cellClass createFilterBlock:(acct_createFilter)filterBlock getCellBindModelBlock:(acct_getCellBindModel)getCellBindModelBlock;
-(void)addHeaderWithClass:(Class)cellClass createFilterBlock:(acct_createFilter)filterBlock getCellBindModelBlock:(acct_getCellBindModel)getCellBindModelBlock;
-(void)addFooterWithClass:(Class)cellClass createFilterBlock:(acct_createFilter)filterBlock getCellBindModelBlock:(acct_getCellBindModel)getCellBindModelBlock;

-(void)addCellWithClass:(Class)cellClass cellToBindModelBlock:(acct_cellToBindModel)cellToBindModelBlock;
-(void)addCellWithClass:(Class)cellClass createFilterBlock:(acct_createFilter)filterBlock cellToBindModelBlock:(acct_cellToBindModel)cellToBindModelBlock;
-(void)addHeaderWithClass:(Class)cellClass createFilterBlock:(acct_createFilter)filterBlock cellToBindModelBlock:(acct_cellToBindModel)cellToBindModelBlock;
-(void)addFooterWithClass:(Class)cellClass createFilterBlock:(acct_createFilter)filterBlock cellToBindModelBlock:(acct_cellToBindModel)cellToBindModelBlock;

@end

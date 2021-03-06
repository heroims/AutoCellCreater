//
//  AutoCellCreaterTableView.m
//  xgoods
//
//  Created by admin on 2017/1/17.
//  Copyright © 2017年 admin. All rights reserved.
//

#import "AutoCellCreaterTableView.h"
#import <objc/runtime.h>

static const void *acct_bindModelKey = &acct_bindModelKey;
static const void *acct_indexPathKey = &acct_indexPathKey;

@implementation UITableViewHeaderFooterView (AutoCellCreaterTableView)

@dynamic acct_bindModel;
@dynamic acct_indexPath;

-(void)setAcct_bindModel:(id)acct_bindModel{
    objc_setAssociatedObject(self, acct_bindModelKey, acct_bindModel, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(id)acct_bindModel{
    return objc_getAssociatedObject(self, acct_bindModelKey);
}

-(void)setAcct_indexPath:(NSIndexPath *)acct_indexPath{
    objc_setAssociatedObject(self, acct_indexPathKey, acct_indexPath, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(NSIndexPath *)acct_indexPath{
    return objc_getAssociatedObject(self, acct_indexPathKey);
}

-(void)_acct_setBindModel:(id)bindModel indexPath:(NSIndexPath*)indexPath{
    self.acct_bindModel=bindModel;
    self.acct_indexPath=indexPath;
    if ([self conformsToProtocol:objc_getProtocol("AutoCellCreaterTableViewOrderProtocol")]) {
        [(UITableView<AutoCellCreaterTableViewOrderProtocol>*)self acct_setBindModel:bindModel indexPath:indexPath];
    }
}

-(CGFloat)acct_getCellHeight{
    if ([self conformsToProtocol:objc_getProtocol("AutoCellCreaterTableViewOrderProtocol")]) {
        return [[self class] acct_getCellHeightWithModel:self.acct_bindModel indexPath:self.acct_indexPath];
    }
    return 45;
}

@end

@implementation UITableViewCell (AutoCellCreaterTableView)

@dynamic acct_bindModel;
@dynamic acct_indexPath;

-(void)setAcct_bindModel:(id)acct_bindModel{
    objc_setAssociatedObject(self, acct_bindModelKey, acct_bindModel, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(id)acct_bindModel{
    return objc_getAssociatedObject(self, acct_bindModelKey);
}

-(void)setAcct_indexPath:(NSIndexPath *)acct_indexPath{
    objc_setAssociatedObject(self, acct_indexPathKey, acct_indexPath, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(NSIndexPath *)acct_indexPath{
    return objc_getAssociatedObject(self, acct_indexPathKey);
}

-(void)_acct_setBindModel:(id)bindModel indexPath:(NSIndexPath*)indexPath{
    self.acct_bindModel=bindModel;
    self.acct_indexPath=indexPath;
    if ([self conformsToProtocol:objc_getProtocol("AutoCellCreaterTableViewOrderProtocol")]) {
        [(UITableView<AutoCellCreaterTableViewOrderProtocol>*)self acct_setBindModel:bindModel indexPath:indexPath];
    }
}

-(CGFloat)acct_getCellHeight{
    if ([self conformsToProtocol:objc_getProtocol("AutoCellCreaterTableViewOrderProtocol")]) {
        return [[self class] acct_getCellHeightWithModel:self.acct_bindModel indexPath:self.acct_indexPath];
    }
    return 45;
}

@end

typedef enum AutoCellCreaterTableViewActionType:NSInteger{
    AutoCellCreaterTableViewActionType_None,
    AutoCellCreaterTableViewActionType_Add,
    AutoCellCreaterTableViewActionType_Replace,
    AutoCellCreaterTableViewActionType_Remove
}AutoCellCreaterTableViewActionType;


@interface  AutoCellCreaterTableViewActionModel : NSObject

@property(nonatomic,assign)AutoCellCreaterTableViewActionType actionType;
@property(nonatomic,strong)NSIndexPath *indexPath;

-(id)initWithActionType:(AutoCellCreaterTableViewActionType)actionType indexPath:(NSIndexPath*)indexPath;

@end

@implementation AutoCellCreaterTableViewActionModel

-(id)initWithActionType:(AutoCellCreaterTableViewActionType)actionType indexPath:(NSIndexPath*)indexPath{
    if (self=[super init]) {
        self.actionType=actionType;
        self.indexPath=indexPath;
    }
    return self;
}

@end

typedef enum LastAddACCTableViewSectionType:NSInteger{
    LastAddACCTableViewSectionType_Header,
    LastAddACCTableViewSectionType_Footer
}LastAddACCTableViewSectionType;

@interface AutoCellCreaterTableView ()<UITableViewDelegate,UITableViewDataSource>{
    BOOL isNotFirstAddHeader;
    BOOL isNotFirstAddFooter;
    LastAddACCTableViewSectionType lastAddSectionType;
}

@property(nonatomic,strong)NSMutableDictionary *createrDisorderDic;

@property(nonatomic,strong)NSMutableDictionary *createrDic;

@property(nonatomic,assign)NSInteger createNumberOfSections;

@property(nonatomic,strong)AutoCellCreaterTableViewActionModel *toDoAction;

@property(nonatomic,copy)acct_viewForFooterInSection viewForFooterInSectionBlock;
@property(nonatomic,copy)acct_heightForFooterInSection heightForFooterInSectionBlock;
@property(nonatomic,copy)acct_viewForHeaderInSection viewForHeaderInSectionBlock;
@property(nonatomic,copy)acct_heightForHeaderInSection heightForHeaderInSectionBlock;
@property(nonatomic,copy)acct_editingStyleForRowAtIndexPath acct_editingStyleForRowAtIndexPathBlock;
@property(nonatomic,copy)acct_commitEditingStyle acct_commitEditingStyleBlock;

@end

@implementation AutoCellCreaterTableView

static NSString *const AutoCellCreaterTableViewItemTypeCell = @"AutoCellCreaterTableViewItemTypeCell";
static NSString *const AutoCellCreaterTableViewItemTypeHeader = @"AutoCellCreaterTableViewItemTypeHeader";
static NSString *const AutoCellCreaterTableViewItemTypeFooter = @"AutoCellCreaterTableViewItemTypeFooter";

-(id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style{
    if (self=[super initWithFrame:frame style:style]) {
        self.dataSource=self;
        self.delegate=self;
    }
    return self;
}

#pragma mark - block形式封装

-(void)acct_setViewForHeaderInSectionBlock:(acct_viewForHeaderInSection)viewBlock heightForHeaderInSection:(acct_heightForHeaderInSection)heightBlock{
    self.viewForHeaderInSectionBlock=viewBlock;
    self.heightForHeaderInSectionBlock=heightBlock;
}

-(void)acct_setViewForFooterInSectionBlock:(acct_viewForFooterInSection)viewBlock heightForFooterInSection:(acct_heightForFooterInSection)heightBlock{
    self.viewForFooterInSectionBlock=viewBlock;
    self.heightForFooterInSectionBlock=heightBlock;
}

-(void)acct_setEditingStyleForRowAtIndexPathBlock:(acct_editingStyleForRowAtIndexPath)editingStyleBlock commitEditingStyleBlock:(acct_commitEditingStyle)commitBlock{
    self.acct_editingStyleForRowAtIndexPathBlock=editingStyleBlock;
    self.acct_commitEditingStyleBlock=commitBlock;
}


-(void)addHeaderWithClass:(Class)cellClass createFilterBlock:(acct_createFilter)filterBlock customSetCellBlock:(acct_customSetCell)customSetCellBlock heightForRowAtIndexPathBlock:(acct_heightForRowAtIndexPath)heightForRowAtIndexPathBlock{
    [self addCellWithClass:cellClass createFilterBlock:filterBlock customSetCellBlock:customSetCellBlock heightForRowAtIndexPathBlock:heightForRowAtIndexPathBlock cellType:AutoCellCreaterTableViewItemTypeHeader];
}

-(void)addHeaderWithClass:(Class)cellClass createFilterBlock:(acct_createFilter)filterBlock getCellBindModelBlock:(acct_getCellBindModel)getCellBindModelBlock{
#ifdef RELEASE
#else
    NSAssert([cellClass conformsToProtocol:objc_getProtocol("AutoCellCreaterTableViewOrderProtocol")], @"未实现AutoCellCreaterTableViewOrderProtocol禁止使用");
#endif

    [self addCellWithClass:cellClass createFilterBlock:filterBlock customSetCellBlock:^(UITableView *tableView, UIView *tableViewCell, NSIndexPath *indexPath) {
        if (getCellBindModelBlock) {
            UITableViewHeaderFooterView<AutoCellCreaterTableViewOrderProtocol> *cell=(UITableViewHeaderFooterView<AutoCellCreaterTableViewOrderProtocol>*)tableViewCell;
            
            id bindModel=getCellBindModelBlock(tableView,indexPath);
            
            cell.acct_bindModel=bindModel;
            cell.acct_indexPath=indexPath;
            
            [cell acct_setBindModel:bindModel indexPath:indexPath];
        }
        
    } heightForRowAtIndexPathBlock:^CGFloat(UITableView *tableView, NSIndexPath *indexPath) {
        if (getCellBindModelBlock) {
            id bindModel=getCellBindModelBlock(tableView,indexPath);
            
            return [cellClass acct_getCellHeightWithModel:bindModel indexPath:indexPath];
        }
        return 0.1;
    } cellType:AutoCellCreaterTableViewItemTypeHeader];
}

-(void)addHeaderWithClass:(Class)cellClass createFilterBlock:(acct_createFilter)filterBlock cellToBindModelBlock:(acct_cellToBindModel)cellToBindModelBlock{
#ifdef RELEASE
#else
    NSAssert([cellClass conformsToProtocol:objc_getProtocol("AutoCellCreaterTableViewOrderProtocol")], @"未实现AutoCellCreaterTableViewOrderProtocol禁止使用");
#endif
    
    [self addCellWithClass:cellClass createFilterBlock:filterBlock customSetCellBlock:^(UITableView *tableView, UIView *tableViewCell, NSIndexPath *indexPath) {
        if (cellToBindModelBlock) {
            UITableViewHeaderFooterView<AutoCellCreaterTableViewOrderProtocol> *cell=(UITableViewHeaderFooterView<AutoCellCreaterTableViewOrderProtocol>*)tableViewCell;
            
            id bindModel=cellToBindModelBlock(tableView,cell,indexPath);
            
            cell.acct_bindModel=bindModel;
            cell.acct_indexPath=indexPath;
            
            [cell acct_setBindModel:bindModel indexPath:indexPath];
        }
        
    } heightForRowAtIndexPathBlock:^CGFloat(UITableView *tableView, NSIndexPath *indexPath) {
        if (cellToBindModelBlock) {
            id bindModel=cellToBindModelBlock(tableView,nil,indexPath);
            
            return [cellClass acct_getCellHeightWithModel:bindModel indexPath:indexPath];
        }
        return 0.1;
    } cellType:AutoCellCreaterTableViewItemTypeHeader];
}

-(void)addFooterWithClass:(Class)cellClass createFilterBlock:(acct_createFilter)filterBlock customSetCellBlock:(acct_customSetCell)customSetCellBlock heightForRowAtIndexPathBlock:(acct_heightForRowAtIndexPath)heightForRowAtIndexPathBlock{
    [self addCellWithClass:cellClass createFilterBlock:filterBlock customSetCellBlock:customSetCellBlock heightForRowAtIndexPathBlock:heightForRowAtIndexPathBlock cellType:AutoCellCreaterTableViewItemTypeFooter];
}

-(void)addFooterWithClass:(Class)cellClass createFilterBlock:(acct_createFilter)filterBlock getCellBindModelBlock:(acct_getCellBindModel)getCellBindModelBlock{
#ifdef RELEASE
#else
    NSAssert([cellClass conformsToProtocol:objc_getProtocol("AutoCellCreaterTableViewOrderProtocol")], @"未实现AutoCellCreaterTableViewOrderProtocol禁止使用");
#endif

    [self addCellWithClass:cellClass createFilterBlock:filterBlock customSetCellBlock:^(UITableView *tableView, UIView *tableViewCell, NSIndexPath *indexPath) {
        if (getCellBindModelBlock) {
            UITableViewHeaderFooterView<AutoCellCreaterTableViewOrderProtocol> *cell=(UITableViewHeaderFooterView<AutoCellCreaterTableViewOrderProtocol>*)tableViewCell;
            
            id bindModel=getCellBindModelBlock(tableView,indexPath);
            
            cell.acct_bindModel=bindModel;
            cell.acct_indexPath=indexPath;
            
            [cell acct_setBindModel:bindModel indexPath:indexPath];
        }
        
    } heightForRowAtIndexPathBlock:^CGFloat(UITableView *tableView, NSIndexPath *indexPath) {
        if (getCellBindModelBlock) {
            id bindModel=getCellBindModelBlock(tableView,indexPath);
            
            return [cellClass acct_getCellHeightWithModel:bindModel indexPath:indexPath];
        }
        return 0.1;
    } cellType:AutoCellCreaterTableViewItemTypeFooter];
}

-(void)addFooterWithClass:(Class)cellClass createFilterBlock:(acct_createFilter)filterBlock cellToBindModelBlock:(acct_cellToBindModel)cellToBindModelBlock{
#ifdef RELEASE
#else
    NSAssert([cellClass conformsToProtocol:objc_getProtocol("AutoCellCreaterTableViewOrderProtocol")], @"未实现AutoCellCreaterTableViewOrderProtocol禁止使用");
#endif
    
    [self addCellWithClass:cellClass createFilterBlock:filterBlock customSetCellBlock:^(UITableView *tableView, UIView *tableViewCell, NSIndexPath *indexPath) {
        if (cellToBindModelBlock) {
            UITableViewHeaderFooterView<AutoCellCreaterTableViewOrderProtocol> *cell=(UITableViewHeaderFooterView<AutoCellCreaterTableViewOrderProtocol>*)tableViewCell;
            
            id bindModel=cellToBindModelBlock(tableView,cell,indexPath);
            
            cell.acct_bindModel=bindModel;
            cell.acct_indexPath=indexPath;
            
            [cell acct_setBindModel:bindModel indexPath:indexPath];
        }
        
    } heightForRowAtIndexPathBlock:^CGFloat(UITableView *tableView, NSIndexPath *indexPath) {
        if (cellToBindModelBlock) {
            id bindModel=cellToBindModelBlock(tableView,nil,indexPath);
            
            return [cellClass acct_getCellHeightWithModel:bindModel indexPath:indexPath];
        }
        return 0.1;
    } cellType:AutoCellCreaterTableViewItemTypeFooter];
}

-(void)addCellWithClass:(Class)cellClass heightForRowAtIndexPathBlock:(acct_heightForRowAtIndexPath)heightForRowAtIndexPathBlock{
    
    [self addCellWithClass:cellClass createFilterBlock:nil customSetCellBlock:nil heightForRowAtIndexPathBlock:heightForRowAtIndexPathBlock];
}

-(void)addCellWithClass:(Class)cellClass createFilterBlock:(acct_createFilter)filterBlock heightForRowAtIndexPathBlock:(acct_heightForRowAtIndexPath)heightForRowAtIndexPathBlock{
    [self addCellWithClass:cellClass createFilterBlock:filterBlock customSetCellBlock:nil heightForRowAtIndexPathBlock:(acct_heightForRowAtIndexPath)heightForRowAtIndexPathBlock];
}

-(void)addCellWithClass:(Class)cellClass customSetCellBlock:(acct_customSetCell)customSetCellBlock heightForRowAtIndexPathBlock:(acct_heightForRowAtIndexPath)heightForRowAtIndexPathBlock{
    [self addCellWithClass:cellClass createFilterBlock:nil customSetCellBlock:customSetCellBlock heightForRowAtIndexPathBlock:heightForRowAtIndexPathBlock];
}

-(void)addCellWithClass:(Class)cellClass createFilterBlock:(acct_createFilter)filterBlock customSetCellBlock:(acct_customSetCell)customSetCellBlock heightForRowAtIndexPathBlock:(acct_heightForRowAtIndexPath)heightForRowAtIndexPathBlock {
    [self addCellWithClass:cellClass createFilterBlock:filterBlock customSetCellBlock:customSetCellBlock heightForRowAtIndexPathBlock:heightForRowAtIndexPathBlock cellType:AutoCellCreaterTableViewItemTypeCell];
}

-(void)addCellWithClass:(Class)cellClass getCellBindModelBlock:(acct_getCellBindModel)getCellBindModelBlock{
    [self addCellWithClass:cellClass createFilterBlock:nil getCellBindModelBlock:getCellBindModelBlock];
}

-(void)addCellWithClass:(Class)cellClass createFilterBlock:(acct_createFilter)filterBlock getCellBindModelBlock:(acct_getCellBindModel)getCellBindModelBlock{
#ifdef RELEASE
#else
    NSAssert([cellClass conformsToProtocol:objc_getProtocol("AutoCellCreaterTableViewOrderProtocol")], @"未实现AutoCellCreaterTableViewOrderProtocol禁止使用");
#endif

    [self addCellWithClass:cellClass createFilterBlock:filterBlock customSetCellBlock:^(UITableView *tableView, UIView *tableViewCell, NSIndexPath *indexPath) {
        if (getCellBindModelBlock) {
            UITableViewCell<AutoCellCreaterTableViewOrderProtocol> *cell=(UITableViewCell<AutoCellCreaterTableViewOrderProtocol>*)tableViewCell;
            
            id bindModel=getCellBindModelBlock(tableView,indexPath);
            
            cell.acct_bindModel=bindModel;
            cell.acct_indexPath=indexPath;
            
            [cell acct_setBindModel:bindModel indexPath:indexPath];
        }
    } heightForRowAtIndexPathBlock:^CGFloat(UITableView *tableView, NSIndexPath *indexPath) {
        if (getCellBindModelBlock) {
            id bindModel=getCellBindModelBlock(tableView,indexPath);
            
            return [cellClass acct_getCellHeightWithModel:bindModel indexPath:indexPath];
        }
        return 0;
    } cellType:AutoCellCreaterTableViewItemTypeCell];

}

-(void)addCellWithClass:(Class)cellClass cellToBindModelBlock:(acct_cellToBindModel)cellToBindModelBlock{
    [self addCellWithClass:cellClass createFilterBlock:nil cellToBindModelBlock:cellToBindModelBlock];
}

-(void)addCellWithClass:(Class)cellClass createFilterBlock:(acct_createFilter)filterBlock cellToBindModelBlock:(acct_cellToBindModel)cellToBindModelBlock{
#ifdef RELEASE
#else
    NSAssert([cellClass conformsToProtocol:objc_getProtocol("AutoCellCreaterTableViewOrderProtocol")], @"未实现AutoCellCreaterTableViewOrderProtocol禁止使用");
#endif
    
    [self addCellWithClass:cellClass createFilterBlock:filterBlock customSetCellBlock:^(UITableView *tableView, UIView *tableViewCell, NSIndexPath *indexPath) {
        if (cellToBindModelBlock) {
            UITableViewCell<AutoCellCreaterTableViewOrderProtocol> *cell=(UITableViewCell<AutoCellCreaterTableViewOrderProtocol>*)tableViewCell;
            
            id bindModel=cellToBindModelBlock(tableView,cell,indexPath);
            
            cell.acct_bindModel=bindModel;
            cell.acct_indexPath=indexPath;
            
            [cell acct_setBindModel:bindModel indexPath:indexPath];
        }
    } heightForRowAtIndexPathBlock:^CGFloat(UITableView *tableView, NSIndexPath *indexPath) {
        if (cellToBindModelBlock) {
            id bindModel=cellToBindModelBlock(tableView,nil,indexPath);
            
            return [cellClass acct_getCellHeightWithModel:bindModel indexPath:indexPath];
        }
        return 0;
    } cellType:AutoCellCreaterTableViewItemTypeCell];

}

-(void)addCellWithClass:(Class)cellClass createFilterBlock:(acct_createFilter)filterBlock customSetCellBlock:(acct_customSetCell)customSetCellBlock heightForRowAtIndexPathBlock:(acct_heightForRowAtIndexPath)heightForRowAtIndexPathBlock cellType:(NSString*)cellType{

    self.createrType=AutoCellCreaterTableViewType_Disorder;
    if ([cellType isEqualToString:AutoCellCreaterTableViewItemTypeCell]) {
#ifdef RELEASE
#else
        NSAssert([cellClass isKindOfClass:object_getClass([UITableViewCell class])], @"cell不是继承UITableViewCell的类");
#endif

        [self registerClass:cellClass forCellReuseIdentifier:NSStringFromClass(cellClass)];
    }
    if ([cellType isEqualToString:AutoCellCreaterTableViewItemTypeFooter]) {
#ifdef RELEASE
#else
        NSAssert([cellClass isKindOfClass:object_getClass([UITableViewHeaderFooterView class])], @"footer不是继承UITableViewHeaderFooterView的类");
#endif

        [self registerClass:cellClass forHeaderFooterViewReuseIdentifier:NSStringFromClass(cellClass)];
    }
    if ([cellType isEqualToString:AutoCellCreaterTableViewItemTypeHeader]) {
#ifdef RELEASE
#else
        NSAssert([cellClass isKindOfClass:object_getClass([UITableViewHeaderFooterView class])], @"header不是继承UITableViewHeaderFooterView的类");
#endif

        [self registerClass:cellClass forHeaderFooterViewReuseIdentifier:NSStringFromClass(cellClass)];
    }
    
    NSMutableDictionary *tmpCreaterDic=[[NSMutableDictionary alloc] init];
    if (cellClass) {
        [tmpCreaterDic setObject:cellClass forKey:@"cellClass"];
    }
    if (filterBlock) {
        [tmpCreaterDic setObject:[filterBlock copy] forKey:@"filterBlock"];
    }
    if (customSetCellBlock) {
        [tmpCreaterDic setObject:[customSetCellBlock copy] forKey:@"customSetCellBlock"];
    }
    if (heightForRowAtIndexPathBlock) {
        [tmpCreaterDic setObject:[heightForRowAtIndexPathBlock copy] forKey:@"heightForRowAtIndexPathBlock"];
    }
    
    NSMutableArray *tmpCreaterArray=self.createrDisorderDic[cellType];
    [tmpCreaterArray addObject:tmpCreaterDic];
    
    [self.createrDisorderDic setObject:tmpCreaterArray forKey:cellType];
}


#pragma mark - 插Cell封装

-(void)addHeaderWithHeaderView:(UIView*)headerView{
    if (isNotFirstAddHeader) {
        self.createNumberOfSections+=1;
    }
    isNotFirstAddHeader=YES;
    [self addHeaderInSection:self.createNumberOfSections headerView:headerView];
}

-(void)addHeaderInSection:(NSInteger)section headerView:(UIView*)headerView{
    self.createNumberOfSections=section;
    
    lastAddSectionType=LastAddACCTableViewSectionType_Header;
    
    NSString *indexPathString=[NSString stringWithFormat:@"header-%zi",section];
    [self.createrDic setObject:headerView forKey:indexPathString];
}

-(void)replaceHeaderInSection:(NSInteger)section headerView:(UIView*)headerView{
    self.createNumberOfSections=section;
    
    NSString *indexPathString=[NSString stringWithFormat:@"header-%zi",section];
    [self.createrDic setObject:headerView forKey:indexPathString];
}

-(void)removeHeaderInSection:(NSInteger)section{
    NSString *indexPathString=[NSString stringWithFormat:@"header-%zi",section];
    [self.createrDic removeObjectForKey:indexPathString];
}


-(void)addFooterWithFooterView:(UIView*)footerView{
    if (isNotFirstAddFooter&&lastAddSectionType==LastAddACCTableViewSectionType_Footer) {
        self.createNumberOfSections+=1;
    }
    isNotFirstAddFooter=YES;
    [self addFooterInSection:self.createNumberOfSections footerView:footerView];
}

-(void)addFooterInSection:(NSInteger)section footerView:(UIView*)footerView{
    self.createNumberOfSections=section;
    
    lastAddSectionType=LastAddACCTableViewSectionType_Footer;
    
    NSString *indexPathString=[NSString stringWithFormat:@"footer-%zi",section];
    [self.createrDic setObject:footerView forKey:indexPathString];
}

-(void)replaceFooterInSection:(NSInteger)section footerView:(UIView*)footerView{
    self.createNumberOfSections=section;
    
    NSString *indexPathString=[NSString stringWithFormat:@"footer-%zi",section];
    [self.createrDic setObject:footerView forKey:indexPathString];
}

-(void)removeFooterInSection:(NSInteger)section{
    NSString *indexPathString=[NSString stringWithFormat:@"footer-%zi",section];
    [self.createrDic removeObjectForKey:indexPathString];
}

-(void)addCellWithClass:(Class)cellClass bindModel:(id)bindModel{
    [self addCellWithClass:cellClass bindModel:bindModel customSetCellBlock:nil];
}
-(void)addCellWithClass:(Class)cellClass bindModel:(id)bindModel customSetCellBlock:(acct_customSetCell)customSetCellBlock{
    NSMutableArray *tmpCellArr=self.createrDic[AutoCellCreaterTableViewItemTypeCell];
    
    [self addCellWithClass:cellClass bindModel:bindModel indexPath:[NSIndexPath indexPathForRow:((NSMutableArray*)tmpCellArr[self.createNumberOfSections]).count inSection:self.createNumberOfSections] customSetCellBlock:customSetCellBlock];
}

-(void)addCellWithClass:(Class)cellClass bindModel:(id)bindModel indexPath:(NSIndexPath *)indexPath{
    [self addCellWithClass:cellClass bindModel:bindModel indexPath:indexPath customSetCellBlock:nil];
}

-(void)addCellWithClass:(Class)cellClass bindModel:(id)bindModel indexPath:(NSIndexPath*)indexPath customSetCellBlock:(acct_customSetCell)customSetCellBlock{
#ifdef RELEASE
#else
    NSAssert([cellClass isKindOfClass:object_getClass([UITableViewCell class])], @"cell不是继承UITableViewCell的类");
#endif

    NSMutableArray *tmpCellArr=self.createrDic[AutoCellCreaterTableViewItemTypeCell];
    
    NSMutableDictionary *tmpCreaterDic=[[NSMutableDictionary alloc] init];
    if (bindModel) {
        [tmpCreaterDic setObject:bindModel forKey:@"bindModel"];
    }
    if (cellClass) {
        [tmpCreaterDic setObject:cellClass forKey:@"cellClass"];
    }
    if (customSetCellBlock) {
        [tmpCreaterDic setObject:[customSetCellBlock copy] forKey:@"customSetCellBlock"];
    }
    
    self.createNumberOfSections=indexPath.section;
    if (((NSMutableArray*)tmpCellArr[indexPath.section]).count>indexPath.row) {
        [tmpCellArr[indexPath.section] insertObject:tmpCreaterDic atIndex:indexPath.row];
        
    }
    else if(((NSMutableArray*)tmpCellArr[indexPath.section]).count==indexPath.row){
        [tmpCellArr[indexPath.section] addObject:tmpCreaterDic];
    }
    else{
#ifdef RELEASE
#else
        NSAssert(false, @"添加的元素太跳跃了看仔细indexPath");
#endif
    }
}

-(void)replaceCellWithClass:(Class)cellClass bindModel:(id)bindModel indexPath:(NSIndexPath*)indexPath{
    [self replaceCellWithClass:cellClass bindModel:bindModel indexPath:indexPath customSetCellBlock:nil];
}

-(void)replaceCellWithClass:(Class)cellClass bindModel:(id)bindModel indexPath:(NSIndexPath*)indexPath customSetCellBlock:(acct_customSetCell)customSetCellBlock{
    NSMutableArray *tmpCellArr=self.createrDic[AutoCellCreaterTableViewItemTypeCell];
    
    NSMutableDictionary *tmpCreaterDic=[[NSMutableDictionary alloc] init];
    if (bindModel) {
        [tmpCreaterDic setObject:bindModel forKey:@"bindModel"];
    }
    if (cellClass) {
        [tmpCreaterDic setObject:cellClass forKey:@"cellClass"];
    }
    if (customSetCellBlock) {
        [tmpCreaterDic setObject:[customSetCellBlock copy] forKey:@"customSetCellBlock"];
    }
    
    if (tmpCellArr.count>indexPath.section&&((NSMutableArray*)tmpCellArr[indexPath.section]).count>indexPath.row) {
        [(NSMutableArray*)tmpCellArr[indexPath.section] replaceObjectAtIndex:indexPath.row withObject:tmpCreaterDic];
    }
    else{
#ifdef RELEASE
#else
        NSAssert(false, @"未找到该元素");
#endif
    }
    
}

-(void)removeCellWithIndexPath:(NSIndexPath*)indexPath{
    NSMutableArray *tmpCellArr=self.createrDic[AutoCellCreaterTableViewItemTypeCell];
    if (tmpCellArr.count>indexPath.section&&((NSMutableArray*)tmpCellArr[indexPath.section]).count>indexPath.row) {
        [(NSMutableArray*)tmpCellArr[indexPath.section] removeObjectAtIndex:indexPath.row];
    }
    else{
#ifdef RELEASE
#else
        NSAssert(false, @"未找到该元素");
#endif
    }
}

-(void)removeCellsWithSection:(NSInteger)section{
    NSMutableArray *tmpCellArr=self.createrDic[AutoCellCreaterTableViewItemTypeCell];
    if (tmpCellArr.count>section) {
        [tmpCellArr[section] removeAllObjects];
    }
    [self reloadData];
}

#pragma mark - 链式语法封装

- (AutoCellCreaterTableView * (^)(Class cellClass,id bindModel,NSIndexPath *indexPath,acct_customSetCell customSetCellBlock))acct_addCell{
    AutoCellCreaterTableView *(^acct_addCellBlock)(Class cellClass,id bindModel,NSIndexPath *indexPath,acct_customSetCell customSetCellBlock)=^(Class cellClass,id bindModel,NSIndexPath *indexPath,acct_customSetCell customSetCellBlock){
        [self addCellWithClass:cellClass bindModel:bindModel indexPath:indexPath customSetCellBlock:customSetCellBlock];
        self.toDoAction=[[AutoCellCreaterTableViewActionModel alloc] initWithActionType:AutoCellCreaterTableViewActionType_Add indexPath:indexPath];
        return self;
    };
    return acct_addCellBlock;
}

- (AutoCellCreaterTableView * (^)(Class cellClass,id bindModel,NSIndexPath *indexPath,acct_customSetCell customSetCellBlock))acct_replaceCell{
    AutoCellCreaterTableView *(^acct_replaceCellBlock)(Class cellClass,id bindModel,NSIndexPath *indexPath,acct_customSetCell customSetCellBlock)=^(Class cellClass,id bindModel,NSIndexPath *indexPath,acct_customSetCell customSetCellBlock){
        [self replaceCellWithClass:cellClass bindModel:bindModel indexPath:indexPath customSetCellBlock:customSetCellBlock];
        self.toDoAction=[[AutoCellCreaterTableViewActionModel alloc] initWithActionType:AutoCellCreaterTableViewActionType_Replace indexPath:indexPath];
        return self;
    };
    return acct_replaceCellBlock;
}

- (AutoCellCreaterTableView * (^)(NSIndexPath *indexPath))acct_removeCell{
    AutoCellCreaterTableView *(^acct_removeCellBlock)(NSIndexPath *indexPath)=^(NSIndexPath *indexPath){
        [self removeCellWithIndexPath:indexPath];
        self.toDoAction=[[AutoCellCreaterTableViewActionModel alloc] initWithActionType:AutoCellCreaterTableViewActionType_Remove indexPath:indexPath];
        return self;
    };
    return acct_removeCellBlock;
}

- (void (^)(void))acct_reloadData{
    void (^acct_reloadDataBlock)(void)= ^(void){
        self.acct_reloadDataAnimation(UITableViewRowAnimationNone);
    };
    return acct_reloadDataBlock;
}

- (void (^)(UITableViewRowAnimation animation))acct_reloadDataAnimation{
    void (^acct_reloadDataAnimationBlock)(UITableViewRowAnimation animation)=^(UITableViewRowAnimation animation){
        if (self.toDoAction) {
            switch (self.toDoAction.actionType) {
                case AutoCellCreaterTableViewActionType_Add:{
                    [self beginUpdates];
                    [self insertRowsAtIndexPaths:@[self.toDoAction.indexPath] withRowAnimation:animation];
                    [self endUpdates];
                    break;
                }
                case AutoCellCreaterTableViewActionType_Remove:{
                    [self beginUpdates];
                    [self deleteRowsAtIndexPaths:@[self.toDoAction.indexPath] withRowAnimation:animation];
                    [self endUpdates];
                    break;
                }
                case AutoCellCreaterTableViewActionType_Replace:{
                    [self beginUpdates];
                    [self reloadRowsAtIndexPaths:@[self.toDoAction.indexPath] withRowAnimation:animation];
                    [self endUpdates];
                    break;
                }
                default:
                    [self reloadData];
                    break;
            }
            self.toDoAction=nil;
        }
        else{
            [self reloadData];
        }
    };
    return acct_reloadDataAnimationBlock;
}


#pragma mark - UITableViewDataSource - UITableViewDelegate
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.createrType==AutoCellCreaterTableViewType_Order) {
        NSMutableArray *tmpCellArr=self.createrDic[AutoCellCreaterTableViewItemTypeCell];
        
        if (tmpCellArr.count>indexPath.section&&((NSMutableArray*)tmpCellArr[indexPath.section]).count>indexPath.row) {
            NSMutableDictionary *tmpCreaterDic=((NSMutableArray*)tmpCellArr[indexPath.section])[indexPath.row];
            NSString *cellIdentifier=NSStringFromClass(tmpCreaterDic[@"cellClass"]);
            
            UITableViewCell * autoCreateCell = [self dequeueReusableCellWithIdentifier:cellIdentifier];
            if (!autoCreateCell) {
                autoCreateCell = [((UITableViewCell*)[tmpCreaterDic[@"cellClass"] alloc]) initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            }
            [autoCreateCell _acct_setBindModel:tmpCreaterDic[@"bindModel"] indexPath:indexPath];
            acct_customSetCell customSetCellBlock=tmpCreaterDic[@"customSetCellBlock"];
            if (customSetCellBlock) {
                customSetCellBlock(self,autoCreateCell,indexPath);
            }
            return autoCreateCell;
        }
        
    }
    
    if (self.createrType==AutoCellCreaterTableViewType_Disorder) {
        NSArray *createrArray=self.createrDisorderDic[AutoCellCreaterTableViewItemTypeCell];
        
        if (createrArray.count<1) {
            return nil;
        }
        for (NSDictionary *createrDic in createrArray) {
            acct_createFilter filterBlock=createrDic[@"filterBlock"];
            acct_customSetCell customSetCellBlock=createrDic[@"customSetCellBlock"];
            
            if (filterBlock==nil||filterBlock(tableView,indexPath)) {
                Class cellClass=createrDic[@"cellClass"];
                NSString *cellIdentifier=NSStringFromClass(cellClass);
                UITableViewCell * autoCreateCell = [self dequeueReusableCellWithIdentifier:cellIdentifier];
                if (!autoCreateCell) {
                    autoCreateCell = [((UITableViewCell*)[cellClass alloc]) initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
                }
                if (customSetCellBlock) {
                    customSetCellBlock(self,autoCreateCell,indexPath);
                }
                
                return autoCreateCell;
            }
        }
    }
    
    return nil;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    if (_viewForFooterInSectionBlock) {
        return _viewForFooterInSectionBlock(tableView,section);
    }
    if (self.createrType==AutoCellCreaterTableViewType_Disorder) {
        NSArray *createrArray=self.createrDisorderDic[AutoCellCreaterTableViewItemTypeFooter];
        NSIndexPath *indexPath=[NSIndexPath indexPathForRow:0 inSection:section];
        
        if (createrArray.count>0) {
            for (NSDictionary *createrDic in createrArray) {
                acct_createFilter filterBlock=createrDic[@"filterBlock"];
                acct_customSetCell customSetCellBlock=createrDic[@"customSetCellBlock"];
                
                if (filterBlock==nil||filterBlock(tableView,indexPath)) {
                    Class cellClass=createrDic[@"cellClass"];
                    NSString *cellIdentifier=NSStringFromClass(cellClass);
                    UITableViewHeaderFooterView * autoCreateCell = [self dequeueReusableHeaderFooterViewWithIdentifier:cellIdentifier];
                    if (!autoCreateCell) {
                        autoCreateCell = [((UITableViewHeaderFooterView*)[cellClass alloc]) initWithReuseIdentifier:cellIdentifier];
                    }
                    if (customSetCellBlock) {
                        customSetCellBlock(self,autoCreateCell,indexPath);
                    }
                    
                    return autoCreateCell;
                }
            }
        }
    }
    NSString *indexPathString=[NSString stringWithFormat:@"footer-%zi",section];
    return [self.createrDic objectForKey:indexPathString];
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (_viewForHeaderInSectionBlock) {
        return _viewForHeaderInSectionBlock(tableView,section);
    }
    if (self.createrType==AutoCellCreaterTableViewType_Disorder) {
        NSArray *createrArray=self.createrDisorderDic[AutoCellCreaterTableViewItemTypeHeader];
        NSIndexPath *indexPath=[NSIndexPath indexPathForRow:0 inSection:section];
        
        if (createrArray.count>0) {
            for (NSDictionary *createrDic in createrArray) {
                acct_createFilter filterBlock=createrDic[@"filterBlock"];
                acct_customSetCell customSetCellBlock=createrDic[@"customSetCellBlock"];
                
                if (filterBlock==nil||filterBlock(tableView,indexPath)) {
                    Class cellClass=createrDic[@"cellClass"];
                    NSString *cellIdentifier=NSStringFromClass(cellClass);
                    UITableViewHeaderFooterView * autoCreateCell = [self dequeueReusableHeaderFooterViewWithIdentifier:cellIdentifier];
                    if (!autoCreateCell) {
                        autoCreateCell = [((UITableViewHeaderFooterView*)[cellClass alloc]) initWithReuseIdentifier:cellIdentifier];
                    }
                    if (customSetCellBlock) {
                        customSetCellBlock(self,autoCreateCell,indexPath);
                    }
                    
                    return autoCreateCell;
                }
            }
        }
    }
    NSString *indexPathString=[NSString stringWithFormat:@"header-%zi",section];
    return [self.createrDic objectForKey:indexPathString];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (_acct_numberOfRowsInSectionBlock) {
        return _acct_numberOfRowsInSectionBlock(tableView,section);
    }
    NSMutableArray *tmpCellArr=self.createrDic[AutoCellCreaterTableViewItemTypeCell];
    if (tmpCellArr.count>section) {
        return ((NSMutableArray*)tmpCellArr[section]).count;
    }
    
    return 0;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (_acct_numberOfSectionsInTableViewBlock) {
        return _acct_numberOfSectionsInTableViewBlock(tableView);
    }
    return  self.createNumberOfSections+1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.createrType==AutoCellCreaterTableViewType_Disorder) {
        NSArray *createrArray=self.createrDisorderDic[AutoCellCreaterTableViewItemTypeCell];
        
        if (createrArray.count<1) {
            return 0;
        }
        for (NSDictionary *createrDic in createrArray) {
            acct_createFilter filterBlock=createrDic[@"filterBlock"];
            acct_heightForRowAtIndexPath heightForRowAtIndexPathBlock=createrDic[@"heightForRowAtIndexPathBlock"];
            if (filterBlock==nil||filterBlock(tableView,indexPath)) {
                if (heightForRowAtIndexPathBlock) {
                    return heightForRowAtIndexPathBlock(tableView,indexPath);
                }
            }
        }
    }
    if (self.createrType==AutoCellCreaterTableViewType_Order) {
        NSMutableArray *tmpCellArr=self.createrDic[AutoCellCreaterTableViewItemTypeCell];
        if (tmpCellArr.count>indexPath.section&&((NSMutableArray*)tmpCellArr[indexPath.section]).count>indexPath.row) {
            NSMutableDictionary *tmpCreaterDic=((NSMutableArray*)tmpCellArr[indexPath.section])[indexPath.row];
            Class cellClass=[tmpCreaterDic objectForKey:@"cellClass"];
            
            return [cellClass acct_getCellHeightWithModel:tmpCreaterDic[@"bindModel"] indexPath:indexPath];
        }
    }
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    double footerHeight=0.1;
    if (_heightForFooterInSectionBlock) {
        footerHeight=_heightForFooterInSectionBlock(tableView,section);
    }
    else{
        if (self.createrType==AutoCellCreaterTableViewType_Disorder) {
            NSArray *createrArray=self.createrDisorderDic[AutoCellCreaterTableViewItemTypeFooter];
            
            if (createrArray.count<1) {
                footerHeight= 0;
            }
            for (NSDictionary *createrDic in createrArray) {
                acct_createFilter filterBlock=createrDic[@"filterBlock"];
                acct_heightForRowAtIndexPath heightForRowAtIndexPathBlock=createrDic[@"heightForRowAtIndexPathBlock"];
                if (filterBlock==nil||filterBlock(tableView,[NSIndexPath indexPathForRow:0 inSection:section])) {
                    if (heightForRowAtIndexPathBlock) {
                        footerHeight= heightForRowAtIndexPathBlock(tableView,[NSIndexPath indexPathForRow:0 inSection:section]);
                    }
                }
            }
        }
    }
    NSString *indexPathString=[NSString stringWithFormat:@"footer-%zi",section];
    if ([self.createrDic objectForKey:indexPathString]) {
        footerHeight=((UIView*)[self.createrDic objectForKey:indexPathString]).frame.size.height;
    }
    
    return footerHeight<=0?0.1:footerHeight;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    double headerHeight=0.1;
    if (_heightForHeaderInSectionBlock) {
        headerHeight=_heightForHeaderInSectionBlock(tableView,section);
    }
    else{
        if (self.createrType==AutoCellCreaterTableViewType_Disorder) {
            NSArray *createrArray=self.createrDisorderDic[AutoCellCreaterTableViewItemTypeHeader];
            
            if (createrArray.count<1) {
                headerHeight= 0;
            }
            for (NSDictionary *createrDic in createrArray) {
                acct_createFilter filterBlock=createrDic[@"filterBlock"];
                acct_heightForRowAtIndexPath heightForRowAtIndexPathBlock=createrDic[@"heightForRowAtIndexPathBlock"];
                if (filterBlock==nil||filterBlock(tableView,[NSIndexPath indexPathForRow:0 inSection:section])) {
                    if (heightForRowAtIndexPathBlock) {
                        headerHeight= heightForRowAtIndexPathBlock(tableView,[NSIndexPath indexPathForRow:0 inSection:section]);
                    }
                }
            }
        }
    }
    NSString *indexPathString=[NSString stringWithFormat:@"header-%zi",section];
    if ([self.createrDic objectForKey:indexPathString]) {
        headerHeight=((UIView*)[self.createrDic objectForKey:indexPathString]).frame.size.height;
    }
    return headerHeight<=0?0.1:headerHeight;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (_acct_tableViewDidSelectRowAtIndexPathBlock) {
        _acct_tableViewDidSelectRowAtIndexPathBlock(tableView,indexPath);
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_acct_editingStyleForRowAtIndexPathBlock) {
        return _acct_editingStyleForRowAtIndexPathBlock(tableView,indexPath);
    }
    return UITableViewCellEditingStyleNone;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return (_acct_commitEditingStyleBlock&&_acct_editingStyleForRowAtIndexPathBlock);
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_acct_commitEditingStyleBlock) {
        _acct_commitEditingStyleBlock(tableView,editingStyle,indexPath);
    }
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (_acct_scrollViewDidScrollBlock) {
        _acct_scrollViewDidScrollBlock(scrollView);
    }
}

#pragma mark - Getter and Setter

-(NSMutableDictionary *)createrDisorderDic{
    if (!_createrDisorderDic) {
        _createrDisorderDic=[[NSMutableDictionary alloc] init];
        NSMutableArray *cellArr=[[NSMutableArray alloc] init];
        [_createrDisorderDic setObject:cellArr forKey:AutoCellCreaterTableViewItemTypeCell];
        
        NSMutableArray *headerArr=[[NSMutableArray alloc] init];
        [_createrDisorderDic setObject:headerArr forKey:AutoCellCreaterTableViewItemTypeHeader];
        
        
        NSMutableArray *footerArr=[[NSMutableArray alloc] init];
        [_createrDisorderDic setObject:footerArr forKey:AutoCellCreaterTableViewItemTypeFooter];
        
    }
    return _createrDisorderDic;
}

-(NSMutableDictionary *)createrDic{
    if (!_createrDic) {
        _createrDic=[[NSMutableDictionary alloc] init];
        
        NSMutableArray *cellArr=[[NSMutableArray alloc] init];
        [cellArr addObject:[[NSMutableArray alloc] init]];
        [_createrDic setObject:cellArr forKey:AutoCellCreaterTableViewItemTypeCell];
    }
    return _createrDic;
}

-(void)setCreateNumberOfSections:(NSInteger)createNumberOfSections{
    if (_createNumberOfSections>createNumberOfSections) {
        
    }
    else{
        _createNumberOfSections=createNumberOfSections;
        NSMutableArray *tmpCellArr=self.createrDic[AutoCellCreaterTableViewItemTypeCell];
        if (tmpCellArr.count<=_createNumberOfSections) {
            for (NSInteger i=0; i<=_createNumberOfSections+1-tmpCellArr.count; i++) {
                [tmpCellArr addObject:[[NSMutableArray alloc] init]];
            }
        }
        
    }
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

@end

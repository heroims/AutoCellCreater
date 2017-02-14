
//
//  AutoCellCreaterCollectionView.m
//  xgoods
//
//  Created by admin on 2017/1/18.
//  Copyright © 2017年 admin. All rights reserved.
//

#import "AutoCellCreaterCollectionView.h"
#import <objc/runtime.h>

static const void *accc_bindModelKey = &accc_bindModelKey;
static const void *accc_indexPathKey = &accc_indexPathKey;

@implementation UICollectionReusableView (AutoCellCreaterCollectionView)

@dynamic accc_bindModel;
@dynamic accc_indexPath;

-(void)setAccc_bindModel:(id)accc_bindModel{
    objc_setAssociatedObject(self, accc_bindModelKey, accc_bindModel, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(id)accc_bindModel{
    return objc_getAssociatedObject(self, accc_bindModelKey);
}

-(void)setAccc_indexPath:(NSIndexPath *)accc_indexPath{
    objc_setAssociatedObject(self, accc_indexPathKey, accc_indexPath, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(NSIndexPath *)accc_indexPath{
    return objc_getAssociatedObject(self, accc_indexPathKey);
}

-(void)_accc_setBindModel:(id)bindModel indexPath:(NSIndexPath*)indexPath{
    self.accc_bindModel=bindModel;
    self.accc_indexPath=indexPath;
    if ([self conformsToProtocol:objc_getProtocol("AutoCellCreaterCollectionViewOrderProtocol")]) {
        [(UICollectionViewCell<AutoCellCreaterCollectionViewOrderProtocol>*)self accc_setBindModel:bindModel indexPath:indexPath];
    }
}

-(CGSize)accc_getCellSize{
    if ([self conformsToProtocol:objc_getProtocol("AutoCellCreaterCollectionViewOrderProtocol")]) {
        return [[self class] accc_getCellSizeWithModel:self.accc_bindModel indexPath:self.accc_indexPath];
    }
    return CGSizeMake(100, 100);
}

@end

typedef enum AutoCellCreaterCollectionViewActionType:NSInteger{
    AutoCellCreaterCollectionViewActionType_None,
    AutoCellCreaterCollectionViewActionType_Add,
    AutoCellCreaterCollectionViewActionType_Replace,
    AutoCellCreaterCollectionViewActionType_Remove
}AutoCellCreaterCollectionViewActionType;


@interface  AutoCellCreaterCollectionViewActionModel : NSObject

@property(nonatomic,assign)AutoCellCreaterCollectionViewActionType actionType;
@property(nonatomic,strong)NSIndexPath *indexPath;

-(id)initWithActionType:(AutoCellCreaterCollectionViewActionType)actionType indexPath:(NSIndexPath*)indexPath;

@end

@implementation AutoCellCreaterCollectionViewActionModel

-(id)initWithActionType:(AutoCellCreaterCollectionViewActionType)actionType indexPath:(NSIndexPath*)indexPath{
    if (self=[super init]) {
        self.actionType=actionType;
        self.indexPath=indexPath;
    }
    return self;
}

@end

typedef enum LastAddACCCollectionViewSectionType:NSInteger{
    LastAddACCCollectionViewSectionType_Header,
    LastAddACCCollectionViewSectionType_Footer
}LastAddACCCollectionViewSectionType;

@interface AutoCellCreaterCollectionView ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>{
    BOOL isNotFirstAddHeader;
    BOOL isNotFirstAddFooter;
    LastAddACCCollectionViewSectionType lastAddSectionType;
}

@property(nonatomic,strong)NSMutableArray *createrArrary;

@property(nonatomic,strong)NSMutableDictionary *createrDic;

@property(nonatomic,assign)NSInteger createNumberOfSections;

@property(nonatomic,strong)AutoCellCreaterCollectionViewActionModel *toDoAction;

@property(nonatomic,copy)accc_viewForFooterInSection viewForFooterInSectionBlock;
@property(nonatomic,copy)accc_referenceSizeForFooterInSection sizeForFooterInSectionBlock;
@property(nonatomic,copy)accc_viewForHeaderInSection viewForHeaderInSectionBlock;
@property(nonatomic,copy)accc_referenceSizeForHeaderInSection sizeForHeaderInSectionBlock;

@end

@implementation AutoCellCreaterCollectionView

-(id)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout{
    if (self=[super initWithFrame:frame collectionViewLayout:layout]) {
        self.dataSource=self;
        self.delegate=self;
    }
    return self;
}

-(void)accc_setViewForHeaderInSectionBlock:(accc_viewForHeaderInSection)viewBlock sizeForHeaderInSection:(accc_referenceSizeForHeaderInSection)sizeBlock{
    self.viewForHeaderInSectionBlock=viewBlock;
    self.sizeForHeaderInSectionBlock=sizeBlock;
}
-(void)accc_setViewForFooterInSectionBlock:(accc_viewForFooterInSection)viewBlock sizeForFooterInSection:(accc_referenceSizeForFooterInSection)sizeBlock{
    self.viewForFooterInSectionBlock=viewBlock;
    self.sizeForFooterInSectionBlock=sizeBlock;
}

-(void)addCellWithClass:(Class)cellClass sizeForItemAtIndexPathBlock:(accc_sizeForItemAtIndexPath)sizeForItemAtIndexPathBlock{
    
    [self addCellWithClass:cellClass createFilterBlock:nil customSetCellBlock:nil sizeForItemAtIndexPathBlock:sizeForItemAtIndexPathBlock];
}

-(void)addCellWithClass:(Class)cellClass createFilterBlock:(accc_createFilter)filterBlock sizeForItemAtIndexPathBlock:(accc_sizeForItemAtIndexPath)sizeForItemAtIndexPathBlock{
    [self addCellWithClass:cellClass createFilterBlock:filterBlock customSetCellBlock:nil sizeForItemAtIndexPathBlock:sizeForItemAtIndexPathBlock];
}

-(void)addCellWithClass:(Class)cellClass customSetCellBlock:(accc_customSetCell)customSetCellBlock sizeForItemAtIndexPathBlock:(accc_sizeForItemAtIndexPath)sizeForItemAtIndexPathBlock{
    [self addCellWithClass:cellClass createFilterBlock:nil customSetCellBlock:customSetCellBlock sizeForItemAtIndexPathBlock:sizeForItemAtIndexPathBlock];
}

-(void)addCellWithClass:(Class)cellClass createFilterBlock:(accc_createFilter)filterBlock customSetCellBlock:(accc_customSetCell)customSetCellBlock sizeForItemAtIndexPathBlock:(accc_sizeForItemAtIndexPath)sizeForItemAtIndexPathBlock{
    [self registerClass:cellClass forCellWithReuseIdentifier:NSStringFromClass(cellClass)];
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
    if (sizeForItemAtIndexPathBlock) {
        [tmpCreaterDic setObject:[sizeForItemAtIndexPathBlock copy] forKey:@"sizeForItemAtIndexPathBlock"];
    }
    
    [self.createrArrary addObject:tmpCreaterDic];
}

-(void)addHeaderWithHeaderClass:(Class)headerClass bindModel:(id)bindModel{
    if (isNotFirstAddHeader) {
        self.createNumberOfSections+=1;
    }
    isNotFirstAddHeader=YES;
    [self addHeaderInSection:self.createNumberOfSections headerClass:headerClass bindModel:bindModel];
}
-(void)addHeaderInSection:(NSInteger)section headerClass:(Class)headerClass bindModel:(id)bindModel{
    self.createNumberOfSections=section;
    
    lastAddSectionType=LastAddACCCollectionViewSectionType_Header;
    
    NSString *indexPathString=[NSString stringWithFormat:@"header-%zi",section];
    [self registerClass:headerClass forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:NSStringFromClass(headerClass)];
    NSMutableDictionary *tmpCreaterDic=[[NSMutableDictionary alloc] init];
    if (bindModel) {
        [tmpCreaterDic setObject:bindModel forKey:@"bindModel"];
    }
    if (headerClass) {
        [tmpCreaterDic setObject:headerClass forKey:@"headerClass"];
    }
    
    [self.createrDic setObject:tmpCreaterDic forKey:indexPathString];
}

-(void)replaceHeaderInSection:(NSInteger)section headerClass:(Class)headerClass bindModel:(id)bindModel{
    self.createNumberOfSections=section;
    
    NSString *indexPathString=[NSString stringWithFormat:@"header-%zi",section];
    [self registerClass:headerClass forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:NSStringFromClass(headerClass)];
    NSMutableDictionary *tmpCreaterDic=[[NSMutableDictionary alloc] init];
    if (bindModel) {
        [tmpCreaterDic setObject:bindModel forKey:@"bindModel"];
    }
    if (headerClass) {
        [tmpCreaterDic setObject:headerClass forKey:@"headerClass"];
    }
    
    [self.createrDic setObject:tmpCreaterDic forKey:indexPathString];
}

-(void)removeHeaderInSection:(NSInteger)section{
    NSString *indexPathString=[NSString stringWithFormat:@"header-%zi",section];
    [self.createrDic removeObjectForKey:indexPathString];
}

-(void)addFooterWithFooterClass:(Class)footerClass bindModel:(id)bindModel{
    if (isNotFirstAddFooter&&lastAddSectionType==LastAddACCCollectionViewSectionType_Footer) {
        self.createNumberOfSections+=1;
    }
    isNotFirstAddFooter=YES;
    [self addFooterInSection:self.createNumberOfSections footerClass:footerClass bindModel:bindModel];
}
-(void)addFooterInSection:(NSInteger)section footerClass:(Class)footerClass bindModel:(id)bindModel{
    self.createNumberOfSections=section;
    
    lastAddSectionType=LastAddACCCollectionViewSectionType_Footer;
    
    NSString *indexPathString=[NSString stringWithFormat:@"footer-%zi",section];
    [self registerClass:footerClass forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:NSStringFromClass(footerClass)];
    NSMutableDictionary *tmpCreaterDic=[[NSMutableDictionary alloc] init];
    if (bindModel) {
        [tmpCreaterDic setObject:bindModel forKey:@"bindModel"];
    }
    if (footerClass) {
        [tmpCreaterDic setObject:footerClass forKey:@"headerClass"];
    }
    
    [self.createrDic setObject:tmpCreaterDic forKey:indexPathString];
}

-(void)replaceFooterInSection:(NSInteger)section footerClass:(Class)footerClass bindModel:(id)bindModel{
    self.createNumberOfSections=section;
    
    NSString *indexPathString=[NSString stringWithFormat:@"footer-%zi",section];
    [self registerClass:footerClass forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:NSStringFromClass(footerClass)];
    NSMutableDictionary *tmpCreaterDic=[[NSMutableDictionary alloc] init];
    if (bindModel) {
        [tmpCreaterDic setObject:bindModel forKey:@"bindModel"];
    }
    if (footerClass) {
        [tmpCreaterDic setObject:footerClass forKey:@"headerClass"];
    }
    
    [self.createrDic setObject:tmpCreaterDic forKey:indexPathString];
}

-(void)removeFooterInSection:(NSInteger)section{
    NSString *indexPathString=[NSString stringWithFormat:@"footer-%zi",section];
    [self.createrDic removeObjectForKey:indexPathString];
}

-(void)addCellWithClass:(Class)cellClass bindModel:(id)bindModel{
    NSMutableArray *tmpCellArr=self.createrDic[@"cell"];
    
    [self addCellWithClass:cellClass bindModel:bindModel indexPath:[NSIndexPath indexPathForItem:((NSMutableArray*)tmpCellArr[self.createNumberOfSections]).count inSection:self.createNumberOfSections]];
}

-(void)addCellWithClass:(Class)cellClass bindModel:(id)bindModel indexPath:(NSIndexPath*)indexPath{
    NSMutableArray *tmpCellArr=self.createrDic[@"cell"];

    NSString *cellIdentifier=NSStringFromClass(cellClass);
    [self registerClass:cellClass forCellWithReuseIdentifier:cellIdentifier];
    
    NSMutableDictionary *tmpCreaterDic=[[NSMutableDictionary alloc] init];
    if (bindModel) {
        [tmpCreaterDic setObject:bindModel forKey:@"bindModel"];
    }
    if (cellClass) {
        [tmpCreaterDic setObject:cellClass forKey:@"cellClass"];
    }
    
    self.createNumberOfSections=indexPath.section;
    if (((NSMutableArray*)tmpCellArr[indexPath.section]).count>indexPath.item) {
        [tmpCellArr[indexPath.section] insertObject:tmpCreaterDic atIndex:indexPath.item];
        
    }
    else if(((NSMutableArray*)tmpCellArr[indexPath.section]).count==indexPath.item){
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
    NSMutableArray *tmpCellArr=self.createrDic[@"cell"];
    
    NSMutableDictionary *tmpCreaterDic=[[NSMutableDictionary alloc] init];
    if (bindModel) {
        [tmpCreaterDic setObject:bindModel forKey:@"bindModel"];
    }
    if (cellClass) {
        [tmpCreaterDic setObject:cellClass forKey:@"cellClass"];
    }
    if (tmpCellArr.count>indexPath.section&&((NSMutableArray*)tmpCellArr[indexPath.section]).count>indexPath.item) {
        [(NSMutableArray*)tmpCellArr[indexPath.section] replaceObjectAtIndex:indexPath.item withObject:tmpCreaterDic];
    }
    else{
#ifdef RELEASE
#else
        NSAssert(false, @"未找到该元素");
#endif
    }
    
}

-(void)removeCellWithIndexPath:(NSIndexPath*)indexPath{
    NSMutableArray *tmpCellArr=self.createrDic[@"cell"];
    if (tmpCellArr.count>indexPath.section&&((NSMutableArray*)tmpCellArr[indexPath.section]).count>indexPath.item) {
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
    NSMutableArray *tmpCellArr=self.createrDic[@"cell"];
    if (tmpCellArr.count>section) {
        [tmpCellArr[section] removeAllObjects];
    }
}

- (AutoCellCreaterCollectionView * (^)(Class cellClass,id bindModel,NSIndexPath *indexPath))accc_addCell{
    AutoCellCreaterCollectionView *(^accc_addCellBlock)()=^(Class cellClass,id bindModel,NSIndexPath *indexPath){
        [self addCellWithClass:cellClass bindModel:bindModel indexPath:indexPath];
        self.toDoAction=[[AutoCellCreaterCollectionViewActionModel alloc] initWithActionType:AutoCellCreaterCollectionViewActionType_Add indexPath:indexPath];
        return self;
    };
    return accc_addCellBlock;
}

- (AutoCellCreaterCollectionView * (^)(Class cellClass,id bindModel,NSIndexPath *indexPath))accc_replaceCell{
    AutoCellCreaterCollectionView *(^accc_replaceCellBlock)()=^(Class cellClass,id bindModel,NSIndexPath *indexPath){
        [self replaceCellWithClass:cellClass bindModel:bindModel indexPath:indexPath];
        self.toDoAction=[[AutoCellCreaterCollectionViewActionModel alloc] initWithActionType:AutoCellCreaterCollectionViewActionType_Replace indexPath:indexPath];
        return self;
    };
    return accc_replaceCellBlock;
}

- (AutoCellCreaterCollectionView * (^)(NSIndexPath *indexPath))accc_removeCell{
    AutoCellCreaterCollectionView *(^accc_removeCellBlock)()=^(NSIndexPath *indexPath){
        [self removeCellWithIndexPath:indexPath];
        self.toDoAction=[[AutoCellCreaterCollectionViewActionModel alloc] initWithActionType:AutoCellCreaterCollectionViewActionType_Remove indexPath:indexPath];
        return self;
    };
    return accc_removeCellBlock;
}

- (void (^)())accc_reloadData{
    void (^accc_reloadDataBlock)()= ^(){
        if (self.toDoAction) {
            switch (self.toDoAction.actionType) {
                case AutoCellCreaterCollectionViewActionType_Add:{
                    [self reloadItemsAtIndexPaths:@[self.toDoAction.indexPath]];
                    break;
                }
                case AutoCellCreaterCollectionViewActionType_Remove:{
                    [self reloadItemsAtIndexPaths:@[self.toDoAction.indexPath]];
                    break;
                }
                case AutoCellCreaterCollectionViewActionType_Replace:{
                    [self reloadItemsAtIndexPaths:@[self.toDoAction.indexPath]];
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
    return accc_reloadDataBlock;
}

#pragma mark - UICollectionViewDelegate - UICollectionViewDataSource - UICollectionViewDelegateFlowLayout

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    if (self.createrType==AutoCellCreaterCollectionViewType_Order) {
        NSMutableArray *tmpCellArr=self.createrDic[@"cell"];
        if (tmpCellArr.count>indexPath.section&&((NSMutableArray*)tmpCellArr[indexPath.section]).count>indexPath.item) {
            NSMutableDictionary *tmpCreaterDic=((NSMutableArray*)tmpCellArr[indexPath.section])[indexPath.item];
            NSString *cellIdentifier=NSStringFromClass(tmpCreaterDic[@"cellClass"]);
            
            UICollectionViewCell *cell=[self dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
            [cell _accc_setBindModel:tmpCreaterDic[@"bindModel"] indexPath:indexPath];
            
            return cell;
        }
    }
    
    if (self.createrType==AutoCellCreaterCollectionViewType_Disorder) {
        if (self.createrArrary.count<1) {
            return nil;
        }
        for (NSDictionary *createrDic in self.createrArrary) {
            accc_createFilter filterBlock=createrDic[@"filterBlock"];
            accc_customSetCell customSetCellBlock=createrDic[@"customSetCellBlock"];
            
            if (filterBlock==nil||filterBlock(collectionView,indexPath)) {
                Class cellClass=createrDic[@"cellClass"];
                NSString *cellIdentifier=NSStringFromClass(cellClass);
                UICollectionViewCell * autoCreateCell = [self dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
                if (customSetCellBlock) {
                    customSetCellBlock(self,autoCreateCell,indexPath);
                }
                
                return autoCreateCell;
            }
        }
    }
    
    return nil;
}

- (UICollectionReusableView *) collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *reusableview = nil;
    
    if (kind == UICollectionElementKindSectionHeader) {
        if (_viewForHeaderInSectionBlock) {
            reusableview=_viewForHeaderInSectionBlock(collectionView,indexPath.section);
            return reusableview;
        }
        
        NSString *indexPathString=[NSString stringWithFormat:@"header-%zi",indexPath.section];
        NSMutableDictionary *tmpCreaterDic=[self.createrDic objectForKey:indexPathString];
        NSString *headerIdentifier=NSStringFromClass(tmpCreaterDic[@"headerClass"]);
        
        reusableview=[self dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:headerIdentifier forIndexPath:indexPath];
        [reusableview _accc_setBindModel:tmpCreaterDic[@"bindModel"] indexPath:indexPath];
        
        return reusableview;
        
    }
    if (kind == UICollectionElementKindSectionFooter) {
        if (_viewForFooterInSectionBlock) {
            reusableview=_viewForFooterInSectionBlock(collectionView,indexPath.section);
            return reusableview;
        }
        NSString *indexPathString=[NSString stringWithFormat:@"footer-%zi",indexPath.section];
        NSMutableDictionary *tmpCreaterDic=[self.createrDic objectForKey:indexPathString];
        NSString *footIdentifier=NSStringFromClass(tmpCreaterDic[@"footerClass"]);
        
        reusableview=[self dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:footIdentifier forIndexPath:indexPath];
        [reusableview _accc_setBindModel:tmpCreaterDic[@"bindModel"] indexPath:indexPath];
        
        return reusableview;
    }
    
    return reusableview;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if (_accc_numberOfRowsInSectionBlock) {
        return _accc_numberOfRowsInSectionBlock(collectionView,section);
    }
    
    NSMutableArray *tmpCellArr=self.createrDic[@"cell"];
    if (tmpCellArr.count>section) {
        return ((NSMutableArray*)tmpCellArr[section]).count;
    }

    return 0;
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    if (_accc_numberOfSectionsInCollectionViewBlock) {
        return _accc_numberOfSectionsInCollectionViewBlock(collectionView);
    }
    return  self.createNumberOfSections+1;
}


-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    if (self.createrType==AutoCellCreaterCollectionViewType_Disorder) {
        if (self.createrArrary.count<1) {
            return CGSizeZero;
        }
        for (NSDictionary *createrDic in self.createrArrary) {
            accc_createFilter filterBlock=createrDic[@"filterBlock"];
            accc_sizeForItemAtIndexPath accc_sizeForItemAtIndexPathBlock=createrDic[@"accc_sizeForItemAtIndexPathBlock"];
            if (filterBlock==nil||filterBlock(collectionView,indexPath)) {
                if (accc_sizeForItemAtIndexPathBlock) {
                    return accc_sizeForItemAtIndexPathBlock(collectionView,collectionViewLayout,indexPath);
                }
            }
        }
    }
    if (self.createrType==AutoCellCreaterCollectionViewType_Order) {
        NSMutableArray *tmpCellArr=self.createrDic[@"cell"];
        if (tmpCellArr.count>indexPath.section&&((NSMutableArray*)tmpCellArr[indexPath.section]).count>indexPath.row) {
            NSMutableDictionary *tmpCreaterDic=((NSMutableArray*)tmpCellArr[indexPath.section])[indexPath.row];
            Class cellClass=[tmpCreaterDic objectForKey:@"cellClass"];
            return [cellClass accc_getCellSizeWithModel:tmpCreaterDic[@"bindModel"] indexPath:indexPath];
        }
    }
    return CGSizeZero;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    CGSize headerSize=CGSizeZero;
    if (_sizeForHeaderInSectionBlock) {
        headerSize=_sizeForHeaderInSectionBlock(collectionView,collectionViewLayout,section);
    }
    else{
        NSString *indexPathString=[NSString stringWithFormat:@"header-%zi",section];
        NSMutableDictionary *tmpCreaterDic=[self.createrDic objectForKey:indexPathString];
        Class cellClass=[tmpCreaterDic objectForKey:@"headerClass"];
        headerSize = [cellClass accc_getCellSizeWithModel:tmpCreaterDic[@"bindModel"] indexPath:[NSIndexPath indexPathForItem:0 inSection:section]];
    }
    return headerSize;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section{
    CGSize footerSize=CGSizeZero;
    if (_sizeForFooterInSectionBlock) {
        footerSize=_sizeForFooterInSectionBlock(collectionView,collectionViewLayout,section);
    }
    else{
        NSString *indexPathString=[NSString stringWithFormat:@"footer-%zi",section];
        NSMutableDictionary *tmpCreaterDic=[self.createrDic objectForKey:indexPathString];
        Class cellClass=[tmpCreaterDic objectForKey:@"footerClass"];
        footerSize = [cellClass accc_getCellSizeWithModel:tmpCreaterDic[@"bindModel"] indexPath:[NSIndexPath indexPathForItem:0 inSection:section]];
    }
    return footerSize;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (_accc_collectionViewDidSelectRowAtIndexPathBlock) {
        _accc_collectionViewDidSelectRowAtIndexPathBlock(collectionView,indexPath);
    }
}

#pragma mark - Getter and Setter

-(NSMutableArray *)createrArrary{
    if (!_createrArrary) {
        _createrArrary=[[NSMutableArray alloc] init];
    }
    return _createrArrary;
}

-(NSMutableDictionary *)createrDic{
    if (!_createrDic) {
        _createrDic=[[NSMutableDictionary alloc] init];
        NSMutableArray *cellArr=[[NSMutableArray alloc] init];
        [cellArr addObject:[[NSMutableArray alloc] init]];
        [_createrDic setObject:cellArr forKey:@"cell"];

    }
    return _createrDic;
}

-(void)setCreateNumberOfSections:(NSInteger)createNumberOfSections{
    if (_createNumberOfSections>createNumberOfSections) {
        
    }
    else{
        _createNumberOfSections=createNumberOfSections;
        NSMutableArray *tmpCellArr=self.createrDic[@"cell"];
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

//
//  ViewController.m
//  AutoCellCreaterDemo
//
//  Created by admin on 2017/2/4.
//  Copyright © 2017年 admin. All rights reserved.
//

#import "ViewController.h"

#import "AutoCellCreaterTableView.h"
#import "AutoCellCreaterCollectionView.h"

@interface TestCell : UICollectionViewCell<AutoCellCreaterCollectionViewOrderProtocol>

@end
@implementation TestCell

-(void)accc_setBindModel:(id)bindModel indexPath:(NSIndexPath *)indexPath{
    self.contentView.backgroundColor=[UIColor colorWithRed:(random()%255)/255. green:(random()%255)/255. blue:(random()%255)/255. alpha:1];
}
+(CGSize)accc_getCellSizeWithModel:(id)model indexPath:(NSIndexPath *)indexPath{
    if (indexPath.row==1) {
        return CGSizeMake(100, 100);
    }
    return CGSizeMake(200, 200);
}

@end

@interface TestHeader : UICollectionReusableView<AutoCellCreaterCollectionViewOrderProtocol>

@end

@implementation TestHeader

-(void)accc_setBindModel:(id)bindModel indexPath:(NSIndexPath *)indexPath{
    self.backgroundColor=[UIColor colorWithRed:(random()%255)/255. green:(random()%255)/255. blue:(random()%255)/255. alpha:1];
}

+(CGSize)accc_getCellSizeWithModel:(id)model indexPath:(NSIndexPath*)indexPath{
    if (indexPath.row==1) {
        return CGSizeMake([UIScreen mainScreen].bounds.size.width, 50);
    }
    return CGSizeMake([UIScreen mainScreen].bounds.size.width, 100);
}

@end

@interface TestAutoTabelViewCell1 : UITableViewCell<AutoCellCreaterTableViewOrderProtocol>

@end
@implementation TestAutoTabelViewCell1

-(void)acct_setBindModel:(id)bindModel indexPath:(NSIndexPath *)indexPath{
    self.textLabel.text=[NSString stringWithFormat:@"%zi-%zi",indexPath.section,indexPath.row];
}

+(CGFloat)acct_getCellHeightWithModel:(id)model indexPath:(NSIndexPath*)indexPath{
    if (indexPath.row==1) {
        return 100;
    }
    return 50;
}


@end

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //插入式写法UITableView
    AutoCellCreaterTableView *tableView1=[[AutoCellCreaterTableView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width/2., self.view.bounds.size.height/2.) style:UITableViewStylePlain];
    UILabel *lbl=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 20)];
    lbl.text=@"dsfsdf";
    [tableView1 addHeaderWithHeaderView:lbl];
    [tableView1 addCellWithClass:[TestAutoTabelViewCell1 class] bindModel:nil];
    [tableView1 addCellWithClass:[TestAutoTabelViewCell1 class] bindModel:nil];
    [tableView1 addCellWithClass:[TestAutoTabelViewCell1 class] bindModel:nil];
    [tableView1 addCellWithClass:[TestAutoTabelViewCell1 class] bindModel:nil];
    UILabel *lbl2=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 20)];
    lbl2.text=@"sdfasdf";
    [tableView1 addFooterWithFooterView:lbl2];
    
    UILabel *lbl1=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 20)];
    lbl1.text=@"dddddd";
    [tableView1 addHeaderWithHeaderView:lbl1];
    [tableView1 addCellWithClass:[TestAutoTabelViewCell1 class] bindModel:nil];
    [tableView1 addCellWithClass:[TestAutoTabelViewCell1 class] bindModel:nil];
    [tableView1 addCellWithClass:[TestAutoTabelViewCell1 class] bindModel:nil indexPath:[NSIndexPath indexPathForRow:0 inSection:3]];
    [tableView1 addCellWithClass:[TestAutoTabelViewCell1 class] bindModel:nil];
    [self.view addSubview:tableView1];
    tableView1.acct_addCell([TestAutoTabelViewCell1 class],nil,[NSIndexPath indexPathForRow:0 inSection:1]).acct_reloadData();

    
    //逻辑写法UITableView，相当于delegate变成block
    AutoCellCreaterTableView *tableView2=[[AutoCellCreaterTableView alloc] initWithFrame:CGRectMake(self.view.bounds.size.width/2., 0, self.view.bounds.size.width/2., self.view.bounds.size.height/2.) style:UITableViewStylePlain];
    tableView2.createrType=AutoCellCreaterTableViewType_Disorder;
    [tableView2 addCellWithClass:NSClassFromString(@"TestAutoTabelViewCell1") createFilterBlock:nil customSetCellBlock:^(UITableView *tableView, UITableViewCell *tableViewCell, NSIndexPath *indexPath) {
        tableViewCell.textLabel.text=[NSString stringWithFormat:@"%zi-%zi",indexPath.section,indexPath.row];
        [tableViewCell setSelectionStyle:UITableViewCellSelectionStyleNone];
    } heightForRowAtIndexPathBlock:^CGFloat(UITableView *tableView, NSIndexPath *indexPath) {
        if (indexPath.row==1) {
            return 100;
        }
        return 50;
    }];
    [tableView2 setAcct_tableViewDidSelectRowAtIndexPathBlock:^(UITableView *tableView, NSIndexPath *indexPath) {
        NSLog(@"11111");
    }];
    [tableView2 setAcct_numberOfRowsInSectionBlock:^NSInteger(UITableView *tableView,NSInteger section){
        return 10;
    }];
    [self.view addSubview:tableView2];

    //插入式写法UICollectionView
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    AutoCellCreaterCollectionView *mainView = [[AutoCellCreaterCollectionView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height/2., self.view.bounds.size.width, self.view.bounds.size.height/2.) collectionViewLayout:flowLayout];
    [mainView addHeaderWithHeaderClass:[TestHeader class] bindModel:nil];
    [mainView addCellWithClass:NSClassFromString(@"TestCell") bindModel:nil];
    [mainView addCellWithClass:NSClassFromString(@"TestCell") bindModel:nil];
    [mainView addCellWithClass:NSClassFromString(@"TestCell") bindModel:nil];
    [mainView addHeaderWithHeaderClass:[TestHeader class] bindModel:nil];
    [mainView addCellWithClass:NSClassFromString(@"TestCell") bindModel:nil];
    [mainView addCellWithClass:NSClassFromString(@"TestCell") bindModel:nil];
    [mainView addCellWithClass:NSClassFromString(@"TestCell") bindModel:nil];
    [mainView addHeaderWithHeaderClass:[TestHeader class] bindModel:nil];
    [mainView addCellWithClass:NSClassFromString(@"TestCell") bindModel:nil];
    [mainView addCellWithClass:NSClassFromString(@"TestCell") bindModel:nil];
    [mainView addCellWithClass:NSClassFromString(@"TestCell") bindModel:nil];
    [mainView addCellWithClass:NSClassFromString(@"TestCell") bindModel:nil];
    [mainView addCellWithClass:NSClassFromString(@"TestCell") bindModel:nil];
    [mainView addCellWithClass:NSClassFromString(@"TestCell") bindModel:nil];
    [mainView addCellWithClass:NSClassFromString(@"TestCell") bindModel:nil];
    [mainView addCellWithClass:NSClassFromString(@"TestCell") bindModel:nil];
    [mainView addCellWithClass:NSClassFromString(@"TestCell") bindModel:nil];
    [mainView addCellWithClass:NSClassFromString(@"TestCell") bindModel:nil indexPath:[NSIndexPath indexPathForRow:0 inSection:4]];
    [mainView addCellWithClass:NSClassFromString(@"TestCell") bindModel:nil];
    [mainView removeHeaderInSection:0];
    [mainView removeCellWithIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
    
    [self.view addSubview:mainView];
    
    
    mainView.accc_addCell([TestCell class],nil,[NSIndexPath indexPathForItem:0 inSection:1]).accc_reloadData();


    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

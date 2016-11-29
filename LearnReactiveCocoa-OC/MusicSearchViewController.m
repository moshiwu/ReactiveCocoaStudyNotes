//
//  MusicSearchViewController.m
//  LearnReactiveCocoa-OC
//
//  Created by 莫锹文 on 2016/11/28.
//  Copyright © 2016年 莫锹文. All rights reserved.
//

#import "MusicSearchViewController.h"
#import "RACPlayGroundViewController+Example.h"
#import "NetworkManager.h"
#import "MusicSearchViewModel.h"
#import "UIImageView+WebCache.h"

@interface MusicSearchViewController () <UISearchBarDelegate, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITextField *searchBar;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) MusicSearchViewModel *viewModel;

@end

@implementation MusicSearchViewController

- (MusicSearchViewModel *)viewModel
{
	if (_viewModel == nil)
	{
		_viewModel = [MusicSearchViewModel new];
	}

	return _viewModel;
}

- (void)viewDidLoad
{
	[super viewDidLoad];

	[self initLayout];
	[self displayLayout];
	[self initOther];
}

- (void)initLayout
{
	self.searchBar = [[UITextField alloc] init];
//	self.searchBar.delegate = self;
	self.searchBar.borderStyle = UITextBorderStyleRoundedRect;

	self.searchBar.returnKeyType = UIReturnKeySearch;
	[self.view addSubview:self.searchBar];

	self.tableView = [UITableView new];
	self.tableView.delegate = self;
	self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	[self.view addSubview:self.tableView];
    
}

- (void)displayLayout
{
	MyWeakSelf;

	[self.searchBar mas_makeConstraints:^(MASConstraintMaker *make) {
		make.left.equalTo(ws.view.mas_left).offset(4);
		make.right.equalTo(ws.view.mas_right).offset(-4);
//		make.top.equalTo(ws.view.mas_top).offset(64);
        make.top.equalTo(ws.mas_topLayoutGuideBottom);
		make.height.equalTo(@30);
	}];

	[self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
		make.left.equalTo(ws.view.mas_left);
		make.right.equalTo(ws.view.mas_right);
		make.top.equalTo(ws.searchBar.mas_bottom);
		make.bottom.equalTo(ws.view.mas_bottom);
	}];
}

- (void)initOther
{
	self.title = @"搜索页面";

	RAC(self.viewModel, searchText) = self.searchBar.rac_textSignal;

	MyWeakSelf;

	[RACObserve(self.viewModel, response) subscribeNext:^(id _Nullable x) {
		NSLog(@"response change : %@", x);

		[ws.tableView reloadData];
	}];
}

#pragma mark - UITableView Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return self.viewModel.response.musics.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *name = @"123";

	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:name];

	if (cell == nil)
	{
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:name];
        
        UIImageView *myImageView = [[UIImageView alloc] init];
        myImageView.tag = 101;
        [cell.contentView addSubview:myImageView];
        
        [myImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(cell.contentView.mas_left).offset(12);
            make.top.equalTo(cell.contentView.mas_top).offset(8);
            make.bottom.equalTo(cell.contentView.mas_bottom).offset(-8);
            make.width.equalTo(myImageView.mas_height);
        }];
        
        UILabel *label = [UILabel new];
        label.numberOfLines = 0;
        label.tag = 102;
        [cell.contentView addSubview:label];
        
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(myImageView.mas_right).offset(8);
            make.height.equalTo(cell.contentView.mas_height );
            make.right.equalTo(cell.contentView.mas_right).offset(-8);
            make.centerY.equalTo(cell.contentView.mas_centerY);
        }];
	}

    
	DouBanSearchResponseSubMusic *musicModel = self.viewModel.response.musics[indexPath.row];

	NSString *path = musicModel.image;
    
    
    UIImageView *imageView = [cell viewWithTag:101];
    
    [imageView sd_setImageWithURL:[NSURL URLWithString:path] placeholderImage:nil options:SDWebImageProgressiveDownload completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (image == nil) {
            return;
        }
        imageView.image = image;
    }];
    
    UILabel *label = [cell viewWithTag:102];
    label.text = musicModel.title;
	return cell;
}

@end

//
//  Created by Ole Gammelgaard Poulsen on 05/12/13.
//  Copyright (c) 2012 SHAPE A/S. All rights reserved.
//

#import "SubscribeViewController.h"
#import "SubscribeViewModel.h"
#import "Masonry.h"
@interface SubscribeViewController ()

@property (nonatomic, strong) SubscribeViewModel *viewModel;

@property (nonatomic, strong) UITextField *emailTextField;
@property (nonatomic, strong) UIButton *subscribeButton;
@property (nonatomic, strong) UILabel *statusLabel;

@end

@implementation SubscribeViewController {}

#pragma mark - Life cycle methods

- (id)init
{
	self = [super init];

	if (self)
	{
		self.viewModel = [SubscribeViewModel new];
	}
	return self;
}

- (void)viewDidLoad
{
	[super viewDidLoad];

	self.title = NSLocalizedString(@"Subscribe Example", nil);

	[self addViews];
	[self defineLayout];
	[self bindWithViewModel];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];

//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
////        self.emailTextField.text = @"111@qq.com";
//        self.viewModel.email = @"222@qq.com";
//
//        [[self.viewModel.subscribeCommand execute:nil] subscribeCompleted:^{
//            NSLog(@"the command executed");
//        }];
//    });
}

#pragma mark -

- (void)addViews
{
	[self.view addSubview:self.emailTextField];
	[self.view addSubview:self.subscribeButton];
	[self.view addSubview:self.statusLabel];
}

- (void)defineLayout
{
	@weakify(self);

	[self.emailTextField mas_makeConstraints:^(MASConstraintMaker *make) {
		@strongify(self);
		make.top.equalTo(self.view).with.offset(100.f);
		make.left.equalTo(self.view).with.offset(20.f);
		make.height.equalTo(@50.f);
	}];

	[self.subscribeButton mas_makeConstraints:^(MASConstraintMaker *make) {
		@strongify(self);
		make.centerY.equalTo(self.emailTextField);
		make.right.equalTo(self.view).with.offset(-25.f);
		make.width.equalTo(@70.f);
		make.height.equalTo(@30.f);
		make.left.equalTo(self.emailTextField.mas_right).with.offset(20.f);
	}];

	[self.statusLabel mas_makeConstraints:^(MASConstraintMaker *make) {
		@strongify(self);
		make.top.equalTo(self.emailTextField.mas_bottom).with.offset(20.f);
		make.left.equalTo(self.emailTextField);
		make.right.equalTo(self.subscribeButton);
		make.height.equalTo(@30.f);
	}];
}

- (void)bindWithViewModel
{
	RAC(self.viewModel, email) = self.emailTextField.rac_textSignal;
	self.subscribeButton.rac_command = self.viewModel.subscribeCommand;
	RAC(self.statusLabel, text) = RACObserve(self.viewModel, statusMessage);

    RAC(self.emailTextField,text) = RACObserve(self.viewModel, email);

//    [RACSignal interval:1 onScheduler:[RACScheduler scheduler]]
    
//    RACSignal *timeSignal = [RACSignal interval:1 onScheduler:[RACScheduler mainThreadScheduler]];
//	RAC(self.emailTextField, text) = [[timeSignal startWith:[NSDate date]] map:^id (NSDate *value) {
//		NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitMinute | NSCalendarUnitSecond fromDate:value];
//		return [NSString stringWithFormat:@"%ld:%02ld", dateComponents.minute, dateComponents.second];
//	}];
}

#pragma mark - Views

- (UITextField *)emailTextField
{
	if (!_emailTextField)
	{
		_emailTextField = [UITextField new];
		_emailTextField.borderStyle = UITextBorderStyleRoundedRect;
		_emailTextField.font = [UIFont boldSystemFontOfSize:16];
		_emailTextField.placeholder = NSLocalizedString(@"Email address", nil);
		_emailTextField.keyboardType = UIKeyboardTypeEmailAddress;
		_emailTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
	}
	return _emailTextField;
}

- (UIButton *)subscribeButton
{
	if (!_subscribeButton)
	{
		_subscribeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		[_subscribeButton setTitle:NSLocalizedString(@"Subscribe", nil) forState:UIControlStateNormal];
	}
	return _subscribeButton;
}

- (UILabel *)statusLabel
{
	if (!_statusLabel)
	{
		_statusLabel = [UILabel new];
	}
	return _statusLabel;
}

@end

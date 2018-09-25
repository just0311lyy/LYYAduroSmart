//
//  ASQRCodeViewController.m
//  AduroSmart
//
//  Created by MacBook on 16/7/12.
//  Copyright © 2016年 MacBook. All rights reserved.
//

#import "ASQRCodeViewController.h"
#import "ASRootTabBarViewController.h"
#import "ASDeviceListViewController.h"
#import <AVFoundation/AVFoundation.h>

static const float QRCodeViewWidthOrHeight = 220; //正方形二维码的边长
static const float lineMinY = 80 + 64;
static const float lineMaxY = lineMinY + QRCodeViewWidthOrHeight;

@interface ASQRCodeViewController ()<AVCaptureMetadataOutputObjectsDelegate,UIAlertViewDelegate> // 用于处理采集信息的代理
/**
 *  会话, 输入输出的中间桥梁
 */
@property (nonatomic, strong) AVCaptureSession *qrSession;

/**
 *  读取
 */
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *qrVideoPreviewLayer;

/**
 *  交互线
 */
@property (nonatomic, strong) UIImageView *line;

/**
 *  交互线控制
 */
@property (nonatomic, strong) NSTimer *lineTimer;

@end

@implementation ASQRCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = [ASLocalizeConfig localizedString:@"二维码扫描"];
    [self initWithQRCode];
    [self setupScanWindowView]; //设置扫描二维码区域的视图
    [self beginQRCodeReading];  //开始扫码
    
    [self initWithNavBarBtn];
    
    
}
//-(void)viewDidAppear:(BOOL)animated{
//    [super viewDidAppear:animated];
//    if (!isInitUI) {
//        [self initWithQRCode];
//    }
//}

//导航栏左右按钮
-(void)initWithNavBarBtn
{
    UIView *barView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_ADURO_WIDTH,64)];
    barView.backgroundColor = LOGO_COLOR;
    [self.view addSubview:barView];
    
    UIButton *leftBarBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftBarBtn setBackgroundImage:[UIImage imageNamed:@"back_nav"] forState:UIControlStateNormal];
    [leftBarBtn addTarget:self action:@selector(backBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [barView addSubview:leftBarBtn];
    leftBarBtn.frame = CGRectMake(10, 20, 34, 34);
    //标题
    UILabel *titleLabel = [UILabel new];
    [barView addSubview:titleLabel];
    [titleLabel setTextColor:[UIColor whiteColor]];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [titleLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(barView.mas_top).offset(10);
        make.centerX.equalTo(barView.mas_centerX);
        make.width.equalTo(@(100));
        make.bottom.equalTo(barView.mas_bottom);
    }];
    [titleLabel setText:[ASLocalizeConfig localizedString:@"二维码扫描"]];

}

-(void)initWithQRCode{
    //获取摄像设备
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    //接收创建输入流的错误（没有错误为nil）
    NSError *error = nil;
    //创建输入流
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    if (error) {
        isInitUI = NO;
        NSLog(@"没有摄像头-%@",error.localizedDescription);
//        UIAlertController *alertCtrl = [UIAlertController alertControllerWithTitle:@"提示" message:@"请在隐私设置中打开摄像头" preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[ASLocalizeConfig localizedString:@"提示"] message:[ASLocalizeConfig localizedString:@"请在隐私设置中打开摄像头"] delegate:self cancelButtonTitle:[ASLocalizeConfig localizedString:@"取消"] otherButtonTitles:[ASLocalizeConfig localizedString:@"去设置"], nil];
        [alertView show];
        return;
    }
    isInitUI = YES;
    
    //设置输出（Metadata元数据）
    AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc] init];
    //设置输出的代理
    //使用主线程队列，响应比较同步；使用其他队列，响应不同步，容易让用户产生不好的体验
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    //有效的扫描区域。定位是以设置的右顶点为原点。屏幕宽所在的那条线为y轴，屏幕高所在的线为x轴
    CGFloat x = lineMinY / SCREEN_ADURO_HEIGHT;
    CGFloat y = ((SCREEN_ADURO_WIDTH-QRCodeViewWidthOrHeight)/2.0)/SCREEN_ADURO_WIDTH;
    CGFloat width = QRCodeViewWidthOrHeight/SCREEN_ADURO_HEIGHT;
    CGFloat height = QRCodeViewWidthOrHeight/SCREEN_ADURO_WIDTH;
    output.rectOfInterest = CGRectMake(x, y, width, height);
    //初始化链接对象
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
    // 高质量采集率
    [session setSessionPreset:AVCaptureSessionPresetHigh];
    [session addInput:input];
    [session addOutput:output];
    // 设置扫码支持的编码格式(如下设置条形码和二维码兼容)
    // 一定要先设置会话的输出为output之后，再指定输出的元数据类型
    //    output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode,AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code];
    [output setMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]];
    //设置预览图层
    AVCaptureVideoPreviewLayer *preView = [AVCaptureVideoPreviewLayer layerWithSession:session];
    //设置preView图层的属性
    preView.borderColor = [UIColor redColor].CGColor;
    preView.borderWidth = 1.5;
    [preView setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    //设置图层的大小
    preView.frame = self.view.layer.bounds;
    //将图层添加到视图的图层
    [self.view.layer insertSublayer:preView atIndex:0];
    self.qrVideoPreviewLayer = preView;
    self.qrSession = session;
   
}


-(void)setupScanWindowView{
    //设置扫描区域的位置
    UIView *scanCodeView = [[UIView alloc] initWithFrame:CGRectMake((SCREEN_ADURO_WIDTH - QRCodeViewWidthOrHeight)/2.0, lineMinY, QRCodeViewWidthOrHeight, QRCodeViewWidthOrHeight)];
    scanCodeView.clipsToBounds = YES; //子视图超出会被修剪掉
    scanCodeView.layer.borderColor = [UIColor whiteColor].CGColor;
    scanCodeView.layer.borderWidth = 1.0;
    [self.view addSubview:scanCodeView];
    
    //基准线
    _line = [[UIImageView alloc] initWithFrame:CGRectMake((SCREEN_ADURO_WIDTH - 300)/2.0, lineMinY, 300, 12*300/320)];
    [_line setImage:[UIImage imageNamed:@"QRCodeLine"]];
    [self.view addSubview:_line];
    
    //最上部view
    UIView *upView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_ADURO_WIDTH , lineMinY)];
    upView.alpha = 0.3;
    upView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:upView];
    
    //左侧view
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, lineMinY, (SCREEN_ADURO_WIDTH - QRCodeViewWidthOrHeight)/2.0, QRCodeViewWidthOrHeight)];
    leftView.alpha = 0.3;
    leftView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:leftView];
    
    //右侧view
    UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_ADURO_WIDTH - CGRectGetMaxX(leftView.frame), lineMinY,CGRectGetMaxX(leftView.frame),QRCodeViewWidthOrHeight)];
    rightView.alpha = 0.3;
    rightView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:rightView];
    
    //底部view
    UIView *downView = [[UIView alloc] initWithFrame:CGRectMake(0,lineMaxY, SCREEN_ADURO_WIDTH , SCREEN_ADURO_HEIGHT-lineMaxY)];
    downView.alpha = 0.3;
    downView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:downView];
    
    //四个边角
    //左上
    UIImage *cornerImage = [UIImage imageNamed:@"codeTopLeft.png"];
    UIImageView *top_left_imgView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(leftView.frame) , lineMinY , cornerImage.size.width , cornerImage.size.height)];
    top_left_imgView.image = cornerImage;
    [self.view addSubview:top_left_imgView];

    //右上
    cornerImage = [UIImage imageNamed:@"codeTopRight"];
    UIImageView *top_right_imgView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(scanCodeView.frame) - cornerImage.size.width , lineMinY , cornerImage.size.width , cornerImage.size.height )];
    top_right_imgView.image = cornerImage;
    [self.view addSubview:top_right_imgView];

    //左下
    cornerImage = [UIImage imageNamed:@"codeBottomLeft"];
    UIImageView *bottom_left_imgView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(leftView.frame) , lineMaxY - cornerImage.size.height , cornerImage.size.width , cornerImage.size.height)];
    bottom_left_imgView.image = cornerImage;
    [self.view addSubview:bottom_left_imgView];
    
    //右下
    cornerImage = [UIImage imageNamed:@"codeBottomRight"];
    UIImageView *bottom_right_imgView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(scanCodeView.frame) - cornerImage.size.width , lineMaxY - cornerImage.size.height , cornerImage.size.width , cornerImage.size.height)];
    bottom_right_imgView.image = cornerImage;
    [self.view addSubview:bottom_right_imgView];
    
    //说明label
    UILabel *instructionLb = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(leftView.frame), CGRectGetMinY(downView.frame) + 25, QRCodeViewWidthOrHeight, 40)];
    instructionLb.backgroundColor = [UIColor clearColor];
    instructionLb.textAlignment = NSTextAlignmentCenter;
    instructionLb.font = [UIFont boldSystemFontOfSize:13.0];
    instructionLb.textColor = [UIColor whiteColor];
    instructionLb.text = [ASLocalizeConfig localizedString:@"扫描网关背面二维码:\n将二维码置于框内, 即可自动扫描"];
    [instructionLb setLineBreakMode:NSLineBreakByWordWrapping];
    [instructionLb setNumberOfLines:2];
    [self.view addSubview:instructionLb];
 
}
#pragma mark - 扫码事件
//开始扫描
-(void)beginQRCodeReading{
    self.lineTimer = [NSTimer scheduledTimerWithTimeInterval:1.0/20 target:self selector:@selector(animationLine) userInfo:nil repeats:YES];
    [self.qrSession startRunning];
    NSLog(@"开始扫码……");
}

//停止扫描
-(void)stopQRCodeReading{
    
    if (self.lineTimer) {
        [self.lineTimer invalidate];
        self.lineTimer = nil;
    }
    [self.qrSession stopRunning];
    NSLog(@"停止扫码……");
}

//取消扫描
-(void)cancleQRCodeReading{
    [self stopQRCodeReading];
    if (self.ASQRCodeCancleBlock) {
        self.ASQRCodeCancleBlock(self);
    }
    NSLog(@"取消扫码……");
}
#pragma mark - 交互线上下滚动
-(void)animationLine{
    
    __block CGRect frame = self.line.frame;
    static BOOL flag = YES;

    if (flag) {
        frame.origin.y = lineMinY;
        flag = NO;
        [UIView animateWithDuration:1.0/20 animations:^{
            frame.origin.y +=5 ;
            self.line.frame = frame ;
        }];
    }else{
        if (self.line.frame.origin.y >= lineMinY) {
            if (self.line.frame.origin.y >= lineMaxY - 12) {
                frame.origin.y = lineMinY;
                self.line.frame = frame;
                
                flag = YES;
            }else{
                
                [UIView animateWithDuration:1.0/20 animations:^{
                    frame.origin.y +=5 ;
                    self.line.frame = frame;
                }];
                
            }
        }else{
            flag = !flag;
        }
    }
}

#pragma mark - 输出代理方法
// 此方法是在识别到QRCode，并且完成转换
// 如果QRCode的内容越大，转换需要的时间就越长
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    // 扫描结果
    if (metadataObjects.count > 0)
    {
        [self stopQRCodeReading];
        
        AVMetadataMachineReadableCodeObject *obj = metadataObjects[0];
        
        if (obj.stringValue && ![obj.stringValue isEqualToString:@""] && obj.stringValue.length > 0)
        {
            if ([obj.stringValue length]>0)
            {
                if (self.ASQRCodeSuncessBlock) {
                    self.ASQRCodeSuncessBlock(self,obj.stringValue);
                }
            }
            else
            {
                if (self.ASQRCodeFailBlock) {
                    self.ASQRCodeFailBlock(self);
                }
            }
        }
        else
        {
            if (self.ASQRCodeFailBlock) {
                self.ASQRCodeFailBlock(self);
            }
        }
    }
    else
    {
        if (self.ASQRCodeFailBlock) {
            self.ASQRCodeFailBlock(self);
        }
    }

}

#pragma mark - buttonAction
-(void)backBtnClick{
    [self cancleQRCodeReading];
    //    [self.navigationController popViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIAlertViewDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

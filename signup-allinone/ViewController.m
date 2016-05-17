//
//  ViewController.m
//  signup-allinone
//
//  Created by 张海禄 on 16/5/12.
//  Copyright © 2016年 张海禄. All rights reserved.
//

#import "ViewController.h"
#import "AFNetworking.h"
#import "UIKit+AFNetworking.h"
#import "NSString+SCMyString.h"
#import "TFHpple.h"
#define CC_MD5_DIGEST_LENGTH    16
@interface ViewController ()<UIWebViewDelegate>
{
    NSMutableArray *listArray;
}
@property(nonatomic,strong) NSString * urlString;
@property(nonatomic,strong) NSString * tbs;

@end

@implementation ViewController




- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.urlString=@"http://wappass.baidu.com/passport/";
    
    UIWebView * webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 20, self.view.frame.size.width, self.view.frame.size.height-20)];
    webView.tag=1;
    webView.backgroundColor=[UIColor whiteColor];
    webView.delegate=self;
    webView.userInteractionEnabled=YES;//让webView支持交互
    webView.scalesPageToFit=YES;//自动缩放以适应屏幕
    webView.scrollView.showsVerticalScrollIndicator=NO;//是否显示滚动条
    webView.scrollView.bounces=NO;//让webView无法滑动出界限
    NSURL * url = [NSURL URLWithString:self.urlString];
    [webView loadRequest:[NSURLRequest requestWithURL:url]];//远程读取网页
    [self.view addSubview:webView];

    
}

//获取贴吧列表
-(void)getlist{
    
    
    AFHTTPSessionManager * manger = [AFHTTPSessionManager manager];
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy defaultPolicy];
    securityPolicy.allowInvalidCertificates = YES;
    //    //2.设置返回数据类型 让其能接收Html数据
    manger.requestSerializer = [AFHTTPRequestSerializer serializer];
    manger.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manger GET:@"http://tieba.baidu.com/f/like/mylike?&pn=1" parameters:nil progress:nil success:^(NSURLSessionDataTask * task, id responseObject) {
        //解析HTML
        TFHpple * doc = [[TFHpple alloc] initWithHTMLData:responseObject];
        
        NSArray * tdArray = [doc searchWithXPathQuery:@"//a"];

        //这个数组中就有需要的值
        TFHppleElement * zongEle = [tdArray objectAtIndex:tdArray.count-1];
        
        //判断是否只有1页的情况
        if ([zongEle.content isEqualToString:@"尾页"]) {//不止一页的情况下
            NSString * yeshu = [NSString stringWithFormat:@"%@",[zongEle.attributes objectForKey:@"href"]];
            NSArray  * array= [yeshu componentsSeparatedByString:@"="];
            //解析出 总共有多少页
           NSMutableArray * arrList01 = [NSMutableArray array];
            for (int i=1; i<[array[1] intValue]+1; i++) {
                [manger GET:[NSString stringWithFormat:@"http://tieba.baidu.com/f/like/mylike?&pn=%d",i] parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                    TFHpple * doc01 = [[TFHpple alloc] initWithHTMLData:responseObject];
                    NSArray * tdArray01 = [doc01 searchWithXPathQuery:@"//tr"];  //这个数组中就有需要的值
                    if ([tdArray01 isKindOfClass:[NSArray class]]&&tdArray01.count>0) {
                        for (int j=1; j<tdArray01.count; j++) {
                            TFHppleElement * trEle01 = [tdArray01 objectAtIndex:j];
                            TFHppleElement * atitleEle01 = [[[trEle01.children objectAtIndex:0] children] objectAtIndex:0];
                          [arrList01 addObject:atitleEle01.content];
                            listArray=[NSMutableArray arrayWithArray:arrList01];
                        }
                    }

                } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                    ;
                }];
                
                }
            
        }else{
            //只要有1页的情况 HTML数据并放回
            TFHpple * doc01 = [[TFHpple alloc] initWithHTMLData:responseObject];
            NSArray * tdArray01 = [doc01 searchWithXPathQuery:@"//tr"];  //这个数组中就有需要的值
            NSMutableArray * arrList01 = [NSMutableArray array];
            if ([tdArray01 isKindOfClass:[NSArray class]]&&tdArray01.count>0) {
                for (int i=1; i<tdArray01.count; i++) {
                  
                    TFHppleElement * trEle01 = [tdArray01 objectAtIndex:i];
                    TFHppleElement * atitleEle01 = [[[trEle01.children objectAtIndex:0] children] objectAtIndex:0];
                    [arrList01 addObject:atitleEle01.content];
                    listArray=[NSMutableArray arrayWithArray:arrList01];
                }
            }
            
        }
        
        [[NSUserDefaults standardUserDefaults]setObject:listArray forKey:@"list"];
    }failure:^(NSURLSessionDataTask *task, NSError * error) {
        NSLog(@"error:%@",error);
    }];
    

    
}



// webView加载页面失败
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    
}
//加载完成(一键签到）
-(void)webViewDidFinishLoad:(UIWebView *)webView{
    
    NSString *BDuss=[[NSUserDefaults standardUserDefaults]stringForKey:@"BDuss"];
    self.tbs=[[NSUserDefaults standardUserDefaults]stringForKey:@"tbs"];
    
        [[NSUserDefaults standardUserDefaults]setObject:self.tbs forKey:@"tbs"];
    
        NSArray *list=[[NSUserDefaults standardUserDefaults]arrayForKey:@"list"];
    //每个贴吧签到
    if(list){
        for (int i=0; i<list.count; i++) {
        NSString *myKm=list[i];
        NSString * Md5Str = [NSString stringWithFormat:@"BDUSS=%@_client_id=03-00-DA-59-05-00-72-96-06-00-01-00-04-00-4C-43-01-00-34-F4-02-00-BC-25-09-00-4E-36_client_type=4_client_version=1.2.1.17_phone_imei=540b43b59d21b7a4824e1fd31b08e9a6kw=%@net_type=3tbs=%@tiebaclient!!!",BDuss,myKm,self.tbs];
        // 替换字符串中的其中一个字符
        NSString * TiStr = [Md5Str stringByReplacingOccurrencesOfString:@"&" withString:@""];
        NSString * MD5STR32 =[NSString md5:TiStr];
        NSString * DAMD5STR32 = [MD5STR32 uppercaseString];
        NSDictionary * dataDic = [NSDictionary dictionaryWithObjectsAndKeys:BDuss,@"BDUSS",@"03-00-DA-59-05-00-72-96-06-00-01-00-04-00-4C-43-01-00-34-F4-02-00-BC-25-09-00-4E-36",@"_client_id",@"4",@"_client_type",@"1.2.1.17",@"_client_version",@"540b43b59d21b7a4824e1fd31b08e9a6",@"_phone_imei",@"3",@"net_type",myKm,@"kw",self.tbs,@"tbs",DAMD5STR32,@"sign",nil];
        
    
        AFHTTPSessionManager * manger = [AFHTTPSessionManager manager];
        AFSecurityPolicy *securityPolicy = [AFSecurityPolicy defaultPolicy];
        securityPolicy.allowInvalidCertificates = YES;
        manger.requestSerializer = [AFHTTPRequestSerializer serializer];
        manger.responseSerializer = [AFHTTPResponseSerializer serializer];
    
        
        [manger POST:@"http://c.tieba.baidu.com/c/c/forum/sign" parameters:dataDic progress:nil  success:^(NSURLSessionDataTask * task, id responseObject) {
           
            NSLog(@"%@吧签到成功",list[i]);
        } failure:^(NSURLSessionDataTask * task, NSError *error) {
            NSLog(@"签到失败");
        }];
     }
    }
    
    }


- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    
    
    
    NSString *BDuss=[[NSString alloc]init];
    
    NSString *urlString = [[request URL] absoluteString];
    //登录成功后 调用的方法
    if ([urlString rangeOfString:@"uid"].location !=NSNotFound){
        //获取Cookies
        NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL: [NSURL URLWithString:@"http://wappass.baidu.com/passport/"]];
        
             //从Cookies获取Bduss
        for (int i=0; i<cookies.count; i++) {
            NSString * bdussStr = [NSString stringWithFormat:@"%@",[cookies objectAtIndex:i]];
            if ([bdussStr rangeOfString:@"BDUSS"].location !=NSNotFound) {
                NSArray  * array= [bdussStr componentsSeparatedByString:@"\""""];
                BDuss=[array objectAtIndex:3];
                [[NSUserDefaults standardUserDefaults]setObject:BDuss forKey:@"BDuss"];
                break;
            }
        }
        
        
         AFHTTPSessionManager * manger1 = [AFHTTPSessionManager manager];
        
        [manger1 POST:@"http://tieba.baidu.com/dc/common/tbs" parameters:nil progress:nil success:^(NSURLSessionDataTask * task, id responseObject) {
        
            self.tbs=[responseObject objectForKey:@"tbs"];
            
            [[NSUserDefaults standardUserDefaults]setObject:self.tbs forKey:@"tbs"];
            
            //获取贴吧列表
            [self getlist];
            
            
        } failure:^(NSURLSessionDataTask *  task, NSError * error) {
            NSLog(@"tbs 获取失败%@",error);
        }];
        

    }
    
    
    return YES;
}










- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

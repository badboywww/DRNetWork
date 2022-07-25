//
//  DRNetWorkTools.m
//  DRNetWork
//
//  Created by DevWang on 2022/7/25.
//

#import "DRNetWorkTools.h"
#import <AFNetworking/AFNetworking.h>
#import <SVProgressHUD/SVProgressHUD.h>
static AFHTTPSessionManager *manager;
static AFURLSessionManager  *session;

@implementation DRNetWorkTools

+ (DRNetWorkTools *)sharedManager {
    static DRNetWorkTools *_afn_tool = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _afn_tool = [[DRNetWorkTools alloc]init];
        [_afn_tool sharedHttpSession];
        [_afn_tool sharedURLSession];
    });
    return _afn_tool;
}


/// 判断当前网络状态
+ (NetworkStatus)getupCheckCurrentNetwork {
    /** 1.判断是否网络正常 */
    Reachability *reach = [Reachability reachabilityForInternetConnection];
    NetworkStatus status = [reach currentReachabilityStatus];
    
    return status;
}

- (AFHTTPSessionManager *)sharedHttpSession {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
         
        /** 1.判断是否网络正常 */
        Reachability *reach = [Reachability reachabilityForInternetConnection];
        NetworkStatus status = [reach currentReachabilityStatus];
        
        if (status == NotReachable) {
            [MBProgressHUD showToastAndMessage:@"没有网络，请检查您的网络" places:0 toView:nil];
            return;
        }
        
        //2.验证 HTTPS 请求的证书是否有效
        AFSecurityPolicy *securityPolicy = [[AFSecurityPolicy alloc] init];
        
        [securityPolicy setAllowInvalidCertificates:NO];
        
        manager.securityPolicy = securityPolicy;
        
        //3.开始网络请求
        manager = [AFHTTPSessionManager manager];
        
        // 3.1 请求序列化
        manager.requestSerializer = [AFHTTPRequestSerializer serializer];
        
        // 3.2 反馈数据序列化
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        
        manager.securityPolicy = [AFSecurityPolicy defaultPolicy];
        
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:
                                                                @"application/json",
                                                                @"application/octet-stream",
                                                                @"text/json",
                                                                @"text/javascript",
                                                                @"text/html",
                                                                @"text/plain",
                                                                
                                                                @"video/mp4",
                                                                @"video/mov",
                                                                @"video/avi",
                                                                
                                                                @"image/jpeg",
                                                                @"image/png",
                                                                
                                                                @"application/msword",
                                                                nil];
        
        manager.securityPolicy.allowInvalidCertificates = YES;
        
        manager.securityPolicy.validatesDomainName = NO;
        
        //超时时间：
        manager.requestSerializer.timeoutInterval = 30;
        
        [manager.requestSerializer setValue:@"app" forHTTPHeaderField:@"platform"];
        
        [manager.requestSerializer setValue:@"mobile" forHTTPHeaderField:@"User-Agent"];
    });
    
    return manager;
}

- (AFURLSessionManager *)sharedURLSession {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        session = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    });
    return session;
}


/// 失败请求返回
/// @param response response
/// @param error error
+ (NSString *)Response:(NSHTTPURLResponse *)response Error:(NSError *)error {
    //通讯协议状态码
    NSLog(@"error==%@",error.localizedFailureReason);
    
    NSInteger statusCode = response.statusCode;
    
    NSLog(@"statusCode=%ld",(long)statusCode);
    
    return [NSString stringWithFormat:@"statusCode:%ld\nError=%@",(long)statusCode,error.localizedFailureReason];
}



/// 请求成功返回
/// @param dict 成功字典
/// @param success 返回
+ (void)setupDict:(NSDictionary *)dict Success:(SuccessBlock)success {
    if ([[dict objectForKey:@"code"]integerValue] == -101) {
        [DRNetWorkTools getupBackLoginPage];
    }else{
        success(dict);
    }
}

/** 返回登录页面 */
+ (void)getupBackLoginPage {
//    RegisteredViewController *firstVc = [[RegisteredViewController alloc]init];
//    UINavigationController *nav=[[UINavigationController alloc]initWithRootViewController:firstVc];
//    [UIApplication sharedApplication].keyWindow.rootViewController = nav;
}

/// 头文件
- (NSDictionary *)setupHttpsHeader {
    NSMutableDictionary *headers = [[NSMutableDictionary alloc]init];
//    [manager.requestSerializer setValue:@"" forHTTPHeaderField:@"token"];
//    [headers setValue:@"" forKey:@"token"];
    return headers;
}

#pragma mark 基本请求方式

/// 基本请求方式
/// @param url API
/// @param thod 请求方式
/// @param params 参数
/// @param success 成功返回
/// @param failed 失败返回
- (void)netWorkWithURL:(NSString *)url
                method:(NetworkMethod)thod
                params:(nullable id)params
               success:(SuccessBlock)success
                failed:(FailedBlock)failed {
    
    switch (thod) {
        case GET:
            [self getDataForGETAndCompletedURL:url
                                        params:params
                                       success:success
                                        failed:failed];
            break;
        case POST:
            [self getDataForPOSTAndCompletedURL:url
                                         params:params
                                        success:success
                                         failed:failed];
            break;
        case PUT:
            break;
        case DELETE:
            break;
        default:
            break;
    }
}

/// get 方式获取数据
/// @param url API
/// @param params 参数
/// @param success 成功返回
/// @param failed 失败返回
- (void)getDataForGETAndCompletedURL:(NSString *)url
                              params:(nullable id)params
                             success:(SuccessBlock)success
                              failed:(FailedBlock)failed {
    
    [manager GET:url parameters:params headers:[self setupHttpsHeader] progress:^(NSProgress * _Nonnull downloadProgress) {
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSDictionary *dict = responseObject;
            [DRNetWorkTools setupDict:dict Success:success];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            failed([DRNetWorkTools Response:(NSHTTPURLResponse*)task.response Error:error]);
        }];
}

/// post 方式获取数据
/// @param url API
/// @param params 参数
/// @param success 成功返回
/// @param failed 失败返回
- (void)getDataForPOSTAndCompletedURL:(NSString *)url
                               params:(nullable id)params
                              success:(SuccessBlock)success
                               failed:(FailedBlock)failed {
    [manager POST:url parameters:params headers:[self setupHttpsHeader] progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dict = responseObject;
        [DRNetWorkTools setupDict:dict Success:success];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failed([DRNetWorkTools Response:(NSHTTPURLResponse*)task.response Error:error]);
    }];
}

#pragma mark 上传下载的请求

/// 单张图片上传
/// @param url API
/// @param image 图片
/// @param format 上传格式
/// @param params 参数
/// @param progress 进度
/// @param success 成功返回
/// @param failed 失败返回
- (void)netWorkImgaeWithURL:(NSString *)url
                      image:(UIImage *)image
                     format:(NetFormat)format
                     params:(nullable NSDictionary *)params
                   progress:(ProgressBlock)progress
                    success:(SuccessBlock)success
                     failed:(FailedBlock)failed {
    
    NSArray *array = [NSArray arrayWithObject:image];
    [self netWorkImgaesWithURL:url
                    imageArray:array
                        format:format
                        params:params
                      progress:progress
                       success:success
                        failed:failed];
}


/// 多张图片上传
/// @param url API
/// @param imageArray 图片组
/// @param format 上传格式
/// @param params 参数
/// @param progress 进度
/// @param success 成功返回
/// @param failed 失败返回
- (void)netWorkImgaesWithURL:(NSString *)url
                  imageArray:(NSArray *)imageArray
                      format:(NetFormat)format
                      params:(nullable NSDictionary *)params
                    progress:(ProgressBlock)progress
                     success:(SuccessBlock)success
                      failed:(FailedBlock)failed {
    
    [SVProgressHUD showProgress:-1 status:@"正在上传,请稍等."];
    
    [manager POST:url parameters:params headers:[self setupHttpsHeader] constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        for (int i = 0; i < imageArray.count; i++) {
            
            NSDateFormatter *formatter=[[NSDateFormatter alloc]init];
            formatter.dateFormat=@"yyyyMMddHHmmss";
            NSString *str=[formatter stringFromDate:[NSDate date]];
            NSString *fileName;
            
            UIImage *image=imageArray[i];
            NSData *imageData = UIImageJPEGRepresentation(image, 0.3);
            
            /*
             *该方法的参数
             1. appendPartWithFileData：要上传的照片[二进制流]
             2. name：对应网站上[upload.php中]处理文件的字段（比如upload）
             3. fileName：要保存在服务器上的文件名
             4. mimeType：上传的文件的类型
             */
            
            if (format == Jpg) {
                fileName = [NSString stringWithFormat:@"%@.jpg",str];
                [formData appendPartWithFileData:imageData name:@"file" fileName:fileName mimeType:@"image/jpeg"];
            }else if(format == Png){
                 fileName = [NSString stringWithFormat:@"%@.png",str];
                [formData appendPartWithFileData:imageData name:@"file" fileName:fileName mimeType:@"image/png"];
            }else{
                [MBProgressHUD showToastAndMessage:@"您需要上传个什么格式的图片呢？" places:0 toView:nil];
                return;
            }
        }
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        NSLog(@"uploadProgress is %lld,总字节 is %lld",uploadProgress.completedUnitCount,uploadProgress.totalUnitCount);
        NSLog(@"进度%f",uploadProgress.fractionCompleted);
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD showProgress:uploadProgress.fractionCompleted];
        });
        progress(uploadProgress);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSString *resultCode = [NSString stringWithFormat:@"%@",[responseObject objectForKey:@"code"]];
        NSString *resultInfo = [responseObject objectForKey:@"msg"];
        NSLog(@"resultInfo is %@",resultInfo);
        
        if ([resultCode longLongValue] > 0) {
            if (success == nil) return ;
            success(responseObject);
        }else {
            if (failed == nil) return ;
            NSHTTPURLResponse *response = (NSHTTPURLResponse*)task.response;
            //通讯协议状态码
            NSInteger statusCode = response.statusCode;
            NSLog(@"statusCode=%ld",(long)statusCode);
            failed([NSString stringWithFormat:@"%ld",(long)statusCode]);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [SVProgressHUD showErrorWithStatus:@"上传失败"];
        if (failed == nil) return ;
        failed([DRNetWorkTools Response:(NSHTTPURLResponse*)task.response Error:error]);
    }];
}

/// 上传视频
/// @param url API
/// @param params 参数
/// @param data 视频数据
/// @param progress 进度
/// @param success 成功返回
/// @param faild 失败返回
- (void)netWorkVideoWithURL:(NSString *)url
                     params:(nullable NSDictionary *)params
                       data:(NSData *)data
                   progress:(ProgressBlock)progress
                    success:(SuccessBlock)success
                     failed:(FailedBlock)faild {
    
    [manager POST:url parameters:params headers:[self setupHttpsHeader] constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat =@"yyyyMMddHHmmss";
        NSString *str = [formatter stringFromDate:[NSDate date]];
        NSLog(@"str:%@",str);
        NSString *fileName = [NSString stringWithFormat:@"%@.mp4", str];
        [formData appendPartWithFileData:data name:@"file" fileName:fileName mimeType:@"video/mpeg4"];
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        NSLog(@"uploadProgress is %lld,总字节 is %lld",uploadProgress.completedUnitCount,uploadProgress.totalUnitCount);
        NSLog(@"进度%f",uploadProgress.fractionCompleted);
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD showProgress:uploadProgress.fractionCompleted];
        });
        progress(uploadProgress);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSString *resultCode = [NSString stringWithFormat:@"%@",[responseObject objectForKey:@"code"]];
        NSString *resultInfo = [responseObject objectForKey:@"msg"];
        [SVProgressHUD dismiss];
        NSLog(@"resultInfo is %@",resultInfo);
        if ([resultCode integerValue] > 0) {
            if (success == nil) return ;
            success(responseObject);
        }else {
            [SVProgressHUD showErrorWithStatus:resultInfo];
            if (faild == nil) return ;
            NSHTTPURLResponse *response = (NSHTTPURLResponse*)task.response;
            //通讯协议状态码
            NSInteger statusCode = response.statusCode;
            NSLog(@"statusCode=%ld",(long)statusCode);
            faild([NSString stringWithFormat:@"%ld",(long)statusCode]);
            
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [SVProgressHUD showErrorWithStatus:@"上传失败"];
        [SVProgressHUD dismiss];
        if (faild == nil) return ;
        faild([DRNetWorkTools Response:(NSHTTPURLResponse*)task.response Error:error]);
    }];
}


/// 上传文件
/// @param url API
/// @param filePath 文件路径
/// @param format 文件格式
/// @param params 参数
/// @param progress 进度
/// @param success 成功返回
/// @param failed 失败返回
- (void)netWorkFileWithURL:(NSString *)url
                  filePath:(NSString *)filePath
                    format:(NetFormat)format
                    params:(nullable NSDictionary *)params
                  progress:(ProgressBlock)progress
                   success:(SuccessBlock)success
                    failed:(FailedBlock)failed {
    
    [SVProgressHUD showProgress:-1 status:@"正在上传,请稍等."];
    [manager POST:url parameters:params headers:[self setupHttpsHeader] constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        NSURL *fileUrl = [NSURL fileURLWithPath:filePath];
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat =@"yyyyMMddHHmmss";
        NSString *str = [formatter stringFromDate:[NSDate date]];
        NSLog(@"str:%@",str);
        
        NSString *fileName;
        
        if (format == Png) {
            fileName = [NSString stringWithFormat:@"%@_ios.png", str];
            [formData appendPartWithFileURL:fileUrl
                                       name:@"file"
                                   fileName:fileName
                                   mimeType:@"image/png"
                                      error:nil];
        }else if(format == Jpg){
            fileName = [NSString stringWithFormat:@"%@_ios.jpg", str];
            [formData appendPartWithFileURL:fileUrl
                                       name:@"file"
                                   fileName:fileName
                                   mimeType:@"image/jpeg"
                                      error:nil];
        }else if(format == Word){
            fileName = [NSString stringWithFormat:@"%@_ios.word", str];
            [formData appendPartWithFileURL:fileUrl
                                       name:@"file"
                                   fileName:fileName
                                   mimeType:@"application/msword"
                                      error:nil];
        }else if(format == Txt){
            fileName = [NSString stringWithFormat:@"%@_ios.txt", str];
            
            [formData appendPartWithFileURL:fileUrl
                                       name:@"files"
                                   fileName:fileName
                                   mimeType:@"text/plain"
                                      error:nil];
        }else if(format == Avi){
            fileName = [NSString stringWithFormat:@"%@_ios.avi", str];
            [formData appendPartWithFileURL:fileUrl
                                       name:@"file"
                                   fileName:fileName
                                   mimeType:@"tvideo/avi"
                                      error:nil];
        }else if(format == Mov){
            fileName = [NSString stringWithFormat:@"%@_ios.movie", str];
            [formData appendPartWithFileURL:fileUrl
                                       name:@"file"
                                   fileName:fileName
                                   mimeType:@"video/x-sgi-movie"
                                      error:nil];
        }else if(format == Mp4){
            fileName = [NSString stringWithFormat:@"%@_ios.mp4", str];
            [formData appendPartWithFileURL:fileUrl
                                       name:@"file"
                                   fileName:fileName
                                   mimeType:@"video/mpeg4"
                                      error:nil];
        }
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        NSLog(@"uploadProgress is %lld,总字节 is %lld",uploadProgress.completedUnitCount,uploadProgress.totalUnitCount);
        NSLog(@"进度%f",uploadProgress.fractionCompleted);
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD showProgress:uploadProgress.fractionCompleted];
        });
        progress(uploadProgress);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        success(responseObject);
        [SVProgressHUD showSuccessWithStatus:@"上传成功"];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [SVProgressHUD showErrorWithStatus:@"上传失败"];
        if (failed == nil) return ;
        failed([DRNetWorkTools Response:(NSHTTPURLResponse*)task.response Error:error]);
    }];
}


/// 利用队列上传多张图片-每次上传单张
/// @param imageArray 图片数组
/// @param format 图片格式
/// @param params 参数
/// @param success 成功返回
/// @param failed 失败返回
+ (void)netWorkWithUseQueueToUploadImageArray:(NSArray *)imageArray
                                       format:(NetFormat)format
                                       params:(nullable NSDictionary *)params
                                      success:(SuccessArrayBlock)success
                                       failed:(FailedArrayBlock)failed {
    
    NSString *upload_file_url = @"";
    
    /** 设置开启队列 */
    dispatch_group_t group = dispatch_group_create();
    
    /** 创建线程 */
//    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    
    /** 成功返回 */
    NSMutableArray *save_image_url_dataArray = [NSMutableArray array];
    
    /** 失败返回 */
    NSMutableArray *error_msg_Array = [NSMutableArray array];
    
    /** 设置队列循环次数  */
    for (int i = 0 ; i < imageArray.count; i++) {
        
        /** 开启线程队列 */
        dispatch_group_enter(group);
        
        /** 上传图片 网络请求 */
        [[DRNetWorkTools sharedManager] netWorkImgaeWithURL:upload_file_url
                                                      image:imageArray[i]
                                                     format:format
                                                     params:params
                                                   progress:^(NSProgress *progress) {
            
            NSLog(@"0------> 第 %d 张: %@",i+1,progress.localizedDescription);
            
            NSLog(@"1------> 第 %d 张: %@",i+1,progress.localizedAdditionalDescription);
            
            dispatch_async(dispatch_get_main_queue(), ^{
//                [MBProgressHUD showInfoMessage:[NSString stringWithFormat:@"第 %d 张:%@",i+1,progress.localizedDescription]];
                [SVProgressHUD showProgress:progress.fractionCompleted status:[NSString stringWithFormat:@"第 %d 张:%@",i+1,progress.localizedDescription]];
            });
            
           
        } success:^(NSDictionary * _Nonnull result) {
            NSLog(@"Success:%@",result);
            
            if ([[result objectForKey:@"code"]integerValue] > 0) {
                
                NSLog(@"Success: 第 %d 张成功。",i+1);
                
                dispatch_group_leave(group);
                
                @synchronized (save_image_url_dataArray) {
                    [save_image_url_dataArray addObject:[result objectForKey:@"url"]];
                }
                
               
            }else{
                NSLog(@"Error:%@",[NSString stringWithFormat:@"第 %d 张:%@",i+1,[result objectForKey:@"msg"]]);
                
                dispatch_group_leave(group);
                [error_msg_Array addObject:[NSString stringWithFormat:@"第 %d 张:%@",i+1,[result objectForKey:@"msg"]]];
            }
        } failed:^(NSString * _Nonnull result) {
            NSLog(@"Error:%@",[NSString stringWithFormat:@"第 %d 张:%@",i+1,result]);
            
            dispatch_group_leave(group);
            [error_msg_Array addObject:[NSString stringWithFormat:@"第 %d 张上传失败",i+1]];
            
        }];
        
    }
    
    /** 当队列完成时 返回队列信息 返回主队列 */
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        
        NSLog(@"success:%@",save_image_url_dataArray);
        NSLog(@"error:%@",error_msg_Array);
        [SVProgressHUD dismiss];
        success(save_image_url_dataArray);
        failed(error_msg_Array);
        
    });
}

/// 快速上传头像
/// @param avatar 头像
/// @param success 成功返回
/// @param Myprogress 进度
- (void)getUploadAvatar:(UIImage *)avatar
          successReturn:(SuccessString)success
               progress:(ProgressBlock)Myprogress {
    NSString *avatar_url = @"";
    NSDictionary *dict = @{
        @"type":@"avatar"
    };
    [[DRNetWorkTools sharedManager] netWorkImgaeWithURL:avatar_url
                                                  image:avatar
                                                 format:Jpg
                                                 params:dict
                                               progress:^(NSProgress *progress) {
        Myprogress(progress);
    } success:^(NSDictionary * _Nonnull result) {
        NSString *avatar = [NSString stringWithFormat:@"%@",[result objectForKey:@"url"]];
        success(avatar);
    } failed:^(NSString * _Nonnull result) {
        [MBProgressHUD showToastAndMessage:result places:0 toView:nil];
    }];
}

@end

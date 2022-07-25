//
//  DRNetWorkTools.h
//  DRNetWork
//
//  Created by DevWang on 2022/7/25.
//

#import <Foundation/Foundation.h>
#import <Reachability/Reachability.h>
#import "MBProgressHUD+Progress.h"

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    GET = 0,
    POST = 1,
    PUT  = 2,
    DELETE = 3,
} NetworkMethod;

typedef enum : NSUInteger {
    Jpg,
    Png,
    Word,
    Txt,
    Avi,
    Mov,
    Mp4,
    
    
} NetFormat;


typedef enum : NSUInteger {
    JSON,
    FORM_URLENCODED,
} RequestHeader;


typedef void(^SuccessBlock)(id); // 返回数组格式数据
typedef void(^FailedBlock)(id); // 返回数组格式数据
typedef void (^ProgressBlock)(NSProgress * _Nullable progress); //进度返回
typedef void(^SuccessArrayBlock)(NSMutableArray *result); // 返回数组格式数据
typedef void(^FailedArrayBlock)(NSMutableArray *result); // 返回数组格式数据
typedef void (^SuccessString)(NSString * _Nullable result);   // 文字版返回

@interface DRNetWorkTools : NSObject

+ (DRNetWorkTools *)sharedManager;

/// 判断当前网络状态
+ (NetworkStatus)getupCheckCurrentNetwork;

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
                failed:(FailedBlock)failed;


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
                     failed:(FailedBlock)failed;

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
                      failed:(FailedBlock)failed;

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
                     failed:(FailedBlock)faild;

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
                    failed:(FailedBlock)failed;

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
                                       failed:(FailedArrayBlock)failed;

/// 快速上传头像
/// @param avatar 头像
/// @param success 成功返回
/// @param Myprogress 进度
- (void)getUploadAvatar:(UIImage *)avatar
          successReturn:(SuccessString)success
               progress:(ProgressBlock)Myprogress;

@end

NS_ASSUME_NONNULL_END

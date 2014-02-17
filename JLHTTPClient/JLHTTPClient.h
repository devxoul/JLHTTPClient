//
//  JLHTTPClient.h
//  JLHTTPClient
//
//  Created by 전수열 on 13. 2. 23..
//  Copyright (c) 2013년 Joyfl. All rights reserved.
//

#import "AFNetworking.h"

@interface JLHTTPClient : NSObject

@property (nonatomic, strong) AFHTTPRequestOperationManager *manager;

@property (nonatomic, strong) NSString *consumerKey;
@property (nonatomic, strong) NSString *consumerSecret;


#pragma mark -

+ (id)defaultClient;

#pragma mark -

- (AFHTTPRequestOperation *)api:(NSString *)api
                         method:(NSString *)method
                     parameters:(NSDictionary *)parameters
                        success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                        failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

- (AFHTTPRequestOperation *)api:(NSString *)api
                         method:(NSString *)method
                     parameters:(NSDictionary *)parameters
                         upload:(void (^)(long long bytesLoaded, long long bytesTotal))upload
                       download:(void (^)(long long bytesLoaded, long long bytesTotal))download
                        success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                        failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;


#pragma mark -
#pragma mark Single image upload

- (AFHTTPRequestOperation *)api:(NSString *)api
                         method:(NSString *)method
                          image:(UIImage *)image
                        forName:(NSString *)name
                       fileName:(NSString *)fileName
                     parameters:(NSDictionary *)parameters
                        success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                        failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

- (AFHTTPRequestOperation *)api:(NSString *)api
                         method:(NSString *)method
                          image:(UIImage *)image
                        forName:(NSString *)name
                       fileName:(NSString *)fileName
                     parameters:(NSDictionary *)parameters
                         upload:(void (^)(long long bytesLoaded, long long bytesTotal))upload
                       download:(void (^)(long long bytesLoaded, long long bytesTotal))download
                        success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                        failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;


#pragma mark -
#pragma mark Multiple image upload

- (AFHTTPRequestOperation *)api:(NSString *)api
                         method:(NSString *)method
                         images:(NSArray *)images
                       forNames:(NSArray *)names
                      fileNames:(NSArray *)fileNames
                     parameters:(NSDictionary *)parameters
                        success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                        failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

- (AFHTTPRequestOperation *)api:(NSString *)api
                         method:(NSString *)method
                         images:(NSArray *)images
                       forNames:(NSArray *)names
                      fileNames:(NSArray *)fileNames
                     parameters:(NSDictionary *)parameters
                         upload:(void (^)(long long bytesLoaded, long long bytesTotal))upload
                       download:(void (^)(long long bytesLoaded, long long bytesTotal))download
                        success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                        failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;


#pragma mark -

- (AFHTTPRequestOperation *)sendRequest:(NSURLRequest *)request
								 upload:(void (^)(long long bytesLoaded, long long bytesTotal))upload
							   download:(void (^)(long long bytesLoaded, long long bytesTotal))download
                                success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                                failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;


#pragma mark -
#pragma mark OAuth

+ (JLHTTPClient *)OAuthLoaderWithConsumerKey:(NSString *)consumerKey
                              consumerSecret:(NSString *)consumerSecret;

- (void)OAuthRequestTokenWithURLString:(NSString *)urlString
								method:(NSString *)method
							parameters:(NSDictionary *)parameters
                              success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
							   failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

- (void)OAuthAccessTokenWithURLString:(NSString *)urlString
							   method:(NSString *)method
								token:(NSString *)token
							   secret:(NSString *)secret
							 verifier:(NSString *)verifier
                              success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                              failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

@end

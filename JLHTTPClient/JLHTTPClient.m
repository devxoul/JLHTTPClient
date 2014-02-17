//
//  JLHTTPClient.m
//  JLHTTPClient
//
//  Created by 전수열 on 13. 2. 23..
//  Copyright (c) 2013년 Joyfl. All rights reserved.
//

#import "JLHTTPClient.h"

@implementation JLHTTPClient

+ (id)defaultClient
{
	static dispatch_once_t pred = 0;
    __strong static id client = nil;
    dispatch_once(&pred, ^{
        client = [[self alloc] init];
    });
    return client;
}

- (id)init
{
	self = [super init];
    
    self.manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:MFAPIHostURL]];
    
//	_client = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:API_HOST]];
//	[_client setDefaultHeader:@"Accept" value:@"application/json; version=1.0;"];
//	[_client setDefaultHeader:@"Content-Type" value:@"application/json"];
//	[_client setDefaultHeader:@"User-Agent" value:[NSString stringWithFormat:@"MyFoodList iOS %@", VERSION]];
//	[_client registerHTTPOperationClass:[AFJSONRequestOperation class]];
	
	return self;
}


#pragma mark -

- (AFHTTPRequestOperation *)api:(NSString *)api
                         method:(NSString *)method
                     parameters:(NSDictionary *)parameters
                        success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                        failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
	return [self api:api method:method parameters:parameters upload:nil download:nil success:success failure:failure];
}

- (AFHTTPRequestOperation *)api:(NSString *)api
                         method:(NSString *)method
                     parameters:(NSDictionary *)parameters
                         upload:(void (^)(long long bytesLoaded, long long bytesTotal))upload
                       download:(void (^)(long long bytesLoaded, long long bytesTotal))download
                        success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                        failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSURLRequest *request = [self.manager.requestSerializer requestWithMethod:method URLString:[self absolutePath:api]
                                                                   parameters:parameters error:nil];
	return [self sendRequest:request upload:upload download:download success:success failure:failure];
}


#pragma mark -
#pragma mark Single image upload

- (AFHTTPRequestOperation *)api:(NSString *)api
                         method:(NSString *)method
                          image:(UIImage *)image
                        forName:(NSString *)name
                       fileName:(NSString *)fileName
                     parameters:(NSDictionary *)parameters
                        success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                        failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
	return [self api:api method:method image:image forName:name fileName:fileName parameters:parameters upload:nil
            download:nil success:success failure:failure];
}

- (AFHTTPRequestOperation *)api:(NSString *)api
                         method:(NSString *)method
                          image:(UIImage *)image
                        forName:(NSString *)name
                       fileName:(NSString *)fileName
                     parameters:(NSDictionary *)parameters
                         upload:(void (^)(long long bytesLoaded, long long bytesTotal))upload
                       download:(void (^)(long long bytesLoaded, long long bytesTotal))download
                        success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                        failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
	if (!image) {
		return [self api:api method:method parameters:parameters success:success failure:failure];
	}
    
    void(^block)(id<AFMultipartFormData> formData) = ^(id<AFMultipartFormData> formData) {
        NSString *mimeType = @"image/png";
        [formData appendPartWithFileData:UIImagePNGRepresentation(image) name:name fileName:fileName mimeType:mimeType];
    };
    
    NSMutableURLRequest *request = [self.manager.requestSerializer
                                    multipartFormRequestWithMethod:method URLString:[self absolutePath:api]
                                    parameters:parameters constructingBodyWithBlock:block error:nil];
	return [self sendRequest:request upload:upload download:download success:success failure:failure];
}


#pragma mark -
#pragma mark Multiple image upload

- (AFHTTPRequestOperation *)api:(NSString *)api
                         method:(NSString *)method
                         images:(NSArray *)images
                       forNames:(NSArray *)names
                      fileNames:(NSArray *)fileNames
                     parameters:(NSDictionary *)parameters
                        success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                        failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
	return [self api:api method:method images:images forNames:names fileNames:fileNames parameters:parameters
              upload:nil download:nil success:success failure:failure];
}

- (AFHTTPRequestOperation *)api:(NSString *)api
                         method:(NSString *)method
                         images:(NSArray *)images
                       forNames:(NSArray *)names
                      fileNames:(NSArray *)fileNames
                     parameters:(NSDictionary *)parameters
                         upload:(void (^)(long long bytesLoaded, long long bytesTotal))upload
                       download:(void (^)(long long bytesLoaded, long long bytesTotal))download
                        success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                        failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
	if (!images || images.count == 0) {
		return [self api:api method:method parameters:parameters success:success failure:failure];
	}
	
	if (images.count != names.count || names.count != fileNames.count) {
		NSLog(@"Must be image.count == names.count == fileNames.count");
		return nil;
	}
    
    void(^block)(id<AFMultipartFormData> formData) = ^(id<AFMultipartFormData> formData) {
        for (NSInteger i = 0; i < images.count; i++) {
			UIImage *image = [images objectAtIndex:i];
			NSString *name = [names objectAtIndex:i];
			NSString *fileName = [fileNames objectAtIndex:i];
			[formData appendPartWithFileData:UIImagePNGRepresentation(image)
                                        name:name
                                    fileName:fileName
                                    mimeType:@"image/png"];
		}
    };
	
	NSURLRequest *request = [self.manager.requestSerializer multipartFormRequestWithMethod:method
                                                                                 URLString:[self absolutePath:api]
                                                                                parameters:parameters
                                                                 constructingBodyWithBlock:block error:nil];
	return [self sendRequest:request upload:upload download:download success:success failure:failure];
}


#pragma mark -

- (AFHTTPRequestOperation *)sendRequest:(NSURLRequest *)request
                                 upload:(void (^)(long long bytesLoaded, long long bytesTotal))upload
                               download:(void (^)(long long bytesLoaded, long long bytesTotal))download
                                success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                                failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
	AFHTTPRequestOperation *operation = \
    [self.manager
     HTTPRequestOperationWithRequest:request
     success:^(AFHTTPRequestOperation *operation, id responseObject) {
         if (success) {
             success(operation, responseObject);
         }
         
     }
     failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         NSLog(@"## Error");
         NSLog(@"-- URL: %@", operation.request.URL.absoluteString);
         NSLog(@"-- Method: %@", operation.request.HTTPMethod);
         NSLog(@"-- Status: %d", operation.response.statusCode);
         
         NSDictionary *response = nil;
         if (operation.responseData) {
             response = [NSJSONSerialization JSONObjectWithData:operation.responseData options:0 error:nil];
         }
         NSLog(@"-- Response: %@", response);
         
         if (!error) {
             return;
         }
         
         // request timeout
         if (error.code == -1001) {
             [[[UIAlertView alloc]
               initWithTitle:NSLocalizedString(@"OOPS", nil)
               message:NSLocalizedString(@"MESSAGE_REQUEST_TIMEOUT", nil)
               cancelButtonTitle:NSLocalizedString(@"RETRY", nil)
               otherButtonTitles:nil dismissBlock:^(UIAlertView *alertView, NSUInteger buttonIndex) {
                   [self sendRequest:request upload:upload download:download success:success failure:failure];
               }] show];
             return;
         }
         
         // internet connection is offline
         else if (error.code == -1009) {
             [[[UIAlertView alloc]
               initWithTitle:NSLocalizedString(@"OOPS", nil)
               message:NSLocalizedString(@"MESSAGE_INTERNET_OFFLINE", nil)
               cancelButtonTitle:NSLocalizedString(@"RETRY", nil) otherButtonTitles:nil
               dismissBlock:^(UIAlertView *alertView, NSUInteger buttonIndex) {
                   dispatch_async(dispatch_get_main_queue(), ^{
                       [self sendRequest:request upload:upload download:download success:success failure:failure];
                   });
               }] show];
             return;
         }
         
         // other errors
         if (failure) {
             failure(operation, error);
         }
     }];
	
    // set upload block
	if (upload) {
		[operation setUploadProgressBlock:^(NSUInteger bytesWritten,
                                            long long totalBytesWritten,
                                            long long totalBytesExpectedToWrite) {
			upload(totalBytesWritten, totalBytesExpectedToWrite);
		}];
	}
	
    // set download block
	if (download) {
		[operation setDownloadProgressBlock:^(NSUInteger bytesRead,
                                              long long totalBytesRead,
                                              long long totalBytesExpectedToRead) {
			download(totalBytesRead, totalBytesExpectedToRead);
		}];
	}
	
	[self.manager.operationQueue addOperation:operation];
	return operation;
}


#pragma mark -
#pragma mark OAuth

#import "OAuthCore.h"

+ (JLHTTPClient *)OAuthLoaderWithConsumerKey:(NSString *)consumerKey
                              consumerSecret:(NSString *)consumerSecret
{
	JLHTTPClient *client = [[JLHTTPClient alloc] init];
	client.consumerKey = consumerKey;
	client.consumerSecret = consumerSecret;
	return client;
}

- (void)OAuthRequestTokenWithURLString:(NSString *)urlString
								method:(NSString *)method
							parameters:(NSDictionary *)parameters
                               success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                               failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
	NSURL *url = [NSURL URLWithString:urlString];
	
	NSMutableString *paramString = [NSMutableString string];
	[parameters enumerateKeysAndObjectsUsingBlock:
     ^(id key, id obj, BOOL *stop) {
         [paramString appendFormat:@"%@=%@&", key, obj];
     }];
	
    NSData *bodyData = [paramString dataUsingEncoding:NSUTF8StringEncoding];
	NSString *header = OAuthorizationHeader(url, method, bodyData, self.consumerKey, self.consumerSecret, nil, nil);
	
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
	[request setHTTPMethod:method];
    [request setValue:header forHTTPHeaderField:@"Authorization"];
    [request setHTTPBody:bodyData];
	
	[self sendRequest:request upload:nil download:nil success:success failure:failure];
}

- (void)OAuthAccessTokenWithURLString:(NSString *)urlString
							   method:(NSString *)method
								token:(NSString *)token
							   secret:(NSString *)secret
							 verifier:(NSString *)verifier
                              success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                              failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
	NSURL *url = [NSURL URLWithString:urlString];
	
	NSData *bodyData = [[NSString stringWithFormat:@"oauth_verifier=%@", verifier] dataUsingEncoding:NSUTF8StringEncoding];
	NSString *header = OAuthorizationHeader(url, method, bodyData, self.consumerKey, self.consumerSecret, token, secret);
	
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
	[request setHTTPMethod:method];
    [request setValue:header forHTTPHeaderField:@"Authorization"];
    [request setHTTPBody:bodyData];
	
	[self sendRequest:request upload:nil download:nil success:success failure:failure];
}


#pragma mark -
#pragma mark 

- (NSString *)absolutePath:(NSString *)path
{
    return [[NSURL URLWithString:path relativeToURL:self.manager.baseURL] absoluteString];
}

@end

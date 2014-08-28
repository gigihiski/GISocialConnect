//
//  GISocialConnect.m
//  Surabaya Information Update
//
//  Created by Gigih Iski Prasetyawan on 7/11/14.
//  Copyright (c) 2014 Etsuri Ltd. All rights reserved.
//

#import "GISocialConnect.h"

#define facebookAppID @"266279100195239"
#define twitterAppID @""

#define facebookRequestUrl @""
#define facebookFeedUrl @""

#define twitterRequestUrl @"https://api.twitter.com/1.1/users/show.json"
#define twitterFeedUrl @"https://api.twitter.com/1.1/statuses/update_with_media.json"

@interface GISocialConnect()

@property (nonatomic, strong) id responseAccessData;
@property (nonatomic, strong) NSString *socialTypeData;

@property (nonatomic, strong) ACAccountStore *facebookAccountStore;
@property (nonatomic, strong) ACAccount *facebookAccount;

@property (nonatomic, strong) ACAccountStore *twitterAccountStore;
@property (nonatomic, strong) ACAccount *twitterAccount;

@end

@implementation GISocialConnect

@synthesize responseAccessData;
@synthesize socialTypeData;
@synthesize viewController;

@synthesize facebookAccountStore;
@synthesize facebookAccount;
@synthesize delegate;

@synthesize twitterAccountStore;
@synthesize twitterAccount;

- (id) init {
    if (self = [super init]) {
        
    }
    return self;
}

- (void) facebookAuth {
    socialTypeData = @"facebook";
    if (facebookAccountStore == nil){
        facebookAccountStore = [[ACAccountStore alloc] init];
    }
    
    ACAccountType *facebookAccountType = [facebookAccountStore accountTypeWithAccountTypeIdentifier:
                                         ACAccountTypeIdentifierFacebook];
    
    // Read Permission
    NSDictionary * readOptions = @{ACFacebookAppIdKey:facebookAppID, ACFacebookPermissionsKey: @[@"email", @"read_stream"], ACFacebookAudienceKey:ACFacebookAudienceOnlyMe};
    [facebookAccountStore requestAccessToAccountsWithType:facebookAccountType options:readOptions
                                               completion: ^(BOOL granted, NSError *error) {
                                                   NSLog(@"accounts :%@", error);
        if (granted == YES) {
            NSArray *accounts = [facebookAccountStore accountsWithAccountType:facebookAccountType];
            if ([accounts count] > 0) {
                facebookAccount = [accounts lastObject];
                
                // Read write now
                NSDictionary * facebookOptions = @{ACFacebookAppIdKey:facebookAppID, ACFacebookPermissionsKey: @[@"publish_stream"], ACFacebookAudienceKey:ACFacebookAudienceFriends};
                
                [facebookAccountStore requestAccessToAccountsWithType:facebookAccountType options:facebookOptions completion: ^(BOOL granted, NSError *error) {
                    if (granted) {
                        
                        // Sent to delegate
                        if (self.delegate != nil && [self.delegate respondsToSelector:@selector(socialRequest:socialType:error:)]){
                            
                            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
                            [dict setValue:[facebookAccount username] forKey:@"username"];
                            [dict setValue:[facebookAccount username] forKey:@"name"];
                            [dict setValue:[facebookAccount identifier] forKey:@"id"];
                            
                            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
                            
                            NSArray *result = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableLeaves error:&error];
                            
                            responseAccessData = result;
                            
                            [self.delegate socialRequest:result socialType:socialTypeData error:error];
                        }
                    } else {
                        [self.delegate socialRequestFailed:@"Please check your facebook account in setting menu" socialType:socialTypeData error:error];
                    }
                }];
            } else {
                // Error Permission
                [self.delegate socialRequestFailed:@"Please check your facebook account in setting menu" socialType:socialTypeData error:error];
            }
        }else{
            // Account not set
            [self.delegate socialRequestFailed:@"Please check your facebook account in setting menu" socialType:socialTypeData error:error];
        }
    }];
}

- (void) twitterAuth {
    socialTypeData = @"twitter";
    
    if (twitterAccountStore == nil){
        twitterAccountStore = [[ACAccountStore alloc] init];
    }
    
    ACAccountType *twitterAccountType = [twitterAccountStore accountTypeWithAccountTypeIdentifier:
                                         ACAccountTypeIdentifierTwitter];
    
    [twitterAccountStore requestAccessToAccountsWithType:twitterAccountType
                                                 options:nil
                                              completion:^(BOOL granted, NSError *error) {
    if (granted == YES) {
        NSArray *accounts = [twitterAccountStore accountsWithAccountType:twitterAccountType];
        if ([accounts count] > 0) {
            twitterAccount = [accounts lastObject];
          
              if(![[twitterAccount username] isEqual:@""]){
                  
                  SLRequest *twitterInfoRequest = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:[NSURL URLWithString:twitterRequestUrl] parameters:[NSDictionary dictionaryWithObject:[self.twitterAccount username] forKey:@"screen_name"]];
                  [twitterInfoRequest setAccount:twitterAccount];
                  
                  // Making the request
                  [twitterInfoRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                      dispatch_async(dispatch_get_main_queue(), ^{
                          if(responseData){
                              NSError *error;
                              
                              NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseData
                                                                                     options:NSJSONReadingMutableLeaves
                                                                                       error:&error];
                              // Sent to delegate
                              if (self.delegate != nil && [self.delegate respondsToSelector:@selector(socialRequest:socialType:error:)]){
                                  
                                  NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
                                  [dict setValue:[twitterAccount username] forKey:@"username"];
                                  [dict setValue:[twitterAccount username] forKey:@"name"];
                                  [dict setValue:[result objectForKey:@"profile_image_url"] forKey:@"profile_image_url"];
                                  [dict setValue:[result objectForKey:@"id"] forKey:@"id"];
                                  
                                  NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
                                  
                                  NSArray *result = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableLeaves error:&error];
                                  
                                  responseAccessData = result;
                                  
                                  [self.delegate socialRequest:result socialType:socialTypeData error:error];
                              }
                          }
                      });
                  }];
              }else{
                  [self.delegate socialRequestFailed:@"Please check your twitter account in setting menu" socialType:socialTypeData error:error];
              }
          } else {
              [self.delegate socialRequestFailed:@"Please check your twitter account in setting menu" socialType:socialTypeData error:error];
          }
        } else {
            [self.delegate socialRequestFailed:@"Please check your twitter account in setting menu" socialType:socialTypeData error:error];
        }
    }];
}

- (BOOL) isFacebookAutoShare {
//    if([[GIPlistData getUserDefaultByKey:facebookAutoShareKey] isEqualToString:@"YES"]){
//        return YES;
//    }
    return NO;
}

- (BOOL) isTwitterAutoShare {
//    if([[GIPlistData getUserDefaultByKey:twitterAutoShareKey] isEqualToString:@"YES"]){
//        return YES;
//    }
    return NO;
}

- (void) activateFacebookAutoShare:(BOOL)autoShare {
    NSString *string;
    if(autoShare) string = @"YES";
    else string = @"NO";
    //[GIPlistData insertUserDefault:string key:facebookAutoShareKey];
}

- (void) activateTwitterAutoShare:(BOOL)autoShare {
    NSString *string;
    if(autoShare) string = @"YES";
    else string = @"NO";
    //[GIPlistData insertUserDefault:string key:twitterAutoShareKey];
}

- (void) facebookShare:(NSString *)name caption:(NSString *)caption description:(NSString *)description link:(NSString *)link image:(NSString *)image {
    
    if (facebookAccountStore == nil){
        facebookAccountStore = [[ACAccountStore alloc] init];
    }
    
    ACAccountType *facebookAccountType = [facebookAccountStore accountTypeWithAccountTypeIdentifier:
                                          ACAccountTypeIdentifierTwitter];
    
    // Read Permission
    NSDictionary * readOptions = @{ACFacebookAppIdKey:facebookAppID, ACFacebookPermissionsKey: @[@"publish_stream", @"publish_actions", @"email"], ACFacebookAudienceKey:ACFacebookAudienceOnlyMe};
    [self.facebookAccountStore requestAccessToAccountsWithType:facebookAccountType options:readOptions
                                                    completion: ^(BOOL granted, NSError *error) {
                                                        
    if (granted == YES) {
        NSArray *accounts = [facebookAccountStore accountsWithAccountType:facebookAccountType];
        if ([accounts count] > 0) {
            facebookAccount = [accounts lastObject];
            
            /* facebook share */
            NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                               name, @"name",
                                               caption, @"caption",
                                               description, @"description",
                                               link, @"link",
                                               image, @"picture",
                                               facebookAccount.credential.oauthToken,@"access_token",
                                               @"Surabaya Information Update", @"ref",
                                               nil];
            
            NSURL *feedURL = [NSURL URLWithString:facebookFeedUrl];
            
            SLRequest *feedRequest = [SLRequest requestForServiceType:SLServiceTypeFacebook
                                                        requestMethod:SLRequestMethodPOST
                                                                  URL:feedURL
                                                           parameters:parameters];
            [feedRequest performRequestWithHandler:^(NSData *responseData,
                                                     NSHTTPURLResponse *urlResponse, NSError *error) {

                if(!error){
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success"
                                                                    message:@"Feed has been shared"
                                                                   delegate:nil
                                                          cancelButtonTitle:nil
                                                          otherButtonTitles:@"OK", nil];
                    [alert show];
                }else{
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failed"
                                                                    message:@"Please check your facebook account in setting menu"
                                                                   delegate:nil
                                                          cancelButtonTitle:nil
                                                          otherButtonTitles:@"OK", nil];
                    [alert show];
                }
                NSLog(@"Request failed, %@", [urlResponse description]);
            }];
            /* end facebook share */
            
        } else {
            // Error Permission
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failed"
                                                            message:@"Please check your facebook account in setting menu"
                                                           delegate:nil
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:@"OK", nil];
            [alert show];
        }
    }
    }];
}

- (void)twitterShare:(NSString *)tweet image:(UIImage *)image{
    if (twitterAccountStore == nil){
        twitterAccountStore = [[ACAccountStore alloc] init];
    }
    
    ACAccountType *twitterAccountType = [twitterAccountStore accountTypeWithAccountTypeIdentifier:
                                         ACAccountTypeIdentifierTwitter];
    
    [twitterAccountStore requestAccessToAccountsWithType:twitterAccountType
                                                 options:nil
                                              completion:^(BOOL granted, NSError *error) {
        if (granted == YES) {
            NSArray *accounts = [twitterAccountStore accountsWithAccountType:twitterAccountType];
          
          if ([accounts count] > 0) {
              self.twitterAccount = [accounts lastObject];
              
              NSDictionary *message = @{@"status": tweet};
              
              NSURL *feedURL = [NSURL URLWithString:twitterFeedUrl];
              SLRequest *feedRequest = [SLRequest
                                        requestForServiceType:SLServiceTypeTwitter
                                        requestMethod:SLRequestMethodPOST
                                        URL:feedURL parameters:message];
              
              UIImage *squareImage = [self squareImageWithImage:image scaledToSize:CGSizeMake(340, 480)];
              NSData *imageData = UIImageJPEGRepresentation(squareImage, 0.8f);
              [feedRequest addMultipartData:imageData
                                   withName:@"media[]"
                                       type:@"image/jpeg"
                                   filename:@"image.jpg"];
              feedRequest.account = self.twitterAccount;
              [feedRequest performRequestWithHandler:^(NSData *responseData,
                                                       NSHTTPURLResponse *urlResponse, NSError *error) {
                  if(!error){
                      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success"
                                                                      message:@"Feed has been shared"
                                                                     delegate:nil
                                                            cancelButtonTitle:nil
                                                            otherButtonTitles:@"OK", nil];
                      [alert show];
                  }else{
                      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failed"
                                                                      message:@"Please check your twitter account in setting menu"
                                                                     delegate:nil
                                                            cancelButtonTitle:nil
                                                            otherButtonTitles:@"OK", nil];
                      [alert show];
                  }
                  NSLog(@"Twitter HTTP response: %@", [urlResponse description]);
              }];
          }else{
              UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failed"
                                                              message:@"Please check your twitter account in setting menu"
                                                             delegate:nil
                                                    cancelButtonTitle:nil
                                                    otherButtonTitles:@"OK", nil];
              [alert show];
          }
        }
    }];
}

#pragma mark - square image

- (UIImage *)squareImageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    double ratio;
    double delta;
    CGPoint offset;
    
    //make a new square size, that is the resized imaged width
    CGSize sz = CGSizeMake(newSize.width, newSize.width);
    
    //figure out if the picture is landscape or portrait, then
    //calculate scale factor and offset
    if (image.size.width > image.size.height) {
        ratio = newSize.width / image.size.width;
        delta = (ratio*image.size.width - ratio*image.size.height);
        offset = CGPointMake(delta/2, 0);
    } else {
        ratio = newSize.width / image.size.height;
        delta = (ratio*image.size.height - ratio*image.size.width);
        offset = CGPointMake(0, delta/2);
    }
    
    //make the final clipping rect based on the calculated values
    CGRect clipRect = CGRectMake(-offset.x, -offset.y,
                                 (ratio * image.size.width) + delta,
                                 (ratio * image.size.height) + delta);
    
    //start a new context, with scale factor 0.0 so retina displays get
    //high quality image
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        UIGraphicsBeginImageContextWithOptions(sz, YES, 0.0);
    } else {
        UIGraphicsBeginImageContext(sz);
    }
    UIRectClip(clipRect);
    [image drawInRect:clipRect];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

@end

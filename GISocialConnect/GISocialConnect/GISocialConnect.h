//
//  GISocialConnect.h
//  Surabaya Information Update
//
//  Created by Gigih Iski Prasetyawan on 7/11/14.
//  Copyright (c) 2014 Etsuri Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <Social/Social.h>
#import <Accounts/Accounts.h>

// Delegate
@class GISocialConnect;
@protocol GISocialConnectDelegate <NSObject>
@optional

- (void) socialRequest:(id) response socialType:(NSString *) socialType error:(NSError *)error;
- (void) socialRequestFailed:(NSString *)message socialType:(NSString *)socialType error:(NSError *)error;

@required

@end

@interface GISocialConnect : NSObject

@property (nonatomic, weak) id <GISocialConnectDelegate> delegate;

@property (nonatomic, strong) UIViewController *viewController;

/**
 * Facebook Authentication
 */
- (void) facebookAuth;

/**
 * Facebook AutoShare Setting
 */
- (BOOL) isFacebookAutoShare;

/**
 * Facebook AutoShare Setting
 */
- (void) activateFacebookAutoShare:(BOOL)autoShare;

/**
 * Facebook Share
 */
- (void)facebookShare:(NSString *)name caption:(NSString *)caption description:(NSString *)description link:(NSString *)link image:(NSString *)image;

/**
 * Twitter Authentication
 */
- (void) twitterAuth;

/**
 * Twitter AutoShare Setting
 */
- (BOOL) isTwitterAutoShare;

/**
 * Twitter AutoShare Setting
 */
- (void) activateTwitterAutoShare:(BOOL)autoShare;

/**
 * Twitter Share
 */
- (void)twitterShare:(NSString *)tweet image:(UIImage *)image;


@end

//
//  UIImage+PDF.h
//
//  Created by Nigel Barber on 15/10/2011.
//  Copyright 2011 Mindbrix Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIView+Image.h"
#import "PDFView.h"
#import "NSData+MD5.h"
#import "NSString+MD5.h"


@interface UIImage( PDF )

+(void)setShouldCacheOnDisk:(BOOL)shouldCache; // Default = YES
+(void)setShouldCacheInMemory:(BOOL)shouldCache; // Default = NO

+(UIImage *) imageOrPDFNamed:(NSString *)resourceName; 
+(UIImage *) imageOrPDFWithContentsOfFile:(NSString *)path;


+(UIImage *) imageWithPDFNamed:(NSString *)resourceName atSize:(CGSize)size atPage:(NSUInteger)page;
+(UIImage *) imageWithPDFNamed:(NSString *)resourceName atSize:(CGSize)size;

+(UIImage *) imageWithPDFNamed:(NSString *)resourceName atWidth:(CGFloat)width atPage:(NSUInteger)page;
+(UIImage *) imageWithPDFNamed:(NSString *)resourceName atWidth:(CGFloat)width;

+(UIImage *) imageWithPDFNamed:(NSString *)resourceName atHeight:(CGFloat)height atPage:(NSUInteger)page;
+(UIImage *) imageWithPDFNamed:(NSString *)resourceName atHeight:(CGFloat)height;

+(UIImage *) imageWithPDFNamed:(NSString *)resourceName fitSize:(CGSize)size atPage:(NSUInteger)page;
+(UIImage *) imageWithPDFNamed:(NSString *)resourceName fitSize:(CGSize)size;

+(UIImage *) originalSizeImageWithPDFNamed:(NSString *)resourceName atPage:(NSUInteger)page;
+(UIImage *) originalSizeImageWithPDFNamed:(NSString *)resourceName;


+(UIImage *) imageWithPDFURL:(NSURL *)URL atSize:(CGSize)size atPage:(NSUInteger)page;
+(UIImage *) imageWithPDFURL:(NSURL *)URL atSize:(CGSize)size;

+(UIImage *) imageWithPDFURL:(NSURL *)URL atWidth:(CGFloat)width atPage:(NSUInteger)page;
+(UIImage *) imageWithPDFURL:(NSURL *)URL atWidth:(CGFloat)width;

+(UIImage *) imageWithPDFURL:(NSURL *)URL atHeight:(CGFloat)height atPage:(NSUInteger)page;
+(UIImage *) imageWithPDFURL:(NSURL *)URL atHeight:(CGFloat)height;

+(UIImage *) imageWithPDFURL:(NSURL *)URL fitSize:(CGSize)size atPage:(NSUInteger)page;
+(UIImage *) imageWithPDFURL:(NSURL *)URL fitSize:(CGSize)size;


+(UIImage *) imageWithPDFData:(NSData *)data atSize:(CGSize)size;
+(UIImage *) imageWithPDFData:(NSData *)data atSize:(CGSize)size atPage:(NSUInteger)page;

+(UIImage *) imageWithPDFData:(NSData *)data atWidth:(CGFloat)width;
+(UIImage *) imageWithPDFData:(NSData *)data atWidth:(CGFloat)width atPage:(NSUInteger)page;

+(UIImage *) imageWithPDFData:(NSData *)data atHeight:(CGFloat)height;
+(UIImage *) imageWithPDFData:(NSData *)data atHeight:(CGFloat)height atPage:(NSUInteger)page;

+(UIImage *) imageWithPDFData:(NSData *)data fitSize:(CGSize)size;
+(UIImage *) imageWithPDFData:(NSData *)data fitSize:(CGSize)size atPage:(NSUInteger)page;


+(UIImage *) originalSizeImageWithPDFData:(NSData *)data;
+(UIImage *) originalSizeImageWithPDFURL:(NSURL *)URL atPage:(NSUInteger)page;
+(UIImage *) originalSizeImageWithPDFURL:(NSURL *)URL;


@end

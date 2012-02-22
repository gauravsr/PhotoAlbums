//
//  VideoUtil.m
//  PhotoAlbums
//
//  Created by Sourabh Raheja on 22/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VideoUtil.h"

@implementation VideoUtil

+ (CVPixelBufferRef) newPixelBufferFromCGImage: (CGImageRef) image
{
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGImageCompatibilityKey,
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGBitmapContextCompatibilityKey,
                             nil];
    CVPixelBufferRef pxbuffer = NULL;
    
    CGSize frameSize = CGSizeMake(320, 240);
    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault, frameSize.width,
                                          frameSize.height, kCVPixelFormatType_32ARGB, (CFDictionaryRef) options, 
                                          &pxbuffer);
    NSParameterAssert(status == kCVReturnSuccess && pxbuffer != NULL);
    
    CVPixelBufferLockBaseAddress(pxbuffer, 0);
    void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
    NSParameterAssert(pxdata != NULL);
    
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pxdata, frameSize.width,
                                                 frameSize.height, 8, 4*frameSize.width, rgbColorSpace, 
                                                 kCGImageAlphaNoneSkipFirst);
    NSParameterAssert(context);
    
    
    //    CGContextConcatCTM(context, frameTransform);
    CGContextDrawImage(context, CGRectMake(0, 0, CGImageGetWidth(image), 
                                           CGImageGetHeight(image)), image);
    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);
    
    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
    
    return pxbuffer;
}

+ (NSString *) createVideoForAlbum:(Album *)album {
    return [self createVideoForPages:[album.pages allObjects]];
}

+ (NSString *) createVideoForPages:(NSArray *)pages {
    //TODO create a video and attach it to email
    NSError *error = nil;
    
    NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    
    doc = [doc stringByAppendingPathComponent:@"p1"];
    doc = [doc stringByAppendingPathComponent:@"photo"];
    doc = [doc stringByAppendingPathComponent:@"videoFile.mp4"];
    AVAssetWriter *videoWriter = [[AVAssetWriter alloc] initWithURL: [NSURL fileURLWithPath:doc] fileType:AVFileTypeQuickTimeMovie error:&error];
    
    NSLog(@"%@",error );
    
    NSParameterAssert(videoWriter);
    
    NSDictionary *videoSettings = [NSDictionary dictionaryWithObjectsAndKeys: 
                                   AVVideoCodecH264, AVVideoCodecKey,
                                   [NSNumber numberWithInt:640], AVVideoWidthKey,
                                   [NSNumber numberWithInt:480], AVVideoHeightKey,
                                   nil];
    AVAssetWriterInput* writerInput = [[AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo
                                                                          outputSettings:videoSettings] retain];
    
    AVAssetWriterInputPixelBufferAdaptor *pixelBufferInput = [AVAssetWriterInputPixelBufferAdaptor assetWriterInputPixelBufferAdaptorWithAssetWriterInput:writerInput sourcePixelBufferAttributes:videoSettings];
    
    NSParameterAssert(writerInput);
    NSParameterAssert([videoWriter canAddInput:writerInput]);
    
    [videoWriter addInput:writerInput];
    
    [videoWriter startWriting];
    [videoWriter startSessionAtSourceTime:CMTimeMake(0, 10)];
        
    CMTime startTime = kCMTimeZero;
        
    for(Page * page in pages){
        UIImage *image = [UIImage imageWithContentsOfFile:[docPath stringByAppendingPathComponent:page.imagePath]];
        
        CVPixelBufferRef pixelBuffer = [self newPixelBufferFromCGImage:[image CGImage]];
        startTime =  CMTimeAdd(startTime, CMTimeMake(3, 10));
        [pixelBufferInput appendPixelBuffer:pixelBuffer withPresentationTime:startTime];
    }
    
    
    //    Page *firstPage = [pages objectAtIndex:0];
    //    UIImage *image = [UIImage imageWithContentsOfFile:[docPath stringByAppendingPathComponent:firstPage.imagePath]];
    //    
    //    CVPixelBufferRef pixelBuffer = [self newPixelBufferFromCGImage:[image CGImage]];
    
    //    [writerInput appendSampleBuffer:[]];
    
    
    [writerInput markAsFinished];
    [videoWriter endSessionAtSourceTime:CMTimeMake(50, 10)];
    [videoWriter finishWriting];        
        
    return doc;
}

@end

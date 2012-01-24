//
//  PageView.h
//  PhotoBook
//
//  Created by raheja on 11/06/10.
//  Copyright 2010 Xebia IT Architects India Private Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Page.h"

@interface PageView : UIImageView 
{	
	Page			*page;
	BOOL			isLoaded;
}

@property (nonatomic, retain) Page			*page;
@property (assign) BOOL						isLoaded;



@end

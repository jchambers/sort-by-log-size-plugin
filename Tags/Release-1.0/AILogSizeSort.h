//
//  AILogSizeSort.h
//  SortByLogSizePlugin
//
//  Created by Jon Chambers on 9/28/08.
//  Copyright 2008 Jon Chambers. All rights reserved.
//

#import <AIUtilities/AITigerCompatibility.h> 

#import <Adium/AISortController.h>
#import <Adium/AIListContact.h>

@interface AILogSizeSort : AISortController
{
	NSMutableDictionary *logSizeCache;
}

+(unsigned long long)getContactLogSize:(AIListContact *)listObject;

@end

//
//  ABSortByLogSizePlugin.m
//  SortByLogSizePlugin
//
//  Created by Jon Chambers on 9/28/08.
//  Copyright 2008 Jon Chambers. All rights reserved.
//

// Important note:
// http://adiumx.com/pipermail/adium-devl_adiumx.com/2008-September/005692.html

#import "ABSortByLogSizePlugin.h"
#import "AILogSizeSort.h"

#import <AIUtilities/AITigerCompatibility.h> 

#import <Adium/AISharedAdium.h>
#import <Adium/AIContactControllerProtocol.h>

@implementation ABSortByLogSizePlugin

- (void)installPlugin
{
	[[adium contactController] registerListSortController:[[[AILogSizeSort alloc] init] autorelease]];
}

- (void)uninstallPlugin 
{
}

- (NSString *)pluginAuthor
{
	return @"Jon Chambers";
}

- (NSString *)pluginVersion
{
	return @"1.0";
}

- (NSString *)pluginDescription
{
	return @"Allows the Adium contact list to be sorted by chat transcript file size.";
}

- (NSString *)pluginURL
{
	return @"http://projects.eatthepath.com/sort-by-log-size-plugin/";
}

@end

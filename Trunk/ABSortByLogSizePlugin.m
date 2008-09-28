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

#import <Adium/ESDebugAILog.h>
#import <Adium/AISharedAdium.h>
#import <Adium/AIContactControllerProtocol.h>

@implementation ABSortByLogSizePlugin

- (void)installPlugin
{
	AILog(@"ABSortByLogSizePlugin installed.");
	[[adium contactController] registerListSortController:[[[AILogSizeSort alloc] init] autorelease]];
}

- (void)uninstallPlugin 
{
	AILog(@"ABSortByLogSizePlugin uninstalled.");
}

- (NSString *)pluginAuthor
{
	return @"Jon Chambers";
}

- (NSString *)pluginVersion
{
	return @"development";
}

- (NSString *)pluginDescription
{
	return @"Allows the contact list to be sorted by transcript file size.";
}

- (NSString *)pluginURL
{
	return @"http://projects.eatthepath.com/sort-by-log-size-plugin/";
}

@end

/* 
 * $Id$
 *
 * Adium is the legal property of its developers, whose names are listed in the copyright file included
 * with this source distribution.
 *
 * This plugin is copyright (c) 2008 Jon Chambers.  The plugin's official site is:
 * http://projects.eatthepath.com/sort-by-log-size-plugin/
 * 
 * This program is free software; you can redistribute it and/or modify it under the terms of the GNU
 * General Public License as published by the Free Software Foundation; either version 2 of the License,
 * or (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even
 * the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General
 * Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License along with this program; if not,
 * write to the Free Software Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
 */

#import "ABSortByLogSizePlugin.h"
#import "AILogSizeSort.h"

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
	return @"1.1";
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

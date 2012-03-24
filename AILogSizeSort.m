/* 
 * Adium is the legal property of its developers, whose names are listed in the copyright file included
 * with this source distribution.
 *
 * This plugin is copyright (c) 2008-2012 Jon Chambers.  The plugin's official site is:
 * https://github.com/jchambers/sort-by-log-size-plugin/
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

#import <Adium/AIPlugin.h>
#import <Adium/AISharedAdium.h>

#import <AIUtilities/AIStringUtilities.h>

#import <Adium/AIAdiumProtocol.h>
#import <Adium/AIContentControllerProtocol.h>
#import <Adium/AIContactControllerProtocol.h>
#import <Adium/AIListObject.h>
#import <Adium/AIMetaContact.h>

#import <Adium/AIChat.h>
#import <Adium/AIContentObject.h>
#import <Adium/AIContentMessage.h>

#import "AILogSizeSort.h"

@implementation AILogSizeSort

#pragma mark AISortController obligations

/*!
 * @brief Did become active first time
 *
 * Called only once; gives the sort controller an opportunity to set defaults and load preferences lazily.
 */
- (void)didBecomeActiveFirstTime
{
	logSizeCache = [[NSMutableDictionary alloc] init];
	
	// Listen for content addition notifications
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(contentObjectAdded:) 
												 name:Content_ContentObjectAdded 
											   object:nil];
}

/*!
 * @brief Non-localized identifier
 */
- (NSString *)identifier{
    return @"Log size";
}

/*!
 * @brief Localized display name
 */
- (NSString *)displayName{
    return AILocalizedString(@"Sort Contacts by Log Size", nil);
}

/*!
 * @brief Properties which, when changed, should trigger a resort
 */
- (NSSet *)statusKeysRequiringResort{
	return nil;
}

/*!
 * @brief Attribute keys which, when changed, should trigger a resort
 */
- (NSSet *)attributeKeysRequiringResort{
	return nil;
}

#pragma mark Configuration

/*!
 * @brief Window title when configuring the sort
 *
 * Subclasses should provide a title for configuring the sort only if configuration is possible.
 * @result Localized title. If nil, the menu item will be disabled.
 */
- (NSString *)configureSortWindowTitle{
	return nil;
}

/*!
 * @brief Nib name for configuration
 */
- (NSString *)configureNibName{
	return nil;
}

/*!
 * @brief View did load
 */
- (void)viewDidLoad{
}

/*!
 * @brief Preference changed
 *
 * Sort controllers should live update as preferences change.
 */
- (IBAction)changePreference:(id)sender
{
}

/*!
 * @brief Allow users to manually sort groups
 */
-(BOOL)canSortManually
{
	return YES;
}

#pragma mark Cache operations

/*!
 * @brief Creates and populates a new cache entry for a contact if needed
 */
-(void)createCacheEntryIfNil:(AIListContact *)listContact
{
	// Check for a match on the account name; create a new sub-dictionary if needed
	if([logSizeCache valueForKey:[listContact internalUniqueObjectID]] == nil)
	{
		[logSizeCache setValue:[[NSMutableDictionary alloc] init] forKey:[listContact internalUniqueObjectID]];
	}
	
	NSMutableDictionary *accountDictionary = [logSizeCache valueForKey:[listContact internalUniqueObjectID]];
	
	// If we don't already have a valid log size cached for this contact, create one
	if([accountDictionary valueForKey:[listContact UID]] == nil)
	{
		[accountDictionary setValue:[NSNumber numberWithUnsignedLongLong:[self getContactLogSize:listContact]] forKey: [listContact UID]];
	}
}

/*!
 * @brief Invalidates a cached log size for a list contact
 */
-(void)removeCacheEntry:(AIListContact *)listContact
{
	if([listContact isMemberOfClass:[AIMetaContact class]])
	{
		// Recurse!  Invalidate each sub-contact's cache entry.
		id contact;
		
		NSEnumerator *contactEnumerator = [[(AIMetaContact *)listContact uniqueContainedObjects] objectEnumerator];
		
		while(contact = [contactEnumerator nextObject])
		{
			[self removeCacheEntry:contact];
		}
	}
	else
	{
		// Bail out if we don't know about the group this contact is in (there's nothing for us to do
		// anyway).
		if([logSizeCache valueForKey:[listContact internalUniqueObjectID]] == nil) { return; }
		
		// Remove the cache entry for the dirty account.
		[(NSMutableDictionary *)[logSizeCache valueForKey:[listContact internalUniqueObjectID]] removeObjectForKey:[listContact UID]];
	}
}

#pragma mark Event handlers

/*!
 * @brief Handles content send/receive events
 *
 * Handles content send/receive events.  For one-on-one chats, the cached log size for a contact is
 * invalidated (forcing a recalculation on the next sorting cycle).
 */
-(void)contentObjectAdded:(NSNotification *)notification
{
	AIChat *chat = [notification object];
	
	if(![chat isGroupChat])
	{
		[self removeCacheEntry:[chat listObject]];
	}
}

#pragma mark Log operations

/*!
 * @brief Returns the cached log size for a list contact
 */
-(unsigned long long)getCachedLogSize:(AIListContact *)listContact
{
	// Don't cache metacontacts
	if([listContact isMemberOfClass:[AIMetaContact class]])
	{
		return [self getContactLogSize:listContact];
	}

	[self createCacheEntryIfNil:listContact];
	
	NSMutableDictionary *accountDictionary = [logSizeCache valueForKey:[listContact internalUniqueObjectID]];
	return [[accountDictionary valueForKey:[listContact UID]] unsignedLongLongValue];
}

/*!
 * @brief Returns the total aggregate log size for a contact
 *
 * Returns the total aggregate log size for a contact.  For meta-contacts, the
 * total log file size of all sub-contacts is returned.  If no log exists or if
 * something else goes wrong, 0 is returned.
 *
 * @param listContact an AIListContact for which to retrieve a total log file size
 * @return the total log file size in bytes or 0 if an error occurred
 */
-(unsigned long long)getContactLogSize:(AIListContact *)listContact
{
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	if([listContact isMemberOfClass:[AIMetaContact class]])
	{
		// Recurse through all sub-contacts
		id contact;
		unsigned long long size = 0;
		
		NSEnumerator *contactEnumerator = [[(AIMetaContact *)listContact uniqueContainedObjects] objectEnumerator];

		while(contact = [contactEnumerator nextObject])
		{
			size += [self getCachedLogSize:contact];
		}
		
		return size;
	}
	else
	{
		// Find the path to the directory containing the log files for this contact
		NSString *path = [[NSClassFromString(@"AILoggerPlugin") logBasePath] stringByAppendingPathComponent:[NSClassFromString(@"AILoggerPlugin") relativePathForLogWithObject:[listContact UID] onAccount: [listContact account]]];
		
		// Grab an enumerator for all log files for this contact
		NSDirectoryEnumerator *dirEnum = [[NSFileManager defaultManager] enumeratorAtPath:path];
		NSString *file;
		
		unsigned long long size = 0;
		
		while(file = [dirEnum nextObject])
		{
			NSDictionary *fileAttributes = [fileManager fileAttributesAtPath:[path stringByAppendingPathComponent:file] traverseLink:YES];
			
			if (fileAttributes != nil)
			{
				NSNumber *fileSize;
				if(fileSize = [fileAttributes objectForKey:NSFileSize])
				{
					size += [fileSize unsignedLongLongValue];
				}
			}
		}
		
		return size;
	}
}

#pragma mark Sorting

/*!
 * @brief Sort by log size
 */
NSComparisonResult logSizeSort(id objectA, id objectB, BOOL groups, id<AIContainingObject> container)
{
	// Borrowed from AISortController.m
	BOOL objectAIsGroup = [objectA isKindOfClass:[AIListGroup class]];
	BOOL objectBIsGroup = [objectB isKindOfClass:[AIListGroup class]];
	
	if(groups || (objectAIsGroup && objectBIsGroup))
	{
		// Keep groups in manual order (borrowed from ESStatusSort)
		if ([container orderIndexForObject:objectA] > [container orderIndexForObject:objectB])
		{
			return NSOrderedDescending;
		}
		else
		{
			return NSOrderedAscending;
		}
	}
	
	// Catch cases where only one of the objects is a group
	if(objectAIsGroup && !objectBIsGroup)
	{
		return NSOrderedAscending;
	}
	else if(!objectAIsGroup && objectBIsGroup)
	{
		return NSOrderedDescending;
	}
	
	// Get a reference to one and only AILogSizeSort instance.  If this sorting method is being
	// called, it should always be the case that AILogSizeSort is the active sort controller.
	AISortController *sortController = [AISortController activeSortController];
	
	unsigned long long sizeA = 0;
	unsigned long long sizeB = 0;
	
	sizeA = [(AILogSizeSort *)sortController getCachedLogSize:objectA];
	sizeB = [(AILogSizeSort *)sortController getCachedLogSize:objectB];

	if(sizeB == sizeA)
	{
		// Fall back to basic alphabetical sorting in the event of a tie.
		return [[objectA displayName] caseInsensitiveCompare:[objectB displayName]];
	}
	else if(sizeA > sizeB)
	{
		// There's a clear winner; run with it.
		return NSOrderedAscending;
	}
	else
	{
		return NSOrderedDescending;
	}
}

/*!
 * @brief Sort function
 */
- (sortfunc)sortFunction{
	return &logSizeSort;
}
@end

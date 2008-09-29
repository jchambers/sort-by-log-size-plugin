//
//  AILogSizeSort.m
//  SortByLogSizePlugin
//
//  Created by Jon Chambers on 9/28/08.
//  Copyright 2008 Jon Chambers. All rights reserved.
//

#import "AILogSizeSort.h"
#import "AILoggerPlugin.h"

#import <AIUtilities/AITigerCompatibility.h> 
#import <AIUtilities/AIStringUtilities.h>

#import <Adium/AISharedAdium.h>
#import <Adium/ESDebugAILog.h>

#import <Adium/AIContactControllerProtocol.h>
#import <Adium/AIPreferenceControllerProtocol.h>
#import <Adium/AIListObject.h>
#import <Adium/AIMetaContact.h>

@implementation AILogSizeSort

/*!
 * @brief Did become active first time
 *
 * Called only once; gives the sort controller an opportunity to set defaults and load preferences lazily.
 */
- (void)didBecomeActiveFirstTime
{
	NSEnumerator *groupEnumerator = [[[[adium contactController] contactList] listContacts] objectEnumerator];
	
	id group, contact;
	
    while(group = [groupEnumerator nextObject])
	{
		AILog(@"%@", group);
		
		NSEnumerator *contactEnumerator = [[group listContacts] objectEnumerator];
		
		while(contact = [contactEnumerator nextObject])
		{
			AILog(@"\t%@: %lld", contact, [AILogSizeSort getContactLogSize:contact]);
		}
    }
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
    return AILocalizedString(@"Sort Contacts by Log Size",nil);
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
	return AILocalizedString(@"Configure Sort by Log Size",nil);	
}

/*!
 * @brief Nib name for configuration
 */
- (NSString *)configureNibName{
	return @"LogSizeSortConfiguration";
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

#pragma mark Sorting
/*!
 * @brief Alphabetical sort
 */
int logSizeSort(id objectA, id objectB, BOOL groups)
{
	// Not real excited about doing this with an implicit definition, but seems to be
	// the only option for now.
	//AILog([objectA formattedUID]);
	return NSOrderedAscending;
}

/*!
 * @brief Sort function
 */
- (sortfunc)sortFunction{
	return &logSizeSort;
}

+(unsigned long long)getContactLogSize:(AIListContact *)listObject
{
	NSFileManager *fileManager = [NSFileManager defaultManager];

	if([listObject isMemberOfClass:[AIMetaContact class]])
	{
		unsigned long long size = 0;
		
		NSEnumerator *contactEnumerator = [[listObject listContacts] objectEnumerator];
		
		id contact;
		
		while(contact = [contactEnumerator nextObject])
		{
			size += [AILogSizeSort getContactLogSize:contact];
		}
		
		return size;
	}
	else
	{
		NSString *path = [[AILoggerPlugin logBasePath] stringByAppendingPathComponent:[AILoggerPlugin relativePathForLogWithObject:[listObject UID] onAccount: [listObject account]]];

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

@end

//
//  AILogSizeSort.m
//  SortByLogSizePlugin
//
//  Created by Jon Chambers on 9/28/08.
//  Copyright 2008 Jon Chambers. All rights reserved.
//

#import "AILogSizeSort.h"
#import "AILoggerPlugin.h"

#import <Adium/AISharedAdium.h>

#import <AIUtilities/AITigerCompatibility.h> 
#import <AIUtilities/AIStringUtilities.h>

#import <Adium/AIContactControllerProtocol.h>
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
 * Allow users to manually sort groups.
 */
-(BOOL)canSortManually
{
	return YES;
}

/**
 * Returns the total aggregate log size for a contact.  For meta-contacts, the
 * total log file size of all sub-contacts is returned.  If no log exists or if
 * something else goes wrong, 0 is returned.
 *
 * @param listObject an AIListContact for which to retrieve a total log file size
 * @return the total log file size in bytes or 0 if an error occurred
 */
+(unsigned long long)getContactLogSize:(AIListContact *)listObject
{
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	if([listObject isMemberOfClass:[AIMetaContact class]])
	{
		// Recurse through all sub-contacts
		
		id contact;
		unsigned long long size = 0;
		
		NSEnumerator *contactEnumerator = [[listObject listContacts] objectEnumerator];

		while(contact = [contactEnumerator nextObject])
		{
			size += [AILogSizeSort getContactLogSize:contact];
		}
		
		return size;
	}
	else
	{
		// Find the path to the directory containing the log files for this contact
		NSString *path = [[AILoggerPlugin logBasePath] stringByAppendingPathComponent:[AILoggerPlugin relativePathForLogWithObject:[listObject UID] onAccount: [listObject account]]];
		
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
 * @brief Alphabetical sort
 */
int logSizeSort(id objectA, id objectB, BOOL groups)
{
	if(groups)
	{
		// Keep groups in manual order (borrowed from ESStatusSort)
		if ([objectA orderIndex] > [objectB orderIndex])
		{
			return NSOrderedDescending;
		}
		else
		{
			return NSOrderedAscending;
		}
	}
	
	unsigned long long sizeA = [AILogSizeSort getContactLogSize:objectA];
	unsigned long long sizeB = [AILogSizeSort getContactLogSize:objectB];
	
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

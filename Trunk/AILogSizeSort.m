//
//  AILogSizeSort.m
//  SortByLogSizePlugin
//
//  Created by Jon Chambers on 9/28/08.
//  Copyright 2008 Jon Chambers. All rights reserved.
//

#import "AILogSizeSort.h"

#import <AIUtilities/AITigerCompatibility.h> 
#import <AIUtilities/AIStringUtilities.h>
#import <Adium/AIContactControllerProtocol.h>
#import <Adium/AIPreferenceControllerProtocol.h>
#import <AIUtilities/AIDictionaryAdditions.h>
#import <Adium/AIListObject.h>

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
int alphabeticalSort(id objectA, id objectB, BOOL groups)
{
	return NSOrderedAscending;
}

/*!
 * @brief Sort function
 */
- (sortfunc)sortFunction{
	return &alphabeticalSort;
}

@end

//
//  SKOneBoxCoreDataManager.m
//  SKOneBoxSearch
//
//  Copyright (c) 2016 Skobbler. All rights reserved.
//

#import "SKOneBoxCoreDataManager.h"
#import "SKOneBoxRecentSearch.h"

NSString *const kSKOneBoxRecentSearchEntityName = @"SKOneBoxRecentSearch";

@interface SKOneBoxCoreDataManager ()

@property (nonatomic, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, strong) NSManagedObjectModel *managedObjectModel;

@property (nonatomic, strong) NSString *modelName;
@property (nonatomic, strong) NSURL *storeURL;
@property (nonatomic, strong) NSString *storeType;

@property (nonatomic, strong) NSEntityDescription *searchEntity;

@end

@implementation SKOneBoxCoreDataManager

#pragma mark - Init 

+ (SKOneBoxCoreDataManager *)sharedInstance {
    static dispatch_once_t onceToken = 0;
    static id coreDataManager = nil;
    
    dispatch_once(&onceToken, ^{
        coreDataManager = [[SKOneBoxCoreDataManager alloc] init];
    });
    
    return coreDataManager;
}

-(id)init {
    self = [super init];
    if (self) {
        self.storeType = NSSQLiteStoreType;
        self.modelName = @"SKOneBoxDataModel";
        
        self.searchEntity = [NSEntityDescription entityForName:kSKOneBoxRecentSearchEntityName inManagedObjectContext:[self mainManagedObjectContext]];
    }
    return self;
}
#pragma mark - Private

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (!_persistentStoreCoordinator) {
        
        /* Create PSC */
        NSDictionary *options = @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES};
        _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
        
        /* Add store to it */
        NSError *error = nil;
        if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:self.storeURL options:options error:&error]) {
            NSLog(@"CD Error: %s\n%@\n%@", __PRETTY_FUNCTION__, [self class], error);
        }
    }
    return _persistentStoreCoordinator;
}

- (NSManagedObjectModel *)managedObjectModel
{
    if (!_managedObjectModel) {
        
        /* Current model */
        NSBundle *bundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"SKOneBoxSearchBundle" ofType:@"bundle"]];
        NSURL *modelURL = [bundle URLForResource:self.modelName withExtension:@"momd"];
        _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    }
    return _managedObjectModel;
}

- (NSManagedObjectContext *)mainManagedObjectContext
{
    if (!_mainManagedObjectContext) {
        
        /* Create background context with attached psc */
        NSManagedObjectContext *storageBackgroundContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        storageBackgroundContext.persistentStoreCoordinator = self.persistentStoreCoordinator;
        
        /* Create main queue context as main */
        _mainManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        _mainManagedObjectContext.parentContext = storageBackgroundContext;
    }
    return _mainManagedObjectContext;
}

#pragma mark - Private Accessors

- (NSURL *)storeURL
{
    if (!_storeURL) {
        NSFileManager *fileManager = [NSFileManager new];
        NSURL *libraryURL = [[fileManager URLsForDirectory:NSLibraryDirectory inDomains:NSUserDomainMask] lastObject];
        _storeURL = [libraryURL URLByAppendingPathComponent:self.modelName];
    }
    return _storeURL;
}

#pragma mark - Public

- (NSManagedObjectContext *)createChildContextWithType:(NSManagedObjectContextConcurrencyType)type
{
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:type];
    context.parentContext = self.mainManagedObjectContext;
    return context;
}

- (void)save
{
    if (![self.mainManagedObjectContext hasChanges]) {
        return;
    }
    
    /* Save main context */
    NSManagedObjectContext *mainContext = self.mainManagedObjectContext;
    [mainContext performBlockAndWait:^{
        
        NSError *error = nil;
        if (![mainContext save:&error]) {
            [self _printSaveError:error inContext:mainContext];
        } else {
            
            /* Push changes to the store */
            NSManagedObjectContext *parentContext = mainContext.parentContext;
            [parentContext performBlock:^{
                
                NSError *error = nil;
                if (![parentContext save:&error]) {
                    [self _printSaveError:error inContext:parentContext];
                }
            }];
        }
    }];
}

- (void)saveManagedObjectContext:(NSManagedObjectContext*)context
{
    if (![context hasChanges]) {
        return;
    }
    
    [context performBlock:^{
        NSError *error = nil;
        if (![context save:&error]) {
            [self _printSaveError:error inContext:context];
        } else {
            if (context.parentContext) {
                [self saveManagedObjectContext:context.parentContext];
            }
        }
    }];
}

#pragma mark - Private

- (void)_printSaveError:(NSError *)error inContext:(NSManagedObjectContext *)context
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    NSLog(@"%@", error);
    NSLog(@"%@", context);
}

+ (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL {
    if ([[NSFileManager defaultManager] fileExistsAtPath:[URL path]]) {
        NSError *error = nil;
        BOOL success = [URL setResourceValue:[NSNumber numberWithBool:YES]
                                      forKey:NSURLIsExcludedFromBackupKey error:&error];
        return success;
    } else {
        return NO;
    }
}

@end

@implementation SKOneBoxCoreDataManager (Searches)

- (SKOneBoxRecentSearch *)emptySearchInManagedObjectContext:(NSManagedObjectContext *)context {
    return [NSEntityDescription insertNewObjectForEntityForName:[_searchEntity name] inManagedObjectContext:context];
}

- (NSArray *)searchListInManagedObjectContext:(NSManagedObjectContext *)context withPredicate:(NSPredicate*)predicate {
    NSError *error = nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:_searchEntity];
    
    if (predicate) {
        [fetchRequest setPredicate:predicate];
    }
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"frequency" ascending:NO];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    
    NSArray *results = [context executeFetchRequest:fetchRequest error:&error];
    
    if (error) {
#ifdef ENABLED_DEBUG
        NSLog(@"*** Core Data error: %@", error);
#endif
        return nil;
    }
    
    return results;
}

- (SKOneBoxRecentSearch *)createEmptySearch {
    return [self emptySearchInManagedObjectContext:self.mainManagedObjectContext];
}

- (NSArray *)searchList {
    return [self searchListInManagedObjectContext:self.mainManagedObjectContext withPredicate:nil];
}

- (NSArray *)searchListUsingPredicate:(NSPredicate*)predicate {
    return [self searchListInManagedObjectContext:self.mainManagedObjectContext withPredicate:predicate];
}

@end


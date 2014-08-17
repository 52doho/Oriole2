//
//  GameCenterManager.m
//
//  Created by Nihal Ahmed on 12-03-16.
//  Copyright (c) 2012 NABZ Software. All rights reserved.
//

#import "GameCenterManager.h"

// GameCenterManager uses ARC, check for compatibility before building
#if !__has_feature(objc_arc)
#error GameCenterManager uses Objective-C ARC. Compile these files with ARC enabled. Add the -fobjc-arc compiler flag to enable ARC for only these files.
#endif

#define kSavedScores @"SavedScores"
#define kSavedAchievements @"SavedAchievements"

@implementation GameCenterManager

@synthesize isGameCenterAvailable;

static GameCenterManager *sharedManager = nil;

+ (GameCenterManager *)sharedManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[GameCenterManager alloc] init];
    });
    
    return sharedManager;
}

#pragma mark - Methods
- (id)init
{
    if(self = [super init])
    {
        // Check for presence of GKLocalPlayer class.
        BOOL localPlayerClassAvailable = (NSClassFromString(@"GKLocalPlayer")) != nil;
        
        // The device must be running iOS 4.1 or later.
        NSString *reqSysVer = @"4.1";
        NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
        BOOL osVersionSupported = ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending);
        
        BOOL isGameCenterAPIAvailable = (localPlayerClassAvailable && osVersionSupported);
        
        if(isGameCenterAPIAvailable)
        {
            [self setIsGameCenterAvailable:YES];
            
            [GKLocalPlayer localPlayer].authenticateHandler = ^(UIViewController *viewController, NSError *error)
            {
                if (viewController != nil)
                {
                    UIViewController *ctl = [UIApplication sharedApplication].keyWindow.rootViewController;
                    [ctl presentViewController:viewController animated:YES completion:nil];
                }
                else if ([GKLocalPlayer localPlayer].isAuthenticated)
                {
                    if(![[NSUserDefaults standardUserDefaults] boolForKey:[@"scoresSynced" stringByAppendingString:[self localPlayerId]]] ||
                       ![[NSUserDefaults standardUserDefaults] boolForKey:[@"achievementsSynced" stringByAppendingString:[self localPlayerId]]])
                    {
                        [self syncGameCenter];
                    }
                    else
                    {
                        [self reportSavedScoresAndAchievements];
                    }
                    [[NSNotificationCenter defaultCenter] postNotificationName:kGameCenterManagerAvailabilityNotification object:self userInfo:nil];
                }
                else
                {
                    [self setIsGameCenterAvailable:NO];
                }
            };
        }
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(_applicationDidEnterBackground:)
                                                     name:UIApplicationDidEnterBackgroundNotification object:nil];
    }
    return self;
}

- (NSMutableDictionary *)_getData
{
    static NSMutableDictionary *dic;
    if(dic == nil)
    {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if(![fileManager fileExistsAtPath:kGameCenterManagerDataPath])
        {
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            NSData *saveData = [[NSKeyedArchiver archivedDataWithRootObject:dict] encryptedWithKey:kGameCenterManagerKey];
            [saveData writeToFile:kGameCenterManagerDataPath atomically:YES];
        }
        
        NSData *gameCenterManagerData = [[NSData dataWithContentsOfFile:kGameCenterManagerDataPath] decryptedWithKey:kGameCenterManagerKey];
        dic = [NSKeyedUnarchiver unarchiveObjectWithData:gameCenterManagerData];
        
        //NOTE: remove large duplicate data before SlotsFarm v1.2
        [dic removeObjectForKey:kSavedScores];
        [dic removeObjectForKey:kSavedAchievements];
    }
    
    return dic;
}

- (NSMutableDictionary *)_getDataOfCurrentPlayer
{
    NSMutableDictionary *dicData = [self _getData];
    NSString *key = [self localPlayerId];
    NSMutableDictionary *dic = [dicData objectForKey:key];
    if(dic == nil)
    {
        dic = [NSMutableDictionary dictionary];
        [dicData setObject:dic forKey:key];
    }
    
    return dic;
}

- (void)saveData
{
    NSData *data = [[NSKeyedArchiver archivedDataWithRootObject:[self _getData]] encryptedWithKey:kGameCenterManagerKey];
    [data writeToFile:kGameCenterManagerDataPath atomically:YES];
}

- (void)syncGameCenter
{
    if([self isInternetAvailable])
    {
        if(![[NSUserDefaults standardUserDefaults] boolForKey:[@"scoresSynced" stringByAppendingString:[self localPlayerId]]])
        {
            if(_leaderboards == nil)
            {
                [GKLeaderboard loadLeaderboardsWithCompletionHandler:^(NSArray *leaderboards, NSError *error) {
                    if(error == nil)
                    {
                        _leaderboards = [[NSMutableArray alloc] initWithArray:leaderboards];
                        [self syncGameCenter];
                    }
                }];
                return;
            }
            
            if(_leaderboards.count > 0)
            {
                GKLeaderboard *leaderboardRequest = [[GKLeaderboard alloc] initWithPlayerIDs:[NSArray arrayWithObject:[self localPlayerId]]];
                GKLeaderboard *leaderboard = [_leaderboards objectAtIndex:0];
                [leaderboardRequest setCategory:leaderboard.category];
                [leaderboardRequest loadScoresWithCompletionHandler:^(NSArray *scores, NSError *error)
                 {
                     if(error == nil)
                     {
                         if(scores.count > 0)
                         {
                             NSMutableDictionary *dicDataOfCurrentPlayer = [self _getDataOfCurrentPlayer];
                             int savedHighScoreValue = 0;
                             NSNumber *savedHighScore = [dicDataOfCurrentPlayer objectForKey:leaderboardRequest.localPlayerScore.category];
                             if(savedHighScore != nil)
                             {
                                 savedHighScoreValue = [savedHighScore intValue];
                             }
                             [dicDataOfCurrentPlayer setObject:[NSNumber numberWithInt:MAX(leaderboardRequest.localPlayerScore.value, savedHighScoreValue)] forKey:leaderboardRequest.localPlayerScore.category];
                         }
                         
                         //NOTE: crash here: [__NSArrayM removeObjectAtIndex:]: index 0 beyond bounds for empty array'
                         if(_leaderboards.count > 0)
                             [_leaderboards removeObjectAtIndex:0];
                         [self syncGameCenter];
                     }
                 }];
            }
            else
            {
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:[@"scoresSynced" stringByAppendingString:[self localPlayerId]]];
                [self syncGameCenter];
            }
        }
        else if(![[NSUserDefaults standardUserDefaults] boolForKey:[@"achievementsSynced" stringByAppendingString:[self localPlayerId]]])
        {
            [GKAchievement loadAchievementsWithCompletionHandler:^(NSArray *achievements, NSError *error) {
                if(error == nil)
                {
                    if(achievements.count > 0)
                    {
                        NSMutableDictionary *dicDataOfCurrentPlayer = [self _getDataOfCurrentPlayer];
                        for(GKAchievement *achievement in achievements)
                        {
                            [dicDataOfCurrentPlayer setObject:[NSNumber numberWithDouble:achievement.percentComplete] forKey:achievement.identifier];
                        }
                    }
                    
                    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:[@"achievementsSynced" stringByAppendingString:[self localPlayerId]]];
                    [self syncGameCenter];
                }
            }];
        }
    }
}

- (void)reportScore:(NSInteger)score leaderboard:(NSString *)identifier
{
    NSMutableDictionary *dicDataOfCurrentPlayer = [self _getDataOfCurrentPlayer];
    NSNumber *savedHighScore = [dicDataOfCurrentPlayer objectForKey:identifier];
    if(savedHighScore == nil)
    {
        savedHighScore = [NSNumber numberWithInt:0];
    }
    int savedHighScoreValue = [savedHighScore intValue];
    if(score > savedHighScoreValue)
    {
        [dicDataOfCurrentPlayer setObject:[NSNumber numberWithInteger:score] forKey:identifier];
    }
    
    if([self isGameCenterAvailable])
    {
        if([GKLocalPlayer localPlayer].authenticated)
        {
            if([self isInternetAvailable])
            {
                GKScore *gkScore = [[GKScore alloc] initWithCategory:identifier];
                gkScore.value = score;
                [gkScore reportScoreWithCompletionHandler:^(NSError *error) {
                    if(error)
                    {
                        [self _saveDataToReportLater:[NSNumber numberWithDouble:score] category:identifier isScore:YES];
                    }
                    [[NSNotificationCenter defaultCenter] postNotificationName:kGameCenterManagerReportScoreNotification object:self userInfo:nil];
                }];
            }
            else
            {
                [self _saveDataToReportLater:[NSNumber numberWithDouble:score] category:identifier isScore:YES];
            }
        }
    }
}

- (void)reportAchievement:(NSString *)identifier percentComplete:(double)percentComplete
{
    NSMutableDictionary *dicDataOfCurrentPlayer = [self _getDataOfCurrentPlayer];
    NSNumber *savedPercentComplete = [dicDataOfCurrentPlayer objectForKey:identifier];
    if(savedPercentComplete == nil)
    {
        savedPercentComplete = [NSNumber numberWithDouble:0];
    }
    double savedPercentCompleteValue = [savedPercentComplete doubleValue];
    if(percentComplete > savedPercentCompleteValue)
    {
        [dicDataOfCurrentPlayer setObject:[NSNumber numberWithDouble:percentComplete] forKey:identifier];
        
        //NOTE: avoid report again
        if([self isGameCenterAvailable])
        {
            if([GKLocalPlayer localPlayer].authenticated)
            {
                if([self isInternetAvailable])
                {
                    GKAchievement *achievement = [[GKAchievement alloc] initWithIdentifier:identifier];
                    achievement.percentComplete = percentComplete;
                    achievement.showsCompletionBanner = YES;
                    [achievement reportAchievementWithCompletionHandler:^(NSError *error) {
                        if(error)
                        {
                            [self _saveDataToReportLater:[NSNumber numberWithDouble:percentComplete] category:identifier isScore:NO];
                        }
                        [[NSNotificationCenter defaultCenter] postNotificationName:kGameCenterManagerReportAchievementNotification object:self userInfo:nil];
                    }];
                }
                else
                {
                    [self _saveDataToReportLater:[NSNumber numberWithDouble:percentComplete] category:identifier isScore:NO];
                }
            }
        }
    }
}

- (void)_saveDataToReportLater:(NSNumber *)data category:(NSString *)category isScore:(BOOL)isScore
{
    if(!data || !category)
        return;
    
    NSString *key = isScore ? kSavedScores : kSavedAchievements;
    NSMutableDictionary *dicDataOfCurrentPlayer = [self _getDataOfCurrentPlayer];
    NSMutableDictionary *dicSavedData = [dicDataOfCurrentPlayer objectForKey:key];
    if(dicSavedData != nil)
    {
        [dicSavedData setObject:data forKey:category];
    }
    else
    {
        dicSavedData = [NSMutableDictionary dictionaryWithObjectsAndKeys:data, category, nil];
        [dicDataOfCurrentPlayer setObject:dicSavedData forKey:key];
    }
}

- (int)highScoreForLeaderboard:(NSString *)identifier
{
    NSMutableDictionary *dicDataOfCurrentPlayer = [self _getDataOfCurrentPlayer];
    NSNumber *savedHighScore = [dicDataOfCurrentPlayer objectForKey:identifier];
    if(savedHighScore != nil)
    {
        return [savedHighScore intValue];
    }
    return 0;
}

- (NSDictionary *)highScoreForLeaderboards:(NSArray *)identifiers
{
    NSMutableDictionary *dicDataOfCurrentPlayer = [self _getDataOfCurrentPlayer];
    NSMutableDictionary *highScores = [[NSMutableDictionary alloc] initWithCapacity:identifiers.count];
    for(NSString *identifier in identifiers)
    {
        NSNumber *savedHighScore = [dicDataOfCurrentPlayer objectForKey:identifier];
        if(savedHighScore != nil)
        {
            [highScores setObject:[NSNumber numberWithInt:[savedHighScore intValue]] forKey:identifier];
            continue;
        }
        [highScores setObject:[NSNumber numberWithInt:0] forKey:identifier];
    }
    
    NSDictionary *highScoreDict = [NSDictionary dictionaryWithDictionary:highScores];
    
    return highScoreDict;
}

- (double)progressForAchievement:(NSString *)identifier
{
    NSMutableDictionary *dicDataOfCurrentPlayer = [self _getDataOfCurrentPlayer];
    NSNumber *savedPercentComplete = [dicDataOfCurrentPlayer objectForKey:identifier];
    return [savedPercentComplete doubleValue];
}

- (NSDictionary *)progressForAchievements:(NSArray *)identifiers
{
    NSMutableDictionary *dicDataOfCurrentPlayer = [self _getDataOfCurrentPlayer];
    NSMutableDictionary *percent = [[NSMutableDictionary alloc] initWithCapacity:identifiers.count];
    for(NSString *identifier in identifiers)
    {
        NSNumber *savedPercentComplete = [dicDataOfCurrentPlayer objectForKey:identifier];
        if(savedPercentComplete != nil)
        {
            [percent setObject:[NSNumber numberWithDouble:[savedPercentComplete doubleValue]] forKey:identifier];
            continue;
        }
        [percent setObject:[NSNumber numberWithDouble:0] forKey:identifier];
    }
    
    NSDictionary *percentDict = [NSDictionary dictionaryWithDictionary:percent];
    
    return percentDict;
}

- (void)reportSavedScoresAndAchievements
{
    if([self isInternetAvailable])
    {
        GKScore *gkScore = nil;
        
        NSMutableDictionary *dicDataOfCurrentPlayer = [self _getDataOfCurrentPlayer];
        NSMutableDictionary *dicSavedScores = [dicDataOfCurrentPlayer objectForKey:kSavedScores];
        if(dicSavedScores != nil && dicSavedScores.count > 0)
        {
            NSString *category = [[dicSavedScores allKeys] objectAtIndex:0];
            NSNumber *value = dicSavedScores[category];
            
            gkScore = [[GKScore alloc] initWithCategory:category];
            gkScore.value = [value longLongValue];
            
            [dicSavedScores removeObjectForKey:category];
        }
        
        if(gkScore != nil)
        {
            [gkScore reportScoreWithCompletionHandler:^(NSError *error) {
                if(error == nil)
                {
                    [self reportSavedScoresAndAchievements];
                }
                else
                {
                    [self _saveDataToReportLater:[NSNumber numberWithLongLong:gkScore.value] category:gkScore.category isScore:YES];
                }
            }];
        }
        else
        {
            if([GKLocalPlayer localPlayer].authenticated)
            {
                NSString *identifier = nil;
                double percentComplete = 0;
                
                NSMutableDictionary *dicAchievements = [dicDataOfCurrentPlayer objectForKey:kSavedAchievements];
                if(dicAchievements != nil && dicAchievements.count > 0)
                {
                    identifier = [[dicAchievements allKeys] objectAtIndex:0];
                    percentComplete = [dicAchievements[identifier] doubleValue];
                    
                    [dicAchievements removeObjectForKey:identifier];
                }
                
                if(identifier != nil)
                {
                    GKAchievement *achievement = [[GKAchievement alloc] initWithIdentifier:identifier];
                    achievement.percentComplete = percentComplete;
                    [achievement reportAchievementWithCompletionHandler:^(NSError *error) {
                        if(error == nil)
                        {
                            [self reportSavedScoresAndAchievements];
                        }
                        else
                        {
                            [self _saveDataToReportLater:[NSNumber numberWithDouble:percentComplete] category:identifier isScore:NO];
                        }
                    }];
                }
            }
        }
    }
}

- (void)resetAchievements
{
    if([self isGameCenterAvailable]) {
        [GKAchievement resetAchievementsWithCompletionHandler:^(NSError *error) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kGameCenterManagerResetAchievementNotification object:self userInfo:nil];
        }];
    }
}

- (NSString *)localPlayerId
{
    if([self isGameCenterAvailable])
    {
        if([GKLocalPlayer localPlayer].authenticated)
        {
            return [GKLocalPlayer localPlayer].playerID;
        }
    }
    return @"unknownPlayer";
}

- (BOOL)isInternetAvailable
{
    return [KSReachability reachabilityToLocalNetwork].reachable;
}

- (BOOL)isUserAuthenticated
{
    return [GKLocalPlayer localPlayer].authenticated;
}

- (void)dealloc
{
    [self saveData];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - App states -
- (void)_applicationDidEnterBackground:(NSNotification *)notification
{
    [self saveData];
}

@end
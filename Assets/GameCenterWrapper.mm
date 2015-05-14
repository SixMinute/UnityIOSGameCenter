#import "GameCenterWrapper.h"
#import <GameKit/GameKit.h>

static GameCenterWrapper *gameCenterW = NULL;

@interface GameCenterWrapper ()
@property (nonatomic, strong) NSDictionary* _SignInParams;
@end

@implementation GameCenterWrapper

- (void)setup
{
    GKLocalPlayer* localPlayer = [GKLocalPlayer localPlayer];
    
    if(localPlayer.authenticated)
    {
        [localPlayer generateIdentityVerificationSignatureWithCompletionHandler:
         ^(NSURL *publicKeyUrl, NSData *signature, NSData *salt, uint64_t timestamp, NSError *error)
         {
             self._SignInParams = @{@"public_key_url": [publicKeyUrl absoluteString],
                                         @"timestamp": [NSString stringWithFormat:@"%llu", timestamp],
                                         @"signature": [signature base64EncodedStringWithOptions:0],
                                              @"salt": [salt base64EncodedStringWithOptions:0],
                                         @"player_id": [GKLocalPlayer localPlayer].playerID,
                                     @"app_bundle_id": [[NSBundle mainBundle] bundleIdentifier]};
             
         }
        ];
    }
}

- (NSString*)getKey: (NSString*)key
{
    return (NSString*)[self._SignInParams objectForKey:key];
}

GameCenterWrapper* _GameCenterInstance()
{
    if(NULL == gameCenterW)
    {
        gameCenterW = [GameCenterWrapper alloc];
    }
    return gameCenterW;
}

NSString* _CreateNSString (const char* string)
{
    return string ? [NSString stringWithUTF8String: string] : [NSString stringWithUTF8String: ""];
}

char* _MakeStringCopy(NSString* nstring)
{
    const char* string = [nstring UTF8String];
    if (string == NULL)
    {
        return NULL;
    }
    char* res = (char*)malloc(strlen(string) + 1);
    strcpy(res, string);
    return res;
}

extern "C"
{
    void _GameCenterSetup()
    {
        [_GameCenterInstance() setup];
    }
    
    const char* _GameCenterGetKey(const char* key)
    {
        return _MakeStringCopy( [ _GameCenterInstance() getKey: _CreateNSString(key) ] );
    }
}

@end

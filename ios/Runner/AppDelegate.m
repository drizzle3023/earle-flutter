#include "AppDelegate.h"
#include "GeneratedPluginRegistrant.h"

#import "GoogleMaps/GoogleMaps.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  // Override point for customization after application launch.

   [GMSServices provideAPIKey:@"AIzaSyAwnC--Al1DCJdqPecCf1Lpd1Y_fYRUxoQ"];
   [GeneratedPluginRegistrant registerWithRegistry:self];


  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

@end

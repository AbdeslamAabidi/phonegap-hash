//
//  HashPlugin.h
//  Hasher
//
//  Joss Clifford-Frith 2016
//
//  https://github.com/jcf120
//

#import "Cordova/CDV.h"

@interface HashPlugin : CDVPlugin

- (void) hashString: (CDVInvokedUrlCommand*) command;
- (void) hashFile: (CDVInvokedUrlCommand*) command;

@end

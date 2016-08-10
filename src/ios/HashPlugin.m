//
//  HashPlugin.m
//  Hasher
//
//  Joss Clifford-Frith 2016
//
//  https://github.com/jcf120
//

#import "HashPlugin.h"
#import <CommonCrypto/CommonDigest.h>

#pragma mark Local Types

typedef NS_ENUM(NSUInteger, HashType) {
    md5,
    sha1,
    sha256,
    sha384,
    sha512,
    unsupported
};

#pragma mark -

#pragma mark Private Method Declarations

@interface HashPlugin()

#pragma mark Class Methods

+ (NSString*) hashString:(NSString*) str
                hashType:(HashType) hashType;

+ (NSString*) hashFile:(NSString*) path
              hashType:(HashType) hashType;

+ (HashType) hashTypeForString:(NSString*) hashStr;

+ (NSString*) hashData:(NSData*) data
              hashType:(HashType) hashType;

+ (NSString *) upperCaseHexForDigest:(uint8_t *)digest
                                size:(NSUInteger) size;


@end

#pragma mark -

#pragma mark HashPlugin Implementation

@implementation HashPlugin

#pragma mark Public Cordova Interface Methods

- (void) hashString: (CDVInvokedUrlCommand*) command {
    
    CDVPluginResult* result = nil;
    NSString* message = nil;
    
    NSDictionary* params = command.arguments[0];
    NSString* string = params[@"data"];
    NSString* hash = params[@"hash"];
    
    if ( string && hash ) {
        
        HashType hashType = [HashPlugin hashTypeForString: hash];
        message = [HashPlugin hashString: string
                                hashType: hashType];
        
    } else {
        message = @"Invalid arguments.";
    }
    
    result = [CDVPluginResult resultWithStatus: CDVCommandStatus_OK
                               messageAsString: message];
    
    [self.commandDelegate sendPluginResult: result
                                callbackId: command.callbackId];
}

- (void) hashFile: (CDVInvokedUrlCommand*) command {
    
    CDVPluginResult* result = nil;
    NSString* message = nil;
    
    NSDictionary* params = command.arguments[0];
    NSString* path = params[@"data"];
    NSString* hash = params[@"hash"];
    
    if ( path && hash ) {
        
        HashType hashType = [HashPlugin hashTypeForString: hash];
        message = [HashPlugin hashFile: path
                              hashType: hashType];
        
    } else {
        message = @"Invalid arguments.";
    }
    
    result = [CDVPluginResult resultWithStatus: CDVCommandStatus_OK
                               messageAsString: message];
    
    [self.commandDelegate sendPluginResult: result
                                callbackId: command.callbackId];
}

#pragma mark Private Class Methods

+ (NSString*) hashString:(NSString*) str
                hashType:(HashType) hashType {
    
    if ( hashType == unsupported ) {
        return @"Invalid Hash algorithm.";
    }
    
    NSData* data = [str dataUsingEncoding: NSUTF8StringEncoding];
    
    return [HashPlugin hashData: data
                       hashType: hashType];
}

+ (NSString*) hashFile:(NSString*) path
              hashType:(HashType) hashType {
    
    if ( hashType == unsupported ) {
        return @"Invalid Hash algorithm.";
    }
    
    NSString *decodedPath = [path stringByRemovingPercentEncoding];
    
    NSError *err;
    NSData *data = [NSData dataWithContentsOfFile: decodedPath
                                          options: NSDataReadingMappedIfSafe
                                            error: &err];
    
    if (err) {
        return err.localizedDescription;
    }
    
    if (!data) {
        return @"Couldn't load file data.";
    }
    
    return [HashPlugin hashData:data
                       hashType:hashType];
}

+ (HashType) hashTypeForString:(NSString*) hashStr {
    NSString* str = hashStr.lowercaseString;
    if		([str isEqualToString: @"md5"    ]) return md5;
    else if ([str isEqualToString: @"sha1"	 ]) return sha1;
    else if ([str isEqualToString: @"sha-256"]) return sha256;
    else if ([str isEqualToString: @"sha-384"]) return sha384;
    else if ([str isEqualToString: @"sha-512"]) return sha512;
    else 								        return unsupported;
}

+ (NSString*) hashData:(NSData*) data
              hashType:(HashType) hashType {
    
    NSUInteger digestSize = 0;
    
    switch (hashType) {
        case md5:    digestSize = CC_MD5_DIGEST_LENGTH;    break;
        case sha1:   digestSize = CC_SHA1_DIGEST_LENGTH;   break;
        case sha256: digestSize = CC_SHA256_DIGEST_LENGTH; break;
        case sha384: digestSize = CC_SHA384_DIGEST_LENGTH; break;
        case sha512: digestSize = CC_SHA512_DIGEST_LENGTH; break;
        case unsupported: break; // Won't happen but clears compiler warning
    }
    
    uint8_t* digest = malloc(sizeof(uint8_t) * digestSize);
    
    switch (hashType) {
        case md5:    CC_MD5   (data.bytes, (CC_LONG)data.length, digest); break;
        case sha1:   CC_SHA1  (data.bytes, (CC_LONG)data.length, digest); break;
        case sha256: CC_SHA256(data.bytes, (CC_LONG)data.length, digest); break;
        case sha384: CC_SHA384(data.bytes, (CC_LONG)data.length, digest); break;
        case sha512: CC_SHA512(data.bytes, (CC_LONG)data.length, digest); break;
        case unsupported: break; // Won't happen but clears compiler warning
    }
    
    NSString* result = [HashPlugin upperCaseHexForDigest:digest
                                                    size:digestSize];
    
    free(digest);
    
    return result;
}

+ (NSString *) upperCaseHexForDigest:(uint8_t *)digest
                                size:(NSUInteger) size {
    
    NSMutableString *result = [NSMutableString stringWithCapacity: size * 2];
    
    for (NSUInteger i = 0; i < size; i++) {
        [result appendFormat: @"%02X", digest[i]];
    }
    
    return result;
}

@end

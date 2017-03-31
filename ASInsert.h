//
//  ASInsert.h
//  TestASInsert
//
//  Created by Joris Borst Pauwels on 30/03/2017.
//  Copyright © 2017 Joris Borst Pauwels. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ASInsert : NSObject {
    
    NSDictionary<NSString*, id>* _lastErrorInfo;
}

@property (readonly) NSDictionary<NSString*, id>* _Nullable lastErrorInfo;
@property NSAppleScript* _Nullable appleScript;

-(instancetype _Nullable) initWithScriptPath: (NSString*_Nonnull) path;
-(instancetype _Nullable) initWithScriptSource: (NSString *_Nonnull) source;

-(NSAppleEventDescriptor*_Nullable) executeFunction: (NSString* _Nonnull) functionName
                                      withArguments: (NSArray* _Nullable) arguments;

typedef void (^ processResultsBlock)(NSAppleEventDescriptor* _Nullable);
-(void) executeFunctionASync: (NSString* _Nonnull) functionName
               withArguments: (NSArray* _Nullable) scriptArgumentArray
                    andBlock: (processResultsBlock _Nonnull ) processResultsBlock;

@end

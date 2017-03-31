//
//  ASInsert.m
//  TestASInsert
//
//  Created by Joris Borst Pauwels on 30/03/2017.
//  Copyright © 2017 Joris Borst Pauwels. All rights reserved.
//

#import "ASInsert.h"


#define kASAppleScriptSuite 'ascr'
#define kASSubroutineEvent  'psbr'
#define keyASSubroutineName 'snam'


@implementation ASInsert

-(instancetype) initWithScriptPath: (NSString *) path
{
    if( (self = [super init]) ) {
        
        NSDictionary<NSString*, id>* errorInfo;
        _appleScript = [[NSAppleScript alloc] initWithContentsOfURL: [NSURL fileURLWithPath: path]
                                                              error: &errorInfo];
        _lastErrorInfo = errorInfo;
        
        // Compile (if needed)
        // Note: seems that the script is always compiled after initWithContentsOfURL
        if( _appleScript && !_appleScript.isCompiled ) {
            
            NSDictionary<NSString*, id>* errorInfo;
            if( ![_appleScript compileAndReturnError: &errorInfo] ) {
                
                _lastErrorInfo = errorInfo;
                return nil;
            }
        }
    }
    
    return self;
}

-(instancetype) initWithScriptSource: (NSString *) source
{
    if( (self = [super init]) ) {
        
        _appleScript = [[NSAppleScript alloc] initWithSource: source];
        _lastErrorInfo = nil;
        
        // Compile source code
        if( _appleScript && !_appleScript.isCompiled ) {
            
            NSDictionary<NSString*, id>* errorInfo;
            if( ![_appleScript compileAndReturnError: &errorInfo] ) {
                
                _lastErrorInfo = errorInfo;
                return nil;
            }
        }
    }
    
    return self;
}


-(NSAppleEventDescriptor*_Nullable) executeFunction: (NSString* _Nonnull) functionName
                                      withArguments: (NSArray* _Nullable) arguments
{

    // Create a event descriptor based on our current process
    ProcessSerialNumber psn = { 0, kCurrentProcess };
    NSAppleEventDescriptor *targetDesc = [NSAppleEventDescriptor descriptorWithDescriptorType: typeProcessSerialNumber
                                                                                        bytes: &psn
                                                                                       length: sizeof(ProcessSerialNumber) ];
    
    // Create a container event descriptor with our target process
    NSAppleEventDescriptor* containerEvent = [NSAppleEventDescriptor appleEventWithEventClass: kASAppleScriptSuite
                                                                                      eventID: kASSubroutineEvent
                                                                             targetDescriptor: targetDesc
                                                                                     returnID: kAutoGenerateReturnID
                                                                                transactionID: kAnyTransactionID];
    
    // Add the arguments (strings only) to the container event
    if( arguments && [arguments count] ) {
        
        NSAppleEventDescriptor *argDescriptor = [[NSAppleEventDescriptor alloc] initListDescriptor];
        for( NSString* str in arguments )
            [argDescriptor insertDescriptor: [NSAppleEventDescriptor descriptorWithString: str]
                                    atIndex: ([argDescriptor numberOfItems] + 1)];
        
        [containerEvent setParamDescriptor: argDescriptor forKeyword: keyDirectObject];
    }
    
    // Finaly, add the name of the function to call to the container event
    [containerEvent setDescriptor: [NSAppleEventDescriptor descriptorWithString: functionName] forKeyword: keyASSubroutineName];
    
    // Execute the event and return result
    NSDictionary<NSString*, id>* errorInfo;
    NSAppleEventDescriptor* result = [_appleScript executeAppleEvent: containerEvent error: &errorInfo];
    _lastErrorInfo = errorInfo;
    return result;
}

-(void) executeFunctionASync: (NSString* _Nonnull) functionName
               withArguments: (NSArray* _Nullable) scriptArgumentArray
                    andBlock: (processResultsBlock _Nonnull ) processResultsBlock
{
    // Run in background (global queue)
    dispatch_async( dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0 ), ^(void) {
        
        NSAppleEventDescriptor* resultDesc = [self executeFunction: functionName
                                                     withArguments: scriptArgumentArray];
        
        // Run in background (main queue) save for GUI updates
        dispatch_async( dispatch_get_main_queue(), ^(void) {
            
            processResultsBlock( resultDesc );
        });
    });
}

@end

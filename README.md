# AppleScriptInsert
Object-C Class for executing Apple Script from your application

Usage example:

-(void) TestIt {
    
    [self setOutput: @"Waiting for script to finish..."];
    
    NSString* sourceScript =  @"on TESTFUNCTION1(arg1, arg2, arg3)\n\
                                    delay 2\n\
                                    set result to {\"TESTFUNCTION1: The caller passed the following arguments:\", arg1, arg2, arg3}\n\
                                    return result\n\
                                end TESTFUNCTION1\n";
    ASInsert* insert = [[ASInsert alloc] initWithScriptSource: sourceScript ];
    
    // Execute both script functions at the same time, async
    NSArray* args = @[ @"Argument 1",  @"Argument 2",  @"Argument 3" ];
    [insert executeFunctionASync: @"TESTFUNCTION1"
                   withArguments: args
                        andBlock: ^(NSAppleEventDescriptor* resultDesc) {
                    
                     // Process results
                     NSLog( @"%@", resultDesc );
                     if( resultDesc )
                         [self setOutput: [NSString stringWithFormat: @"%@\n%@", self.output, resultDesc.description] ];
                     else
                         [self setOutput: [NSString stringWithFormat: @"%@\n%@", self.output, insert.lastErrorInfo.description] ];
                    }];
}

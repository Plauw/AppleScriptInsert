# AppleScriptInsert
Object-C Class for executing Apple Script from your application

Usage example:

```objc
#import "ASInsert.h"

-(void) TestIt
{
    
    NSString* sourceScript =  @"on TESTFUNCTION1(arg1, arg2, arg3)\n\
                                    delay 2\n\
                                    set result to {\"TESTFUNCTION1: The caller passed the following arguments:\", arg1, arg2, arg3}\n\
                                    return result\n\
                                end TESTFUNCTION1\n";
    ASInsert* insert = [[ASInsert alloc] initWithScriptSource: sourceScript ];
    
    // Execute function TESTFUNCTION1 in the above script (sourceScript) and return immediately
    NSArray* args = @[ @"Argument 1",  @"Argument 2",  @"Argument 3" ];
    [insert executeFunctionASync: @"TESTFUNCTION1"
                   withArguments: args
                        andBlock: ^(NSAppleEventDescriptor* resultDesc) {
                    
                     // Process results here...
                     if( resultDesc )
                         NSLog( @"%@", resultDesc );
                     else
                         NSLog( @"%@", insert.lastErrorInfo.description );
                    }];
}
```

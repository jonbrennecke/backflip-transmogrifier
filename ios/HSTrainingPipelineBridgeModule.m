#import <React/RCTUtils.h>

#import "HSTrainingPipelineBridgeModule.h"

@implementation HSTrainingPipelineBridgeModule

RCT_EXPORT_MODULE(HSTrainingPipeline)

+ (BOOL)requiresMainQueueSetup {
  return NO;
}

RCT_EXPORT_METHOD(createPipeline
                  : (NSDictionary *)requestArgs callback
                  : (RCTResponseSenderBlock)callback) {
  HSTrainingPipelineRequest *request =
      [[HSTrainingPipelineRequest alloc] initWithDict:requestArgs];
  if (!request) {
    id error = RCTMakeError(@"Invalid request sent to HSTrainingPipeline",
                            requestArgs, nil);
    callback(@[ error, @(NO) ]);
    return;
  }
  NSError *error;
  [[HSTrainingPipeline sharedInstance]
      runPipelineWithRequest:request
                       error:&error
           completionHandler:^(enum HSTrainingPileplineResult result) {
             if (error) {
               callback(@[ error, @(NO) ]);
               return;
             }
             if (result != HSTrainingPileplineResultSuccess) {
               callback(@[ [NSNull null], @(NO) ]);
               return;
             }
             callback(@[ [NSNull null], @(YES) ]);
           }];
}

@end

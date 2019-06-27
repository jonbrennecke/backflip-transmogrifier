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
    callback(@[ error, [NSNull null] ]);
    return;
  }
  NSError *error;
  [[HSTrainingPipeline sharedInstance] createPipeline:request error:&error];
  if (error) {
    callback(@[ error, [NSNull null] ]);
    return;
  }
  callback(@[ [NSNull null], [NSNull null] ]);
}

@end

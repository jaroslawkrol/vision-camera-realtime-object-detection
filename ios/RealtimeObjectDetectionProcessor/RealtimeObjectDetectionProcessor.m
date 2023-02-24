#import <Foundation/Foundation.h>
#import <MLKit.h>
#import <VisionCamera/Frame.h>
#import <VisionCamera/FrameProcessorPlugin.h>

@interface RealtimeObjectDetectionProcessorPlugin : NSObject
+ (MLKObjectDetector*)detector:(NSDictionary*)config;
@end

@implementation RealtimeObjectDetectionProcessorPlugin

+ (MLKObjectDetector*)detector:(NSDictionary*)config {
  static MLKObjectDetector* detector = nil;
  if (detector == nil) {
    NSString* filename = config[@"modelFile"];
    NSString* extension = [filename pathExtension];
    NSString* modelName = [filename stringByDeletingPathExtension];
    NSString* path = [[NSBundle mainBundle] pathForResource:modelName ofType:extension];
    MLKLocalModel* localModel = [[MLKLocalModel alloc] initWithPath:path];

    NSNumber* classificationConfidenceThreshold = config[@"classificationConfidenceThreshold"];
    NSNumber* maxPerObjectLabelCount = config[@"maxPerObjectLabelCount"];
    MLKCustomObjectDetectorOptions* options =
        [[MLKCustomObjectDetectorOptions alloc] initWithLocalModel:localModel];
    options.detectorMode = MLKObjectDetectorModeStream;
    options.shouldEnableClassification = YES;
    options.shouldEnableMultipleObjects = NO;
    options.classificationConfidenceThreshold = classificationConfidenceThreshold;
    options.maxPerObjectLabelCount = maxPerObjectLabelCount.intValue;

    detector = [MLKObjectDetector objectDetectorWithOptions:options];
  }
  return detector;
}

static inline id detectObjects(Frame* frame, NSArray* args) {
  NSDictionary* config = [args objectAtIndex:0];
  NSNumber* size = config[@"size"];

  UIImageOrientation orientation = frame.orientation;

  MLKVisionImage* image = [[MLKVisionImage alloc] initWithBuffer:frame.buffer];
  image.orientation = orientation;

  CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(frame.buffer);
  size_t width = CVPixelBufferGetWidth(imageBuffer);
  size_t height = CVPixelBufferGetHeight(imageBuffer);

  NSError* error;
  NSArray<MLKObject*>* objects =
      [[RealtimeObjectDetectionProcessorPlugin detector:config] resultsInImage:image
                                                                           error:&error];

  NSMutableArray* results = [NSMutableArray arrayWithCapacity:objects.count];
  for (MLKObject* object in objects) {
    NSMutableArray* labels = [NSMutableArray arrayWithCapacity:object.labels.count];

    for (MLKObjectLabel* label in object.labels) {
      [labels addObject:@{
        @"index" : [NSNumber numberWithFloat:label.index],
        @"label" : label.text,
        @"confidence" : [NSNumber numberWithFloat:label.confidence]
      }];
    }

    if (labels.count != 0) {
      [results addObject:@{
        @"width" : [NSNumber
            numberWithFloat:object.frame.size.width / width],
        @"height" : [NSNumber
            numberWithFloat:object.frame.size.height / height],
        @"top" :
            [NSNumber numberWithFloat:object.frame.origin.y / height],
        @"left" :
            [NSNumber numberWithFloat:object.frame.origin.x / width],
        @"frameRotation" : [NSNumber numberWithFloat:frame.orientation],
        @"labels" : labels
      }];
    }
  }

  return results;
}

VISION_EXPORT_FRAME_PROCESSOR(detectObjects)

@end

#import <Foundation/Foundation.h>
#import <VisionCamera/Frame.h>
#import <VisionCamera/FrameProcessorPlugin.h>
#import <TensorFlowLiteTaskVision/TensorFlowLiteTaskVision.h>

// TODO: extract to separate file
@interface ImageResizeResult : NSObject

@property(nonatomic, strong, readonly) UIImage* image;
@property(nonatomic, assign, readonly) float ratio;

- (instancetype)initWithImage:(UIImage*)image ratio:(float)ratio;

@end

@implementation ImageResizeResult

- (instancetype)initWithImage:(UIImage*)image ratio:(float)ratio {
  self = [super init];
  if (self) {
    _image = image;
    _ratio = ratio;
  }
  return self;
}

@end

@interface RealtimeObjectDetectionProcessorPlugin : NSObject
+ (TFLObjectDetector*)detector:(NSDictionary*)config;
+ (ImageResizeResult*)resizeFrameToUIimage:(Frame*)frame size:(float)size;
@end

@implementation RealtimeObjectDetectionProcessorPlugin

+ (TFLObjectDetector*)detector:(NSDictionary*)config {
  static TFLObjectDetector* detector = nil;
  if (detector == nil) {
    NSString* filename = config[@"modelFile"];
    NSString* extension = [filename pathExtension];
    NSString* modelName = [filename stringByDeletingPathExtension];
    NSString* modelPath = [[NSBundle mainBundle] pathForResource:modelName ofType:extension];

    NSNumber* classificationConfidenceThreshold = config[@"classificationConfidenceThreshold"];
    NSNumber* maxPerObjectLabelCount = config[@"maxPerObjectLabelCount"];
    TFLObjectDetectorOptions *options = [[TFLObjectDetectorOptions alloc] initWithModelPath:modelPath];
    options.classificationOptions.scoreThreshold = classificationConfidenceThreshold.floatValue;
    options.classificationOptions.maxResults = maxPerObjectLabelCount.intValue;
      options.baseOptions.computeSettings.cpuSettings.numThreads = 2;
//    options.detectorMode = MLKObjectDetectorModeSingleImage;
//    options.shouldEnableClassification = YES;
//    options.shouldEnableMultipleObjects = NO;
//    options.classificationConfidenceThreshold = classificationConfidenceThreshold;
//    options.maxPerObjectLabelCount = maxPerObjectLabelCount.intValue;
    NSError* error;
    detector = [TFLObjectDetector objectDetectorWithOptions:options error:nil];
      if(error) {
          NSLog(@"RealtimeObjectDetectionProcessorPluginInit: Error occurred: %@", error);
      }
  }
  return detector;
}

+ (ImageResizeResult*)resizeFrameToUIimage:(Frame*)frame size:(float)size {
  CGSize targetSize = CGSizeMake(size, size);
  CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(frame.buffer);

  CIImage* ciImage = [CIImage imageWithCVPixelBuffer:imageBuffer];
  CIContext* context = [CIContext contextWithOptions:nil];
  CGImageRef cgImage = [context createCGImage:ciImage fromRect:[ciImage extent]];
  UIImage* uiImage = [UIImage imageWithCGImage:cgImage];
  CGImageRelease(cgImage);

  float widthRatio = targetSize.width / uiImage.size.width;
  float heightRatio = targetSize.height / uiImage.size.height;
  float ratio = widthRatio < heightRatio ? widthRatio : heightRatio;

  CGSize newSize = CGSizeMake(uiImage.size.width * ratio, uiImage.size.height * ratio);
  CGRect rect = CGRectMake(0, 0, newSize.width, newSize.height);

  UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0);
  [uiImage drawInRect:rect];

  UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();

  ImageResizeResult* result = [[ImageResizeResult alloc] initWithImage:newImage ratio:ratio];
  return result;
}

static inline id detectObjects(Frame* frame, NSArray* args) {
  NSDictionary* config = [args objectAtIndex:0];
  NSNumber* size = config[@"size"];

  UIImageOrientation orientation = frame.orientation;

  ImageResizeResult* resizedImageResult =
      [RealtimeObjectDetectionProcessorPlugin resizeFrameToUIimage:frame size:size.floatValue];
  GMLImage* gmlImage = [[GMLImage alloc] initWithImage:resizedImageResult.image];
  gmlImage.orientation = orientation;

  NSError* error;
  TFLDetectionResult *detectionResult =
      [[RealtimeObjectDetectionProcessorPlugin detector:config] detectWithGMLImage:gmlImage error:&error];
    
    if(error) {
        NSLog(@"RealtimeObjectDetectionProcessorPlugin: Error occurred: %@", error);
    } else {
        NSLog(@"detectionResult: %@", detectionResult);
    }

    if(!detectionResult) {
        return @[];
    }
  NSMutableArray* results = [NSMutableArray arrayWithCapacity:detectionResult.detections.count];
  for (TFLDetection* detection in detectionResult.detections) {
    NSMutableArray* labels = [NSMutableArray arrayWithCapacity:detection.categories.count];

      if (detection.categories.count != 0) {
          
        for (TFLCategory* category in detection.categories) {
          [labels addObject:@{
            @"index" : [NSNumber numberWithLong:category.index],
            @"label" : category.displayName,
            @"confidence" : [NSNumber numberWithFloat:category.score]
          }];
        }

      [results addObject:@{
        @"width" : [NSNumber
            numberWithFloat:detection.boundingBox.size.width * resizedImageResult.ratio / resizedImageResult.image.size.width ],
        @"height" : [NSNumber
            numberWithFloat:detection.boundingBox.size.height * resizedImageResult.ratio / resizedImageResult.image.size.height],
        @"top" :
            [NSNumber numberWithFloat:detection.boundingBox.origin.y * resizedImageResult.ratio / resizedImageResult.image.size.height],
        @"left" :
            [NSNumber numberWithFloat:detection.boundingBox.origin.x * resizedImageResult.ratio / resizedImageResult.image.size.width],
        @"frameRotation" : [NSNumber numberWithFloat:frame.orientation],
        @"labels" : labels
      }];
    }
  }

  return results;
}

VISION_EXPORT_FRAME_PROCESSOR(detectObjects)

@end

#import <Foundation/Foundation.h>
#import <MLKit.h>
#import <VisionCamera/Frame.h>
#import <VisionCamera/FrameProcessorPlugin.h>

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
+ (MLKObjectDetector*)detector:(NSString*)filename;
+ (ImageResizeResult*)resizeFrameToUIimage:(Frame*)frame size:(float)size;
@end

@implementation RealtimeObjectDetectionProcessorPlugin

+ (MLKObjectDetector*)detector:(NSString*)filename {
  static MLKObjectDetector* detector = nil;
  if (detector == nil) {
    NSString* extension = [filename pathExtension];
    NSString* modelName = [filename stringByDeletingPathExtension];
    NSString* path = [[NSBundle mainBundle] pathForResource:modelName ofType:extension];
    MLKLocalModel* localModel = [[MLKLocalModel alloc] initWithPath:path];

    MLKCustomObjectDetectorOptions* options =
        [[MLKCustomObjectDetectorOptions alloc] initWithLocalModel:localModel];
    options.detectorMode = MLKObjectDetectorModeSingleImage;
    options.shouldEnableClassification = YES;
    options.shouldEnableMultipleObjects = NO;
    options.classificationConfidenceThreshold = @(0.3);
    options.maxPerObjectLabelCount = 1;

    detector = [MLKObjectDetector objectDetectorWithOptions:options];
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
  NSNumber* size = [args objectAtIndex:0];
  NSString* filename = [args objectAtIndex:1];

  UIImageOrientation orientation = frame.orientation;

  ImageResizeResult* resizedImageResult =
      [RealtimeObjectDetectionProcessorPlugin resizeFrameToUIimage:frame size:size.floatValue];
  MLKVisionImage* image = [[MLKVisionImage alloc] initWithImage:resizedImageResult.image];
  image.orientation = orientation;

  NSError* error;
  NSArray<MLKObject*>* objects =
      [[RealtimeObjectDetectionProcessorPlugin detector:filename] resultsInImage:image
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
            numberWithFloat:object.frame.size.width / resizedImageResult.image.size.width],
        @"height" : [NSNumber
            numberWithFloat:object.frame.size.height / resizedImageResult.image.size.height],
        @"top" :
            [NSNumber numberWithFloat:object.frame.origin.y / resizedImageResult.image.size.height],
        @"left" :
            [NSNumber numberWithFloat:object.frame.origin.x / resizedImageResult.image.size.width],
        @"frameRotation" : [NSNumber numberWithFloat:frame.orientation],
        @"labels" : labels
      }];
    }
  }

  return results;
}

VISION_EXPORT_FRAME_PROCESSOR(detectObjects)

@end

/* globals __detectObjects */
import type { Frame } from 'react-native-vision-camera';

export interface ObjectLabel {
  index: number;
  /**
   * A label describing the image, in english.
   */
  label: string;
  /**
   * A floating point number from 0 to 1, describing the confidence (percentage).
   */
  confidence: number;
}

export interface DetectedObject {
  frameRotation: number;
  labels: ObjectLabel[];

  /**
   * bounding box of detected object in percentage
   */
  top: number;
  left: number;
  width: number;
  height: number;
}

export interface FrameProcessorConfig {
  /**
   * TensorFlow model file. Should contains extension as well (f.e. model.tflite)
   */
  modelFile: string;

  scoreThreshold?: number;

  maxResults?: number;

  numThreads?: number;
}

const defaultFrameProcessorConfig: Partial<FrameProcessorConfig> = {
  scoreThreshold: 0.3,
  maxResults: 1,
  numThreads: 1,
};

/**
 * Returns an array of matching `DetectedObject`s for the given frame.
 */
export function detectObjects(
  frame: Frame,
  config: FrameProcessorConfig
): DetectedObject[] {
  'worklet';
  // @ts-expect-error Frame Processors are not typed.
  return __detectObjects(frame, { ...defaultFrameProcessorConfig, ...config });
}

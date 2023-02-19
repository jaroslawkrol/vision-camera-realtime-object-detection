/* globals __detectObjects */
import { Frame } from 'react-native-vision-camera';

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

  top: number;
  width: number;
  height: number;
  left: number;
}

export interface FrameProcessorConfig {
  model: string;
  size: number;
}

/**
 * Returns an array of matching `DetectedObject`s for the given frame.
 */
export function detectObjects(
  frame: Frame,
  config: FrameProcessorConfig
): DetectedObject[] {
  'worklet';
  // @ts-expect-error Frame Processors are not typed.
  return __detectObjects(frame, config.size, config.model);
}

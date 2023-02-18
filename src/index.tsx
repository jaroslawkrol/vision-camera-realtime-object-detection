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
 * Returns an array of matching `ImageLabel`s for the given frame.
 *
 * This algorithm executes within **~60ms**, so a frameRate of **16 FPS** perfectly allows the algorithm to run without dropping a frame. Anything higher might make video recording stutter, but works too.
 */
export function detectObjects(
  frame: Frame,
  config: FrameProcessorConfig
): DetectedObject[] {
  'worklet';
  // @ts-expect-error Frame Processors are not typed.
  return __detectObjects(frame, config.size, config.model);
}

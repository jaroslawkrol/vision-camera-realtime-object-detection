import React, { useState } from 'react';
import { StyleSheet, Text, useWindowDimensions, View } from 'react-native';
import {
  DetectedObject,
  detectObjects,
  FrameProcessorConfig,
} from 'vision-camera-realtime-object-detection';
import {
  Camera,
  CameraDevice,
  useFrameProcessor,
} from 'react-native-vision-camera';
import { runOnJS } from 'react-native-reanimated';

interface Props {
  device: CameraDevice;
}

const ObjectDetector: React.FC<Props> = ({ device }) => {
  const [objects, setObjects] = useState<DetectedObject[]>([]);

  const frameProcessorConfig: FrameProcessorConfig = {
    modelFile: 'model.tflite',
    scoreThreshold: 0.4,
    maxResults: 1,
    numThreads: 4,
  };

  const windowDimensions = useWindowDimensions();

  const frameProcessor = useFrameProcessor((frame) => {
    'worklet';

    const detectedObjects = detectObjects(frame, frameProcessorConfig);
    runOnJS(setObjects)(
      detectedObjects.map((obj) => ({
        ...obj,
        top: obj.top * windowDimensions.height,
        left: obj.left * windowDimensions.width,
        width: obj.width * windowDimensions.width,
        height: obj.height * windowDimensions.height,
      }))
    );
  }, []);

  return (
    <View style={StyleSheet.absoluteFill}>
      <Camera
        frameProcessorFps={5}
        frameProcessor={frameProcessor}
        style={StyleSheet.absoluteFill}
        device={device}
        isActive={true}
      />
      {objects?.map(
        (
          { top, left, width, height, labels }: DetectedObject,
          index: number
        ) => (
          <View
            key={`${index}`}
            style={[styles.detectionFrame, { top, left, width, height }]}
          >
            <Text style={styles.detectionFrameLabel}>
              {labels
                .map((label) => `${label.label} (${label.confidence})`)
                .join(',')}
            </Text>
          </View>
        )
      )}
    </View>
  );
};

const styles = StyleSheet.create({
  detectionFrame: {
    position: 'absolute',
    borderWidth: 1,
    borderColor: '#00ff00',
    zIndex: 9,
  },
  detectionFrameLabel: {
    backgroundColor: 'rgba(0, 255, 0, 0.25)',
  },
});

export default ObjectDetector;

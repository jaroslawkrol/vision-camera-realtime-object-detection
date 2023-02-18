import React, { useState } from 'react';
import { Dimensions, StyleSheet, Text, View } from 'react-native';
import {
  DetectedObject,
  detectObjects,
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

  const frameProcessorConfig = {
    model: 'efficientnet_lite0_fp32_2.tflite',
    size: 224,
  };

  const { width, height } = Dimensions.get('window');

  const frameProcessor = useFrameProcessor((frame) => {
    'worklet';

    const detectedObjects = detectObjects(frame, frameProcessorConfig);
    runOnJS(setObjects)(
      detectedObjects.map((obj) => ({
        ...obj,
        top: obj.top * height,
        left: obj.left * width,
        width: obj.width * width,
        height: obj.height * height,
      }))
    );
  }, []);

  return (
    <Camera
      frameProcessorFps={5}
      frameProcessor={frameProcessor}
      style={StyleSheet.absoluteFill}
      device={device}
      isActive={true}
      preset={'medium'}
    >
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
              {labels.map((label) => label.label).join(',')}
            </Text>
          </View>
        )
      )}
    </Camera>
  );
};

const styles = StyleSheet.create({
  detectionFrame: {
    position: 'absolute',
    borderWidth: 1,
    borderColor: '#00ff00',
  },
  detectionFrameLabel: {
    backgroundColor: 'rgba(0, 255, 0, 0.25)',
  },
});

export default ObjectDetector;

import {
  requireNativeComponent,
  UIManager,
  Platform,
  ViewStyle,
} from 'react-native';

const LINKING_ERROR =
  `The package 'vision-camera-realtime-object-detection' doesn't seem to be linked. Make sure: \n\n` +
  Platform.select({ ios: "- You have run 'pod install'\n", default: '' }) +
  '- You rebuilt the app after installing the package\n' +
  '- You are not using Expo Go\n';

type VisionCameraRealtimeObjectDetectionProps = {
  color: string;
  style: ViewStyle;
};

const ComponentName = 'VisionCameraRealtimeObjectDetectionView';

export const VisionCameraRealtimeObjectDetectionView =
  UIManager.getViewManagerConfig(ComponentName) != null
    ? requireNativeComponent<VisionCameraRealtimeObjectDetectionProps>(ComponentName)
    : () => {
        throw new Error(LINKING_ERROR);
      };

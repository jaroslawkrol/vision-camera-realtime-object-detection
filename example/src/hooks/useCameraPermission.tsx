import { useEffect, useState } from 'react';
import { check, PERMISSIONS, request } from 'react-native-permissions';
import { Platform } from 'react-native';

interface CameraPermissionState {
  pending: boolean;
  isPermissionGranted: boolean;
}

export const useCameraPermission = () => {
  const [cameraPermissionState, setCameraPermissionState] =
    useState<CameraPermissionState>({
      pending: true,
      isPermissionGranted: false,
    });

  useEffect(() => {
    const bootstrap = async () => {
      const permission =
        Platform.OS === 'ios'
          ? PERMISSIONS.IOS.CAMERA
          : PERMISSIONS.ANDROID.CAMERA;
      const permissionStatus = await check(permission);
      switch (permissionStatus) {
        case 'granted':
        case 'limited': {
          setCameraPermissionState({
            pending: false,
            isPermissionGranted: true,
          });
          break;
        }
        case 'denied': {
          const requestStatus = await request(permission);
          setCameraPermissionState({
            pending: false,
            isPermissionGranted: requestStatus === 'granted',
          });
          break;
        }
        case 'blocked':
        case 'unavailable':
        default: {
          setCameraPermissionState({
            pending: false,
            isPermissionGranted: false,
          });
          break;
        }
      }
    };

    bootstrap();
  }, []);

  return cameraPermissionState;
};

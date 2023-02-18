import React, { useEffect, useState } from 'react';

import { useCameraDevices } from 'react-native-vision-camera';
import { check, PERMISSIONS, request } from 'react-native-permissions';
import LoadingView from './components/LoadingView';
import PermissionDenied from './components/PermissionDenied';
import ObjectDetector from './components/ObjectDetector';

interface AppState {
  isLoading: boolean;
  isPermissionGranted: boolean;
}

export default function App() {
  const devices = useCameraDevices('wide-angle-camera');
  const device = devices.back;

  const [appState, setAppState] = useState<AppState>({
    isLoading: true,
    isPermissionGranted: false,
  });

  useEffect(() => {
    const bootstrap = async () => {
      const permissionStatus = await check(PERMISSIONS.IOS.CAMERA);
      switch (permissionStatus) {
        case 'granted':
        case 'limited': {
          setAppState({
            isLoading: false,
            isPermissionGranted: true,
          });
          break;
        }
        case 'denied': {
          const requestStatus = await request(PERMISSIONS.IOS.CAMERA);
          setAppState({
            isLoading: false,
            isPermissionGranted: requestStatus === 'granted',
          });
          break;
        }
        case 'blocked':
        case 'unavailable':
        default: {
          setAppState({
            isLoading: false,
            isPermissionGranted: false,
          });
          break;
        }
      }
    };

    bootstrap();
  }, []);

  if (appState.isLoading || !device) return <LoadingView />;
  if (!appState.isPermissionGranted) return <PermissionDenied />;
  return <ObjectDetector device={device} />;
}

import React from 'react';

import { useCameraDevices } from 'react-native-vision-camera';
import LoadingView from './components/LoadingView';
import PermissionDenied from './components/PermissionDenied';
import ObjectDetector from './components/ObjectDetector';
import { useCameraPermission } from './hooks/useCameraPermission';

export default function App() {
  const devices = useCameraDevices('wide-angle-camera');
  const device = devices.back;

  const { pending, isPermissionGranted } = useCameraPermission();

  if (!device || pending) return <LoadingView />;
  if (!isPermissionGranted) return <PermissionDenied />;
  return <ObjectDetector device={device} />;
}

package com.visioncamerarealtimeobjectdetection

import com.facebook.react.ReactPackage
import com.facebook.react.bridge.NativeModule
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.uimanager.ViewManager
import com.mrousavy.camera.frameprocessor.FrameProcessorPlugin
import com.visioncamerarealtimeobjectdetection.realtimeobjectdetectionprocessor.RealtimeObjectDetectionProcessorPlugin

class RealtimeObjectDetectionProcessorPluginPackage : ReactPackage {
  override fun createNativeModules(reactContext: ReactApplicationContext): List<NativeModule> {
    FrameProcessorPlugin.register(RealtimeObjectDetectionProcessorPlugin(reactContext))
    return emptyList()
  }

  override fun createViewManagers(reactContext: ReactApplicationContext): List<ViewManager<*, *>> {
    return emptyList()
  }
}

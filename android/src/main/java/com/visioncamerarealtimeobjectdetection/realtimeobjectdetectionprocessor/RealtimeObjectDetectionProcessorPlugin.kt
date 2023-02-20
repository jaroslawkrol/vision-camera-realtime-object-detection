package com.visioncamerarealtimeobjectdetection.realtimeobjectdetectionprocessor

import androidx.camera.core.ImageProxy
import com.facebook.react.bridge.WritableNativeArray;
import com.facebook.react.bridge.WritableNativeMap;
import com.mrousavy.camera.frameprocessor.FrameProcessorPlugin

import com.google.android.gms.tasks.Task;
import com.google.android.gms.tasks.Tasks;

import com.google.mlkit.common.model.LocalModel
import com.google.mlkit.vision.common.InputImage
import com.google.mlkit.vision.objects.custom.CustomObjectDetectorOptions
import com.google.mlkit.vision.objects.ObjectDetection
import com.google.mlkit.vision.objects.ObjectDetector

class RealtimeObjectDetectionProcessorPlugin: FrameProcessorPlugin("detectObjects") {
  private var _detector: ObjectDetector? = null

  val detector: ObjectDetector
    get() {
      if(_detector == null) {
        val localModel = LocalModel.Builder()
                .setAssetFilePath("custom/efficientnet_lite0_fp32_2.tflite")
                .build()


        val customObjectDetectorOptions = CustomObjectDetectorOptions.Builder(localModel)
                .setDetectorMode(CustomObjectDetectorOptions.SINGLE_IMAGE_MODE)
                .enableClassification()
                .setClassificationConfidenceThreshold(0.2f)
                .setMaxPerObjectLabelCount(1)
                .build()

        _detector = ObjectDetection.getClient(customObjectDetectorOptions)
      }
      return _detector!!
    }

  override fun callback(frame: ImageProxy, params: Array<Any>): WritableNativeArray {
    val mediaImage = frame.image
    if(mediaImage != null) {
        val image = InputImage.fromMediaImage(mediaImage, frame.imageInfo.rotationDegrees)
        val task = detector.process(image);
        val results = WritableNativeArray()

        val frameWidth = if(frame.imageInfo.rotationDegrees == 90 || frame.imageInfo.rotationDegrees == 270) mediaImage.width else mediaImage.height
        val frameHeight = if(frame.imageInfo.rotationDegrees == 90 || frame.imageInfo.rotationDegrees == 270) mediaImage.height else mediaImage.width

        try {
            val objects = Tasks.await(task)

            for (detectedObject in objects) {
                val labels = WritableNativeArray()

                for (label in detectedObject.labels) {
                    val labelMap = WritableNativeMap()

                    labelMap.putInt("index", label.index)
                    labelMap.putString("label", label.text)
                    labelMap.putDouble("confidence", label.confidence.toDouble())

                    labels.pushMap(labelMap)
                }

                if (labels.size() > 0) {
                    val objectMap = WritableNativeMap()

                    objectMap.putArray("labels", labels)
                    objectMap.putDouble("top", (detectedObject.boundingBox.top.toFloat() / frameWidth).toDouble())
                    objectMap.putDouble("left", (detectedObject.boundingBox.left.toFloat() / frameHeight).toDouble())
                    objectMap.putDouble("width", ((detectedObject.boundingBox.right - detectedObject.boundingBox.left).toFloat() / frameHeight).toDouble())
                    objectMap.putDouble("height", ((detectedObject.boundingBox.bottom - detectedObject.boundingBox.top).toFloat() / frameWidth).toDouble())

                    results.pushMap(objectMap)
                }
            }

            return results
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    return WritableNativeArray()
  }
}

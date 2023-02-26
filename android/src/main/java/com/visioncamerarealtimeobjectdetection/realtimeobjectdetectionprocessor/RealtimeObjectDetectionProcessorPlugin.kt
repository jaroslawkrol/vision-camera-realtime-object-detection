package com.visioncamerarealtimeobjectdetection.realtimeobjectdetectionprocessor

import android.graphics.Matrix
import android.graphics.RectF
import androidx.camera.core.ImageProxy
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReadableMap
import com.facebook.react.bridge.WritableNativeArray
import com.facebook.react.bridge.WritableNativeMap
import com.google.android.odml.image.MediaMlImageBuilder
import com.mrousavy.camera.frameprocessor.FrameProcessorPlugin
import org.tensorflow.lite.task.core.BaseOptions
import org.tensorflow.lite.task.vision.detector.ObjectDetector

class RealtimeObjectDetectionProcessorPlugin(reactContext: ReactApplicationContext) :
    FrameProcessorPlugin("detectObjects") {
    private val _context: ReactApplicationContext = reactContext
    private var _detector: ObjectDetector? = null

    fun rotateRect(rect: RectF, degrees: Int): RectF {
        val matrix = Matrix()
        matrix.postRotate(degrees.toFloat(), rect.centerX(), rect.centerY())
        val rotatedRect = RectF(rect)
        matrix.mapRect(rotatedRect)
        return rotatedRect
    }

    fun getDetectorWithModelFile(config: ReadableMap): ObjectDetector {
        if (_detector == null) {
            val modelFile = config.getString("modelFile")

            val scoreThreshold = config.getDouble("scoreThreshold").toFloat()
            val maxResults = config.getInt("maxResults")
            val numThreads = config.getInt("numThreads")

            val baseOptionsBuilder = BaseOptions.builder().setNumThreads(numThreads)

            val optionsBuilder =
                ObjectDetector.ObjectDetectorOptions.builder()
                    .setBaseOptions(baseOptionsBuilder.build())
                    .setScoreThreshold(scoreThreshold)
                    .setMaxResults(maxResults)

            _detector =
                ObjectDetector.createFromFileAndOptions(
                    _context,
                    "custom/$modelFile",
                    optionsBuilder.build()
                )
        }
        return _detector!!
    }

    override fun callback(frame: ImageProxy, params: Array<Any>): WritableNativeArray {
        val mediaImage = frame.image

        if (mediaImage == null) {
            return WritableNativeArray()
        }

        val config = params[0] as ReadableMap

        val mlImage = MediaMlImageBuilder(mediaImage).build()

        val frameWidth =
            if (frame.imageInfo.rotationDegrees == 90 || frame.imageInfo.rotationDegrees == 270)
                mediaImage.width
            else mediaImage.height
        val frameHeight =
            if (frame.imageInfo.rotationDegrees == 90 || frame.imageInfo.rotationDegrees == 270)
                mediaImage.height
            else mediaImage.width

        val results = WritableNativeArray()
        val detectedObjects = getDetectorWithModelFile(config).detect(mlImage)

        for (detectedObject in detectedObjects) {
            val labels = WritableNativeArray()

            for (label in detectedObject.categories) {
                val labelMap = WritableNativeMap()

                labelMap.putInt("index", label.index)
                labelMap.putString("label", label.label)
                labelMap.putDouble("confidence", label.score.toDouble())

                labels.pushMap(labelMap)
            }

            if (labels.size() > 0) {
                val objectMap = WritableNativeMap()

                objectMap.putArray("labels", labels)

                val boundingBox =
                    rotateRect(detectedObject.boundingBox, frame.imageInfo.rotationDegrees)

                objectMap.putDouble("top", (boundingBox.top.toFloat() / frameHeight).toDouble())
                objectMap.putDouble("left", (boundingBox.left.toFloat() / frameWidth).toDouble())
                objectMap.putDouble(
                    "width",
                    ((boundingBox.right - boundingBox.left).toFloat() / frameWidth).toDouble()
                )
                objectMap.putDouble(
                    "height",
                    ((boundingBox.bottom - boundingBox.top).toFloat() / frameHeight).toDouble()
                )

                results.pushMap(objectMap)
            }
        }
        return results
    }
}

<div align="right">
<img align="right" src="https://github.com/jaroslawkrol/vision-camera-realtime-object-detection/blob/chore/demo/vc_rod_demo.gif?raw=true" height="550">
</div>

<h1>React Native<br />Realtime Object Detection<br/></h1>

:camera: [VisionCamera](https://github.com/mrousavy/react-native-vision-camera) Frame Processor Plugin for object detection using [TensorFlow Lite Task Vision](https://www.tensorflow.org/lite/inference_with_metadata/task_library/object_detector).

With this library, you can use the benefits of Machine Learning in your React Native app without a single line of native code. [Create your own model](https://www.tensorflow.org/lite/models/modify/model_maker/object_detection) or find and use one commonly available on [TFHub](https://tfhub.dev/). Implement the solution in a few simple steps:

## Minimum requirements​

* `react-native` >= 0.71.3 
* `react-native-reanimated` >= 2.14.4
* `react-native-vision-camera` >= 2.15.4

You can find the model structure requirements [here](https://www.tensorflow.org/lite/examples/object_detection/overview#model_description)

## Installation

Install the required packages in your React Native project:

```shell script
npm install --save vision-camera-realtime-object-detection  
# or yarn 
yarn add vision-camera-realtime-object-detection
```

If you're on a Mac and developing for iOS, you need to install the pods (via Cocoapods) to complete the linking.
```shell script
npx pod-install
```

Add this to your `babel.config.js`
```
[
  'react-native-reanimated/plugin',
  {
    globals: ['__detectObjects'],
  },
]
```
---
:bangbang: Make sure you correctly setup `react-native-reanimated` and insert as a first line of your `index.tsx`

```js
import 'react-native-reanimated'
```

## Usage
### Step 1

To add your custom TensorFlow Lite model to your app, copy your `*.tflite` file to your `asset/model` directory

    ...
    |-- assets
        |-- images
        |-- fonts
        |-- model
            |-- your_custom_model.tflite
    |-- src
        |-- App.tsx
    ...
### Step 2

Add to your `react-native.config.js`
```js
...
 "assets": [
    "./assets/model/",
  ]
```
and run command: 
```shell script
npx react-native-asset
```

### Step 3
:tada: Use Realtime Object Deteciton in your own component!
```js
import { DetectedObject, detectObjects, FrameProcessorConfig } from 'vision-camera-realtime-object-detection';

// ...

const frameProcessorConfig: FrameProcessorConfig = {
    modelFile: 'your_custom_model.tflite', // <!-- name and extension of your model
    scoreThreshold: 0.5,
};

const frameProcessor = useFrameProcessor((frame) => {
  'worklet';

  const detectedObjects: DetectedObject[] = detectObjects(frame, frameProcessorConfig);
}, []);

return (
  <Camera
    device={device}
    isActive={true}
    frameProcessorFps={5}
    frameProcessor={frameProcessor}
  />);
```

## Types

### FrameProcessorConfig

Use the configuration interface to customize the library on your own. In it you can find the following properties:

| Prop | Type | Mandatory | Default | Note |
|:---|:---:|:---:|:---:|:---|
| `modelFile` | `string` | ✔ | -  | The name and extension of your custom TensorFlow Lite model (f.e. `model.tflite`) 
| `scoreThreshold` | `number` | - | 0.3  | (between 0 and 1) Cut-off threshold below which you will discard detection result
| `maxResults` | `number` | - | 1 | Maximum number of top-scored detection results to return. 
| `numThreads` | `number` | - | 1 | the number of threads to be used for TFLite ops that support multi-threading when running inference with CPU. 

---

### DetectedObject

`detectObjects` method returns a list of detected objects in the lens in the following form

| Prop | Type | Note |
|:---|:---:|:---|
| `labels` | `ObjectLabel[]` | An array of labels to match the detected object
| `top` | `number` | (percentage: between 0 and 1) absolute position of the detected object's top edge relative to the frame 
| `left` | `number` | (percentage: between 0 and 1) absolute position of the detected object's left edge relative to the frame 
| `width` | `number` | (percentage: between 0 and 1) width of the detected object relative to the frame 
| `height` | `number` | (percentage: between 0 and 1) height of the detected object's top edge relative to the frame 

### ObjectLabel

| Prop | Type | Note |
|:---|:---:|:---|
| `label` | `string` | label matching the detected object
| `confidence` | `number` | a number between 0 and 1 that indicates confidence that the object of above type was genuinely detected

## Before the release of version 1.0.0 

List of tasks to be implemented: 

- [ ] Adjusting to **VisionCamera V3** (the future version intends to rewrite frame processors and introduces exciting new features, like: drawing on frame in a Frame Processor using RN Skia)
- [ ] CPU and NNAPI delegates for Android
- [ ] GPU and Core ML delegates for IOS
- [ ] Clean up native code

## Contributing

See the [contributing guide](CONTRIBUTING.md) to learn how to contribute to the repository and the development workflow.

## License

MIT

---

Made with [create-react-native-library](https://github.com/callstack/react-native-builder-bob)

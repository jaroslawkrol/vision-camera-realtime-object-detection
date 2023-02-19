# vision-camera-realtime-object-detection

VisionCamera Frame Processor Plugin to detect objects using MLKit

## Installation

```sh
npm install --save vision-camera-realtime-object-detection
```

## Usage

```js
import {
  DetectedObject,
  detectObjects,
} from 'vision-camera-realtime-object-detection';

// ...

const frameProcessor = useFrameProcessor((frame) => {
  'worklet';

  const detectedObjects = detectObjects(frame, frameProcessorConfig);
}, []);
```
## To do: 

[x] #Android - resizing frame

[x] #Android - detecting orientation

[x] #Android - upgrade androidx.camera:camera-core

## Contributing

See the [contributing guide](CONTRIBUTING.md) to learn how to contribute to the repository and the development workflow.

## License

MIT

---

Made with [create-react-native-library](https://github.com/callstack/react-native-builder-bob)

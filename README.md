# NDI SDK for Apple Computers

This repository provides a Swift Package as a wrapper to use NDI SDK on Apple computers, iOS, tvOS and macOS.

## Overview

The NDI &copy; SDK is a powerful tool for real-time sharing of high-quality video, audio, and data between networked devices.

This library provides a wrapper to easily utilize the NDI SDK with Swift.

## SDK Requirements

The NDI SDK is not included in this repository due to licensing constraints. Please download the installer pkg from [NDI.video](https://ndi.video/for-developers/ndi-sdk/download/). Our library assumes the NDI SDK will be installed at `/Library/NDI SDK for Apple`.
You might need to manually link `libndi_ios.a`, `libndi_tvos.a` or `libndi.dylib` for your projects. Add one of them from the installed path.

## Usage

See the unit test for typical scenario. We have included code examples in the `Snippets` directory within this repository. Please refer to these for guidance on how to use the library.

### Example

#### Video distributer

```swift
import NDILib
let sender = NDISend(video: true)
sender.send(frame: SOME_CVPixelBuffer) 
```
Currently, only the following PixelFormats of CVPixelBuffer are supported:
* kCVPixelFormatType_32BGRA
* kCVPixelFormatType_32RGBA
* kCVPixelFormatType_422YpCbCr8
* kCVPixelFormatType_420YpCbCr8BiPlanarFullRange

#### Video subscriber
```swift
import NDILib
let finder = NDIFind()
if finder.wait(for: .second(5)) { // discover NDI source for 5 second
  let receiver = NDIRecv(colorFormat: .brgxbrga, bandwidth: .max) // receive color format is BGRA
  receiver.conect(to: finder.sources[0]) // connect to first discovered source
  while true {
    if let video: CVPixelBuffer = receiver.capture(for: .milliseconds(100)) {
       SOME_PROCESS(capturedCVPixelBuffer: video)
    }
}
```

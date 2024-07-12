# NDI SDK for Apple Computers

This repository provides a Swift Package as a wrapper to use NDI SDK on Apple computers, iOS, tvOS and macOS.

## Overview

The NDI &copy; SDK is a powerful tool for real-time sharing of high-quality video, audio, and data between networked devices.

This library provides a wrapper to easily utilize the NDI SDK with Swift.

## SDK Requirements

This library NDI SDK to work as a wrapper. The NDI SDK is however not included in this repository due to their licensing constraints. Please download the installer pkg from [NDI.video](https://ndi.video/for-developers/ndi-sdk/download/). Our library assumes the NDI SDK will be installed at `/Library/NDI SDK for Apple`.
You might need to manually link `libndi_ios.a`, `libndi_tvos.a` or `libndi.dylib` for your projects. Add one of them from the installed path `/Library/NDI SDK for Apple/lib/*`.

## Usage

See the unit test for a typical scenario. We have also included code example in the `Snippets` directory within this repository. Please refer to these for guidance on how to use this library.

### Example

#### Video distributer

```swift
import NDILib
let sender = NDISend(video: true)
sender.send(frame: SOME_CVPixelBuffer) 
```
Currently, only the following PixelFormats of CVPixelBuffer are supported:
 - kCVPixelFormatType_422YpCbCr8 // UYVY in NDI
 - kCVPixelFormatType_422YpCbCr_4A_8BiPlanar // UYVA in NDI
 - kCVPixelFormatType_422YpCbCr16BiPlanarVideoRange // P216 in NDI
 - kCVPixelFormatType_420YpCbCr8PlanarFullRange // I420 in NDI
 - kCVPixelFormatType_420YpCbCr8BiPlanarFullRange // NV12 in NDI
 - kCVPixelFormatType_32BGRA // BGRA or BGRX in NDI
 - kCVPixelFormatType_32RGBA // RGBA or RGBX in NDI, it might not work with Apple Silicon

PA16 and YV12 in NDI are not supported

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
}
```

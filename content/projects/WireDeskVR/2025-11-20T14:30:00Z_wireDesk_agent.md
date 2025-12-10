+++
title = "WireDeskVR"
description = "Create the agent on Swift"
date = 2025-11-20T14:30:00Z
author = "Maxim Bunkov"
tags = ["vr", "wiredesk", "virtual-reality", "ios", "UnrealEngine", "Oculus", "Vision Pro" ]
template = "project.html"
+++

## Objective

The initial stage and first step involve creating screen capture functionality for the agent, enabling it to broadcast, transcode, and transmit the captured content over a network.

## Project

First, we create a dedicated project to explore the possibilities. Since this is an agent, it will run on macOS as a service or background daemon. Its primary task is straightforward—since it has no UI, we will implement it using Swift and Swift Package Manager as a standard executable.

## Source Code

The core function of the agent initializes a socket for each detected display. We will observe how this functionality performs.

```Swift

    func start() async throws {
        let sender = NetworkSender(host: "127.0.0.1", port: port); sender.start(); self.network = sender

        let content = try await SCShareableContent.current
        guard let display = content.displays.first(where: { $0.displayID == displayID }) else { return }

        let encoder = VideoEncoder(width: display.width, height: display.height, bitrate: 20_000_000)
        encoder.delegate = self; self.encoder = encoder

        let captureSession = ScreenCapture(displayID: displayID)
        captureSession.delegate = self
        self.capture = captureSession

        try await captureSession.start()
    }
```

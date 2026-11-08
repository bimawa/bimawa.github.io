+++
title = "VRDesktopUltra: five Mac screens in VR and a workspace to return to"
date = 2026-11-09
slug = "vrdesktopultra-five-screens-and-a-persistent-workspace"
description = "Five independent Mac screens on Quest Pro, a persistent workspace, a native Mac app, and HEVC optimizations. The project's latest achievements and the limitations still to overcome."
[taxonomies]
tags = ["rust", "development", "productivity"]
+++

In our previous post, we described four Mac screens on Quest Pro and how we eliminated shimmer in the configuration we tested. Since then, VRDesktopUltra has moved closer to being a workspace rather than just an image-streaming demo: with a saved layout, a place of your own in VR, and a regular Mac app.

The main result of this stage is **five independent screens, all visible in the headset at the same time**. Behind that milestone are changes that make everyday startup and returning to VR less cumbersome.

## The fifth screen is a real external monitor

Our test setup now runs all of these together:

- three virtual ultrawide monitors at **5760 × 1200** each;
- the Mac's built-in Retina display, captured at **4112 × 2658**;
- an external **1920 × 1080** monitor.

We connected the external monitor while the Mac app was running. The server detected it and began streaming it as a separate source, without restarting the server or the USB session.

The first check also taught us something important: receiving a fifth stream is not the same as showing a fifth screen to a person. The data reached Quest, but the monitor appeared far outside the configured workspace. We fixed its initial placement: a new screen now appears above the last available monitor, taking that monitor's position, rotation, and size into account.

After the fix, we checked not only logs and checksums, but also the actual scene in the headset. **The external screen is visible and works alongside the other four.** We then restarted the installed Mac app and confirmed that all five sources and the saved layout were restored.

This is a result from one specific Quest Pro setup, not a promise of any number of monitors under any workload.

<!-- more -->

## No need to rebuild the workspace from scratch

A workspace has two distinct layouts: the arrangement of displays in macOS and the placement of virtual surfaces around the user. Both are now saved.

On the Mac, we remember the primary display and the screens' relative positions. In VR, we save each monitor's position, rotation, size, and curvature. Restarting the server should not turn a carefully arranged workspace back into the original row of rectangles.

There is also a persistent floor marker for the user's seat position and facing direction. You can move it with a controller, and a teleport target near the marker snaps to the saved position and orientation. On a new launch, it serves as the point of return to the workspace.

We also separated pausing from closing the workspace. Taking off the headset, opening the system menu, or losing the USB connection does not by itself close it. Explicitly exiting the Quest app stops capture and releases the virtual displays it created; the Mac server stays ready for the next connection.

## A Mac app instead of a mandatory terminal

VRDesktopUltra now has a native app with a menu bar icon. It lets you start or stop the server, open the log, and change display settings.

The settings include the number of virtual displays, their resolution, frame rate, and bitrate. Physical sources can be enabled or disabled; their images are transmitted at their native pixel resolution.

The app uses AppKit and SwiftUI around the existing Rust server, without Electron or an embedded browser. Normal startup of the installed app no longer requires a terminal.

For now, this is an installed development build, not a notarized distribution ready for public download.

## Less redundant work when streaming images

The video path has changed since the previous post, too. Instead of sending an independent keyframe for every update, we now use persistent hardware HEVC streams with predictive frames.

We kept a distinction that matters for desktop content: small changes against an exact base are sent losslessly, while large changes go through the video codec. After 250 ms without large changes, a full lossless update restores the exact image. Cursor movement alone does not prevent this.

Quest also tells the Mac how busy its decoder is. The server takes that recommendation into account **before encoding**: it retains a fresh capture rather than building a queue of increasingly stale frames.

There is also a narrow but clearly measurable result: faster CPU validation of HEVC structure. In a measurement on an M1 Max, validating a 5760 × 1200 keyframe dropped from approximately **5.07 to 0.22 ms**, while a Retina keyframe dropped from **8.02 to 0.33 ms**. We did not reduce resolution or image quality to achieve this.

This speeds up one processing stage, not the entire app. It does not imply an equivalent increase in FPS or a matching reduction in the time until an image becomes visible through the lenses.

## What remains open

Five screens and a persistent workspace are a confirmed step forward. But the project is not yet an everyday tool we can recommend without qualifications.

The VR scene still stutters under load. End-to-end optical latency below 20 ms has not been confirmed. Long-running memory and thermal checks, as well as repeated physical disconnect-and-reconnect cycles for the external monitor, remain ahead.

The fidelity limitation also remains: HEVC uses lossy compression during motion. A subsequent exact update helps with text and a settled desktop, but does not make the entire stream pixel-perfect while drawing.

The main change at this stage is that **you can now return to your configured five-screen workspace in VR**, rather than assembling it again at every launch. The next task is to make that workspace consistently responsive under real workloads.

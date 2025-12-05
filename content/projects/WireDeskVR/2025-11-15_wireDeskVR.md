+++
title = "WireDeskVR"
description = "VR application for virtual work with the WireDesk interface"
date = 2023-05-15T14:30:00Z
author = "Maxim Bunkov"
tags = ["vr", "wiredesk", "virtual-reality", "ios", "UnrealEngine", "Oculus", "Vision Pro" ]
template = "project.html"
+++

## Project Description

WireDeskVR is a VR application that allows users to work with the WireDesk interface in virtual reality. The project implements a full virtual workspace environment with the ability to interact with UI elements via gestures and controllers. At this stage, it is a proof of concept to see how technically feasible it is. Competitors and ideas circulating in the community have also been studied. There will be a lot of research and we will encounter many first-time challenges.

## Technologies

- Swift
- ARKit / RealityKit
- Metal
- Core Motion
- SceneKit
- UnrealEngine
- Android
- Oculus/Meta Quest

## Features

- 3D interaction with the interface
- Support for various controller types
- Integration with the WireDesk API
- Performance optimization for VR devices

I have had a long-standing dream since childhood to create a virtual desktop for working with a computer. Today, technology not only allows us to achieve that but also to implement it with artificial intelligence. This project is more of a test to understand how capable technology is today in helping achieve this goal. The main idea of the first stage is to create NoLatency, transmitting video data from MacBook screens to Oculus Quest. In subsequent stages, we plan to introduce a plugin system and our own binary protocol to unify data from other applications and other users in VR.

## Roadmap

1. Establish a stable connection and configure workstations.
2. Examine and analyze the free space on the computer's resources, as well as on the Opulus system. If resources allow managing screens, also consider creating a gaming zone within virtual reality to let users relieve emotional load by dividing something in VR.
3. Screen sharing and the social component did not take off and are not popular among competitors, so we omit this part. At the third stage, we immediately move to beta testing of the binary protocol for transmitting custom data from macOS and the host to VR headsets.
4. Systematize and standardize the protocol, and also start developing a marketplace for users.
5. Capture the world and find someone to sell it to.

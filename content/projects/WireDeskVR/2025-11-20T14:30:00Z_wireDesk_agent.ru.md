+++
title = "WireDeskVR"
description = "Создание агента на Swift"
date = 2025-11-20T14:30:00Z
author = "Максим Буньков"
tags = ["vr", "wiredesk", "virtual-reality", "ios", "UnrealEngine", "Oculus", "Vision Pro"]
template = "project.html"
+++

## Цель

Начальный этап и первый шаг включают создание функциональности захвата экрана для агента, позволяющей транслировать, транскодировать и передавать захваченный контент по сети.

## Проект

Сначала мы создаём отдельный проект для изучения возможностей. Поскольку это агент, он будет работать на macOS как сервис или фоновый демон. Его основная задача проста — поскольку у него нет UI, мы реализуем его на Swift и Swift Package Manager как стандартный исполняемый файл.

## Исходный код

Основная функция агента инициализирует сокет для каждого обнаруженного дисплея. Посмотрим, как эта функциональность будет работать.

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

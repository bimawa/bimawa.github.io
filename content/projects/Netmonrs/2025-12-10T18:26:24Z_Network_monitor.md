+++
title = "NetMonRS"
description = "Network monitoring connection framework in Rust"
date = 2025-12-10T18:26:24Z
author = "Maxim Bunkov"
tags = ["Rust", "CLI", "Ratatui", "Nerworking"]
template = "project.html"
+++

## Net Monitor Rust
NetRS is a network monitoring tool written in Rust that shows real-time network connections using the Ratatui library for terminal-based user interface. The application lets users monitor active network connections and view connection details including local and remote addresses, protocols, and connection states. Users can filter connections based on different criteria. The tool uses the system's networking features to collect connection information and displays it in an interactive, easy-to-use terminal interface. This tool helps system administrators, network engineers, and developers quickly check network activity on their systems directly from the command line.

This offers a more efficient way to monitor outgoing connections from a specific process.

I developed this tool for the WireDeskVR project to check agent connection status.

It can also be used for other purposes. For example, to find where a specific process connects on your computer.

## Example Usage

```bash
sudo netmonrs /Applications/Zed.app/Contents/MacOS/zed
```

We need sudo access for lsof.

## How it looks
![NetMonRS Interface](/images/netMonrsInterface.png)

## Controls

- `Tab` - Switch focus between active connections and history
- `Up` / `k` - Move up in list
- `Down` / `j` - Move down in list
- `PageUp` / `Ctrl+u` - Page up
- `PageDown` / `Ctrl+d` - Page down
- `q` - Quit application

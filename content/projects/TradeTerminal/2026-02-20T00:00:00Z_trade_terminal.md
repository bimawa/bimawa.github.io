+++
title = "TradeTerminal"
description = "Bybit and Binance trading terminal with CLI interface and minimal latency"
date = 2026-02-20T00:00:00Z
author = "Maxim Bunkov"
tags = ["Rust", "Trading", "CLI", "Bybit", "Binance", "WebSocket", "Docker"]
template = "project.html"
+++

## TradeTerminal

A universal trading terminal for Bybit and Binance with CLI interface and client-server architecture, designed to minimize exchange latency. Built in Rust, the project provides a powerful toolkit for professional cryptocurrency trading.

![TradeTerminal Interface](/images/tradeTerminalInterface.png)

## Key Features

### Trading Operations

- **Order Placement**: Market and Limit orders with fast execution
- **Risk Management**: Automatic position sizing based on USDT risk with exchange fee consideration
- **Take Profit**: Exit position setup as percentage from entry
- **Trailing Stop**: Flexible trailing stop system with support for:
  - Absolute price values and callback in dollars
  - Percentages from current price
  - Ratios for activation based on distance to Stop Loss
- **Auto-Stop (AS)**: Smart exit on active markets
  - Click on price to copy it for quick input
  - Trigger activates when price or percentage is reached
  - Liquidity timer (2 sec) - closes position if trading stops
  - Perfect for profit taking on volatile moves
- **Hedge Mode**: Support for simultaneous Long/Short positions on the same instrument

<!-- more -->
### Interface and Management

- **CLI Interface**: Convenient command line with command shortcuts
- **Pipe Operator**: Combine commands via `|` to create complex scenarios
  - Example: `:br 10 94000 | ts 2% 0.5%` - open position and immediately set trailing stop
- **Command Chains**: Sequential execution via `;`
  - Example: `:ca; br 10 94000` - cancel all orders and open new position
- **State Viewing**: Display open orders, active positions and current balance
- **Order Management**: Cancel individual orders or all at once
- **Multi-symbol**: Quick switching between trading pairs

### Chart and Visualization

- **Built-in Chart**: Interactive chart with multiple timeframe support
- **Sub-second Timeframes**: Unique ability to work with 1s, 5s, 10s, 30s timeframes
  - Uses real tick data from the exchange
  - Aggregation happens on client for maximum accuracy
  - Displays real trades without additional server load
- **Standard Timeframes**: From 1 minute to daily candles (15m, 1h, 4h, D, etc.)
- **Price Levels**: Add and remove horizontal levels
- **Navigation**: Scroll history, zoom, auto-follow last price
- **Sound Indication**: Optional audio signals on exchange trades
  - High tone - buy, low - sell
  - Frequency increases with trading activity

### Architecture

- **Client-Server**: Logic separation for latency optimization
- **WebSocket**: Persistent connection for instant data reception
- **Auto-update**: Automatic position and order data updates
- **Docker Support**: Easy VPS deployment to minimize latency to exchange servers

## Technology Stack

- **Language**: Rust (high performance and memory safety)
- **Protocol**: WebSocket for real-time communication
- **Exchanges**:
  - Bybit API v5 (Testnet and Production)
  - Binance API (Spot and Futures)
- **Deployment**: Docker, Docker Compose
- **UI**: TUI (Text User Interface) with tab support

## Position Size Calculation

The terminal uses an advanced calculation formula that accounts for exchange fees:

```
quantity = risk_usdt / (|entry_price - sl_price| + entry_price * fee * 2)
```

**Parameters:**
- Taker fee: 0.055%
- Maker fee: 0.02%
- Fee multiplied by 2 (entry + SL exit)

**Example:**
- Risk: $10
- Entry: 95000, SL: 94000
- Difference: $1000
- Fee cost: 95000 × 0.00055 × 2 = $104.5
- Total risk per unit: $1104.5
- Quantity: 10 / 1104.5 = 0.00905 BTC

## Trailing Stop: Activation Types

### Absolute Price
`:ts 97000 500` - activate when price reaches 97000, callback $500

### Percentage
`:ts 2% 0.5%` - activate on 2% growth from entry, callback 0.5% from current price

### Ratio
`:ts 1/3 2%` - activate at distance 3 times greater than to Stop Loss

**Formula:** `trigger = entry ± (|SL - entry| × denominator/numerator)`

**Example:**
- Entry: 100
- SL: 101 (1% risk)
- Ratio: `1/3`
- Trigger: 103 (3 times further from entry than SL)
- Then TS moves with 2% callback from current price

## Terminal Commands

### Basic Orders
```
:buy 0.01              # Market buy 0.01 BTC
:buy 0.01 95000        # Limit buy @ 95000
:sell 0.01             # Market sell
:sell 0.01 96000       # Limit sell @ 96000
```

### Orders with Risk Management
```
:buyrisk 10 94000             # Long market, $10 risk, SL @ 94000
:buyrisk 10 94000 95000       # Long limit @ 95000
:buyrisk 10 94000 - 2         # Long market + TP 2%
:sellrisk 10 96000            # Short market, $10 risk, SL @ 96000
:sellrisk 10 96000 95000      # Short limit @ 95000
:sellrisk 10 96000 95000 1.5  # Short limit + TP 1.5%
```

### Trailing Stop
```
:ts 2% 0.5%            # Activation +2%, callback 0.5%
:ts 97000 0.5%         # Activation @ 97000, callback 0.5%
:ts 2% 500             # Activation +2%, callback $500
:ts 1/3 2%             # Activation on 1:3 ratio from SL, callback 2%
```

### Auto-Stop
```
:as 2 0.545            # 2 sec timer, trigger @ 0.545
:as 2 0.2%             # 2 sec timer, trigger +0.2%
```
**Logic:**
- Price can be copied by clicking in the interface
- When trigger is reached, liquidity timer starts
- If no trades occur on exchange in 2 seconds - position closes
- Profit protection on fast moves with subsequent fade

### Combo Commands
```
:br 10 94000 | ts 2% 0.5%     # Long + trailing stop
:sr 10 96000 | ts 2% 0.5%     # Short + trailing stop
:ca; br 10 94000              # Cancel all + new order
```

### Chart
```
:chart                 # Open chart
:tf 1s                 # 1 second timeframe
:tf 5s                 # 5 second timeframe
:tf 15                 # 15 minute timeframe
:tf D                  # Daily timeframe
:level 95000           # Add level
:levels                # Clear levels
:sound                 # Toggle trade sound
```

### Management
```
:cancel abc123         # Cancel order
:cancelall             # Cancel all orders
:symbol ETHUSDT        # Change symbol
:help                  # Help
```

### Command Shortcuts
- `:b` = `:buy`
- `:s` = `:sell`
- `:br` = `:buyrisk`
- `:sr` = `:sellrisk`
- `:ts` = `:trailing-stop`
- `:as` = `:auto-stop`
- `:c` = `:cancel`
- `:ca` = `:cancelall`
- `:sym` = `:symbol`
- `:h` = `:help`

## Navigation

### Main Interface
- `:` - Command input mode
- `Tab` - Switch tabs
- `r` - Refresh data
- `Esc` - Exit input mode
- `q` - Exit program
- `Ctrl+C` - Force exit

### Chart
- `h` - Scroll left (back in time)
- `l` - Scroll right (forward in time)
- `+` / `=` - Zoom in
- `-` - Zoom out
- `0` - Reset to last candles

## Deployment

### Local Run

1. Clone repository
2. Create `.env` file with API keys:
```
BYBIT_API_KEY=your_api_key
BYBIT_API_SECRET=your_api_secret
BYBIT_TESTNET=true
```
3. Start server: `cargo run --bin trade-server`
4. Start client: `SERVER_URL=ws://127.0.0.1:9000 cargo run --bin trade-client`

### VPS Deployment

To minimize latency, it's recommended to place the server in a region close to exchange servers (Bybit/Binance: Singapore, Tokyo):

1. Install Docker on VPS
2. Create `.env` with API keys
3. Run: `docker-compose up -d`
4. Connect client: `SERVER_URL=ws://vps-ip:9000`

## Use Cases

This tool is useful for:

- Professional cryptocurrency trading with minimal latency
- Scalping and intraday trading
- Automating trading strategies via pipes and command chains
- Testing trading ideas on Testnet
- Remote trading via VPS

## Open Source

Released under MIT license. The project demonstrates professional practices for developing high-performance Rust applications and can serve as an educational resource for learning:
- Client-server architecture on WebSocket
- Working with exchange APIs
- TUI application development
- Trading risk management

## Links

- **Status**: In development (private repository)
- **Technologies**: Rust, WebSocket, Docker, Bybit API, Binance API
- **License**: MIT

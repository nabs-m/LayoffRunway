# Layoff Runway

Layoff Runway is a small macOS app built with Swift and SwiftUI to estimate how long your cash runway can last after a layoff.

It combines:

- Remaining paycheques up to a termination date.
- Estimated net severance.
- Optional emergency fund.

Then it compares total available cash against a monthly budget.

## Screenshot

![Layoff Runway screenshot](Docs/screenshot.png)

## Notice

This app is for planning/estimation only (not payroll or tax advice).

## Run Locally

### Option 1: Xcode (recommended)

1. Open `Package.swift` in Xcode.
2. Build and run the `LayoffRunway` executable target.

### Option 2: Terminal

```bash
swift run
```

## Tech Stack

- Swift 5.10+
- SwiftUI
- macOS 14+
- Swift Package Manager
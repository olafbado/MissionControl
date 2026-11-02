<div align="center">

# 🛰️ Mission Control

**Interplanetary fuel calculator built with Elixir, Phoenix and LiveView.**

![Elixir](https://img.shields.io/badge/Elixir-1.17+-4B275F?logo=elixir&logoColor=white)
![Phoenix](https://img.shields.io/badge/Phoenix-1.8-FD4F00?logo=phoenixframework&logoColor=white)
![LiveView](https://img.shields.io/badge/LiveView-1.2-FD4F00)

<img src="docs/images/mission-control.png" alt="Mission Control with the Apollo 11 mission loaded" width="900">

</div>

## ✨ Features

- Fuel recalculated live as you edit the mass and flight path
- Add, remove and edit launch and landing steps on Earth, the Moon and Mars
- One-click example missions: Apollo 11, Mars mission, Passenger ship
- Validation shown where it happens, including flight path rules
- Exact `Decimal` arithmetic, light and dark theme, works on phones

## 🚀 Getting started

Requires Elixir 1.17+ and Erlang/OTP 25+.

```bash
mix setup        # install dependencies and build assets
mix phx.server   # start at http://localhost:4000
```

## 🧮 How it works

Each step needs `mass * gravity * 0.042 - 33` (launch) or `mass * gravity * 0.033 - 42` (land), rounded down.

- **Fuel has mass too**, so it needs more fuel, until the extra amount is zero: landing 28801 kg on Earth takes 9278 + 2960 + 915 + 254 + 40 = 13447 kg.
- **The ship carries the fuel for later steps**, so a path is calculated from the last step to the first.

**Flight path rules:** launches and landings alternate, and a launch must be from the planet of the previous landing.

<img src="docs/images/flight-path-errors.png" alt="A flight path error shown under the third step" width="420">

## 🏗️ Architecture

| Module | Role |
|---|---|
| `FuelCalculator.Flight` | Context, the only API the web layer uses |
| `Flight.Mission`, `Flight.Step` | Embedded schemas: validation and flight path rules |
| `Flight.Fuel` | Fuel calculation |
| `Flight.Action`, `Flight.Planet` | Formulas and gravity |
| `FuelCalculatorWeb.MissionLive` | The page, recalculating on every change |

No database: Ecto is used only for embedded schemas and changesets.

## 🧪 Testing

```bash
mix test        # tests
mix precommit   # warnings as errors, format, Credo (strict) and tests
```

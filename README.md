# EPICS StreamDevice IOC Template

This repository serves as a template for creating EPICS IOC projects using [StreamDevice](https://paulscherrerinstitute.github.io/StreamDevice/index.html).

## Features
- Pre-configured support for StreamDevice.
- Example protocol and database files.
- Ready-to-use `st.cmd` and `envPaths` files.

## Getting Started
1. Click the "Use this template" button on GitHub to create a new repository based on this template.
2. Clone your new repository:
   ```bash
   git clone https://github.com/<your-username>/<your-repo>.git
   cd <your-repo>
```

## UNIMAG states and watchdogs

`STATE_RB` uses the state enumeration shared by the UNIMAG power-supply IOCs:

| Value | State | Alarm | Meaning |
|-------|-------|-------|---------|
| 0 | `OFF` | - | Power supply off |
| 1 | `ON` | - | Output on |
| 2 | `STANDBY` | - | Ready, output disabled |
| 3 | `FAULT` | MAJOR | Power supply fault |
| 4 | `EXT_INTLK` | MAJOR | External interlock |
| 5 | `CONN_FAULT` | MAJOR | Communication errors (the status read fails) |
| 6 | `SP_NOT_REACHED` | MINOR | Current setpoint not reached |
| 7 | `ST_NOT_REACHED` | MAJOR | State not reached (UNIMAG failure) |

Faults win over `ST_NOT_REACHED`, which wins over `SP_NOT_REACHED`. Values from 8 up are
additional, device specific states. `STATE_SP` accepts `OFF`, `ON`, `STANDBY` and `RESET`.

Device specific state: `8 LIMITING` (the supply is in current or voltage limit). `CONN_FAULT` when
`LimitStatus-RB` cannot be read. `STATE_SP` is `OFF`, `ON`, `STANDBY` (output off), `RESET`
(`Reset-Cmd`) and `CLEAR` (`ClearStatus-Cmd`).

### UNIMAG configuration

| Parameter | PV | Description | Default | Units |
|-----------|----|-------------|---------|-------|
| `SET_TOLERANCE` | `SET_TOLERANCE` | Current setpoint tolerance (0 disables the setpoint check) - **disabled by default here**: `CURRENT_SP` is the supply's current limit, so the load decides whether the readback gets there (in constant voltage it stays below) | 0 | Amperes |
| `ZERO_TOLERANCE` | `ZERO_TOLERANCE` | Zero current tolerance (a zero setpoint counts as reached within it) | 0.5 | Amperes |
| `SET_TIMEOUT_S` | `SET_TIMEOUT_S` | Setpoint / state timeout (restarts on progress) | 30 | Seconds |

They are db macros (same names) and live PVs, so they can also be changed at runtime. The
timeout restarts whenever the readback gets closer to the setpoint, on a new setpoint and on a
new state command. The setpoint check only runs while the supply is `ON`, and the state check
is armed by the first `STATE_SP` command after boot, so a supply left running is not reported.
`SP_NOT_REACHED` and `ST_NOT_REACHED` (and `SP_ERR`, `SP_WDOG`, `ST_WDOG`) are readable PVs.

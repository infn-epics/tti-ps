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

Values from 8 up are additional, device specific states. A setpoint or state not reached is a
software state, reported by `STATE_SM` (below) and not by `STATE_RB`. `STATE_SP` accepts `OFF`, `ON`, `STANDBY` and `RESET`.

Device specific state: `8 LIMITING` (the supply is in current or voltage limit). `CONN_FAULT` when
`LimitStatus-RB` cannot be read. `STATE_SP` is `OFF`, `ON`, `STANDBY` (output off), `RESET`
(`Reset-Cmd`) and `CLEAR` (`ClearStatus-Cmd`).

### UNIMAG state machine (`STATE_SM`)

`STATE_SM` tells what the supply is doing:

| Value | State | Alarm | Meaning |
|-------|-------|-------|---------|
| 0 | `READY` | - | Idle, last command done |
| 1 | `GOTOSET` | - | Readback going to the setpoint (within `SET_TOLERANCE`) |
| 2 | `GOTOSTATE` | - | Commanded state not reached yet |
| 3 | `GOZERO` | - | Readback going to a zero setpoint (within `ZERO_TOLERANCE`) |
| 4 / 5 | `GOPOS` / `GONEG` | - | Polarity change: not used by this IOC |
| 6 | `SPNOTSET` | MINOR | Setpoint not reached within `SET_TIMEOUT_S` (`SP_NOT_REACHED`) |
| 7 | `STATENOTSET` | MAJOR | State not reached within `SET_TIMEOUT_S` (`ST_NOT_REACHED`) |

Commands are not sent again (no `RETRY`). `SPNOTSET` / `STATENOTSET` clear when the target is
reached, on a new command, or with `STATE_SP` = `RESET`, which restarts both timeouts.
With the default `SET_TOLERANCE` 0 the setpoint is not checked: `GOTOSET`, `GOZERO` and
`SPNOTSET` are not used.

### UNIMAG configuration

| Parameter | PV | Description | Default | Units |
|-----------|----|-------------|---------|-------|
| `SET_TOLERANCE` | `SET_TOLERANCE` | Current setpoint tolerance (0 disables the setpoint check) - **disabled by default here**: `CURRENT_SP` is the supply's current limit, so the load decides whether the readback gets there (in constant voltage it stays below) | 0 | Amperes |
| `ZERO_TOLERANCE` | `ZERO_TOLERANCE` | Zero current tolerance (a zero setpoint counts as reached within it) | 0.5 | Amperes |
| `SET_TIMEOUT_S` | `SET_TIMEOUT_S` | Setpoint / state timeout (restarts on progress) | 30 | Seconds |

They are db macros (same names) and live PVs, so they can also be changed at runtime. The
timeout restarts whenever the readback gets closer to the setpoint, on a new setpoint and on a
new state command. The setpoint check only runs while the supply is `ON`. It is armed by the first `CURRENT_SP`
written after boot, the state check by the first `STATE_SP` command, so a supply left running is
not reported.
`SP_NOT_REACHED` and `ST_NOT_REACHED` (and `SP_ERR`, `SP_WDOG`, `ST_WDOG`) are readable PVs.

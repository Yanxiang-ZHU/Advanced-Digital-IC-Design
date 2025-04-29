# Dot Product Hardware Model

This project presents a basic hardware model for calculating a **dotproduct**, using Verilog-style modular design. The system utilizes one **load/store module**, one **multiplication module**, and one **addition module**, operating over a 10-stage controller-driven pipeline.

## Architecture Overview

The computation pipeline is broken down into **10 stages**, plus a **finish signal stage**. Each stage represents a specific step in reading inputs, processing intermediate values, or writing outputs.

### Controller State Machine

The controller is structured as a finite state machine (FSM) with the following states:

| State | Description |
|-------|-------------|
| `S0`  | Read input values from `a[i]` and `b[i]`, and write them into SRAM (1 value per clock cycle). |
| `S1`  | Read `b[i]` from SRAM. |
| `S2`  | Read `a[i]` from SRAM and compute `b[i] * 2`, then write to register file. |
| `S3`  | Compute `a[i] + b[i] * 2` and write to register file. |
| `S4`  | Store result of `a[i] + b[i] * 2` to `c[i]` in SRAM. |
| `S5`  | Read `b[i]` from SRAM again. |
| `S6`  | Read `a[i]` from SRAM and compute `b[i] * 5`, then write to register file. |
| `S7`  | Compute `a[i] + b[i] * 5` and write to register file. |
| `S8`  | Compute `c[i] * (a[i] + b[i] * 5)` and write to register file. |
| `S9`  | Store result of `c[i] * (a[i] + b[i] * 5)` to `c[i]` in SRAM. |
| `FINISH` | Output the `done` signal. |

### Execution Flow

- **Initialization (S0):**  
  Input arrays `a[]` and `b[]` are read into SRAM one value per clock cycle.  
  > _Note_: This can be skipped if input data is pre-initialized in a COE file or equivalent memory image.

- **First Computation Loop (S1–S4):**  
  Computes the intermediate value `c[i] = a[i] + 2 * b[i]`.

- **Second Computation Loop (S5–S9):**  
  Computes the final result `c[i] = c[i] * (a[i] + 5 * b[i])`.

- **Completion (FINISH):**  
  A `done` signal is asserted to indicate completion.

## Performance

In this single-module setup:
- Total clock cycles ≈ `11 * n`, where `n` is the number of input elements.
- Includes `2 * n` cycles for the S0 phase (loading `a[]` and `b[]` into SRAM).

To accelerate execution, **multiple functional units** (e.g., additional multipliers or adders) can be instantiated, allowing parallel operations and reducing the total number of clock cycles.

## Future Extensions

- Support for vectorized functional units.
- External memory initialization to bypass S0.
- Parameterizable pipeline depth and memory width.

## License

[MIT License](./LICENSE)
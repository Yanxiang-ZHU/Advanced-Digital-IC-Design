# Dot Product Hardware Synthesis Design

## Project Overview

This project implements a hardware design for a dot product computation (`dotproduct`) as part of the *Digital Integrated Circuit Design Automation* course. It focuses on dataflow control, scheduling, control logic, and hardware architecture, with simulation-based verification. The design explores two configurations:

- **Min-Resource**: Uses one multiplier, one adder, and one Load/Store unit, with each operation limited to one per cycle, targeting low-resource embedded systems.
- **Multi-Resource**: Employs two multipliers, two adders, and two Load/Store units with loop unrolling for parallel computation, optimizing performance for high-throughput scenarios.


---

## Design Details

### Dataflow and Scheduling

The program processes two nested loops, with input arrays `a[]` and `b[]` pre-stored in SRAM. Integer addition, multiplication, and SRAM read/write operations are assumed to complete in one clock cycle.

- **Min-Resource**: Sequential execution with a single Load/Store, MUL, and ADD module. Data is scheduled to read `b[i]` before `a[i]` for efficiency. Without loop merging, intermediate results `c[i] = a[i] + 2*b[i]` are written to SRAM, followed by `c[i] = c[i] * (a[i] + 5*b[i])`. Total cycles: ~11*n (2*n for SRAM initialization).
- **Multi-Resource**: Parallel execution with loop unrolling, using two sets of modules. SRAM initialization takes ~n cycles, and computation processes two elements (`c[i]`, `c[i+1]`) in ~9 cycles, reducing total cycles to ~5.5*n for even n (approaching 4.5*n for large odd n).

### Register Allocation

An 8-register bank (R1–R4, R7–R10) stores intermediate values:
- R1, R2: Load `a[i]`, `b[i]` from SRAM.
- R3, R4: Store `b[i]*2` and `a[i] + 2*b[i]` (first loop).
- R7–R10: Store `b[i]*5`, `c[i]`, `a[i] + 5*b[i]`, and `c[i] * (a[i] + 5*b[i])` (second loop).

Registers are reused in non-pipelined designs to minimize resource usage.

### Control Logic

A Finite State Machine (FSM) with 10 states (S0–S9) and a FINISH state manages the computation:
- **S0**: Initializes SRAM with `a[]` and `b[]`.
- **S1–S4**: Computes `c[i] = a[i] + 2*b[i]`.
- **S5–S9**: Computes `c[i] = c[i] * (a[i] + 5*b[i])`.

In Multi-Resource, the FSM supports parallel data paths for simultaneous processing.

### SRAM Design

The SRAM module (32-bit width, 300-word depth) stores:
- `a[]`: Addresses 0–99.
- `b[]`: Addresses 100–199.
- `c[]`: Addresses 200–299.

S0 initializes SRAM in 2*n cycles (Min-Resource) or n cycles (Multi-Resource). Only one read/write operation is allowed per cycle in Min-Resource, extended to two in Multi-Resource.

---

## Implementation and Results

### Min-Resource Design

Comprises four modules: Top, Datapath, Controller, and SRAM, plus a testbench.
- **Top**: Coordinates Datapath and Controller.
- **Datapath**: Manages register operations and SRAM access based on Load/Store/MUL/ADD signals.
- **Controller**: Implements the FSM for S0–S9.
- **SRAM**: Handles data read/write.
- **Testbench**: Tests with 16-element `a[]` and `b[]` arrays, showing `c[]` updated twice in SRAM (first loop intermediates, then final results).

### Multi-Resource Design

Extends to two parallel data paths, reducing cycles via loop unrolling. Simulation confirms simultaneous SRAM writes for `a[i]`, `a[i+1]`, `b[i]`, `b[i+1]`, and paired `c[]` updates, halving computation time compared to Min-Resource.

---

# Dot Product with Multi-Resource Architecture

This project simulates an optimized **dot product computation** using multiple hardware resources. Specifically, it deploys **2 load/store blocks**, **2 multipliers**, and **2 adders** to improve performance over the single-resource version.

## Overview

The controller operates similarly to the single-resource model, using a **10-stage state machine**. However, by leveraging **parallelism**, this implementation is able to **process two input elements simultaneously**.

### Key Features

- **Dual read operations:** Two values from `a[]` and `b[]` are read into SRAM simultaneously.
- **Dual computation:** At each step in the processing loop, the system calculates values for both the `i-th` and `(i+1)-th` entries of `c[]`.

### Performance Analysis

This parallelism reduces the required clock cycles significantly:

- **Initialization (S0):**  
  Reading `a[]` and `b[]` into SRAM takes **n** cycles (2 values per cycle).

- **Computation Loop (S1–S9):**  
  Computes two `c[i]` values every **9 cycles**, resulting in a total of `9 * (n / 2)` cycles.

- **Total Execution Time:**  
Total cycles = n (load) + 9 * (n / 2) = 5.5n

This is approximately **half** the execution time of the single-resource model (`~11n` cycles).

### Scalability

This design currently uses **two parallel resources**. However, the architecture can be scaled further by:

- Adding more **load/store units**, **multipliers**, and **adders**.
- Applying **pipelining** or other **hardware acceleration techniques**, depending on resource availability.

Such improvements can further reduce latency and improve throughput for large-scale vector operations.

## Future Directions

- Parameterize the number of processing elements.
- Explore pipelined designs for deeper performance gains.
- Integrate external memory initialization (bypassing SRAM loading).
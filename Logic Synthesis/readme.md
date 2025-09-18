# AIG Circuit Optimization with Mockturtle Framework

## Project Overview

This project is a practical assignment for the *Digital Integrated Circuit Design Automation* course, focusing on logic synthesis and optimization for digital circuits. Using the open-source **Mockturtle** framework, I implemented and validated two industry-standard optimization algorithms for And-Inverter Graph (AIG) circuits: **balance** and **rewrite**. These algorithms target distinct optimization goals critical to chip performance, area, and power consumption:

- **Balance**: Reduces the logic depth (levels) of the circuit to improve timing performance, enabling operation at higher clock frequencies by restructuring the AIG for balanced signal paths.
- **Rewrite**: Minimizes the number of logic gates to optimize circuit area and power efficiency by replacing subgraphs with functionally equivalent, simpler structures.

---

## Algorithms Implemented

### 1. Balance Algorithm

The **balance** algorithm aims to reduce the logic depth of an AIG to enhance timing performance. It restructures the circuit without altering its logical function, minimizing the critical path's logic levels. The process involves:

1. Performing topological sorting of the AIG network to ensure nodes are processed after their inputs.
2. Enumerating cuts (subgraphs with limited inputs, e.g., up to 4) for each node.
3. Computing the Boolean function for each cut and converting it to an optimized Sum-of-Products (SOP) form.
4. Reconstructing the structure to minimize delay, replacing the original logic with the optimal cut if it reduces logic depth.

For example, a Boolean function `F = ab + c(d + ef)` with a logic depth of 4 can be restructured to `F = ab + cd + cef`, reducing the depth to 3 for improved timing.

### 2. Rewrite Algorithm

The **rewrite** algorithm focuses on reducing the number of logic gates to optimize area and power. It identifies and replaces subgraphs with functionally equivalent, simpler structures. The process includes:

1. Enumerating cuts (e.g., 4-input) for each node in topological order.
2. Computing the truth table for each cut's Boolean function.
3. Querying a precomputed database (e.g., NPN equivalence class library) for equivalent structures.
4. Evaluating the gain (`Gain = NodesSaved - NodesAdded`) for each replacement and selecting the structure with the highest gain.

For instance, a subgraph computing `a & b` can be replaced with a simpler equivalent if it reduces the total gate count.

---

## Implementation Details

### Mockturtle Framework

The project leverages **Mockturtle**, an open-source C++17 framework developed by EPFL, designed for logic synthesis and optimization. Its modular, extensible architecture supports AIG, XAG, and MIG networks, using "views" (e.g., `fanout_view`, `depth_view`) to enhance functionality without altering the underlying structure. Mockturtle's built-in utilities for cut enumeration, balancing, and rewriting allowed me to focus on algorithm integration and workflow design.

### Balance Implementation

The balance algorithm uses Mockturtle's `sop_rebalancing` interface to optimize logic depth via SOP-based reconstruction. Key steps include:

- Setting `cut_size = 4` to enumerate subgraphs with up to 4 inputs.
- Instantiating an SOP rebalancer (`sop_rebalancing<Ntk>`).
- Defining a callback function (`rebalancing_fn`) to process each node's cuts, compute truth tables, and perform delay-optimal restructuring.
- Executing `mockturtle::balancing` with the rebalancer and cleaning up dangling nodes using `cleanup_dangling`.

```cpp
mockturtle::sop_rebalancing<Ntk> rebalancer;
mockturtle::rebalancing_function_t<Ntk> rebalancing_fn = [&](...) {
    rebalancer(dest, function, children, best_level, best_cost, callback);
};
ntk = mockturtle::balancing(ntk, rebalancing_fn, ps);
ntk = cleanup_dangling(ntk);
```

### Rewrite Implementation

The rewrite algorithm uses `cut_rewriting_with_compatibility_graph` to reduce gate count. Key steps include:

- Instantiating an NPN equivalence class synthesizer (`xag_npn_resynthesis`) with a precomputed AIG structure database.
- Configuring `cut_size = 4` and other parameters for cut enumeration.
- Executing cut rewriting to replace subgraphs with optimal structures based on gain evaluation.
- Cleaning up dangling nodes post-optimization.

```cpp
xag_npn_resynthesis<aig_network, aig_network, xag_npn_db_kind::aig_complete> resyn;
cut_rewriting_params ps;
ps.cut_enumeration_ps.cut_size = 4;
cut_rewriting_with_compatibility_graph(ntk, resyn, ps);
ntk = cleanup_dangling(ntk);
```

---

## Experimental Results

### Adder Benchmark (`adder.aig`)

- **Initial State**: 1020 gates, 255 levels.
- **Post-Balance**: Gates increased to 1397, levels reduced to 171, improving timing as expected.
- **Post-Rewrite**: Gates and levels reverted to initial values (1020 gates, 255 levels) due to rewrite optimizing for gate count, indicating the original circuit was near-optimal for area.
- **Multiple Iterations**:
  - Repeated balance operations increased gates but further reduced levels, approaching optimal timing via greedy optimization.
  - Repeated rewrite operations reduced gates while increasing levels, optimizing for area.

### Voter Benchmark (`voter.aig`)

- **Initial State**: 13758 gates, 70 levels.
- **Post-Balance and Rewrite**: Reduced to 10866 gates and 67 levels, confirming a structurally superior AIG.
- **Multiple Iterations**: Further reductions in both gates and levels, demonstrating the benefit of combining optimization strategies.

---

## Setup and Execution

- **Environment**:
  - GCC 11.4.0, Clang 14.0.0 (tested on Ubuntu; lower GCC versions incompatible due to virtual machine constraints).
  - Mockturtle framework with standard CMake and Make compilation.
- **Running the Project**:
  - Follow GitHub instructions for Mockturtle setup.
  - Code files: `balance.hpp`, `rewrite.hpp`.
  - Test results: `adder_test.png`, `voter_test.png`.

---

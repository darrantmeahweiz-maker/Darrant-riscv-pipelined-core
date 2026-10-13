# High-Performance 5-Stage Pipelined RISC-V Core (RV32I + Zmmul + Zbb + Xicrc)

An independent, from-scratch 32-bit RISC-V processor microarchitecture written in Verilog HDL. Designed targeting the **Intel Cyclone V FPGA**, this core features a classic 5-stage pipeline, dynamic branch prediction, an 8-entry Return Address Stack (RAS), complete EX/MEM data forwarding paths, load-use interlock hazard resolution, and domain-specific hardware accelerators.

Unlike multi-cycle, area-optimized microcontrollers (such as PicoRV32), this core implements an in-order concurrent pipeline capable of achieving near-unity Instructions Per Cycle (IPC ~ 1.0) on linear code and tight loops.

---

## Microarchitecture Overview

The processor implements an in-order pipeline partitioned into five discrete stages with full hazard mitigation and speculative control units:

```
+------------+     +------------+     +------------+     +------------+     +------------+
|  IF Stage  | --> |  ID Stage  | --> |  EX Stage  | --> | MEM Stage  | --> |  WB Stage  |
|            |     |            |     |            |     |            |     |            |
| Pre-Decode |     | RegFile R/W|     | ALU / Zmmul|     | DMEM Access|     | RegFile    |
| Dynamic BP |     | Decode     |     | Zbb / Xicrc|     | Align/Sign |     | Writeback  |
| 8-Deep RAS |     | Control    |     | Br. Monitor|     | Bus Master |     | Mux        |
+------------+     +------------+     +------------+     +------------+     +------------+
      ^                                     |
      |=========== Pipeline Flush ==========| (Misprediction / Ghost Fetch Healing)
```

### Pipeline Stages
* **IF (Instruction Fetch):** Contains PC generation logic, PC redirection multiplexers, Pre-Decoder, dynamic branch prediction state machines, and an 8-level Return Address Stack (RAS).
* **ID (Instruction Decode):** Features a 32x32-bit dual-read/single-write Register File with `x0` hardwired to zero, immediate generation, and control signal decoding.
* **EX (Execute):** Encapsulates the Base Integer ALU, single-cycle Multiplier (`Zmmul`), Bit Manipulation unit (`Zbb`), Custom CRC unit (`Xicrc`), and the `Branch_Monitor` verification unit. Computes actual branch targets and compares them against IF predictions.
* **MEM (Memory):** Generates byte/halfword/word store masks and sign/zero-extends load operations interfacing with Data Memory.
* **WB (Writeback):** Selects between ALU output, custom extension results, and memory load data to commit values back into the register file.

---

## Key Hardware Features

### 1. Hazard Mitigation & Forwarding Unit
* **Data Forwarding:** Eliminates RAW (Read-After-Write) stalls via low-latency bypass paths:
  * **EX-to-EX Forwarding:** Forwards uncommitted ALU/extension results directly from the EX/MEM pipeline register into EX stage operand multiplexers.
  * **MEM-to-EX Forwarding:** Forwards results from the MEM/WB pipeline register to EX stage operand multiplexers.
* **Load-Use Interlock:** Automatically detects dependencies where an instruction immediately consumes the result of an ongoing memory load. The hazard unit freezes the IF/ID registers for 1 cycle, inserts a bubble into the ID/EX register, and resumes execution seamlessly.

### 2. Speculative Control & RAS
* **Dynamic Branch Prediction:** Trains dynamically on backward/forward branch patterns, tracking branch history to minimize branch penalty latency.
* **Hardware Return Address Stack (RAS):** 8-level deep LIFO stack dedicated to tracking subroutine calls (`jal` / `jalr` using link register `x1`/`ra` and alternate link register `x5`/`t0` per standard RISC-V ABI). Accurately predicts returns without draining the pipeline.
* **Branch Monitor & Misprediction Recovery:** Monitored directly in the Execute stage. If a branch direction evaluates false or a target address mismatches (such as during a RAS capacity overflow/sabotage), the core asserts `Mispredict_Flag`, flushes invalid speculative instructions across `FlushD` and `FlushE`, and restores the PC stream in a single healing cycle.

---

## Supported Instruction Set Architecture (ISA)

The core has achieved 100% functional coverage across standard and custom extensions:

| Category | Extension | Mnemonics Covered | Description |
| :--- | :--- | :--- | :--- |
| **Integer Core** | **RV32I** | `add`, `sub`, `sll`, `slt`, `sltu`, `xor`, `srl`, `sra`, `or`, `and`<br>`addi`, `slti`, `sltiu`, `xori`, `ori`, `andi`, `slli`, `srli`, `srai`<br>`lb`, `lh`, `lw`, `lbu`, `lhu`<br>`sb`, `sh`, `sw`<br>`beq`, `bne`, `blt`, `bge`, `bltu`, `bgeu`<br>`jal`, `jalr`<br>`lui`, `auipc`<br>`fence`, `ecall`, `ebreak` | Full standard 32-bit Base Integer Instruction Set including non-delay branch and jump behavior. |
| **Multiplication** | **Zmmul** | `mul`, `mulh`, `mulhsu`, `mulhu` | Hardware multiplication extension calculating standard lower 32 bits and upper 32 bits (Signed, Unsigned, Mixed). |
| **Bit Manipulation**| **Zbb** | `clz`, `cpop`, `rev8`, `rol`, `ror` | Basic bit manipulation acceleration: Count Leading Zeros, Population Count, Byte-Reverse, Rotate Left/Right. |
| **Custom IP** | **Xicrc** | `crcb`, `crch`, `crcw` | Custom hardware CRC accelerator supporting Byte, Halfword, and Word computations mapped to custom `funct7` decodes. |

---

## Verification Methodology

Verification is driven by an autonomous, bare-metal self-checking testbench (`tb_RISCV_Core.v`) loading pre-compiled hexadecimal instruction memory blocks (`program.hex` starting at address `0x00400000`).

### Test Coverage Highlights
* **Predictor Saturation Stress:** Executes 6 distinct branch-training kernels (BEQ, BNE, BLT, BGE, BLTU, BGEU) across 60+ iterations each (360+ total branch executions), forcing predictor state machines through strongly-taken and strongly-not-taken saturation.
* **Deep RAS Overflow Verification:** Traverses a nested function call tree 9 levels deep. Because the physical hardware RAS holds 8 entries, the 9th call intentionally wraps the internal stack pointer, forcing an eviction. The testbench verifies that the `Branch_Monitor` catches the predicted-address mismatch upon final return, asserts a pipeline flush, and recovers execution flow.
* **Ghost Fetch Immunity:** Verification monitors the Execute Stage (`dut.PCE`) rather than speculative Fetch wires (`dut.PCF`), ensuring transient ghost fetches during pipeline flushes do not cause false testbench assertion failures.
* **Continuous Self-Checking Traps:** Every functional block verifies its outputs via hardware comparison branches. Any arithmetic or control failure diverts execution to `FAIL_TRAP` (`0x00400230`), setting `x4 = 0xFFFFFFFF`. Complete verification terminates cleanly at `PASS_TRAP` (`0x00400234`), retaining `x4 = 0x00000000`.

---

## Repository Structure

```
├── rtl/                        # Synthesizable Verilog Source Files
│   ├── RISCV_Core.v            # Top-level core wrapper
│   ├── Hazard_Unit.v           # Forwarding, stall, and flush control unit
│   ├── Branch_Predictor.v      # Dynamic branch prediction & BTB logic
│   ├── RAS.v                   # 8-entry hardware Return Address Stack
│   ├── ALU.v                   # Base integer arithmetic logic unit
│   ├── Zmmul_Unit.v            # Hardware multiplier
│   ├── Zbb_Unit.v              # Bit manipulation logic
│   └── Xicrc_Unit.v            # Custom CRC accelerator
├── tb/                         # Simulation Testbenches
│   └── tb_RISCV_Core.v         # Autonomous self-checking testbench
├── hex/                        # Bare-metal Firmware & Test Binaries
│   └── program.hex             # Exhaustive ISA validation binary
├── build/                      # Simulation binaries and VCD waveforms
├── Makefile                    # Automated build and test scripts
└── README.md
```

---

## Simulation & Build Guide

### Prerequisites
* **OS:** Linux / Ubuntu (or Windows Subsystem for Linux - WSL2)
* **Simulator:** Icarus Verilog (`iverilog`, `vvp`)
* **Waveform Viewer:** GTKWave

Install dependencies on Debian/Ubuntu:
```bash
sudo apt update
sudo apt install iverilog gtkwave
```

### Running the Verification Suite
1. Clone the repository:
   ```bash
   git clone [https://github.com/](https://github.com/)<your-username>/riscv-pipelined-core.git
   cd riscv-pipelined-core
   ```

2. Compile the RTL and testbench:
   ```bash
   mkdir -p build
   iverilog -o build/core_sim tb/tb_RISCV_Core.v rtl/*.v
   ```

3. Run the simulation:
   ```bash
   vvp build/core_sim
   ```

4. Expected Terminal Output:
   ```text
   ========================================
    🚀 RISC-V EXHAUSTIVE SELF-CHECKING VERIFICATION
   ========================================
   ... [Instruction execution trace] ...
   ========================================
    ✅ TEST PASSED!
    🏁 All ISA, Hazards, and Speculation checks completed perfectly.
       Self-Check Status Register (x4) is 0x00000000.
    💡 [15995000] RAS Overflow/Mispredict Detected! Healing pipeline...
   ========================================
   ```

5. Inspect Pipeline Waveforms:
   ```bash
   gtkwave build/core_waveform.vcd
   ```

---

## Development Roadmap (FPGA SoC Target)

Current ongoing development focuses on expanding this standalone execution core into a fully featured System-on-Chip (SoC) for physical evaluation on the **Intel Cyclone V FPGA**:

- [x] Complete 5-stage pipeline with full EX/MEM data forwarding.
- [x] Dynamic Branch Predictor, 8-deep RAS, and Execute-stage pipeline recovery.
- [x] RV32I + Zmmul + Zbb + Xicrc functional verification.
- [ ] **Synchronous Memory Subsystem:** Refactor asynchronous memory structures to align with physical FPGA synchronous Block RAM (BRAM) 1-cycle read latencies.
- [ ] **Standardized Interconnect Bus:** Implement an AXI4-Lite / APB master interface for memory-mapped peripheral integration.
- [ ] **Memory-Mapped Peripherals (UART):** Integrate a hardware UART TX/RX controller to transmit debug/register dumps and console output over USB.
- [ ] **Quartus Prime Timing Closure & Synthesis:** Target timing closure on Cyclone V logic elements.
- [ ] **Multi-cycle Units:** Implement long-latency multicycle Division ('M' extension) and single-precision Floating Point ('F' extension).

# VHDL Bubble Sort Implementation for RAM 🚀

## Overview 📝
This project implements a **Bubble Sort algorithm** on a RAM module using VHDL. The design includes a finite state machine (FSM) controller, RAM, and testbenches to validate the implementation. The project is simulated to sort a sequence of numbers stored in memory.

---

## 📂 Project Structure
The project is organized into the following components:

### Source Files 📜
- **RAM Module (`Ram.vhd`)**: 
  - A parameterized RAM module with external output ports (`FIRST` and `LAST`) for testing purposes.
  - Configured with the following parameters:
    - `RAM_WIDTH = 8`
    - `RAM_DEPTH = 16`
    - `RAM_ADD = 4`

- **FSM (`FSM.vhd`)**:
  - A two-process High-Level State Machine (HLSM) controlling the sorting algorithm.
  - Interacts with the RAM and handles data read/write operations, as well as sequencing through the sorting steps.

- **Top-Level Module (`TopLevel.vhd`, `TopLevel_2.vhd`)**:
  - Wrappers integrating the RAM and FSM.
  - Serve as the main interface for simulation and testing.

- **Memory Initialization File (`memory.mem`)**:
  - Provides an initial pattern for the RAM content, as defined in the assignment.

### Testbenches 🧪
- **`tb_sorting_system.vhd`**: Validates the sorting functionality by asserting conditions on the RAM contents.
- **`TopLevelDownUp_tb.vhd`**: Tests the top-level entity for general behavior.

### Configuration and Simulation Files ⚙️
- **`Configuration_final.wcfg`**: 
  - Waveform configuration file for simulation.
  - Tracks critical signals such as `Clk`, `Reset`, `Start`, `current_state`, `inner_counter`, and `data_out`.

### Documentation 📖
- **State Diagram (`State_Diagram.png`)**:
  - Visual representation of the FSM states and transitions.
- **Report (`VHDL special project report.docx`)**:
  - Detailed documentation of the implementation and its components.

---

## ⚙️ Functionality

### 🧩 Sorting Algorithm
The **Bubble Sort algorithm** is implemented through the FSM, which iteratively compares and swaps adjacent elements in RAM. The FSM manages the sorting process in stages, controlled by clock cycles and specific states.

### 🛠️ State Machine
The FSM transitions between states such as:
- **Idle**: Waiting for the start signal.
- **Load**: Initializing RAM and setting up.
- **Compare**: Comparing adjacent elements.
- **Swap**: Swapping elements if necessary.
- **Done**: Indicating the sorting is complete.

📌 *Refer to the `State_Diagram.png` for more details.*

### 🕒 Simulation
Simulations are run to verify the design:
- The system requires approximately **5,470,000 ns** to sort the data.
- The simulation tool should be set to run for **1000 µs** to observe the full sorting process.

---

## 🛠️ How to Use

1. **Setup**:
   - Open the project file (`ProjectAssignment.xpr`) in Xilinx Vivado or your preferred FPGA development tool.
   - Ensure the simulation configuration (`Configuration_final.wcfg`) is loaded.

2. **Simulation**:
   - Run the provided testbenches (`tb_sorting_system.vhd`, `TopLevelDownUp_tb.vhd`).
   - Observe the waveforms to verify the sorting functionality.

3. **Modify**:
   - Customize the `memory.mem` file to initialize RAM with different data patterns.
   - Adjust parameters in `Ram.vhd` as needed for different word sizes or depths.

---

## 📌 Additional Notes
- Ensure sufficient simulation time to observe sorting completion.
- The project is designed for educational purposes, demonstrating FSM-based control of sorting on FPGA hardware.

---

## ✍️ Authors
This project was completed as part of a VHDL special project assignment at POLITO.
Authors are: Andrea Mugnaini.

---


# FPGA based autonomous fluid filling system
This is FSM based moore-state machine that controls the fluid levels in a storage tank without the human intervention. Firstly, it was designed solely
domestic water tanks, but given its effectiveness it can be used in Industrial setups such as chemmical and petroleum factories where, MCU delays and 
software based systems are vulnerable. This FPGA based system simply runs the hardware based FSM.
## DEVELOPMENT BOARD:
I had shrike-lite available in my lab, so thought it would be a good practice to code an moore-state machine on an actual chip. It incorporates
Renesas forgeFPGA. 
### Tech details:
| **Resource** | **Utilization** | **Available** | **Percentage** | 
| :--- | :--- | :--- | :--- | 
| **CLB LUTs (Look-Up Tables)** | 98 | 1120 | 8.75 % | 
| **CLB (FFs)** | 38 | 1120 | 3.39 % | 
| **IOB (FFs)** | 5 | 736 | 0.68 % |
| **I/O Pins** | 10 | 184 | 4.30 % |
* Clock Freq.: 50MHz, Maximum Achievable freq.: 110MHz

## Block Diagram:
<img width="800" height="750" alt="fig_system" src="https://github.com/user-attachments/assets/4d48d535-4685-4464-b4a3-52f855273377" />

## State Transistion Diagram:
<img width="620" height="750" alt="state_diagram" src="https://github.com/user-attachments/assets/626ec21c-5945-48d3-9704-4b500ae92486" />  

### State Machine Operational Flow

The `water_fill.v` operates on a synchronous clocked architecture with a continuous asynchronous reset (`rst_n`). The logic is designed to prioritize hardware preservation over aggressive pumping, utilizing five distinct operational states:

* **`BOOT` (Initialization):** Triggered upon power-up or a hard hardware reset. In this state, the FPGA evaluates the static environment. It checks the immediate status of all hydro-probes and the municipal flow switch to safely determine the next logical transition without jolting the actuators.

* **`PRE_FILL` (Pressure Stabilization Delay):**
  A critical industrial safety state. When the tank requires water and city flow is detected, the system does not immediately engage the 220V AC pump. Instead, it opens the inlet `valve` and enters a parametric wait state (default: 5 seconds). This allows the physical water pressure in the municipal pipes to stabilize and purge air pockets before the heavy motor draws load.

* **`FILLING` (Active Pumping):**
  Both the inlet `valve` and the `motor` are held high (logic `1`). The system remains locked in this state, filling the reservoir until the water physically bridges the `max_sense` probe. 

* **`FULL` (Standby & Hysteresis):**
  Once the tank reaches maximum capacity, the FSM transitions here, shutting down the motor and valve. 
  * *Hysteresis Lock:* To prevent destructive motor chatter (rapid ON/OFF cycling caused by waves or minor water usage), the FSM will not leave the `FULL` state until the water level drops completely below the `mid_sense` probe. 

* **`DROUGHT` (Dry-Run Protection):**
  The ultimate hardware failsafe. If the municipal flow switch (`flow_sense`) drops to logic `0` at *any* point during the `PRE_FILL` or `FILLING` phases, the FSM immediately aborts the operation and jumps to `DROUGHT`. The motor is instantly killed to prevent catastrophic dry-running and overheating. The FSM remains trapped in this safety lockout until city water pressure is physically restored.  

## Periperals Used:
- To detect the flow of incoming liquid, a simple flow meter was used.
- A solenoid based valve was used to control the flow of liquid.
- capacitive sensors can be used to detect the level of liquid in the tank.  
> ***NOTE:*** For water, a simple PWM based SS-304 rods can be used at low voltages, PWM signal helps in countering the oxidation of the rods.    

### Physical Pin Mapping (Renesas ForgeFPGA / Shrike Lite)

| Logical Port in Verilog | Direction | Physical Pin | Internal Pad Function |
| :--- | :---: | :---: | :--- |
| `clk_en` | Output | **Internal** | `OSC_EN` (Enables Internal Oscillator) |
| `rst_n` | Input | **PIN 4** | `GPIO13_IN` |
| `valve` | Output | **PIN 7** | `GPIO16_OUT` |
| `valve_en` | Output | **PIN 7** | `GPIO16_OE` |
| `raw_flow_sense` | Input | **PIN 13** | `GPIO0_IN` |
| `raw_low_sense` | Input | **PIN 14** | `GPIO1_IN` |
| `raw_mid_sense` | Input | **PIN 15** | `GPIO2_IN` |
| `raw_max_sense` | Input | **PIN 20** | `GPIO7_IN` |
| `motor` | Output | **PIN 23** | `GPIO8_OUT` |
| `motor_en` | Output | **PIN 23** | `GPIO8_OE` |  

> ***Note:*** The ForgeFPGA requires explicit Output Enable (`_en`) signals for all outputs. 


### Physical Pin Mapping (Xilinx Artix-7 / Basys 3)

The design is mapped to the following physical pins on the Basys 3 development board. All pins are configured for the High Range (HR) 3.3V banks (`LVCMOS33`).

| Logical Port in Verilog | Direction | FPGA Physical Pin | I/O Standard | Connected Hardware (Basys 3) |
| :--- | :---: | :---: | :---: | :--- |
| `clk` | Input | **W5** | LVCMOS33 | 50 MHz Onboard Oscillator |
| `rst_n` | Input | **V17** | LVCMOS33 | Slide Switch SW0 (Rightmost) |
| `flow_sense` | Input | **V16** | LVCMOS33 | Slide Switch SW1 |
| `low_sense` | Input | **V15** | LVCMOS33 | Slide Switch SW2 |
| `mid_sense` | Input | **W16** | LVCMOS33 | Slide Switch SW3 |
| `max_sense` | Input | **W17** | LVCMOS33 | Slide Switch SW4 |
| `motor` | Output | **U16** | LVCMOS33 | LED 0 (Rightmost LED) |
| `valve` | Output | **E19** | LVCMOS33 | LED 1 |

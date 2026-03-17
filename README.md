# FPGA based autonomous fluid filling system
This is FSM based moore-state machine that controls the fluid levels in a storage tank without the human intervention. Firstly, it was designed solely
domestic water tanks, but given its effectiveness it can be used in Industrial setups such as chemmical and petroleum factories where, MCU delays and 
software based systems are vulnerable. This FPGA based system simply runs the hardware based FSM.
## DEVELOPMENT BOARD:
I had shrike-lite available in my lab, so thought it would be a good practice to code an moore-state machine on an actual chip. It incorporates
Renesas forgeFPGA. 
### Tech details:
Clock Speed | LUTs | Max. acheivable Clock Speed | Utilised LUTs|
|----------|----------|----------|----------|
50 MHz | 1124 | 88 MHz | 99 LUTs|

<img width="1021" height="735" alt="fig_system" src="https://github.com/user-attachments/assets/4d48d535-4685-4464-b4a3-52f855273377" />
Fig: Block Diagram of complete system. 


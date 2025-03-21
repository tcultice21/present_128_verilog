# present_128_verilog
## Verilog PRESENT-128 implementation

Implementation in synthesizable Verilog of PRESENT Block Cipher algorithm in 128-bit mode. Currently only doing 4 rounds temporarily, but this can be changed by simply altering the round counter condition and generating new test cases for 32 rounds. This change is temporary for use in class assignments.

Controller included for providing a testing apparatus for loaded RAM elements (up to 32 test cases, but can be changed for more).

Scripts for generating test cases provided in ./test_case_generator_py. This will use a python implementation of PRESENT to create 32 unique signatures.

### Info about PRESENT:
PRESENT is an ultra lightweight block cipher algorithm, developed by the Orange Labs (France), Ruhr University Bochum (Germany) and the Technical University of Denmark in 2007. PRESENT was designed by Andrey Bogdanov, Lars R. Knudsen, Gregor Leander, Christof Paar, Axel Poschmann, Matthew J. B. Robshaw, Yannick Seurin, and C. Vikkelsoe. It is one of the most compact block ciphers ever designed. The block size is 64 bits and the key size can be 80 bit or 128 bit. It is intended to be used in situations where low-power consumption and high chip efficiency is desired. The International Organization for Standardization and the International Electrotechnical Commission included PRESENT in the new international standard for lightweight cryptographic methods. (See http://en.wikipedia.org/wiki/PRESENT_(cipher))

The original reference paper describing the PRESENT algorithm in full detail is the following:
A. Bogdanov, L. R. Knudsen, G. Leander, C. Paar, A. Poschmann, M. J. B. Robshaw, Y. Seurin and C. Vikkelsoe. PRESENT: An Ultra-Lightweight Block Cipher. CHES Conference 2007. [https://link.springer.com/chapter/10.1007/978-3-540-74735-2_31](https://link.springer.com/chapter/10.1007/978-3-540-74735-2_31).

### Block Diagram:
![Present Block Diagram](./imgs/Block_Diagram.png)

### Expected Simulation Results (Xilinx Vivado Behavioral Simulation Waveform):
![Xilinx Vivado Simulation Results](./imgs/simulation_waveform.png)
Note: Above is based on provided .mem files and controller. The "valid" flag will determine test success.

### Files and Folders:
- imgs -- contains images for READMEs in this repository
- basys3_hw_fpga_config -- Contains the constraints file needed for implementation on Diligent Basys3 FPGA
- test_case_generator_py -- Contains the Py notebook (ipynb) for generating quick and easy PRESENT-128 test mem files
- present.v -- Contains the core PRESENT-128 implementation and module
- controller.v -- Contains the testing apparatus controller and "top module" of this repository
- inputs.mem -- Memory file of 32 192-bit plaintext/key concatenations for PRESENT-128 testing
- benchmarks.mem -- Memory file of 32 64-bit responses from PRESENT-128 test vectors
- README.md -- This file

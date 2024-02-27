# DSP48A1 Verilog Code and Testbench Repository

This repository contains Verilog code for the DSP48A1 chip, along with a testbench for verifying the functionality of the code. The code can be simulated using ModelSim and can also be run in Vivado for synthesis and implementation on FPGA devices.

## Contents
The repository includes the following files:

1. dsp48a1.v: This file contains the Verilog code for the DSP48A1 chip. It implements the desired functionality and can be customized according to your specific requirements.

2. REGISTER.v:  This file contains the Verilog code for the repeated Part if you need to make input and output registered or not

3. testbench.v: This file contains the testbench code written in Verilog. It provides stimulus to the DSP48A1 module and verifies the correctness of its output.

4. run.do: This file is used for simulation in ModelSim. It contains the necessary commands to compile and simulate the Verilog files.

## Getting Started
To get started with this repository, follow these steps:

1. Clone the repository to your local machine using the following command:
```ruby
git clone <https://github.com/Abdelrahman1810/DSP48A1.git>
```
2. Open ModelSim and navigate to the directory where the repository is cloned.
3. Compile the Verilog files by executing the following command in the ModelSim transcript tap: 
```ruby
do run.do
```
This will compile the dsp48a1.v, register.v, testbench.v files.


> [!IMPORTANT]
> You need to download [Modelsim](https://www.intel.com/content/www/us/en/software-kit/750368/modelsim-intel-fpgas-standard-edition-software-version-18-1.html) and [Vivado](https://www.xilinx.com/support/download.html) first.

## Using Vivado
f you want to synthesize and implement the DSP48A1 design on an FPGA device using Vivado, follow these additional steps:

1. Launch Vivado and create a new project.

2. Add the dsp48a1.v and register.v files to the project as a design source.

3. Add the testbench.v file to the project as a simulation source.
    > if you already simulate the design in the modelsim you can Ignore this step

4. Run synthesis, implementation, and generate the bitstream using Vivado's tools.

5. Program the bitstream onto the target FPGA device and test the functionality.

> [!TIP]
> It will be better if you write a constrain file depend on the target FPGA.

> XILINX documentation [Slice User Guide](https://docs.xilinx.com/v/u/en-US/ug389)

## Contributing
If you find any issues or have suggestions for improvement, feel free to submit a pull request or open an issue in the repository. Contributions are always welcome!

## Contact info 💜

<a href="http://wa.me/201061075354" target="_blank"><img alt="LinkedIn" src="https://img.shields.io/badge/whatsapp-128C7E.svg?style=for-the-badge&logo=whatsapp&logoColor=white" /></a> 

<a href="https://www.linkedin.com/in/abdelrahman-mohammed-814a9022a/" target="_blank"><img alt="LinkedIn" src="https://img.shields.io/badge/linkedin-0077b5.svg?style=for-the-badge&logo=linkedin&logoColor=white" /></a>

Gmail : abdelrahmansalby23@gmail.com 📫

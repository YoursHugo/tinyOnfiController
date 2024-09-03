# tinyOnfiController
This is an intern project for the summer of 2024 at the Wuhan National Laboratory for Optoelectronics, Huazhong University of Science and Technology.

In this project, I am working on the design and implementation of a ONFI controller for NAND flash memory. The controller is designed to be simple and efficient, and it is implemented in Verilog.

If you want to run this project, make sure that you have installed gtkwave and iverilog on your machine with this cammand:

```bash
sudo apt-get install iverilog gtkwave
```

Check the installation by running the following commands:

```bash
$ iverilog -v
Icarus Verilog version 12.0 (stable) ()

Copyright (c) 2000-2021 Stephen Williams (steve@icarus.com)
```

You can run the project by executing the following commands:

```bash
make MODULE=$(moduleName)
```

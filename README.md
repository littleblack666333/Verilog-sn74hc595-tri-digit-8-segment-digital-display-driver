# Verilog Driver Code for SN74HC595 Drived Tri-digit 8-segment Display Module
## Basic Description
This is a Verilog driver for a tri-digit 8-segment display module driven by the SN74HC595 chip, designed to display 
specified digits using an FPGA. The display module consists of three 8-segment displays (seven segments for digits and 
one segment for the decimal point), each driven by a 74HC595 chip. The three 74HC595 chips are cascaded in series, 
allowing the FPGA to control the display characters via serial communication. The three digits to be displayed should 
be input to the driver module in 8421 BCD format, with the module containing the corresponding decoding logic.\
Testbench included.
## Driver Module Description
### Port Information
This module includes five input ports and three output ports, defined as follows:
#### Input Ports:
* `clk`: 1-bit wide, clock signal, default at 50MHz
* `rst_n`: 1-bit wide, reset signal, active low
* `trigger`: 1-bit wide, trigger signal, active on the rising edge, used to display the currently inputted three digits  
  on the display and refresh the display. The frequency of the `trigger` signal    should not exceed that of 
  the `clk` signal.
* `num0`: 4-bit wide, 8421 BCD code for the first digit to be displayed, representing the leftmost digit on the display 
  module
* `num1`: 4-bit wide, 8421 BCD code for the second digit to be displayed
* `num2`: 4-bit wide, 8421 BCD code for the third digit to be displayed
#### Output Ports:
* `clk_serial`: 1-bit wide, serial output clock, used to control the shift register of the 74HC595 chip for data input 
  to the display module
* `data`: 1-bit wide, serial data output port
* `load`: 1-bit wide, load signal output port, active on the rising edge, used to transfer the data from the shift 
  register to the display register in the 74HC595 chip, refreshing the display
#### Configurable Parameters
* `STEP_LENGTH`: The number of `clk` signals in each step; one `clk_serial` cycle contains two steps, which can 
  transmit 1 bit of data.
* `POINT_POS`: The position of the decimal point, displayed after the corresponding digit; if set to 0, the decimal 
  point is not displayed.
#### Display Module Information
* Each digit of the display module is driven by one 74HC595 chip.
* The three 74HC595 chips are cascaded in series, so the data input first corresponds to the last digit.
* Each digit consists of 8-bit data: 7 bits control the 7-segment LEDs for digit display, and 1 bit controls the 
  decimal point.
* The display encoding for each character is detailed in the code.
---------------------------------------------------------------------------------
## 基本描述
本代码是针对由SN74HC595芯片驱动的三联8段数码管模块的Verilog驱动程序，用于利用FPGA在该数码管模块上显示出指定的数字。本驱动对应的数码
管模块由3个八段数码管（七段LED用于显示数字，第八段LED用于显示小数点）构成，对于每一个数码管，采用一片74HC595芯片驱动。3片74HC595芯
片之间采用串行的方式级联。因此FPGA可以采用串行通信的方式控制数码管的显示的字符。对于拟显示的3个数字，应采用8421BCD码的形式输入该驱动
模块，模块内包含对应的译码部分。\
包含驱动代码本体和对应的testbench文件。
## 驱动模块描述
### 端口信息
本模块包含5个输入端口与3个输出端口，端口定义如下：
#### 输入端口：
* `clk`: 位宽为1位，时钟信号，默认为50MHz
* `rst_n`: 位宽为1位，复位信号，低有效
* `trigger`: 位宽为1位，触发信号，上升沿有效，用于将当前输入的3个数字显示在数码管上，刷新数码管的显示。`trigger`信号的变化频率应不
  大于`clk`信号
* `num0`: 位宽为4位，拟显示的第一个数字的8421BCD码，第一个数字是显示模块上最左边的数字
* `num1`: 位宽为4位，拟显示的第二个数字的8421BCD码
* `num2`: 位宽为4位，拟显示的第三个数字的8421BCD码
#### 输出端口：
* `clk_serial`: 位宽为1位，串行输出时钟，用于控制74HC595芯片的移位寄存器，以实现数据输入显示模块
* `data`: 位宽为1位，串行数据输出端口
* `load`: 位宽为1为，装数信号输出端口，上升沿有效，用于将74HC595芯片中移位寄存器的数据输出到显示寄存器中，刷新数码管的显示
### 可修改参数信息
* `STEP_LENGTH`: 每一个步长包含的`clk`时钟信号的数量，一个`clk_serial`周期包含两个步长，可以传送1bit数据
* `POINT_POS`: 小数点的位置，显示在对应的数字后，若为0则不显示小数点
### 数码管模块信息
* 数码管模块的每一个数码管均由1个74HC595芯片驱动
* 3个74HC595芯片之间采用串行通信的方式级联，因此最先输入的数据是最后一个数字的数据
* 每个数字包含8bit数据，7bit数据控制数字显示的7段LED，1bit数据控制小数点的显示
* 每个字符对应的显示编码详见代码

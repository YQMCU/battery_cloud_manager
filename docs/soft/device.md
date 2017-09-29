# 设备程序设计

使用基于lua脚本开发的[合宙科技](http://www.openluat.com)**Air810**模块[采购链接](https://item.taobao.com/item.htm?spm=a1z10.5-c.w4002-17070547242.24.4f5b64bdSxvUFv&id=547529605583)，
在Lua程序中开发软件程序。

程序主要完成四个功能。

## 功能描述：

1. 电池状态采集
    
    状态采集基于BMS[寄存器协议](../../pre/reg)的，编程实现模块和BMS之间的485通讯。

    485通讯的本质就是串口通讯，而BMS的modbus通讯又是将无语意的串口通讯包装成有一定协议的数据帧通讯。

    以**命令字**作为读写的操作方式控制，以**地址**区分设备，然后十六进制数据发送通讯的内容。
    
    **modbus通讯协议**[参考](../assets/references/MODBUS通讯协议.pdf)

2. 电池参数控制
    
    参数控制基于后台管理服务器和前端设备的**GPRS**通讯。

3. 定位

    模块支持GPS和LBS双重定位，考虑到设备应用于室内环境，GPS基本没有用，程序中关闭了GPS功能，只采用LBS向[合宙云平台](http://iot.openluat.com)请求基站定位。

    基站定位是基于udp协议和合宙云平台进行通讯。

4. 信息的传递

    服务器和设备基于GPRS协议传递信息，程序中常规程序采用tcp协议通讯,保持长连接通信，并间隔发送心跳包。

    心跳包的作用既保证通讯的持续性，又可以在服务器端有指令待发送的时候给设备发送指令。

## 程序描述

### 项目结构

模块中搭建有Lua虚拟机，功能程序都是架构于Lua虚拟机之上的脚本程序，project中Lib文件夹存放设备功能实现所需要的脚本程序。

<center>
**项目示意图**

![项目图](../../assets/images/项目示意图.png)
</center>

### 程序介绍
|文件名|功能|
|:---|:---:|
|ld_info.lua|设备参数预设|
|ld_flash.lua|flash操作|
|ld_bms_cmd.lua|与BMS通讯读取电池数据脚本|
|ld_lbs.lua|基站定位|
|ld_gps|gps定位|
|ld_tcp_heart|tcp长连接通讯|
|ld_uart|串口处理程序|
|ld_update|远程脚本升级程序|
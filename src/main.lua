--必须在这个位置定义PROJECT和VERSION变量
--PROJECT：ascii string类型，可以随便定义，只要不使用,就行
--VERSION：ascii string类型，如果使用Luat物联云平台固件升级的功能，必须按照"X.X.X"定义，X表示1位数字；否则可随便定义
PROJECT = "LD_Battery_Manager_Cloud"
VERSION = "2.0.0"
require"sys"

--[[
如果使用UART输出trace，打开这行注释的代码"--sys.opntrace(true,1)"即可，第2个参数1表示UART1输出trace，根据自己的需要修改这个参数
这里是最早可以设置trace口的地方，代码写在这里可以保证UART口尽可能的输出“开机就出现的错误信息”
如果写在后面的其他位置，很有可能无法输出错误信息，从而增加调试难度
]]
 sys.opntrace(true,1)


APP_DEBUG = true -- 调试接口


-- 系统参数等flash信息处理
require"ld_flash"

-- 请求基站定位的KEY
--PRODUCT_KEY = ld_flash.readflash('LD_LBS_PRODUCT_KEY')-- "WlhKN4JunVtzNXJxcqdIjd42Tboib30c"
PRODUCT_KEY = "WlhKN4JunVtzNXJxcqdIjd42Tboib30c"


-- 心跳长链接,与服务器联络的关键程序
require"ld_tcp_heart" -- 心跳长连接 发送地址等相关信息

-- 串口程序,与BMS定时处理发送的关键程序
require"ld_bms_cmd"

-- 串口程序,与BMS进行通讯接收的关键程序
require"ld_uart" --串口程序


-- GPS定位功能程序
require"ld_gps"

-- LBS基站定位功能程序
require"ld_lbs"


sys.init(0,0)
sys.run()

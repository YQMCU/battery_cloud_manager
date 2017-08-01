--[[
  功能描述: 串口处理程序
  更新时间: 2017-07-31 00:44
]]

module(...,package.seeall)

-- bms控制处理程序
require"ld_bms_cmd" 
require"common"




local function print(...)
  if APP_DEBUG then 
    _G.print('LD_UART:',...)
  end
end


local schar,slen,sfind,sbyte,ssub = string.char,string.len,string.find,string.byte,string.sub

--[[
功能需求：
uart按照帧结构接收解析外围设备的输入

帧结构如下：
起始标志：1字节，固定为0x01
数据个数：1字节，校验码和数据个数之间的所有数据字节个数
指令：1字节
数据1：1字节
数据2：1字节
数据3：1字节
数据4：1字节
校验码：数据个数到数据4的异或运算
结束标志：1字节，固定为0xFE
]]


--串口ID,1对应uart1
--如果要修改为uart3，把UART_ID赋值为3即可
local UART_ID = 3
--起始，结束标志
local FRM_HEAD,FRM_TAIL = 0x01,0xFE
--指令
local CMD_01 = 0x01
--串口读到的数据缓冲区
local rdbuf = ""



--[[
函数名：read
功能  ：读取串口接收到的数据
参数  ：无
返回值：无
]]

local function read_byte()
  local data = ""
  local tbyte = {}
  local str = ""
  --底层core中，串口收到数据时：
  --如果接收缓冲区为空，则会以中断方式通知Lua脚本收到了新数据；
  --如果接收缓冲器不为空，则不会通知Lua脚本
  --所以Lua脚本中收到中断读串口数据时，每次都要把接收缓冲区中的数据全部读出，这样才能保证底层core中的新数据中断上来，此read函数中的while语句中就保证了这一点
  while true do   
    data = uart.read(UART_ID,"*l",0)
    if not data or string.len(data) == 0 then break end
    --打开下面的打印会耗时
--    print("read",common.binstohexs(data)) --string
    
--    普通字符串
    str = str..data
    
--    common.binstohexs 16进制接收 字符串形式处理
--    write(common.binstohexs(str))
    
--    _G.print("recv",common.binstohexs(str))
--    ld_tcp_heart.snd("recv"..common.binstohexs(str),"LOCRPT")
    
  end
  
   -- print("recv",common.binstohexs(str))
  
  -- 有BMS请求 处理请求
  if ld_tcp_heart.t_bms_request_state == '2' then
    ld_tcp_heart.t_bms_request_rdbuf = common.binstohexs(str)
    ld_tcp_heart.t_bms_request_state = '0' -- 请求接收完成
    print('bms request success',common.binstohexs(str))
    ld_tcp_heart.snd(ld_tcp_heart.t_device_ctrl_id..'repo'..ld_tcp_heart.t_bms_request_rdbuf)
    print(ld_tcp_heart.t_device_ctrl_id..'repo'..ld_tcp_heart.t_bms_request_rdbuf)
    -- 清除缓冲
    ld_tcp_heart.t_bms_request_rdbuf = ""
    ld_tcp_heart.t_bms_request_sndbuf = ""
    ld_tcp_heart.t_device_ctrl_id = ""
    
  -- 无请求或者请求已经完成 正常对接bms状态
  else
      ld_tcp_heart.t_rbuf_table[ld_bms_cmd.estat] = common.binstohexs(str)
      print('recv normal bms info',common.binstohexs(str)) 
  end
  
  -- 1 发送 
--  if send_state == 1 then 
--    send_state = 0 
--    rdbuf = "data1-"..str
--  elseif send_state == 2 then
--    send_state = 0 
--    rdbuf = "data2-"..str
--  elseif send_state == 3 then
--    send_state = 0 
--    rdbuf = "data3-"..str
--  end
--  return common.binstohexs(str)
--  print(str)
--  print(common.binstohexs(str))
  
end

--[[
函数名：write
功能  ：通过串口发送数据
参数  ：
    s：要发送的数据
返回值：无
]]
function write(s)
  print("write",s)
  uart.write(UART_ID,s)
end

--保持系统处于唤醒状态，此处只是为了测试需要，所以此模块没有地方调用pm.sleep("test")休眠，不会进入低功耗休眠状态
--在开发“要求功耗低”的项目时，一定要想办法保证pm.wake("test")后，在不需要串口时调用pm.sleep("test")
--pm.wake("test")
--注册串口的数据接收函数，串口收到数据后，会以中断方式，调用read接口读取数据
sys.reguart(UART_ID,read_byte)
--配置并且打开串口
uart.setup(UART_ID,9600,8,uart.PAR_NONE,uart.STOP_1)



-- 16进制写
--function w()
--  local t = {0x01,0x03,0x17,0x70,0x00,0x5a,0xc1,0x9e}
--  for i=1,table.maxn(t) do 
--    uart.write(UART_ID,t[i])
--  end
--end
--
--function tx_byte(id,t)
--  for i=1,table.maxn(t) do uart.write(id,t[i]) end
--end

-- ascii码制写 字符串
--function t()
--  print("tx flag",tx_flag)
--  write("01031770005ac19e")
--end

--sys.timer_loop_start(t,1000*60)

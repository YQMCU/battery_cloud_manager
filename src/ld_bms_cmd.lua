--[[
  功能描述: BMS控制发送指令程序
  更新时间: 2017-07-31 03:22
]]

module(...,package.seeall)

local bit = require"bit"
local pack = require"pack"
local string = require"string"
local ld_flash = require"ld_flash"
--local ld_tcp_heart = require("ld_tcp_heart")
local band,brshift,blshift,bxor = bit.band,bit.rshift,bit.lshift,bit.bxor
local sformat = string.format

require"ld_uart"
require"common"



local function print(...)
  if APP_DEBUG then 
    _G.print('LD_BMS_CMD:',...)
  end
end



-- crc右移检测程序
local function crc_rshift_check(crc,str)

  --首先 crc xor str
  crc = bxor(crc,strtonum(str))
  --[[
    ffff xor 0001 = fffe
  ]]

  -- 循环右移
  for i=1,8 do
    -- 获取低位 待检测
    local lbit = band(crc,1)
    crc = brshift(crc,1)
    if lbit==1 then
      crc = bxor(crc,0xa001)
    end
    --pcrc(crc)
  end
  return crc
end


-- crc16字符串处理程序返回crc校验码
local function crc16_str(str)
  -- 设置初始CRC
  local crc = 0xffff
  -- 依次送入字符串中的十六进制数(需要用sub拆分) 进行右移检测
  for i=1,string.len(str)/2 do
    -- 右移检测 并更新crc
    crc = crc_rshift_check(crc,string.sub(str,i*2-1,i*2))
  end
  -- 将crc高低字节调换
  local crc_h,crc_l= band(crc,0xff00),band(crc,0x00ff)
  crc = band(blshift(crc_l,8),0xff00)+band(brshift(crc_h,8),0x00ff)
  return crc
  --
end



-- 普通轮询状态
estat = 0 

function ctrl_bms(str)
  ld_uart.write(common.hexstobins(str..sformat("%04x",crc16_str(str))))
end


function progress_check()
  -- state 1 : 请求状态中，正在发送等待接收
  print("bms cmd timeout check.")
--  ld_tcp_heart.snd("BMS timeout check")
  print('ld_tcp_heart.t_bms_request_state'..ld_tcp_heart.t_bms_request_state)
  if ld_tcp_heart.t_bms_request_state == '2' then
    -- 没有BMS发送指令
--    t_bms_request_state = '0' -- 强行结束
    ld_tcp_heart.snd(ld_tcp_heart.t_device_ctrl_id..'repo'..'fail')
    print(ld_tcp_heart.t_device_ctrl_id..'repo'..'fail')
    print('send bms cmd timeout.'); --BMS不在线
--    ld_tcp_heart.snd('BMS send cmd timeout'); --BMS不在线
    -- 清除缓冲
    ld_tcp_heart.t_bms_request_rdbuf = ""
    ld_tcp_heart.t_bms_request_sndbuf = ""  
    ld_tcp_heart.t_device_ctrl_id = ""
    -- 回复内容
  elseif ld_tcp_heart.t_bms_request_state == '0' then
    -- 接收正常
--    t_bms_request_state = '0' -- 正常结束 
--    print('BMS发送指令超时');
  else 
    
  end 
  ld_tcp_heart.t_bms_request_state = '0' -- 正常结束 
  
end

local cmd_table = {}

-- 发送UART指令给BMS,分为定时发送和接收到请求指令的发送
local function emit()

  print("emit uart cmd to bms.")
  print("ld_tcp_heart.t_bms_request_state",ld_tcp_heart.t_bms_request_state)
  if ld_tcp_heart.t_bms_request_state == '1' and estat == 0 then
    -- 发送 等待 请求 状态中
    ctrl_bms(ld_tcp_heart.t_bms_request_sndbuf) -- 发送缓存指令
    ld_tcp_heart.t_bms_request_state = '2'
    
    print('progress check')
--    ld_tcp_heart.snd('progress check')
    
    -- 十秒钟没有反映 就 证明 未获得应答
    sys.timer_start(progress_check,10000) -- 检测是否可以已经处理 10s
  elseif ld_tcp_heart.t_bms_request_state == '2' then
    -- 已经发送
    -- print('wait ')
  elseif  ld_tcp_heart.t_bms_request_state == '0' or ld_tcp_heart.t_bms_request_state == '1' then
  --  print("emiting")
    -- 当前上报信息周期还未获得完整的数据信息
    if ld_tcp_heart.t_bms_success_symbol == false then
      if estat == 0 then 
        cmd_table = {
          ld_flash.readflash('LD_BMS_DATA_01'),
          ld_flash.readflash('LD_BMS_DATA_02'),
          ld_flash.readflash('LD_BMS_DATA_03'),
          ld_flash.readflash('LD_BMS_DATA_04'),
          ld_flash.readflash('LD_BMS_DATA_05'),
          ld_flash.readflash('LD_BMS_DATA_06'),
          ld_flash.readflash('LD_BMS_DATA_07'),
          ld_flash.readflash('LD_BMS_DATA_08'),
          ld_flash.readflash('LD_BMS_DATA_09'),
          ld_flash.readflash('LD_BMS_DATA_10')
        }
      end
      print('cmd_table',cmd_table)
      print('estat',estat,'cmd_table[1]',cmd_table[1])
      local cmd = cmd_table[estat+1]
      ld_uart.write(common.hexstobins(cmd))
      print('send estat ',estat,' cmd ',cmd)
      estat = estat + 1 -- 进入下一发送状态
      if estat == ld_flash.readflash('LD_BMS_DATA_NUM') then
        estat = 0
        ld_tcp_heart.t_bms_success_symbol = true -- 等待上报服务器
      end
    end
  end
end

if ld_flash.readflash("LD_BMS_REQUEST_NEED") == true then
  sys.timer_loop_start(emit,ld_flash.readflash("LD_BMS_REQUEST_TIME"))
else
end



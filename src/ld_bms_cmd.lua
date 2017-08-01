--[[
  ��������: BMS���Ʒ���ָ�����
  ����ʱ��: 2017-07-31 03:22
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



-- crc���Ƽ�����
local function crc_rshift_check(crc,str)

  --���� crc xor str
  crc = bxor(crc,strtonum(str))
  --[[
    ffff xor 0001 = fffe
  ]]

  -- ѭ������
  for i=1,8 do
    -- ��ȡ��λ �����
    local lbit = band(crc,1)
    crc = brshift(crc,1)
    if lbit==1 then
      crc = bxor(crc,0xa001)
    end
    --pcrc(crc)
  end
  return crc
end


-- crc16�ַ���������򷵻�crcУ����
local function crc16_str(str)
  -- ���ó�ʼCRC
  local crc = 0xffff
  -- ���������ַ����е�ʮ��������(��Ҫ��sub���) �������Ƽ��
  for i=1,string.len(str)/2 do
    -- ���Ƽ�� ������crc
    crc = crc_rshift_check(crc,string.sub(str,i*2-1,i*2))
  end
  -- ��crc�ߵ��ֽڵ���
  local crc_h,crc_l= band(crc,0xff00),band(crc,0x00ff)
  crc = band(blshift(crc_l,8),0xff00)+band(brshift(crc_h,8),0x00ff)
  return crc
  --
end



-- ��ͨ��ѯ״̬
estat = 0 

function ctrl_bms(str)
  ld_uart.write(common.hexstobins(str..sformat("%04x",crc16_str(str))))
end


function progress_check()
  -- state 1 : ����״̬�У����ڷ��͵ȴ�����
  print("bms cmd timeout check.")
--  ld_tcp_heart.snd("BMS timeout check")
  print('ld_tcp_heart.t_bms_request_state'..ld_tcp_heart.t_bms_request_state)
  if ld_tcp_heart.t_bms_request_state == '2' then
    -- û��BMS����ָ��
--    t_bms_request_state = '0' -- ǿ�н���
    ld_tcp_heart.snd(ld_tcp_heart.t_device_ctrl_id..'repo'..'fail')
    print(ld_tcp_heart.t_device_ctrl_id..'repo'..'fail')
    print('send bms cmd timeout.'); --BMS������
--    ld_tcp_heart.snd('BMS send cmd timeout'); --BMS������
    -- �������
    ld_tcp_heart.t_bms_request_rdbuf = ""
    ld_tcp_heart.t_bms_request_sndbuf = ""  
    ld_tcp_heart.t_device_ctrl_id = ""
    -- �ظ�����
  elseif ld_tcp_heart.t_bms_request_state == '0' then
    -- ��������
--    t_bms_request_state = '0' -- �������� 
--    print('BMS����ָ�ʱ');
  else 
    
  end 
  ld_tcp_heart.t_bms_request_state = '0' -- �������� 
  
end

local cmd_table = {}

-- ����UARTָ���BMS,��Ϊ��ʱ���ͺͽ��յ�����ָ��ķ���
local function emit()

  print("emit uart cmd to bms.")
  print("ld_tcp_heart.t_bms_request_state",ld_tcp_heart.t_bms_request_state)
  if ld_tcp_heart.t_bms_request_state == '1' and estat == 0 then
    -- ���� �ȴ� ���� ״̬��
    ctrl_bms(ld_tcp_heart.t_bms_request_sndbuf) -- ���ͻ���ָ��
    ld_tcp_heart.t_bms_request_state = '2'
    
    print('progress check')
--    ld_tcp_heart.snd('progress check')
    
    -- ʮ����û�з�ӳ �� ֤�� δ���Ӧ��
    sys.timer_start(progress_check,10000) -- ����Ƿ�����Ѿ����� 10s
  elseif ld_tcp_heart.t_bms_request_state == '2' then
    -- �Ѿ�����
    -- print('wait ')
  elseif  ld_tcp_heart.t_bms_request_state == '0' or ld_tcp_heart.t_bms_request_state == '1' then
  --  print("emiting")
    -- ��ǰ�ϱ���Ϣ���ڻ�δ���������������Ϣ
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
      estat = estat + 1 -- ������һ����״̬
      if estat == ld_flash.readflash('LD_BMS_DATA_NUM') then
        estat = 0
        ld_tcp_heart.t_bms_success_symbol = true -- �ȴ��ϱ�������
      end
    end
  end
end

if ld_flash.readflash("LD_BMS_REQUEST_NEED") == true then
  sys.timer_loop_start(emit,ld_flash.readflash("LD_BMS_REQUEST_TIME"))
else
end



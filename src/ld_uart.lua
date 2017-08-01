--[[
  ��������: ���ڴ������
  ����ʱ��: 2017-07-31 00:44
]]

module(...,package.seeall)

-- bms���ƴ������
require"ld_bms_cmd" 
require"common"




local function print(...)
  if APP_DEBUG then 
    _G.print('LD_UART:',...)
  end
end


local schar,slen,sfind,sbyte,ssub = string.char,string.len,string.find,string.byte,string.sub

--[[
��������
uart����֡�ṹ���ս�����Χ�豸������

֡�ṹ���£�
��ʼ��־��1�ֽڣ��̶�Ϊ0x01
���ݸ�����1�ֽڣ�У��������ݸ���֮������������ֽڸ���
ָ�1�ֽ�
����1��1�ֽ�
����2��1�ֽ�
����3��1�ֽ�
����4��1�ֽ�
У���룺���ݸ���������4���������
������־��1�ֽڣ��̶�Ϊ0xFE
]]


--����ID,1��Ӧuart1
--���Ҫ�޸�Ϊuart3����UART_ID��ֵΪ3����
local UART_ID = 3
--��ʼ��������־
local FRM_HEAD,FRM_TAIL = 0x01,0xFE
--ָ��
local CMD_01 = 0x01
--���ڶ��������ݻ�����
local rdbuf = ""



--[[
��������read
����  ����ȡ���ڽ��յ�������
����  ����
����ֵ����
]]

local function read_byte()
  local data = ""
  local tbyte = {}
  local str = ""
  --�ײ�core�У������յ�����ʱ��
  --������ջ�����Ϊ�գ�������жϷ�ʽ֪ͨLua�ű��յ��������ݣ�
  --������ջ�������Ϊ�գ��򲻻�֪ͨLua�ű�
  --����Lua�ű����յ��ж϶���������ʱ��ÿ�ζ�Ҫ�ѽ��ջ������е�����ȫ���������������ܱ�֤�ײ�core�е��������ж���������read�����е�while����оͱ�֤����һ��
  while true do   
    data = uart.read(UART_ID,"*l",0)
    if not data or string.len(data) == 0 then break end
    --������Ĵ�ӡ���ʱ
--    print("read",common.binstohexs(data)) --string
    
--    ��ͨ�ַ���
    str = str..data
    
--    common.binstohexs 16���ƽ��� �ַ�����ʽ����
--    write(common.binstohexs(str))
    
--    _G.print("recv",common.binstohexs(str))
--    ld_tcp_heart.snd("recv"..common.binstohexs(str),"LOCRPT")
    
  end
  
   -- print("recv",common.binstohexs(str))
  
  -- ��BMS���� ��������
  if ld_tcp_heart.t_bms_request_state == '2' then
    ld_tcp_heart.t_bms_request_rdbuf = common.binstohexs(str)
    ld_tcp_heart.t_bms_request_state = '0' -- ����������
    print('bms request success',common.binstohexs(str))
    ld_tcp_heart.snd(ld_tcp_heart.t_device_ctrl_id..'repo'..ld_tcp_heart.t_bms_request_rdbuf)
    print(ld_tcp_heart.t_device_ctrl_id..'repo'..ld_tcp_heart.t_bms_request_rdbuf)
    -- �������
    ld_tcp_heart.t_bms_request_rdbuf = ""
    ld_tcp_heart.t_bms_request_sndbuf = ""
    ld_tcp_heart.t_device_ctrl_id = ""
    
  -- ��������������Ѿ���� �����Խ�bms״̬
  else
      ld_tcp_heart.t_rbuf_table[ld_bms_cmd.estat] = common.binstohexs(str)
      print('recv normal bms info',common.binstohexs(str)) 
  end
  
  -- 1 ���� 
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
��������write
����  ��ͨ�����ڷ�������
����  ��
    s��Ҫ���͵�����
����ֵ����
]]
function write(s)
  print("write",s)
  uart.write(UART_ID,s)
end

--����ϵͳ���ڻ���״̬���˴�ֻ��Ϊ�˲�����Ҫ�����Դ�ģ��û�еط�����pm.sleep("test")���ߣ��������͹�������״̬
--�ڿ�����Ҫ�󹦺ĵ͡�����Ŀʱ��һ��Ҫ��취��֤pm.wake("test")���ڲ���Ҫ����ʱ����pm.sleep("test")
--pm.wake("test")
--ע�ᴮ�ڵ����ݽ��պ����������յ����ݺ󣬻����жϷ�ʽ������read�ӿڶ�ȡ����
sys.reguart(UART_ID,read_byte)
--���ò��Ҵ򿪴���
uart.setup(UART_ID,9600,8,uart.PAR_NONE,uart.STOP_1)



-- 16����д
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

-- ascii����д �ַ���
--function t()
--  print("tx flag",tx_flag)
--  write("01031770005ac19e")
--end

--sys.timer_loop_start(t,1000*60)

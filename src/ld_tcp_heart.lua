--[[
  ��������: TCP����������,
  					����������Ϣ,�Ͷ�ʱ��������ϱ�����,
						������TCP���յ�������ָ��ʱ������Ӧ�Ĵ���
  ����ʱ��: 2017-07-31 04:33
]]

module(...,package.seeall)

-- socket���ܿ�
require"socket"

-- ����ܿ� ���ڻ�ȡ�豸imei��sn���
require"misc"


-- flash��д�����ļ�
local ld_flash = require"ld_flash"

-- string�ַ���ƥ��
local smatch = string.match



-- ��ȡ��������
t_lng = ""--g_lng
t_lat = ""--g_lat
t_gps_status = "0"--g_gps_status
t_rbuf_01 = ""
t_rbuf_02 = ""
t_rbuf_03 = ""
t_rbuf_04 = ""
t_rbuf_05 = ""
t_rbuf_06 = ""
t_rbuf_07 = ""
t_rbuf_08 = ""
t_rbuf_09 = ""
t_rbuf_10 = ""
t_rbuf_table = {'','','','','','','','','',''}


-- BMS�������� 
-- '0' ������
-- '1' ������ ������
-- '2' ���� ������
t_bms_request_state = '0' -- ������  

t_bms_request_sndbuf = "" -- ����buf
t_bms_request_rdbuf = "" -- ����buf
t_device_ctrl_id = ""

t_reset_symbol = true -- ������־


-- ��Ϣ��ȡ�ɹ���־λ
t_gps_success_symbol = false
t_bms_success_symbol = false


local t_temp_id,t_temp_sndbuf = "","" -- ����id ���� sndbuf




--[[
��������
1����������׼�����������Ӻ�̨
2�����ӳɹ���ÿ��10���ӷ���һ��������"heart data\r\n"����̨��ÿ��20���ӷ���һ��λ�ð�"loc data\r\n"����̨
3�����̨���ֳ����ӣ��Ͽ���������ȥ���������ӳɹ���Ȼ���յ�2����������
4���յ���̨������ʱ����rcv�����д�ӡ����
����ʱ���Լ��ķ������������޸������PROT��ADDR��PORT��֧��������IP��ַ

������Ϊ�����ӣ�ֻҪ��������ܹ���⵽�������쳣�������Զ�ȥ��������
]]

-- local ssub,schar,smatch,sbyte,slen = string.sub,string.char,string.match,string.byte,string.len
--����ʱ���Լ��ķ�����
--local SCK_IDX,PROT,ADDR,PORT = 1,"TCP","47.90.92.56",63101
local SCK_IDX,PROT,ADDR,PORT = 1,"TCP","47.93.33.171",63101 -- aliyun java
--local SCK_IDX,PROT,ADDR,PORT = 1,"TCP",ld_flash.readflash('LD_SERVER_IP'),ld_flash.readflash('LD_SERVER_PORT')
--linksta:���̨��socket����״̬
local linksta
--һ�����������ڵĶ�����������Ӻ�̨ʧ�ܣ��᳢���������������ΪRECONN_PERIOD�룬�������RECONN_MAX_CNT��
--���һ�����������ڶ�û�����ӳɹ�����ȴ�RECONN_CYCLE_PERIOD������·���һ����������
--�������RECONN_CYCLE_MAX_CNT�ε��������ڶ�û�����ӳɹ������������
local RECONN_MAX_CNT,RECONN_PERIOD,RECONN_CYCLE_MAX_CNT,RECONN_CYCLE_PERIOD = 3,5,3,20
--reconncnt:��ǰ���������ڣ��Ѿ������Ĵ���
--reconncyclecnt:�������ٸ��������ڣ���û�����ӳɹ�
--һ�����ӳɹ������Ḵλ���������
--conning:�Ƿ��ڳ�������
local reconncnt,reconncyclecnt,conning = 0,0

--[[
��������print
����  ����ӡ�ӿڣ����ļ��е����д�ӡ�������testǰ׺
����  ����
����ֵ����
]]
local function print(...)
	if APP_DEBUG then
		_G.print("LD_TCP_HEAET:",...)
	end
end

--[[
��������snd
����  �����÷��ͽӿڷ�������
����  ��
        data�����͵����ݣ��ڷ��ͽ���¼�������ntfy�У��ḳֵ��item.data��
		para�����͵Ĳ������ڷ��ͽ���¼�������ntfy�У��ḳֵ��item.para�� 
����ֵ�����÷��ͽӿڵĽ�������������ݷ����Ƿ�ɹ��Ľ�������ݷ����Ƿ�ɹ��Ľ����ntfy�е�SEND�¼���֪ͨ����trueΪ�ɹ�������Ϊʧ��
]]
function snd(data,para)
	return socket.send(SCK_IDX,data,para)
end


-- �������
local function clearbuf()
  
  t_lng = ""--g_lng
  t_lat = ""--g_lat
  t_gps_status = "0"--g_gps_status
  t_rbuf_01 = ""
  t_rbuf_02 = ""
  t_rbuf_03 = ""
  t_rbuf_04 = ""
  t_rbuf_05 = ""
  t_rbuf_06 = ""
  t_rbuf_07 = ""
  t_rbuf_08 = ""
  t_rbuf_09 = ""
  t_rbuf_10 = ""
  t_rbuf_table = {'','','','','','','','','',''} -- 10data
  t_gps_success_symbol = false
	t_bms_success_symbol = false

end


--[[
��������locrpt
����  ������λ�ð����ݵ���̨
����  ����
����ֵ����
]]
function locrpt()  
	print("locrpt",linksta)
	if linksta and t_reset_symbol == false then
		-- ��ȡBMS����
		t_rbuf_01	= t_rbuf_table[1]
		t_rbuf_02	= t_rbuf_table[2]
		t_rbuf_03	= t_rbuf_table[3]
		t_rbuf_04	= t_rbuf_table[4]
		t_rbuf_05	= t_rbuf_table[5]
		t_rbuf_06	= t_rbuf_table[6]
		t_rbuf_07	= t_rbuf_table[7]
		t_rbuf_08	= t_rbuf_table[8]
		t_rbuf_09	= t_rbuf_table[9]
		t_rbuf_10	= t_rbuf_table[10]

	  -- ���ϱ���������Ϣ����
    local send_data = "dev:"..misc.getimei()..";"	    
    send_data = send_data.."gps:"..t_gps_status..","..t_lng..","..t_lat..";"
    send_data = send_data.."data1:"..t_rbuf_01..";"
    send_data = send_data.."data2:"..t_rbuf_02..";"
    send_data = send_data.."data3:"..t_rbuf_03..";"
    send_data = send_data.."data4:"..t_rbuf_04..";"
    send_data = send_data.."data5:"..t_rbuf_05..";"
    send_data = send_data.."data6:"..t_rbuf_06..";"
    send_data = send_data.."data7:"..t_rbuf_07..";"
    send_data = send_data.."data8:"..t_rbuf_08..";"
    send_data = send_data.."data9:"..t_rbuf_09..";"
    send_data = send_data.."data10:"..t_rbuf_10..";"
    -- ���Ͳ����÷��ͻص�����
    snd(send_data,"LOCRPT")
    
    -- ����ϱ���Ϣ���� ����һ�η���
    clearbuf()

    sys.dispatch('REQUEST_GPS') -- ����GPS��Ϣ�ַ�
	else
	 t_reset_symbol = false
	end
end


--[[
��������locrptcb
����  ��λ�ð����ͻص���������ʱ����20���Ӻ��ٴη���λ�ð�
����  ��		
		item��table���ͣ�{data=,para=}����Ϣ�ش��Ĳ��������ݣ��������socket.sendʱ����ĵ�2���͵�3�������ֱ�Ϊdat��par����item={data=dat,para=par}
		result�� bool���ͣ����ͽ����trueΪ�ɹ�������Ϊʧ��
����ֵ����
]]
function locrptcb(item,result)
	print("locrptcb",linksta)
	if linksta then
		sys.timer_start(locrpt,ld_flash.readflash("LD_TCP_REPO_TIME"))
	end
end



-- �ϱ��豸������Ϣ
function reset_repo()
	-- ������Ϣ����
  local send_data = "rsdev:"..misc.getimei()..";"
  send_data = send_data.."tip:"..ld_flash.readflash('LD_SERVER_IP')..";"
  send_data = send_data.."tport:"..ld_flash.readflash('LD_SERVER_PORT')..";"
  send_data = send_data.."key:"..ld_flash.readflash('LD_LBS_PRODUCT_KEY')..";"
  send_data = send_data.."heart_t:"..ld_flash.readflash('LD_TCP_HEART_TIME')..";"
  send_data = send_data.."repo_t:"..ld_flash.readflash('LD_TCP_REPO_TIME')..";"
  send_data = send_data.."bms_t:"..ld_flash.readflash('LD_BMS_REQUEST_TIME')..";"
  send_data = send_data.."gps_t:"..ld_flash.readflash('LD_GPS_REQUEST_TIME')..";"
  if ld_flash.readflash('LD_GPS_REQUEST_NEED') == true then
    send_data = send_data.."gps:1;"  
  else
    send_data = send_data.."gps:0;"
  end
  if ld_flash.readflash('LD_BMS_REQUEST_NEED') == true then
    send_data = send_data.."bms:1;"  
  else
    send_data = send_data.."bms:0;"
  end
	
	-- �����豸������Ϣ  
  snd(send_data,"HEARTRPT") -- �������д���
end



--[[
��������heartrpt
����  ���������������ݵ���̨
����  ����
����ֵ����
]]
function heartrpt()
	print("heartrpt",linksta)
	if linksta then
	  if t_reset_symbol == true then
		  reset_repo()
		  print('This device is rebooted just now.')
		  
		else
		  snd("ld"..misc.getimei(),"HEARTRPT")
		end
				
	end
end

--[[
��������locrptcb
����  �����������ͻص���������ʱ����10���Ӻ��ٴη���������
����  ��		
		item��table���ͣ�{data=,para=}����Ϣ�ش��Ĳ��������ݣ��������socket.sendʱ����ĵ�2���͵�3�������ֱ�Ϊdat��par����item={data=dat,para=par}
		result�� bool���ͣ����ͽ����trueΪ�ɹ�������Ϊʧ��
����ֵ����
]]
function heartrptcb(item,result)
	print("heartrptcb",linksta)
	if linksta then
		sys.timer_start(heartrpt,ld_flash.readflash("LD_TCP_HEART_TIME"))
	end
end


--[[
��������sndcb
����  �����ݷ��ͽ������
����  ��          
		item��table���ͣ�{data=,para=}����Ϣ�ش��Ĳ��������ݣ��������socket.sendʱ����ĵ�2���͵�3�������ֱ�Ϊdat��par����item={data=dat,para=par}
		result�� bool���ͣ����ͽ����trueΪ�ɹ�������Ϊʧ��
����ֵ����
]]
local function sndcb(item,result)
	print("sndcb",item.para,result)
	if not item.para then return end
	if item.para=="LOCRPT" then
		locrptcb(item,result)
	elseif item.para=="HEARTRPT" then
		heartrptcb(item,result)
	end
end


--[[
��������reconn
����  ��������̨����
        һ�����������ڵĶ�����������Ӻ�̨ʧ�ܣ��᳢���������������ΪRECONN_PERIOD�룬�������RECONN_MAX_CNT��
        ���һ�����������ڶ�û�����ӳɹ�����ȴ�RECONN_CYCLE_PERIOD������·���һ����������
        �������RECONN_CYCLE_MAX_CNT�ε��������ڶ�û�����ӳɹ������������
����  ����
����ֵ����
]]
local function reconn()
	print("reconn",reconncnt,conning,reconncyclecnt)
	--conning��ʾ���ڳ������Ӻ�̨��һ��Ҫ�жϴ˱����������п��ܷ��𲻱�Ҫ������������reconncnt���ӣ�ʵ�ʵ�������������
	if conning then return end
	--һ�����������ڵ�����
	if reconncnt < RECONN_MAX_CNT then		
		reconncnt = reconncnt+1
		link.shut()
		connect()
	--һ���������ڵ�������ʧ��
	else
		reconncnt,reconncyclecnt = 0,reconncyclecnt+1
		if reconncyclecnt >= RECONN_CYCLE_MAX_CNT then
			sys.restart("connect fail")
		end
		sys.timer_start(reconn,RECONN_CYCLE_PERIOD*1000)
	end
end

--[[
��������ntfy
����  ��socket״̬�Ĵ�����
����  ��
        idx��number���ͣ�socket.lua��ά����socket idx��������socket.connectʱ����ĵ�һ��������ͬ��������Ժ��Բ�����
        evt��string���ͣ���Ϣ�¼�����
		result�� bool���ͣ���Ϣ�¼������trueΪ�ɹ�������Ϊʧ��
		item��table���ͣ�{data=,para=}����Ϣ�ش��Ĳ��������ݣ�Ŀǰֻ����SEND���͵��¼����õ��˴˲������������socket.sendʱ����ĵ�2���͵�3�������ֱ�Ϊdat��par����item={data=dat,para=par}
����ֵ����
]]
function ntfy(idx,evt,result,item)
	print("ntfy",evt,result,item)
	--���ӽ��������socket.connect����첽�¼���
	if evt == "CONNECT" then
		conning = false
		--���ӳɹ�
		if result then
			reconncnt,reconncyclecnt,linksta = 0,0,true
			--ֹͣ������ʱ��
			sys.timer_stop(reconn)
			--��������������̨
			heartrpt()
			--����λ�ð�����̨
			locrpt()
		--����ʧ��
		else
			--RECONN_PERIOD�������
			sys.timer_start(reconn,RECONN_PERIOD*1000)
		end	
	--���ݷ��ͽ��������socket.send����첽�¼���
	elseif evt == "SEND" then
		if item then
			sndcb(item,result)
		end
		--����ʧ�ܣ�RECONN_PERIOD���������̨����Ҫ����reconn����ʱsocket״̬��Ȼ��CONNECTED���ᵼ��һֱ�����Ϸ�����
		--if not result then sys.timer_start(reconn,RECONN_PERIOD*1000) end
		if not result then link.shut() end
	--���ӱ����Ͽ�
	elseif evt == "STATE" and result == "CLOSED" then
		linksta = false
		sys.timer_stop(heartrpt)
		sys.timer_stop(locrpt)
		reconn()
	--���������Ͽ�������link.shut����첽�¼���
	elseif evt == "STATE" and result == "SHUTED" then
		linksta = false
		sys.timer_stop(heartrpt)
		sys.timer_stop(locrpt)
		reconn()
	--���������Ͽ�������socket.disconnect����첽�¼���
	elseif evt == "DISCONNECT" then
		linksta = false
		sys.timer_stop(heartrpt)
		sys.timer_stop(locrpt)
		reconn()		
	end
	--�����������Ͽ�������·����������
	if smatch((type(result)=="string") and result or "","ERROR") then
		--RECONN_PERIOD�����������Ҫ����reconn����ʱsocket״̬��Ȼ��CONNECTED���ᵼ��һֱ�����Ϸ�����
		--sys.timer_start(reconn,RECONN_PERIOD*1000)
		link.shut()
	end
end



-- �ȴ��������������
function wait_send()
  if t_bms_request_state == '0' then
    t_bms_request_state = '1'
    t_device_ctrl_id = t_temp_id
    t_bms_request_sndbuf = t_temp_sndbuf
  else
    sys.timer_start(wait_send,1000)
  end
  print('Waiting uart release')
end


--[[
��������rcv
����  ��socket�������ݵĴ�����
����  ��
        idx ��socket.lua��ά����socket idx��������socket.connectʱ����ĵ�һ��������ͬ��������Ժ��Բ�����
        data�����յ�������
����ֵ����
]]
function rcv(idx,data)
	print("receive tcp message",data)
	

	if(smatch(data,"^%d+BMS[0-9ABCDEF]+$")) then
	 -- BMS ����
	 t_temp_id,t_temp_sndbuf = smatch(data,"(%d+)BMS([0-9ABCDEF]+)")
	 print("t_device_ctrl_id"..t_device_ctrl_id,t_bms_request_sndbuf)
	 print("t_bms_request_state"..t_bms_request_state)
	 if t_bms_request_state == '0' then
	   t_bms_request_state = '1'
	   t_device_ctrl_id = t_temp_id
	   t_bms_request_sndbuf = t_temp_sndbuf
	   print("send uart command")
	 else
	   sys.timer_start(wait_send,1000) -- �ȴ���BMS�������ڴ����� ������ʱ��1s
	   print("waiting uart progress")
	 end
	 
	elseif (smatch(data,"^%d+PAR%S+IS%S+$")) then
	 -- �������� 
	 local id,para,val = smatch(data,"^(%d+)PAR(%S+)IS(%S+)$")
	 print('para cmd,',id,para,val)
	 if para == 'tip' then
	 	para = 'LD_SERVER_IP'
	 	-- reconn() -- ����������
	 elseif para == 'tport' then
	 	para = 'LD_SERVER_PORT'
	 	-- reconn() -- ����������
	 elseif para == 'key' then
	  para = 'LD_LBS_PRODUCT_KEY'
	 elseif para == 'heart_t' then
	 	para = 'LD_TCP_HEART_TIME'
	 elseif para == 'repo_t' then
	 	para = 'LD_TCP_REPO_TIME'
	 elseif para == 'bms_t' then
	 	para = 'LD_BMS_REQUEST_TIME'
	 elseif para == 'gps_t' then
	 	para = 'LD_GPS_REQUEST_TIME'	
	 elseif para == 'gps' then
	 	para = 'LD_GPS_REQUEST_NEED'	
	 elseif para == 'bms' then
	 	para = 'LD_BMS_REQUEST_NEED'	
	 else
	 end
	 local result = ld_flash.writeflash(para,val)
	 if result then
	 	snd(id..'repo success')
	 else 
	 	snd(id..'repo fail')
	 end

	elseif (smatch(data,"^%d+PARREAD%S+$")) then
		local id,para = smatch(data,"^(%d+)PARREAD(%S+$)")
		if para == 'tip' then
			para = 'LD_SERVER_IP'
		-- reconn() -- ����������
		elseif para == 'tport' then
			para = 'LD_SERVER_PORT'
		-- reconn() -- ����������
		elseif para == 'key' then
		  para = 'LD_LBS_PRODUCT_KEY'
		elseif para == 'heart_t' then
			para = 'LD_TCP_HEART_TIME'
		elseif para == 'repo_t' then
			para = 'LD_TCP_REPO_TIME'
		elseif para == 'bms_t' then
			para = 'LD_BMS_REQUEST_TIME'
		elseif para == 'gps_t' then
			para = 'LD_GPS_REQUEST_TIME'	
		elseif para == 'gps' then
			para = 'LD_GPS_REQUEST_NEED'	
		elseif para == 'bms' then
			para = 'LD_BMS_REQUEST_NEED'	
		else
		end
		local val = ld_flash.readflash(para)
		snd(id..'repo'..para..'is'..val)
	end

end

--[[
��������connect
����  ����������̨�����������ӣ�
        ������������Ѿ�׼���ã���������Ӻ�̨��������������ᱻ���𣬵���������׼���������Զ�ȥ���Ӻ�̨
		ntfy��socket״̬�Ĵ�����
		rcv��socket�������ݵĴ�����
����  ����
����ֵ����
]]
function connect()
	socket.connect(SCK_IDX,PROT,ADDR,PORT,ntfy,rcv)
	conning = true
end

-- �豸��ʼ��
local function deviceInit()
	connect() -- TCP����
	sys.dispatch('REQUEST_GPS') -- ����GPS��Ϣ�ַ�
end


-- �ϵ�30s���豸��ʼ��
sys.timer_start(deviceInit,30*1000)

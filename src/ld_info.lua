--[[
	��������: ϵͳ��������,�����flash������������޸�
	����ʱ��: 2017-07-31 00:05
]]

module(...)

-- ��ʱ��λ-��- ����1000ms
local sec = 1000

-- ��ʱ��λ-��- ����60s
local min = 60*sec

-- ��������ַ
LD_SERVER_IP = "47.93.33.171"
-- �������������ö˿�
LD_SERVER_PORT = 63101

LD_LBS_PRODUCT_KEY = "WlhKN4JunVtzNXJxcqdIjd42Tboib30c"

-- �Ƿ���Ҫд��Flash
LD_FLASH_NEED = true

-- TCP����������ʱ��
LD_TCP_HEART_TIME = 5*sec -- 5s

-- TCP�������ϱ���Ϣʱ��
LD_TCP_REPO_TIME = 3*min -- 3min

-- BMS�����ȡ��Ϣָ�����
LD_BMS_DATA_NUM = 6

-- BMS�����ȡ��Ϣָ��
LD_BMS_DATA_01 = "01030000003C45DB"
LD_BMS_DATA_02 = "01030190002AC5C4"
LD_BMS_DATA_03 = "0103012C001485F0"
LD_BMS_DATA_04 = "01031770005AC19E"
LD_BMS_DATA_05 = "010317CA0014604F"
LD_BMS_DATA_06 = "0103138800438095"
LD_BMS_DATA_07 = ""
LD_BMS_DATA_08 = ""
LD_BMS_DATA_09 = ""
LD_BMS_DATA_10 = ""

-- LD_BMS_DATA_TABLE = {
-- 	LD_BMS_DATA_01,
-- 	LD_BMS_DATA_02,
-- 	LD_BMS_DATA_03,
-- 	LD_BMS_DATA_04,
-- 	LD_BMS_DATA_05,
-- 	LD_BMS_DATA_06,
-- 	LD_BMS_DATA_07,
-- 	LD_BMS_DATA_08,
-- 	LD_BMS_DATA_09,
-- 	LD_BMS_DATA_10
-- }

-- BMS��Ϣ��ȡʱ��
-- 5*10 = 50s 
LD_BMS_REQUEST_TIME = 5*sec --5s

--gps����ʱ��
LD_GPS_REQUEST_TIME = 30*sec--30s

-- sys.dispatch(GPS_REQUEST)

-- �Ƿ���Ҫ��λ����
LD_GPS_REQUEST_NEED = true

-- �Ƿ���ҪBMSͨѶ
LD_BMS_REQUEST_NEED = true


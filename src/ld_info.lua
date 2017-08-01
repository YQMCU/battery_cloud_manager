--[[
	功能描述: 系统参数设置,可配合flash操作程序进行修改
	更新时间: 2017-07-31 00:05
]]

module(...)

-- 计时单位-秒- 等于1000ms
local sec = 1000

-- 计时单位-分- 等于60s
local min = 60*sec

-- 服务器地址
LD_SERVER_IP = "47.93.33.171"
-- 服务器程序设置端口
LD_SERVER_PORT = 63101

LD_LBS_PRODUCT_KEY = "WlhKN4JunVtzNXJxcqdIjd42Tboib30c"

-- 是否需要写入Flash
LD_FLASH_NEED = true

-- TCP长链接心跳时间
LD_TCP_HEART_TIME = 5*sec -- 5s

-- TCP长链接上报信息时间
LD_TCP_REPO_TIME = 3*min -- 3min

-- BMS常规获取信息指令个数
LD_BMS_DATA_NUM = 6

-- BMS常规获取信息指令
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

-- BMS信息读取时间
-- 5*10 = 50s 
LD_BMS_REQUEST_TIME = 5*sec --5s

--gps请求时间
LD_GPS_REQUEST_TIME = 30*sec--30s

-- sys.dispatch(GPS_REQUEST)

-- 是否需要定位功能
LD_GPS_REQUEST_NEED = true

-- 是否需要BMS通讯
LD_BMS_REQUEST_NEED = true


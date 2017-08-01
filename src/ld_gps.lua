--[[
  功能描述: 系统定位功能和请求GPS消息处理及回调函数
  更新时间: 2017-07-31 02:20
]]

module(...,package.seeall)

-- flash操作功能文件
local ld_flash = require("ld_flash")


require"agps"
require"gps"


-- gps.open(gps.DEFAULT,{cause="ld_gps"})

-- 例如gps.open(gps.TIMERORSUC,{cause="TEST",val=120,cb=testgpscb})
-- gps.TIMERORSUC为GPS工作模式，"TEST"为“GPS应用”标记，120秒为GPS开启最大时长，testgpscb为回调函数

local smatch = string.match


--[[
函数名：print
功能  ：打印接口，此文件中的所有打印都会加上linkair前缀
参数  ：无
返回值：无
]]
local function print(...)
  if APP_DEBUG then 
    _G.print("LD_GPS:",...)
  end
end



local function gpsCallback()
  -- GPS定位成功
  if gps.isfix() == true then 
    local t = {}
    t.lng,t.lat = smatch(gps.getgpslocation(),"[EW]*,(%d+%.%d+),[NS]*,(%d+%.%d+)")
    t.lng,t.lat = t.lng or "",t.lat or ""
    ld_tcp_heart.t_lat = t.lat
    ld_tcp_heart.t_lng = t.lng
    print('GPS is OK.',t.lat,t.lng)
    ld_tcp_heart.t_gps_status = "1"
    ld_tcp_heart.t_gps_success_symbol = true
  else
    -- 请求基站定位
    -- require"ld_lbs"
    print('GPS is fail.')
    ld_tcp_heart.t_gps_status = "0"
    sys.dispatch('REQUEST_LBS')
  end
end

local function requestGps()
  -- 需要定位功能
  if ld_flash.readflash("LD_GPS_REQUEST_NEED") == true and ld_tcp_heart.t_gps_success_symbol == false then
    -- getloc() -- 执行请求
    -- 判断gps请求应用未打开  打开gps 并等待 120s 做出响应
--    print('gps.isactive(gps.TIMERORSUC,{cause="ld_gps",val=120,cb=gpsCallback})',gps.isactive(gps.TIMERORSUC,{cause="ld_gps",val=120,cb=gpsCallback}))
--    if gps.isactive(gps.TIMERORSUC,{cause="ld_gps",val=120,cb=gpsCallback}) == false then
--      print("gps app is not active.")
    gps.open(gps.TIMERORSUC,{cause="ld_gps",val=120,cb=gpsCallback})
--    else
--    end 
  else
  end
end

-- gps初始化
gps.init()

-- 注册GPS请求程序
sys.regapp(requestGps,'REQUEST_GPS')

-- if ld_flash.readflash("LD_GPS_REQUEST_NEED") == true then
--   sys.timer_loop_start(getloc,ld_flash.readflash("LD_GPS_REQUEST_TIME"))
-- else
-- end

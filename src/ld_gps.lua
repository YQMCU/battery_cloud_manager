--[[
  ��������: ϵͳ��λ���ܺ�����GPS��Ϣ�����ص�����
  ����ʱ��: 2017-07-31 02:20
]]

module(...,package.seeall)

-- flash���������ļ�
local ld_flash = require("ld_flash")


require"agps"
require"gps"


-- gps.open(gps.DEFAULT,{cause="ld_gps"})

-- ����gps.open(gps.TIMERORSUC,{cause="TEST",val=120,cb=testgpscb})
-- gps.TIMERORSUCΪGPS����ģʽ��"TEST"Ϊ��GPSӦ�á���ǣ�120��ΪGPS�������ʱ����testgpscbΪ�ص�����

local smatch = string.match


--[[
��������print
����  ����ӡ�ӿڣ����ļ��е����д�ӡ�������linkairǰ׺
����  ����
����ֵ����
]]
local function print(...)
  if APP_DEBUG then 
    _G.print("LD_GPS:",...)
  end
end



local function gpsCallback()
  -- GPS��λ�ɹ�
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
    -- �����վ��λ
    -- require"ld_lbs"
    print('GPS is fail.')
    ld_tcp_heart.t_gps_status = "0"
    sys.dispatch('REQUEST_LBS')
  end
end

local function requestGps()
  -- ��Ҫ��λ����
  if ld_flash.readflash("LD_GPS_REQUEST_NEED") == true and ld_tcp_heart.t_gps_success_symbol == false then
    -- getloc() -- ִ������
    -- �ж�gps����Ӧ��δ��  ��gps ���ȴ� 120s ������Ӧ
--    print('gps.isactive(gps.TIMERORSUC,{cause="ld_gps",val=120,cb=gpsCallback})',gps.isactive(gps.TIMERORSUC,{cause="ld_gps",val=120,cb=gpsCallback}))
--    if gps.isactive(gps.TIMERORSUC,{cause="ld_gps",val=120,cb=gpsCallback}) == false then
--      print("gps app is not active.")
    gps.open(gps.TIMERORSUC,{cause="ld_gps",val=120,cb=gpsCallback})
--    else
--    end 
  else
  end
end

-- gps��ʼ��
gps.init()

-- ע��GPS�������
sys.regapp(requestGps,'REQUEST_GPS')

-- if ld_flash.readflash("LD_GPS_REQUEST_NEED") == true then
--   sys.timer_loop_start(getloc,ld_flash.readflash("LD_GPS_REQUEST_TIME"))
-- else
-- end

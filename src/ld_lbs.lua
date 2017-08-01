--[[
  功能描述: 请求LBS基站定位消息处理
  更新时间: 2017-07-31 02:20
]]

module(...,package.seeall)



-- 基站定位库文件
require"lbsloc"

--是否查询GPS位置字符串信息
local qryaddr

--[[
函数名：print
功能  ：打印接口，此文件中的所有打印都会加上test前缀
参数  ：无
返回值：无
]]
local function print(...)
  if APP_DEBUG then
    _G.print("LD_LBS:",...)
  end
end

--[[
函数名：qrygps
功能  ：查询GPS位置请求
参数  ：无
返回值：无
]]
function qrygps()
  qryaddr = not qryaddr
  lbsloc.request(getgps,qryaddr)
end

--[[
函数名：getgps
功能  ：获取经纬度后的回调函数
参数  ：
    result：number类型，获取结果，0表示成功，其余表示失败。此结果为0时下面的5个参数才有意义
    lat：string类型，纬度，整数部分3位，小数部分7位，例如031.2425864
    lng：string类型，经度，整数部分3位，小数部分7位，例如121.4736522
    addr：string类型，GB2312编码的位置字符串。调用lbsloc.request查询经纬度，传入的第二个参数为true时，才返回本参数
    latdm：string类型，纬度，度分格式，整数部分5位，小数部分6位，dddmm.mmmmmm，例如03114.555184
    lngdm：string类型，纬度，度分格式，整数部分5位，小数部分6位，dddmm.mmmmmm，例如12128.419132
返回值：无
]]
function getgps(result,lat,lng,addr,latdm,lngdm)
  --获取经纬度成功
  if result==0 then
    ld_tcp_heart.t_lat = lat
    ld_tcp_heart.t_lng = lng
    print("LBS is OK:",lat,lng)
  --失败
  else
    print('LBS is fail.')
    ld_tcp_heart.t_lat = 'fail'
    ld_tcp_heart.t_lng = 'fail'
  end
  ld_tcp_heart.t_gps_success_symbol = true
end

sys.regapp(qrygps,'REQUEST_LBS')
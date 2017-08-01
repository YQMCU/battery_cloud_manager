--[[
  ��������: ����LBS��վ��λ��Ϣ����
  ����ʱ��: 2017-07-31 02:20
]]

module(...,package.seeall)



-- ��վ��λ���ļ�
require"lbsloc"

--�Ƿ��ѯGPSλ���ַ�����Ϣ
local qryaddr

--[[
��������print
����  ����ӡ�ӿڣ����ļ��е����д�ӡ�������testǰ׺
����  ����
����ֵ����
]]
local function print(...)
  if APP_DEBUG then
    _G.print("LD_LBS:",...)
  end
end

--[[
��������qrygps
����  ����ѯGPSλ������
����  ����
����ֵ����
]]
function qrygps()
  qryaddr = not qryaddr
  lbsloc.request(getgps,qryaddr)
end

--[[
��������getgps
����  ����ȡ��γ�Ⱥ�Ļص�����
����  ��
    result��number���ͣ���ȡ�����0��ʾ�ɹ��������ʾʧ�ܡ��˽��Ϊ0ʱ�����5��������������
    lat��string���ͣ�γ�ȣ���������3λ��С������7λ������031.2425864
    lng��string���ͣ����ȣ���������3λ��С������7λ������121.4736522
    addr��string���ͣ�GB2312�����λ���ַ���������lbsloc.request��ѯ��γ�ȣ�����ĵڶ�������Ϊtrueʱ���ŷ��ر�����
    latdm��string���ͣ�γ�ȣ��ȷָ�ʽ����������5λ��С������6λ��dddmm.mmmmmm������03114.555184
    lngdm��string���ͣ�γ�ȣ��ȷָ�ʽ����������5λ��С������6λ��dddmm.mmmmmm������12128.419132
����ֵ����
]]
function getgps(result,lat,lng,addr,latdm,lngdm)
  --��ȡ��γ�ȳɹ�
  if result==0 then
    ld_tcp_heart.t_lat = lat
    ld_tcp_heart.t_lng = lng
    print("LBS is OK:",lat,lng)
  --ʧ��
  else
    print('LBS is fail.')
    ld_tcp_heart.t_lat = 'fail'
    ld_tcp_heart.t_lng = 'fail'
  end
  ld_tcp_heart.t_gps_success_symbol = true
end

sys.regapp(qrygps,'REQUEST_LBS')
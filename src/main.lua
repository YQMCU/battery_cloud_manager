--���������λ�ö���PROJECT��VERSION����
--PROJECT��ascii string���ͣ�������㶨�壬ֻҪ��ʹ��,����
--VERSION��ascii string���ͣ����ʹ��Luat������ƽ̨�̼������Ĺ��ܣ����밴��"X.X.X"���壬X��ʾ1λ���֣��������㶨��
PROJECT = "LD_Battery_Manager_Cloud"
VERSION = "2.0.0"
require"sys"

--[[
���ʹ��UART���trace��������ע�͵Ĵ���"--sys.opntrace(true,1)"���ɣ���2������1��ʾUART1���trace�������Լ�����Ҫ�޸��������
�����������������trace�ڵĵط�������д��������Ա�֤UART�ھ����ܵ�����������ͳ��ֵĴ�����Ϣ��
���д�ں��������λ�ã����п����޷����������Ϣ���Ӷ����ӵ����Ѷ�
]]
 sys.opntrace(true,1)


APP_DEBUG = true -- ���Խӿ�


-- ϵͳ������flash��Ϣ����
require"ld_flash"

-- �����վ��λ��KEY
--PRODUCT_KEY = ld_flash.readflash('LD_LBS_PRODUCT_KEY')-- "WlhKN4JunVtzNXJxcqdIjd42Tboib30c"
PRODUCT_KEY = "WlhKN4JunVtzNXJxcqdIjd42Tboib30c"


-- ����������,�����������Ĺؼ�����
require"ld_tcp_heart" -- ���������� ���͵�ַ�������Ϣ

-- ���ڳ���,��BMS��ʱ�����͵Ĺؼ�����
require"ld_bms_cmd"

-- ���ڳ���,��BMS����ͨѶ���յĹؼ�����
require"ld_uart" --���ڳ���


-- GPS��λ���ܳ���
require"ld_gps"

-- LBS��վ��λ���ܳ���
require"ld_lbs"


sys.init(0,0)
sys.run()

--[[
  ��������: flash����������,���޸�ld_info.lua�еĲ���
  ����ʱ��: 2017-07-31 00:44
]]


module(...,package.seeall)

-- ϵͳ���� Ҳ��flash���޸ĵ�ֵ
require"ld_info"

-- nvm ��flash�������ܿ�
require"nvm"


local function print(...)
  if APP_DEBUG then 
    _G.print('LD_FLASH:',...)
  end
end



-- �޸Ĳ���ʱ�����Ϣ
-- ���nvm���޸Ĳ���ʱ�����Ϣ�ַ����� ����
local function paraChangedInd(k,v,r)
  -- print("paraChangedInd",k,v,r)
  -- printAllPara()
  -- return true
end

-- �޸�table���Ͳ���ʱ�����Ϣ
local function tParaChangedInd(k,kk,v,r)
  -- print("tParaChangedInd",k,kk,v,r)
  --   printAllPara()
  -- return true
end

-- ��Ϣ�ַ�
local procer =
{
  PARA_CHANGED_IND = paraChangedInd, --����nvm.set�ӿ��޸Ĳ�����ֵ�����������ֵ�����ı䣬nvm.lua�����sys.dispatch�ӿ��׳�PARA_CHANGED_IND��Ϣ
  TPARA_CHANGED_IND = tParaChangedInd,  --����nvm.sett�ӿ��޸�table���͵Ĳ����е�ĳһ���ֵ�����ֵ�����ı䣬nvm.lua�����sys.dispatch�ӿ��׳�TPARA_CHANGED_IND��Ϣ
}

--ע����Ϣ������
sys.regapp(procer)

--��ʼ����������ģ��
nvm.init("ld_info.lua")


-- ��ȡflash�е�����
function readflash(para)
  print('get para-',para,nvm.get(para))
  return nvm.get(para)
end

-- д���дflash������
function writeflash(para,val)
  nvm.set(para,val)
  if readflash(para) == val then
    return true
  else
    return false
  end
  print('set para-',para,nvm.get(para));
end


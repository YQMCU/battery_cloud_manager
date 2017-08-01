--[[
  功能描述: flash基本操作库,可修改ld_info.lua中的参数
  更新时间: 2017-07-31 00:44
]]


module(...,package.seeall)

-- 系统参数 也是flash可修改的值
require"ld_info"

-- nvm 是flash操作功能库
require"nvm"


local function print(...)
  if APP_DEBUG then 
    _G.print('LD_FLASH:',...)
  end
end



-- 修改参数时候的消息
-- 配合nvm中修改参数时候的消息分发程序 保留
local function paraChangedInd(k,v,r)
  -- print("paraChangedInd",k,v,r)
  -- printAllPara()
  -- return true
end

-- 修改table类型参数时候的消息
local function tParaChangedInd(k,kk,v,r)
  -- print("tParaChangedInd",k,kk,v,r)
  --   printAllPara()
  -- return true
end

-- 消息分发
local procer =
{
  PARA_CHANGED_IND = paraChangedInd, --调用nvm.set接口修改参数的值，如果参数的值发生改变，nvm.lua会调用sys.dispatch接口抛出PARA_CHANGED_IND消息
  TPARA_CHANGED_IND = tParaChangedInd,  --调用nvm.sett接口修改table类型的参数中的某一项的值，如果值发生改变，nvm.lua会调用sys.dispatch接口抛出TPARA_CHANGED_IND消息
}

--注册消息处理函数
sys.regapp(procer)

--初始化参数管理模块
nvm.init("ld_info.lua")


-- 读取flash中的数据
function readflash(para)
  print('get para-',para,nvm.get(para))
  return nvm.get(para)
end

-- 写入改写flash的数据
function writeflash(para,val)
  nvm.set(para,val)
  if readflash(para) == val then
    return true
  else
    return false
  end
  print('set para-',para,nvm.get(para));
end


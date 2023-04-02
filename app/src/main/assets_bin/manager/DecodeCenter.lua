--解析中心，用于加载固定的模板
local DecodeCenter={}
DecodeCenter.supportDecoders={}

function DecodeCenter.loadSupport(supportConfig)
  local supportDecoders=DecodeCenter.supportDecoders
  for index=1,#supportDecoders do
    supportDecoders[index](supportConfig)
  end
end

function DecodeCenter.addSupportDecoder(supportDecoder)
  table.insert(DecodeCenter.supportDecoders,supportDecoder)
end

function DecodeCenter.init()
  --TODO: 加载默认的一些配置
end

return DecodeCenter
--解析中心，用于加载固定的模板
local DecodeCenter = {}

---支持解析器
---@type table<string, function[]>
DecodeCenter.supportDecodersMap = {}

---加载支持配置
---@param supportConfig table
function DecodeCenter.loadSupport(supportConfig)
    local supportDecodersMap = DecodeCenter.supportDecodersMap
    
    for decoderType, decodersList in pairs(supportConfig) do
        local content = supportConfig[decoderType]
        if content then--只有配置文件中有此项时候调用解析器
            for index = 1, #decodersList do
                decodersList[index](content)
            end
        end
    end
end

---添加解析器
---@param supportDecoder function function(supportDecoder: table)
---@param decoderType string 解析器类型
function DecodeCenter.addSupportDecoder(supportDecoder, decoderType)
    table.insert(DecodeCenter.supportDecoders, supportDecoder)
end

function DecodeCenter.init()
    --TODO: 加载默认的一些配置
end

return DecodeCenter

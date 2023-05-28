--解析中心，用于加载固定的模板
local DecodeCenter = {}

---支持解析器
---@type table<string, function[]>
local supportDecodersMap = {}

---加载支持配置
---@param supportConfig table
function DecodeCenter.loadSupport(supportConfig)
    local supportDecodersMap = supportDecodersMap
    for decoderType, content in pairs(supportConfig) do
        local decodersList = supportDecodersMap[decoderType]
        if decodersList then --只有配置文件中有此项时候调用解析器
            for index = 1, #decodersList do
                decodersList[index](content)
            end
        end
    end
end

---添加解析器
---@param supportDecoder function function(content: table)
---@param decoderType string 解析器类型，如editor
function DecodeCenter.addSupportDecoder(supportDecoder, decoderType)
    local decodersList = supportDecodersMap[decoderType]
    if not decodersList then
        decodersList = {}
        supportDecodersMap[decoderType] = decodersList
    end
    table.insert(decodersList, supportDecoder)
end

function DecodeCenter.init()
    --TODO: 加载默认的一些配置
end

return DecodeCenter

package.path = package.path .. ";Jesse205Library\\test\\?.lua;"
package.path = package.path .. ";app\\src\\main\\assets_bin\\?.lua;"
require "env"

import "manager.DecodeCenter"
import "config.support.androidXSupportConfig"


DecodeCenter.addSupportDecoder(function(content)
    print("文件模板解析收到了通知", content)
end, "fileTemplates")

DecodeCenter.addSupportDecoder(function(content)
    print("编辑器解析收到了通知", content)
end, "editor")


DecodeCenter.loadSupport(androidXSupportConfig)

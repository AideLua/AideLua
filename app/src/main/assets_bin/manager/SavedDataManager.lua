---管理保存的数据
local SavedDataManager={}
--lua数据库列表
local luaDatabases={}

---打开 Lua 数据库
---@param path string 数据库路径
---@param tag all 数据库标志，用于复用数据库对象
function SavedDataManager.openLuaDatabase(path,tag)
  local db=luaDatabases[tag]
  if not db then--如果没有打开，那就打开一个新的
    File(FileUtil.getParentPath(path)).mkdirs()--新建父文件夹
    db=db.open(path)
    luaDatabases[tag]=db
  end
  return db
end

---关闭所有 Lua 数据库
function SavedDataManager.closeAllLuaDatabases()

end

---关闭所有数据库
function SavedDataManager.closeAllDatabases()
  SavedDataManager.closeAllLuaDatabases()
end


--Activity 生命周期
function SavedDataManager.onDestroy()
  SavedDataManager.closeAllDatabases()
end

---获取所有 Lua 数据库
function SavedDataManager.getLuaDatabases()
  return luaDatabases
end

function SavedDataManager.init()
  --TODO:一系列的初始化
end

return SavedDataManager

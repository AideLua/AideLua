local buildConfig=...

function onBeforeUnzip(baseApkPath)
  return baseApkPath
end

function onUnzip(unzipDirPath)
  return unzipDirPath
end

function onBeforeCompile(unzipDirPath)
  return unzipDirPath
end

function onCompile(unzipDirPath)
  return unzipDirPath
end

function onBeforePack(unzipDirPath,packedApkPath)
  return unzipDirPath,packedApkPath
end

function onPack(packedApkPath)
  return packedApkPath
end
function loadContent(content) {
    let converter = new showdown.Converter();
    console.log(converter.makeHtml(content));
    document.body.innerHTML = converter.makeHtml(content);
}

androlua.doLuaString('activity.runOnUiThread(Runnable({\
  run=function()\
    EditorsManager.actions.applyMarkdown(FilesTabManager.fileConfig.newContent)\
  end\
}))')

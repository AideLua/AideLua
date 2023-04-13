return {
    layout = {
        FrameLayout,
        layout_height = "fill",
        layout_width = "fill",
        id = "editorParent",
        layoutTransition = newLayoutTransition(),
        {
            ProgressBar, --进度条
            id = "progressBar",
            layout_gravity = "center",
        },
        {
            EditText, --手写编辑框
            layout_width = "fill",
            layout_height = "fill",
            id = "pencilEdit",
            gravity = "top|left",
            text = " ",
            textSize = 0,
        },
        {
            MyLuaEditor, --Lua编辑器
            layout_height = "fill",
            id = "editor",
            layout_width = "fill",
            focusable = true,
            textHighlightColor = 0x99616161,
            keywordColor = 0xff3f51b5,
            stringColor = 0xffc2185b,
            commentColor = 0xff9e9e9e,
            basewordColor = 0xff3f51b5,
            userwordColor = 0xff5c6bc0,
            textSize = math.dp2int(14),
            --nonPrintingCharVisibility=true;
            --highlightCurrentRow=false;
            --longPressCaps=true;
            --autoComplete=false;
            --wordWrap=true;
            --focusableInTouchMode=false;
        }
    }
}

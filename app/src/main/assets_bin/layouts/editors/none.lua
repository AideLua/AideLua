return {
    {
        LinearLayout,
        id = "editorParent",
        layout_height = "fill",
        layout_width = "fill",
        gravity = "center",
        {
            LinearLayout,
            gravity = "center",
            orientation = "vertical",
            layout_margin = "16dp",
            {
                AppCompatImageView,
                imageResource = R.drawable.ic_undraw_opened_tabs,
                layout_height = "240dp",
                layout_width = "240dp",
                scaleType = "fitCenter",
                layout_weight = 1,
            },
            {
                TextView,
                text = R.string.file_noOpen,
                textSize = "16dp",
            },
        },
    },
}

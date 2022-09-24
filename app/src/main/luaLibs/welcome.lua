local gLLO=getLocalLangObj
permissionInformation={
  {
    icon=R.drawable.ic_file_outline,
    title=R.string.jesse205_permission_storage;
    summary=gLLO("用于存储项目、编辑文件、调试项目等","Used to store projects, edit files, debug projects, etc");
    permissions={"android.permission.WRITE_EXTERNAL_STORAGE","android.permission.READ_EXTERNAL_STORAGE"};
  },
  {
    icon=R.drawable.ic_phone_outline,
    title=R.string.jesse205_permission_phone;
    summary=gLLO("用于统计软件","Used for statistics of software");
    permissions={"android.permission.READ_PHONE_STATE"};
  },
}

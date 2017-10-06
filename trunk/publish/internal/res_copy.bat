::第1步:设置路径
set project_dir=%1
::第2步:删除旧的资源
rd /s/q ResourcesCrypto
md ResourcesCrypto
::第3步:拷贝新资源
xcopy /e/y %project_dir%\Resources\* ResourcesCrypto
del ResourcesCrypto\NativeFileList.txt
del ResourcesCrypto\NativeVersion.txt
::第4步:挑选配置
copy %project_dir%\internal\Config.json ResourcesCrypto\Config.json
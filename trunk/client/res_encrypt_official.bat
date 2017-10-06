::第1步:设置路径
set resource_dir=Resources
set tools_dir=..\..\frameworks\tools
for /f "delims=" %%i in (version.txt) do set version=%%i
set encrypt_date={\"date\":\"%date:~0,4%-%date:~5,2%-%date:~8,2%\",\"time\":\"%time:~0,8%\",\"version\":\"%version%\",\"build\":\"1\"}
::第2步:删除旧的资源
rd /s/q ResourcesCrypto_official
md ResourcesCrypto_official
::第3步:拷贝新资源
xcopy Resources\* ResourcesCrypto_official /e/y
del ResourcesCrypto_official\NativeFileList.txt
del ResourcesCrypto_official\NativeVersion.txt
::第4步:挑选配置
copy official\Config.json ResourcesCrypto_official\Config.json
::第5步:加密
call crypto.bat %tools_dir% ResourcesCrypto_official
::生成md5文件列表
set exts=.txt .lua .xml .csv .ttf .fnt .ogg .jpg .png .plist .json .ExportJson .csb .vsh .fsh .tmx .mp3 .wav
call %tools_dir%\md5.exe -dir ResourcesCrypto_official/ -cut ResourcesCrypto_official/ -ext %exts%
ren ResourcesCrypto_official\Md5FileList.txt NativeFileList.txt
::初始资源版本号
call %tools_dir%\write.exe -rep -file ResourcesCrypto_official\NativeVersion.txt -str %encrypt_date%
pause
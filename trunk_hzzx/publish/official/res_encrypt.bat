::第1步:设置路径
set project_dir=%1
if "" == "%project_dir%" goto end
set resource_dir=%2
if "" == "%resource_dir%" goto end
set version_file=%3
if "" == "%version_file%" goto end
set tools_dir=..\..\..\..\frameworks\tools
for /f "delims=" %%i in (%project_dir%\version.txt) do set version=%%i
set encrypt_date={\"date\":\"%date:~0,4%-%date:~5,2%-%date:~8,2%\",\"time\":\"%time:~0,8%\",\"version\":\"%version%\"
::第2步:加密
call crypto.bat %tools_dir% %resource_dir%
::第3步:生成md5文件列表
set exts=.txt .lua .xml .csv .ttf .fnt .ogg .jpg .png .plist .json .ExportJson .csb .vsh .fsh .tmx .mp3 .wav
call %tools_dir%\md5.exe -dir %resource_dir%/ -cut %resource_dir%/ -ext %exts%
ren %resource_dir%\Md5FileList.txt CheckFileList.txt
::第4步:自动增加资源版本号
call %tools_dir%\autoincrement.exe -rep -file %version_file%
for /f "delims=" %%i in (%version_file%) do set res_version=%%i
call %tools_dir%\write.exe -rep -file %resource_dir%\CheckVersion.txt -str %encrypt_date%,\"build\":\"%res_version%\"}
:end
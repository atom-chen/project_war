::第1步:资源生成
cd ..\..\client
call resource_en.bat
cd ..\publish\internal
call res_copy.bat ..\..\client
call res_encrypt.bat ..\..\client ResourcesCrypto ResourceVersionGooglePlay.txt
::第2步:同步到download目录
xcopy /e/y ResourcesCrypto\* D:\work\wow\test_web\upgrade\priv\www\gwar
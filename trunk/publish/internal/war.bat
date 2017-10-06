::第1步:资源生成
cd ..\..\client
call resource_cn_simplified.bat
cd ..\publish\internal
call res_copy.bat ..\..\client
call res_encrypt.bat ..\..\client ResourcesCrypto ResourceVersion.txt
::第2步:同步到download目录
xcopy /e/y ResourcesCrypto\* D:\work\wow\test_web\upgrade\priv\www\war
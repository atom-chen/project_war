::��1��:��Դ����
cd ..\..\client
call resource_cn_simplified.bat
cd ..\publish\internal
call res_copy.bat ..\..\client
call res_encrypt.bat ..\..\client ResourcesCrypto ResourceVersion.txt
::��2��:ͬ����downloadĿ¼
xcopy /e/y ResourcesCrypto\* D:\work\wow\test_web\upgrade\priv\www\war
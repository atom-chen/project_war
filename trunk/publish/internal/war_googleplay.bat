::��1��:��Դ����
cd ..\..\client
call resource_en.bat
cd ..\publish\internal
call res_copy.bat ..\..\client
call res_encrypt.bat ..\..\client ResourcesCrypto ResourceVersionGooglePlay.txt
::��2��:ͬ����downloadĿ¼
xcopy /e/y ResourcesCrypto\* D:\work\wow\test_web\upgrade\priv\www\gwar
::��1��:��Դ����
cd ..\..\client
call resource_en.bat
cd ..\publish\official
call res_copy.bat ..\..\client
call res_encrypt.bat ..\..\client ResourcesCrypto ResourceVersionGooglePlay.txt
::��2��:ͬ����downloadĿ¼
xcopy /e/y ResourcesCrypto\* D:\work\download_war\release\gwar
svn add --force D:\work\download_war\release\gwar*.*
svn commit -m "auto generate official resource by script" D:\work\download_war\release\gwar\*.*
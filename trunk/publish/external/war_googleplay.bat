::��1��:��Դ����
cd ..\..\client
call resource_en.bat
cd ..\publish\external
call res_copy.bat ..\..\client
call res_encrypt.bat ..\..\client ResourcesCrypto ResourceVersionGooglePlay.txt
::��2��:ͬ����downloadĿ¼
xcopy /e/y ResourcesCrypto\* D:\work\download_war\debug\gwar
svn add --force D:\work\download_war\debug\gwar\*.*
svn commit -m "auto generate external resource by script" D:\work\download_war\debug\gwar\*.*
::��3��:
plink -pw onekes!@# -ssh root@121.199.4.73 svn up /opt/download/gwar/
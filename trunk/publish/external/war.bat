::��1��:��Դ����
cd ..\..\client
call resource_cn_simplified.bat
cd ..\publish\external
call res_copy.bat ..\..\client
call res_encrypt.bat ..\..\client ResourcesCrypto ResourceVersion.txt
::��2��:ͬ����downloadĿ¼
xcopy /e/y ResourcesCrypto\* D:\work\download_war\debug\war
svn add --force D:\work\download_war\debug\war\*.*
svn commit -m "auto generate external resource by script" D:\work\download_war\debug\war\*.*
::��3��:
plink -pw onekes!@# -ssh root@121.199.4.73 svn up /opt/download/war/
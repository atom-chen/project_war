::第1步:资源生成
cd ..\..\client
call resource_cn_simplified.bat
cd ..\publish\external
call res_copy.bat ..\..\client
call res_encrypt.bat ..\..\client ResourcesCrypto ResourceVersionIOS.txt
::第2步:同步到download目录
xcopy /e/y ResourcesCrypto\* D:\work\download_war\debug\iwar
svn add --force D:\work\download_war\debug\iwar\*.*
svn commit -m "auto generate external resource by script" D:\work\download_war\debug\iwar\*.*
::第3步:
plink -pw onekes!@# -ssh root@121.199.4.73 svn up /opt/download/iwar/
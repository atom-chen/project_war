::第1步:资源生成
call res_copy.bat ..\..\client
call res_encrypt.bat ..\..\client ResourcesCrypto ResourceVersion.txt
::第2步:资源版本号提交
svn add ResourceVersion.txt
svn commit -m "WAR-000 auto commit" ResourceVersion.txt
::第3步:同步到download目录
xcopy /e/y ResourcesCrypto\* D:\work\download_war\debug\lwar
svn add --force D:\work\download_war\debug\lwar\*.*
svn commit -m "auto generate external resource by script" D:\work\download_war\debug\lwar\*.*
::第4步:
plink -pw onekes!@# -ssh root@121.199.4.73 svn up /opt/download/lwar/
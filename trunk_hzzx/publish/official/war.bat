::第1步:资源生成
call res_copy.bat ..\..\client
call res_encrypt.bat ..\..\client ResourcesCrypto ResourceVersion.txt
::第2步:资源版本号提交
svn add ResourceVersion.txt
svn commit -m "WAR-000 auto commit" ResourceVersion.txt
::第3步:同步到download目录
xcopy /e/y ResourcesCrypto\* D:\work\download_war\release\lwar
svn add --force D:\work\download_war\release\lwar\*.*
svn commit -m "auto generate official resource by script" D:\work\download_war\release\lwar\*.*
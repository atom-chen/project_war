::第1步:资源生成
cd ..\..\client
call resource_cn_simplified.bat
cd ..\publish\official
call res_copy.bat ..\..\client
call res_encrypt.bat ..\..\client ResourcesCrypto ResourceVersion.txt
::第2步:同步到download目录
xcopy /e/y ResourcesCrypto\* D:\work\download_war\release\war
svn add --force D:\work\download_war\release\war*.*
svn commit -m "auto generate official resource by script" D:\work\download_war\release\war\*.*
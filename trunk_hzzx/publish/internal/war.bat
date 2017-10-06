::第1步:资源生成
call res_copy.bat ..\..\client
call res_encrypt.bat ..\..\client ResourcesCrypto ResourceVersion.txt
::第2步:资源版本号提交
svn add ResourceVersion.txt
svn commit -m "WAR-000 auto commit" ResourceVersion.txt
::第3步:
xcopy /e/y ResourcesCrypto\* D:\work\wow\test_web\upgrade\priv\www\lwar
::��1��:��Դ����
call res_copy.bat ..\..\client
call res_encrypt.bat ..\..\client ResourcesCrypto ResourceVersion.txt
::��2��:��Դ�汾���ύ
svn add ResourceVersion.txt
svn commit -m "WAR-000 auto commit" ResourceVersion.txt
::��3��:ͬ����downloadĿ¼
xcopy /e/y ResourcesCrypto\* D:\work\download_war\release\lwar
svn add --force D:\work\download_war\release\lwar\*.*
svn commit -m "auto generate official resource by script" D:\work\download_war\release\lwar\*.*
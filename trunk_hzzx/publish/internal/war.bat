::��1��:��Դ����
call res_copy.bat ..\..\client
call res_encrypt.bat ..\..\client ResourcesCrypto ResourceVersion.txt
::��2��:��Դ�汾���ύ
svn add ResourceVersion.txt
svn commit -m "WAR-000 auto commit" ResourceVersion.txt
::��3��:
xcopy /e/y ResourcesCrypto\* D:\work\wow\test_web\upgrade\priv\www\lwar
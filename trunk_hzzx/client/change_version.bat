set old_version_str="0.8.6"
set old_version_code="80600"
set new_version_str="0.8.7"
set new_version_code="80700"
set tools_dir=..\..\frameworks\tools
call %tools_dir%\replace.exe Resources\NativeVersion.txt %old_version_str% %new_version_str%
call %tools_dir%\replace.exe version.txt %old_version_str% %new_version_str%
::杭州哲信
call %tools_dir%\replace.exe proj.android\AndroidManifest.xml %old_version_str% %new_version_str% %old_version_code% %new_version_code%
pause
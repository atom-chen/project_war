set old_version_str="0.8.8"
set old_version_code="80800"
set new_version_str="0.8.9"
set new_version_code="80900"
set tools_dir=..\..\frameworks\tools
call %tools_dir%\replace.exe Resources\NativeVersion.txt %old_version_str% %new_version_str%
call %tools_dir%\replace.exe version.txt %old_version_str% %new_version_str%
::自有
call %tools_dir%\replace.exe proj.android\AndroidManifest.xml %old_version_str% %new_version_str% %old_version_code% %new_version_code%
::Cocos
call %tools_dir%\replace.exe proj.android_cocos\AndroidManifest.xml %old_version_str% %new_version_str% %old_version_code% %new_version_code%
::Coda
call %tools_dir%\replace.exe proj.android_coda\AndroidManifest.xml %old_version_str% %new_version_str% %old_version_code% %new_version_code%
::电信
call %tools_dir%\replace.exe proj.android_dx\AndroidManifest.xml %old_version_str% %new_version_str% %old_version_code% %new_version_code%
::飞信
call %tools_dir%\replace.exe proj.android_fx\AndroidManifest.xml %old_version_str% %new_version_str% %old_version_code% %new_version_code%
::Google Play
call %tools_dir%\replace.exe proj.android_googleplay\AndroidManifest.xml %old_version_str% %new_version_str% %old_version_code% %new_version_code%
::联通
call %tools_dir%\replace.exe proj.android_lt\AndroidManifest.xml %old_version_str% %new_version_str% %old_version_code% %new_version_code%
::移动
call %tools_dir%\replace.exe proj.android_yd\AndroidManifest.xml %old_version_str% %new_version_str% %old_version_code% %new_version_code%
::易接
call %tools_dir%\replace.exe proj.android_yj\AndroidManifest.xml %old_version_str% %new_version_str% %old_version_code% %new_version_code%
::IOS
call %tools_dir%\replace.exe proj.ios_mac\ios\Info_mxrllx.plist %old_version_str% %new_version_str%
call %tools_dir%\replace.exe proj.ios_mac\ios\Info_kittycrush.plist %old_version_str% %new_version_str%
pause
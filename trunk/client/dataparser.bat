set tools_dir=..\..\frameworks\tools
set src_path=data
set target_path=Resources\Data
call %tools_dir%\data2lua.exe -dir %src_path% -ext .csv .xml
call %tools_dir%\lua\lua.exe -e "local run=dofile('dataparser.lua') run('%src_path%')"
copy %src_path%\*.lua %target_path%
copy %src_path%\cn\*.lua %target_path%
::拷贝到中文资源目录
copy %src_path%\cn\copy_special_tplt.lua	Resources_CNSimplified\Data\copy_special_tplt.lua
copy %src_path%\cn\copy_tplt.lua			Resources_CNSimplified\Data\copy_tplt.lua
copy %src_path%\cn\hero_tplt.lua			Resources_CNSimplified\Data\hero_tplt.lua
copy %src_path%\cn\item_tplt.lua			Resources_CNSimplified\Data\item_tplt.lua
copy %src_path%\cn\share_tplt.lua			Resources_CNSimplified\Data\share_tplt.lua
copy %src_path%\cn\shop_tplt.lua			Resources_CNSimplified\Data\shop_tplt.lua
::拷贝到英文资源目录
copy %src_path%\en\copy_special_tplt.lua	Resources_EN\Data\copy_special_tplt.lua
copy %src_path%\en\copy_tplt.lua			Resources_EN\Data\copy_tplt.lua
copy %src_path%\en\hero_tplt.lua			Resources_EN\Data\hero_tplt.lua
copy %src_path%\en\item_tplt.lua			Resources_EN\Data\item_tplt.lua
copy %src_path%\en\share_tplt.lua			Resources_EN\Data\share_tplt.lua
copy %src_path%\en\shop_tplt.lua			Resources_EN\Data\shop_tplt.lua
::删除
del %src_path%\*.lua
del %src_path%\cn\*.lua
del %src_path%\en\*.lua
pause
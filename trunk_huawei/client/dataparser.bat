set path=CSV
set file_type=csv
::set file_type=xml
set tools_dir=..\..\frameworks\tools
call %tools_dir%\data2lua.exe -dir %path% -ext .%file_type%
call %tools_dir%\lua\lua.exe -e "local run=dofile('dataparser.lua') run('%path%', '%file_type%')"
pause
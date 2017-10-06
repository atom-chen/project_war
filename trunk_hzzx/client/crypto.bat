set tools_dir=%1
set file_path=%2
if "" == "%tools_dir%" goto end
if "" == "%file_path%" goto end
set key="m~;(v(9/3|q4Hrh0YZgDo^GLt2A9I[*go`cmquW[D04p|~`B2#!dfZR83{9o7M9|ICC-hSt47ABav?`KuC*2g6Z093*W48T~Zm2we>C81T}uI[6}:222Vi4n&6$8ZND3pe6>}uC+-VOK8_9Yn6<BXY#Hb27GO3NCL8&gHbD2eK5vRZM^,c?0og4&zZMe,UNP1f3T38597gfco994jaU53(TF/[g0~w8+38|cg4Z8,Z751v'b}7*c74iK?ZwH3>6|"
set sign="onekes"
::xxtea算法;加密;lua,csv
call %tools_dir%\crypto.exe -alg 3 -op 1 -key %key% -sign %sign% -dir %file_path% -ext .lua .csv
:end
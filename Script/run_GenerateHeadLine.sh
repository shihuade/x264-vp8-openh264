

#!/bin/bash
#usage: runGenerateHeadLine ${FinalResultFile} 
runGenerateHeadLine()
{
	if [ ! $# -eq 1 ]
	then
		echo "usage: runGenerateHeadLine \${FinalResultFile} "
		return 1
	fi
	
	
	local FinalResultFile=$1
	local HeadLine_1="TestSequence, openh264QP ,  ,      ,       ,   ,   , , openh264BR,  ,       ,      ,   ,   , , VP8 ,      ,       ,      ,   ,   , , "
	local HeadLine_2="            , BR,     PSNR_Y, PSNR_U,PSNR_V,FPS, ET, , BR,    PSNR_Y, PSNR_U,PSNR_V,FPS, ET, , BR,  PSNR_Y, PSNR_U,PSNR_V,FPS, ET, , "
	
	local Profile=""
	local Speed=""
	local TempData_1=""
	local TempData_2=""
   	declare -a aX264Profile
	declare -a aX264Speed
	aX264Profile=(baseline main  high)
	aX264Speed=(veryfast fast    slow)
	local Index=""
	let "Index=0"
	for Profile in ${aX264Profile[@]}
	do
		for Speed in ${aX264Speed[@]}
		do
			TempData_1="x264_${Index}, Profile_${Profile},Speed_${Speed},       ,   ,"
			TempData_2="BR                      , PSNR_Y,PSNR_U,PSNR_V, FPS,"
			HeadLine_1="${HeadLine_1},${TempData_1},"
			HeadLine_2="${HeadLine_2},${TempData_2},"	
			let "Index++"
		done
	
	done
	
	echo "${HeadLine_1}">${FinalResultFile}
	echo "${HeadLine_2}">>${FinalResultFile}
	
}
FinalResultFile=$1
runGenerateHeadLine ${FinalResultFile} 



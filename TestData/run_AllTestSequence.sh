age: runGenerateHeadLine ${FinalResultFile} 
runGenerateHeadLine()
{
	if [ ! $# -eq 2 ]
	then
		echo "usage: runGenerateHeadLine \${FinalResultFile} "
		return 1
	fi
	
	
	local FinalResultFile=$1
	local HeadLine_1="TestSequence, openh264 ,       ,      ,   ,   , ,   ,      ,       ,      ,   ,   , , , "
	local HeadLine_2="            , BR,PSNR_Y, PSNR_U,PSNR_V,FPS, ET, , BR,PSNR_Y, PSNR_U,PSNR_V,FPS, ET, , , "
	
	local Profile=""
	local Speed=""
	local TempData_1=""
	local TempData_2=""
   	declare -a aX264Profile
	declare -a aX264Speed
	aX264Profile=(baseline )
	aX264Speed=(veryfast   veryslow)
	
	for Profile in ${aX264Profile[@]}
	do
		for Speed in ${aX264Speed[@]}
		do
			TempData_1="x264_${Profile}_${Speed},      ,       ,      ,   "
			TempData_2="BR,                     ,PSNR_Y, PSNR_U,PSNR_V,FPS"
			HeadLine_1=",${HeadLine_1},${TempData_1}"
			HeadLine_2=",${HeadLine_1},${TempData_2}"			
		done
	
	done
	
	echo "${HeadLine_1}">${FinalResultFile}
	echo "${HeadLine_2}">>${FinalResultFile}
	
}




#usage: runAllTestSequence  ${ConfigureFile} ${SequenceLocation}
runAllTestSequence()
{

	if [ ! $# -eq 2 ]
	then
		echo "usage: runAllTestSequence \${ConfigureFile} \${SequenceLocation} "
		return 1
	fi

	local ConfigureFile=$1
	local SequenceLocation=$2
	local FinalResultFile="AllTestSequence.csv"

	local TestYUVName=""
	local TestYUV=""	
	local line=""
	
	while read line
	do
		if [ -n "$line"  ]
		then
			TestYUVName="$line"
			echo "current YUV is:  $TestYUVName"	
			TestYUV=`./run_GetYUVPath.sh  ${TestYUVName}  ${SequenceLocation}`
			if [ -n  "${TestYUV}"  ]
			then
				echo "test YUV: ${TestYUVName} is under testing..."
				echo "Test yuv full path is ${TestYUV} "
				./run_OneTestSequence.sh  ${TestYUV} ${FinalResultFile}
				echo ""
			else
				echo "can not find Test YUV : ${YUVName}"
			fi
		fi
	
	done <${ConfigureFile}




}

ConfigureFile=$1
SequenceLocation=$2

runAllTestSequence  ${ConfigureFile} ${SequenceLocation}



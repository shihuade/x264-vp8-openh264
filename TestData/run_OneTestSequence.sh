
#!/bin/bash



#uasage: runOneBitRate_openh264  ${TargetBitRate}  ${InputYUV}
runOneBitRate_openh264()
{
	if [ ! $# -eq 2 ]
	then
		echo "uasage: runOneBitRate_openh264  \${TargetBitRate}  \${InputYUV}"
		return 1
	fi
	
	local TargetBitRate=$1
	local InputYUV=$2
	local Option="BR"
	
	local TempInfo=""
	local PerfInfo=""
	local LogFile=""
	local OutputFile=""
	local TempLog="Tem_openh264.log"
	
	local YUVName=`echo  ${InputYUV} | awk 'BEGIN {FS="/"}  {print $NF}'`
	LogFile="openh264_${YUVName}_BR_${TargetBitRate}.log"
	OutputFile="openh264_${YUVName}_BR_${TargetBitRate}.264"
	./run_TestOpenh264.sh   ${Option}  ${InputYUV} ${OutputFile}   ${TargetBitRate}   ${LogFile}>${TempLog}
	
	#get performance info
	PerfInfo=`./run_GetPerfInfo_openh264.sh   ${LogFile}`
	echo ${PerfInfo}	

}

#uasage:runOneBitRate_VP8  ${TargetBitRate}  ${InputYUV}
runOneBitRate_VP8()
{
	if [ ! $# -eq 2 ]
	then
		echo "uasage:runOneBitRate_VP8  \${TargetBitRate}  \${InputYUV}"
		return 1
	fi
	
	local TargetBitRate=$1
	local InputYUV=$2
	
	local PerfInfo=""
	local LogFile=""
	local OutputFile=""
	
	local TempLog="Tem_vp8.log"
	
	local YUVName=`echo  ${InputYUV} | awk 'BEGIN {FS="/"}  {print $NF}'`
	LogFile="VP8_${YUVName}_BR_${TargetBitRate}.log"
	OutputFile="VP8_${YUVName}_BR_${TargetBitRate}.vp8"
	./run_TestVP8.sh   ${InputYUV}  ${OutputFile}   ${TargetBitRate}    ${LogFile}>${TempLog}
	
	#get performance info
	PerfInfo=`./run_GetPerfInfo_VP8.sh   ${LogFile}`
	echo ${PerfInfo}	

}

#usage: runOneBitRate_X264 ${TargetBitRate}  ${InputYUV}
runOneBitRate_X264()
{
	if [ ! $# -eq 2 ]
	then
		echo  "usage: runOneBitRate_X264 \${TargetBitRate}  \${InputYUV}"
		return 1
	fi

	local TargetBitRate=$1
	local InputYUV=$2
	
	local Profile=""
	local Profile=""
	local Speed=""
	
	local TempInfo=""
	local PerfInfo=""
	local LogFile=""
	local OutputFile=""
	local YUVName=`echo  ${InputYUV} | awk 'BEGIN {FS="/"}  {print $NF}'`
	
	local TempLog="Tem_x264.log"
	declare -a aX264Profile
	declare -a aX264Speed
	aX264Profile=(baseline )
	aX264Speed=(veryfast   veryslow)
	
	
	for Profile  in ${aX264Profile[@]}
	do
		for Speed in ${aX264Speed[@]}
		do
			LogFile="X264_${YUVName}_Profile_${Profile}_Speed_${Speed}_BR_${TargetBitRate}.log"
			OutputFile="X264_${YUVName}_Profile_${Profile}_Speed_${Speed}_BR_${TargetBitRate}.264"
			./run_TestX264.sh  ${Profile}  ${Speed} ${InputYUV} ${OutputFile}  ${TargetBitRate}   ${LogFile}>${TempLog}
			
			#get performance info
			TempInfo=`./run_GetPerfInfo_X264.sh   ${LogFile}`
			PerfInfo="${PerfInfo},  , ${TempInfo}"			
		done
	
	done
	
	echo ${PerfInfo}
}

#usage: runBitRateMode  ${InputYUV}  ${StatisticFile}
runBitRateMode()
{


	if [ ! $# -eq 2 ]
	then
		echo  "usage: runBitRateMode  \${InputYUV}  \${StatisticFile}"
		return 1
	fi
	
	local InputYUV=$1
	local StatisticFile=$2
	
	
	local Openh264PerfInfo=""
	local VP8PerfInfo=""
	local X264PerfInfo=""

	local TargetBitRate=""
	
	
	local YUVName=`echo  ${InputYUV} | awk 'BEGIN {FS="/"}  {print $NF}'`
	declare -a aOpenh264BR
    aOpenh264BR=`./run_GetTargetBitRate.sh   ${YUVName}`
	
	for   TargetBitRate in ${aOpenh264BR}
	do
		echo ""
		echo "openh264 ..."
		Openh264PerfInfo=`runOneBitRate_openh264  ${TargetBitRate}  ${InputYUV}`
		
		echo ""
		echo "VP8 ..."		
		VP8PerfInfo=`runOneBitRate_VP8  ${TargetBitRate}  ${InputYUV}`	
		
		echo ""
		echo "X264 ....."
		X264PerfInfo=` runOneBitRate_X264 ${TargetBitRate}  ${InputYUV}`
		echo ""

		echo "${YUVName}_${TargetBitRate},${Openh264PerfInfo}, , ${VP8PerfInfo}, , ${X264PerfInfo}">>${StatisticFile}
	done
	
	

	
}


InputYUV=$1
StatisticFile=$2
runBitRateMode  ${InputYUV}  ${StatisticFile}



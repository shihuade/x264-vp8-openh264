#!/bin/bash


#uasage: runOneBitRate_openh264  ${Option}  ${TargetBitRate}  ${InputYUV}
runOneBitRate_openh264()
{
	if [ ! $# -eq 3  ]
	then
		echo "uasage: runOneBitRate_openh264  \${Option} \${TargetBitRate}  \${InputYUV}"
		return 1
	fi
	
	local Option=$1
	local TargetBitRate=$2
	local InputYUV=$3
	
	
	local TempInfo=""
	local PerfInfo=""
	local LogFile=""
	local OutputFile=""
	local YUVName=`echo  ${InputYUV} | awk 'BEGIN {FS="/"}  {print $NF}'`
	
	LogFile="openh264_${YUVName}_BR_${TargetBitRate}.log"
	OutputFile="openh264_${YUVName}_BR_${TargetBitRate}.264"
	./run_TestOpenh264.sh   ${Option}  ${InputYUV} ${OutputFile}   ${TargetBitRate}   ${LogFile}>>${TempLog}
	
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
	
	local YUVName=`echo  ${InputYUV} | awk 'BEGIN {FS="/"}  {print $NF}'`
	LogFile="VP8_${YUVName}_BR_${TargetBitRate}.log"
	OutputFile="VP8_${YUVName}_BR_${TargetBitRate}.vp8"
	./run_TestVP8.sh   ${InputYUV}  ${OutputFile}   ${TargetBitRate}    ${LogFile}>>${TempLog}
	
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
	declare -a aX264Profile
	declare -a aX264Speed
	declare -a aTestIndex
	aX264Profile=(baseline)
	aX264Speed=(faster fast)
	aTestIndex=(0 1 2)
	
	for Profile  in ${aX264Profile[@]}
	do
		for TestIndex in ${aTestIndex[@]}
		do
		    if [ ${TestIndex} -eq 0  ]
			then
				for Speed in ${aX264Speed[@]}
				do
					LogFile="X264_${YUVName}_Profile_${Profile}_Speed_${Speed}_BR_${TargetBitRate}_TestIndex_${TestIndex}.log"
					OutputFile="X264_${YUVName}_Profile_${Profile}_Speed_${Speed}_BR_${TargetBitRate}_TestIndex_${TestIndex}.264"
					./run_TestX264.sh  ${TestIndex} ${Profile}  ${Speed} ${InputYUV} ${OutputFile}  ${TargetBitRate}   ${LogFile}>>${TempLog}
					
					#get performance info
					TempInfo=`./run_GetPerfInfo_X264.sh   ${LogFile}`
					PerfInfo="${PerfInfo},  ,  ,${TempInfo}"
				done					
			else
					LogFile="X264_${YUVName}_Profile_${Profile}_Speed_${Speed}_BR_${TargetBitRate}_TestIndex_${TestIndex}.log"
					OutputFile="X264_${YUVName}_Profile_${Profile}_Speed_${Speed}_BR_${TargetBitRate}_TestIndex_${TestIndex}.264"
					./run_TestX264.sh  ${TestIndex} ${Profile}  ${Speed} ${InputYUV} ${OutputFile}  ${TargetBitRate}   ${LogFile}>>${TempLog}					
					#get performance info
					TempInfo=`./run_GetPerfInfo_X264.sh   ${LogFile}`
					PerfInfo="${PerfInfo},  ,  ,${TempInfo}"						
			fi
			
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
		echo "${YUVName}_${TargetBitRate},${Openh264PerfInfo}, , ${VP8PerfInfo}  ${X264PerfInfo}">>${StatisticFile}
	done
	
	
	
}
#uasage: runOneQPOpenh264  ${TargetQP}  ${InputYUV}
runOneQPOpenh264()
{
	if [ ! $# -eq 2 ]
	then
		echo "uasage: runOneQPOpenh264  \${TargetQP}  \${InputYUV}"
		return 1
	fi
	
	local TargetQP=$1
	local InputYUV=$2
	local Option="QP"
	
	local TempInfo=""
	local PerfInfo=""
	local LogFile=""
	local OutputFile=""
	
	local YUVName=`echo  ${InputYUV} | awk 'BEGIN {FS="/"}  {print $NF}'`
	LogFile="openh264_${YUVName}_BR_${TargetBitRate}.log"
	OutputFile="openh264_${YUVName}_QP_${TargetQP}.264"
	./run_TestOpenh264.sh   ${Option}  ${InputYUV} ${OutputFile}   ${TargetQP}   ${LogFile}>>${TempLog}
	
	#get performance info
	PerfInfo=`./run_GetPerfInfo_openh264.sh   ${LogFile}`
	echo ${PerfInfo}   
}
runQPMode()
{
	if [ ! $# -eq 2 ]
	then
		echo  "usage: runBitRateMode  \${InputYUV}  \${StatisticFile}"
		return 1
	fi
	
	local InputYUV=$1
	local StatisticFile=$2
	
	
	local Openh264PerfInfoQP=""
	local Openh264PerfInfoBR=""
	local Openh264PerfInfoMulti=""
	local VP8PerfInfo=""
	local X264PerfInfo=""
	local TargetBitRate=""
	local QP=""
	
	declare -a aOpenh264PerfInfo
	
	local YUVName=`echo  ${InputYUV} | awk 'BEGIN {FS="/"}  {print $NF}'`
	
	TempLog="${YUVName}_Console.log"
	
	declare -a aOpenh264QP
    aOpenh264QP=(12   18  24  36 )
	
	for   QP  in ${aOpenh264QP[@]}
	do
		echo ""
		echo "...........QP is ${QP}.................."
		echo ""
		
		echo "openh264 QP mode..."
		Openh264PerfInfoQP=`runOneQPOpenh264  ${QP}  ${InputYUV}`
		aOpenh264PerfInfo=( ${Openh264PerfInfoQP} )	
		echo "openh264 perfer info is : ${Openh264PerfInfoQP}"	
		TargetBitRate=`echo ${aOpenh264PerfInfo[0]}  | awk 'BEGIN {FS="."}  {print $1}'`		
		echo "QP mode, openh264 bitrate is ${TargetBitRate}"
		
		echo "opeh264 BR mode"
		Openh264PerfInfoBR=`runOneBitRate_openh264  BR ${TargetBitRate}  ${InputYUV}`
		echo "Openh264PerfInfoBR is ${Openh264PerfInfoBR}"
		
		echo "opeh264 BR mode"
		Openh264PerfInfoMulti=`runOneBitRate_openh264 MultiSlice ${TargetBitRate}  ${InputYUV}`
		echo "Openh264PerfInfoMulti is ${Openh264PerfInfoMulti}"
		
		#echo ""
		#echo "VP8 ..."		
		#VP8PerfInfo=`runOneBitRate_VP8  ${TargetBitRate}  ${InputYUV}`	
		
		echo ""
		echo "X264 ....."
		X264PerfInfo=` runOneBitRate_X264 ${TargetBitRate}  ${InputYUV}`
		echo ""
		echo "${YUVName}_QP_${QP}_TarBit_${TargetBitRate},${Openh264PerfInfoQP},  ,${Openh264PerfInfoBR}, ,${Openh264PerfInfoMulti}, , ${X264PerfInfo}">>${StatisticFile}
	done
	
	
	
}
InputYUV=$1
StatisticFile=$2
runQPMode  ${InputYUV}  ${StatisticFile}



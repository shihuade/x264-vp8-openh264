#!/bin/bash




#usage runGetYUVInfo $TestSequencName
#eg. input: ABC_1920X1080_30fps_XXX.yuv output: 1920 1080 30
#eg. input: ABC_1920X1080_XXX.yuv output: 1920 1080 0
#eg. input: ABC_XXX.yuv output: 0 0 0
runGetYUVInfo()
{
	if [ ! $# -eq 1 ]
	then
		echo "no parameter!"
		return 1
	fi
	
	local SequenceName=$1
	local PicWidth="0"
	local PicHeight="0"
	local FPS="0"

	declare -a aPicInfo
	aPicInfo=(`echo ${SequenceName} | awk 'BEGIN {FS="[_.]"} {for(i=1;i<=NF;i++) printf("%s ",$i)}'`)

	local Iterm
	local Index=""
	local Pattern_01="[xX]"
	local Pattern_02="^[1-9][0-9]"
	local Pattern_03="[1-9][0-9]$"
	local Pattern_04="fps$"

	#get PicW PicH info
	let "Index=0"
	for Iterm in ${aPicInfo[@]}
	do
		if [[ $Iterm =~ $Pattern_01 ]] && [[ $Iterm =~ $Pattern_02 ]] && [[ $Iterm =~ $Pattern_03 ]]
		then
				PicWidth=`echo $Iterm | awk 'BEGIN {FS="[xX]"} {print $1}'`
				PicHeight=`echo $Iterm | awk 'BEGIN {FS="[xX]"} {print $2}'`
				break
		fi
		
		let "Index++"
	done

	#get fps info
	let "Index++"
	if [ $Index -le ${#aPicInfo[@]} ]
	then
		if [[ ${aPicInfo[$Index]} =~ ^[1-9] ]] || [[ ${aPicInfo[$Index]} =~ $Pattern_04 ]]
		then
			FPS=`echo ${aPicInfo[$Index]} | awk 'BEGIN {FS="[a-zA-Z]" } {print $1} '`
		fi
	fi

	echo "$PicWidth $PicHeight $FPS"

}

#usage  runParseYUVName ${YUVPathInfo}
#eg:    input:   runParseYUVName  "../../../YUV/foreman_352x288_30"
#	output:	 foreman_352x288_30
runParseYUVName()
{

	if [ ! $# -eq 1 ]
	then
		echo "not enough parameters!"
		echo "usage: runParseYUVName \${YUVPathInfo}}"
		return 1
	fi
	
	local YUVPathInfo=$1
	local YUVName=""

	YUVName=`echo $YUVPathInfo | awk 'BEGIN {FS="/"} {print $NF}'`
	echo ${YUVName}

}



#usage  runGetPerformanceInfo   ${PerformanceLogFile}
runGetPerformanceInfo_VP9()
{

	if [ ! $# -eq 1 ]
	then
		echo "not enough parameters!"
		echo "usage: runControlBRModTest \${PerformanceLogFile}"
		return 1
	fi

	local PerformanceLogFile=$1

	local PSNROverAll=""
	local PSNRAverage=""
	local PSNRY=""
	local BitRate=""
	local FPS=""
	local EncodeTime=""

	while read line
	do 
		if [[ $line =~ "b/s"  ]]
		then
			#line looks like : ... Pass 1/1 frame ... Pass 1/1 frame   10/10     69355B   55484b/f 1664520b/s   19536 ms (0.51 fps)
			BitRate=`echo $line | awk 'BEGIN {FS="frame"} {print $NF}'` #10/10     69355B   55484b/f 1664520b/s   19536 ms (0.51 fps)
			BitRate=`echo $BitRate | awk 'BEGIN {FS="B"}{print $1}'`   #10/10     69355 
			BitRate=`echo $BitRate | awk '{print $2}'`                 #69355

			FPS=`echo $line | awk 'BEGIN {FS="("} {print $2}'` 
			FPS=`echo $FPS | awk '{print $1}'`
			
			EncodeTime=`echo $line | awk 'BEGIN {FS="b/s"} {print $2}'`
			EncodeTime=`echo $EncodeTime | awk '{print $1}'`
		fi

		if [[  $line =~ "Overall/Avg/Y/U/V"  ]]
		then
			#line looks like : Stream 0 PSNR (Overall/Avg/Y/U/V) 42.719 43.504 42.410 46.919 48.277
			local PSNRInfo=`echo $line |awk 'BEGIN {FS=")"} {print $2}'`
			PSNROverAll=`echo $PSNRInfo | awk '{print $1}'`
			PSNRAverage=`echo $PSNRInfo | awk '{print $2}'`
			PSNRY=`echo $PSNRInfo | awk '{print $3}'`
		fi

	done <${PerformanceLogFile}

	echo "${BitRate},${FPS},${PSNROverAll},${PSNRAverage},${PSNRY}" 
	      


}

#usage  runGetPerformanceInfo   ${PerformanceLogFile}
runGetPerformanceInfo_openh264()
{

	if [ ! $# -eq 1 ]
	then
		echo "not enough parameters!"
		echo "usage: runControlBRModTest \${PerformanceLogFile}"
		return 1
	fi

	local PerformanceLogFile=$1

	local PSNRY=""
	local PSNRU=""
	local PSNRV=""
	local BitRate=""
	local FPS=""
	local EncodeTime=""

	while read line
	do 

		if [[ $line =~ "PSNR Y"  ]]
		then
			#SVC: overall PSNR Y: 38.718 U: 42.083 V: 44.385 kb/s: 599.6 fps: 12.000
			PSNRY=`echo $line | awk 'BEGIN {FS="Y:"} {print $2}'` 
			PSNRY=`echo $PSNRY | awk 'BEGIN {FS="U:"} {print $1}'` 

			PSNRU=`echo $line | awk 'BEGIN {FS="U:"} {print $2}'` 
			PSNRU=`echo $PSNRU | awk 'BEGIN {FS="V:"} {print $1}'` 

			PSNRV=`echo $line | awk 'BEGIN {FS="V:"} {print $2}'` 
			PSNRV=`echo $PSNRV | awk 'BEGIN {FS="kb/s:"} {print $1}'`

			BitRate=`echo $line | awk 'BEGIN {FS="kb/s:"} {print $2}'`   # 599.6 fps: 12.000
			BitRate=`echo $BitRate | awk 'BEGIN {FS="fps"} {print $1}'` 

			FPS=`echo $line | awk 'BEGIN {FS="fps:"} {print $2}'` 	
			FPS=`echo $FPS | awk 'BEGIN {FS="\n"} {print $1}'` 
				
		fi

		if [[  $line =~ "encode time"  ]]
		then
			EncodeTime=`echo $line | awk 'BEGIN {FS=":"} {print $2}'` 	
		fi

	done <${PerformanceLogFile}

	echo "${BitRate},${FPS},${PSNRY},${PSNRU},${PSNRV}" 
	      


}


#usage
#runTest_VBR  ${InputYUV}  ${OutputFile}   ${TargetBR} ${MaxKeyFrameD}   ${LogFile} 
runTest_VBR()
{

	if [ ! $# -eq 5 ]
	then
		echo "not enough parameters!"
		echo "usage: runTest_VBR \${InputYUV} \${OutputFile}  \${TargetBR} \${MaxKeyFrameD}  \${LogFile} "
		return 1
	fi
	echo ""
	echo "vp9 encoder VBR --good  mode......"
	echo ""

	local InputYUV=$1
	local OutputFile=$2
	local TargetBR=$3
	local MaxKeyFrameD=$4
	local LogFile=$5

	local PerfINfo=""
	echo "input yuv is ${InputYUV}"
	echo ""

	#get YUV detail info $picW $picH $FPS
	local PicW=""
	local PicH=""
	local YUVName=`runParseYUVName ${InputYUV}`
	declare -a aYUVInfo
	aYUVInfo=(`runGetYUVInfo ${InputYUV}`)
	PicW=${aYUVInfo[0]}
	PicH=${aYUVInfo[1]}
	
	local EncoderCommand=" \
		 ${InputYUV}            \
		-w ${PicW} -h ${PicH}   \
		-o ${OutputFile}        \
		--codec=vp9 		\
		--end-usage=vbr		\
		--cpu-used=0 	        \
		--psnr	--verbose	\
		--good 	--tune=psnr	\
		--passes=1  --limit=5	\
		--fps=10/1		\
		--min-q=0 --max-q=63	\
		--target-bitrate=${TargetBR} \
		--kf-max-dist=${MaxKeyFrameD}"

	echo ${EncoderCommand}
	./vpxenc ${EncoderCommand} 2>${LogFile}

}



#usage
#runTest_VBR  ${InputYUV}  ${OutputFile}   ${TargetBR} ${MaxKeyFrameD}   ${LogFile} 
runTest_VBR_VP8()
{

	if [ ! $# -eq 5 ]
	then
		echo "not enough parameters!"
		echo "usage: runTest_VBR \${InputYUV} \${OutputFile}  \${TargetBR} \${MaxKeyFrameD} \${LogFile} "
		return 1
	fi
	echo ""
	echo "vp8 encoder VBR --good  mode......"
	echo ""

	local InputYUV=$1
	local OutputFile=$2
	local TargetBR=$3
	local MaxKeyFrameD=$4
	local LogFile=$5

	local PerfINfo=""
	echo "input yuv is ${InputYUV}"
	echo ""

	#get YUV detail info $picW $picH $FPS
	local PicW=""
	local PicH=""
	local YUVName=`runParseYUVName ${InputYUV}`
	declare -a aYUVInfo
	aYUVInfo=(`runGetYUVInfo ${InputYUV}`)
	PicW=${aYUVInfo[0]}
	PicH=${aYUVInfo[1]}
	
	local EncoderCommand=" \
		 ${InputYUV}            \
		-w ${PicW} -h ${PicH}   \
		-o ${OutputFile}        \
		--codec=vp8 		\
		--end-usage=vbr		\
		--cpu-used=0 	        \
		--psnr	--verbose	\
		--good 	--tune=psnr	\
		--passes=1  --limit=5	\
		--fps=10/1		\
		--min-q=0 --max-q=63	\
		--target-bitrate=${TargetBR} \
		--kf-max-dist=${MaxKeyFrameD}"

	echo ${EncoderCommand}
	./vpxenc ${EncoderCommand} 2 >${LogFile}

}



#usage
#runTest_openh264  ${InputYUV} ${OutputFile}   ${TargetBR}   ${LogFile}
runTest_openh264()
{

	if [ ! $# -eq 4 ]
	then
		echo "not enough parameters!"
		echo "usage: runTest_openh264 \${InputYUV} \${OutputFile}  \${TargetBR}   \${LogFile}"
		return 1
	fi
	echo ""
	echo "openh264 encoder....."
	echo ""

	local InputYUV=$1
	local OutputFile=$2
	local TargetBR=$3
	local LogFile=$4

	local PerfINfo=""

	#get YUV detail info $picW $picH $FPS
	local PicW=""
	local PicH=""
	local YUVName=`runParseYUVName ${InputYUV}`
	declare -a aYUVInfo
	aYUVInfo=(`runGetYUVInfo ${InputYUV}`)
	PicW=${aYUVInfo[0]}
	PicH=${aYUVInfo[1]}
	
	local EncoderCommand="welsenc.cfg -numl 1 layer2.cfg \
				-bf ${OutputFile}            \
				-org 0 ${InputYUV}           \
				-sw 0 ${PicW} -sh 0 ${PicH}  \
				-rc 1  -ltarb 0 ${TargetBR}"
	
				


	echo "input yuv is ${InputYUV}"
	echo "Target BitRate is ${TargetBR} "
	echo ""
	echo ${EncoderCommand}

	./h264enc ${EncoderCommand} >${LogFile}

}



#usage  runMain_JoinTest
runMain_JoinTest()
{

	echo ""
	echo "vJoinTest test....."
	echo ""

	local MaxKeyFrameD=9999
	local AllPerformFile="JoinTest-vp9-vp8-openh264.csv"
	declare -a aTargetBitRate 
	declare -a aTestYUVSet
	declare -a aCPUUsed


	aCPUUsed=(0  1  4)
	aTargetBitRate=(256 512 768 1024 1536)
	aTestYUVSet=(BasketballDrillText_832x480_noDuplicate.yuv    \
		  foreman_352x288_30                            \
		  src_pic_in_enc_1440x912_DOC.yuv )

	local TestSetPath="/opt/VideoTest/YUV"
	
	local TestYUV=""
	local OutputFile=""
	local CQLevel=""
	local VP9PerforInfo_VBR=""
	local VP9PerforInfo_RT=""
	local VP8PerforInfo_VBR=""
	local Openh264PerforInfo=""
	local LogFile=""

	#inital perfermance file
	echo "CommonInfo, , \
	        ,VP9-VBR, , , , , \
		,VP8-VBR, , , , , \
		,openh264">${AllPerformFile}

	echo "YUV,TargetBitRate, \
		,BitRate(B), FPS, PSNR_OverAll, PSNR_Average, PSNR_Y,\
		,BitRate(B), FPS, PSNR_OverAll, PSNR_Average, PSNR_Y,\
		,BitRate(kb/s), FPS,PSNRY,PSNRU,PSNRV">>${AllPerformFile}


	for YUV in ${aTestYUVSet[@]}
	do
		for TargetBitRate in ${aTargetBitRate[@]}
		do
			#for VP9 VBR --good Test
			#############################################
			echo ""
			echo "target bitrate is ${TargetBitRate}"
			echo "VP9 VBR Test..."
			echo ""
					
			OutputFile="${YUV}_Target_${TargetBitRate}_VBR.vp9"
			LogFile="${YUV}_Target_${TargetBitRate}_VBR_vp9.log"
			runTest_VBR  "${TestSetPath}/${YUV}"  ${OutputFile}  ${TargetBitRate} ${MaxKeyFrameD} ${LogFile}

			echo ""
			cat ${LogFile}
			echo ""
			VP9PerforInfo_VBR=`runGetPerformanceInfo_VP9   ${LogFile}`
			echo "VP9PerforInfo_VBR ${VP9PerforInfo_VBR}"
 								

			#for VP8 VBR Test
			#############################################
			echo ""
			echo "VP8 VBR --good Test..."
			echo ""
					
			OutputFile="${YUV}_Target_${TargetBitRate}_RT.vp8"
			LogFile="${YUV}_Target_${TargetBitRate}_RT_vp8.log"
			runTest_VBR_VP8  "${TestSetPath}/${YUV}"  ${OutputFile}  ${TargetBitRate} ${MaxKeyFrameD} ${LogFile}
			echo "y" 

			echo ""
			cat ${LogFile}
			echo ""
			VP8PerforInfo_VBR=`runGetPerformanceInfo_VP9   ${LogFile}`
			echo "VP8PerforInfo_VBR ${VP8PerforInfo_VBR}"
		
			#for open h264 test
			############################################# 
			LogFile="${YUV}_Target_${TargetBitRate}_openh264.log"
			OutputFile="${YUV}_Target_${TargetBitRate}_openh264.264"
			runTest_openh264   "${TestSetPath}/${YUV}"  ${OutputFile}  ${TargetBitRate}   ${LogFile}

			
			echo ""
			cat ${LogFile}
			echo ""
			Openh264PerforInfo=`runGetPerformanceInfo_openh264   ${LogFile}`

			echo "${YUV}, ${TargetBitRate}, ,${VP9PerforInfo_VBR}, ,${VP8PerforInfo_VBR}, ,${Openh264PerforInfo}">>${AllPerformFile}
		done	
		
	done


}


#**************************************************
#call main function

InputFile=$1
MaxKeyFrameD=$2
TargetBitRate=$3
CQLevel=$4
#runMain   ${InputFile}  ${MaxKeyFrameD}  ${TargetBitRate}  ${CQLevel}

runMain_JoinTest


	

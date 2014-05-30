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
runGetPerformanceInfo()
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
			local PSNRINfo=`echo $line |awk 'BEGIN {FS=")"} {print $2}'`
			PSNROverAll=`echo $PSNRINfo | awk '{print $1}'`
			PSNRAverage=`echo $PSNRINfo | awk '{print $2}'`
			PSNRY=`echo $PSNRINfo | awk '{print $3}'`
		fi

	done <${PerformanceLogFile}

	echo "${BitRate},${FPS},${PSNROverAll},${PSNRAverage},${PSNRY}" 
	      


}


#usage
#runControlBRModTest ${InputYUV} ${OutputFile}  ${TargetBR} ${MaxKeyFrameD}  ${CPUUsed} ${DataFile}
runTest_VBR()
{

	if [ ! $# -eq 6 ]
	then
		echo "not enough parameters!"
		echo "usage: runControlBRModTest \${InputYUV} \${OutputFile}  \${TargetBR} \${MaxKeyFrameD} \${CPUUsed} \${DataFile}"
		return 1
	fi
	echo ""
	echo "VBR --good  mode......"
	echo ""

	local InputYUV=$1
	local OutputFile=$2
	local TargetBR=$3
	local MaxKeyFrameD=$4
	local LogFile="VP9Enc.log"
	local CPUUSed=$5
	local DataFile=$6
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
		--cpu-used=${CPUUSed}   \
		--psnr	--verbose	\
		--good --cpu-used=1     \
		--end-usage=vbr		\
		--passes=1  --limit=100	\
		--fps=10/1		\
		--target-bitrate=${TargetBR} \
		--kf-max-dist=${MaxKeyFrameD}"

	./vpxenc ${EncoderCommand} 2>${LogFile}
	echo ""
	echo "log file info:"
	cat ${LogFile}
	echo ""
	echo ""
	echo "log file end!"
	echo ""
	PerfINfo=`runGetPerformanceInfo   ${LogFile}`

	echo "${YUVName}, ${EncoderCommand}, ${CPUUSed},${PerfINfo}">>${DataFile}

}





#usage
#runTest_ControlBRMode ${InputYUV} ${OutputFile}  ${TargetBR} ${MaxKeyFrameD}  ${DataFile}
runTest_ControlBRMode()
{

	if [ ! $# -eq 5 ]
	then
		echo "not enough parameters!"
		echo "usage: runControlBRModTest \${InputYUV} \${OutputFile}  \${TargetBR} \${MaxKeyFrameD} \${DataFile}"
		return 1
	fi
	echo ""
	echo "Control bitrate mode......"
	echo ""

	local InputYUV=$1
	local OutputFile=$2
	local TargetBR=$3
	local MaxKeyFrameD=$4
	local LogFile="VP9Enc.log"
	local DataFile=$5

	echo "input yuv is ${InputYUV}"
	echo ""

	#get YUV detail info $picW $picH $FPS
	local PicW=""
	local PicH=""
	declare -a aYUVInfo
	aYUVInfo=(`runGetYUVInfo ${InputYUV}`)
	PicW=${aYUVInfo[0]}
	PicH=${aYUVInfo[1]}

	local EncoderCommand=" \
		 ${InputYUV}             \
		-w ${PicW} -h ${PicH}        \
		-o ${OutputFile}              \
		--codec=vp9 --cpu-used=0     \
		--psnr	--verbose		 \
		--passes=1  --limit=20	\
		--fps=10/1		\
		--target-bitrate=${TargetBR} \
		--kf-max-dist=${MaxKeyFrameD}"

	./vpxenc ${EncoderCommand} 2>${LogFile}
	echo ""
	echo "log file info:"
	cat ${LogFile}
	echo ""
	echo ""
	echo "log file end!"
	echo ""
	runGetPerformanceInfo  ${InputYUV}   "${EncoderCommand}"   ${LogFile}  ${DataFile}

}


#usage
# runTest_ConstantQualityMode  ${InputYUV} ${OutputFile} ${CQLevel} ${MaxKeyFrameD}  ${DataFile}
runTest_ConstantQualityMode()
{

	if [ ! $# -eq 5 ]
	then
		echo "not enough parameters!"
		echo "usage: runConstantQualityModeTest  \${InputYUV} \${OutputFile}  \${CQLevel} \${MaxKeyFrameD}  \${DataFile}"
		return 1
	fi
	
	echo ""
	echo "Constant quality mode (achieves a given quality level)......"
	echo ""

	local InputYUV=$1
	local OutputFile=$2
	local CQLevel=$3         #(0~64)
	local MaxKeyFrameD=$4
	local LogFile="VP9Enc.log"
	local DataFile=$5
     
	echo "input yuv is ${InputYUV}"
	echo ""

	#get YUV detail info $picW $picH $FPS
	local PicW=""
	local PicH=""
	declare -a aYUVInfo
	aYUVInfo=(`runGetYUVInfo ${InputYUV}`)
	PicW=${aYUVInfo[0]}
	PicH=${aYUVInfo[1]}
	
	local EncoderCommand="    \
			 ${InputYUV}        \
				-o ${OutputFile}		  \
				-w ${PicW} -h ${PicH}	\
				--codec=vp8			    \
				--rt			\
				--cpu-used=0  --end-usage=3    \
				--psnr  --verbose		   \
				--passes=1 --limit=10	\
				--fps=10/1		\
				--cq-level=${CQLevel}          \
				--kf-max-dist=${MaxKeyFrameD}"

	./vpxenc ${EncoderCommand} #2>${LogFile}

	echo ""
	echo "log file info:"
	#cat ${LogFile}
	echo ""
	echo ""
	echo "log file end!"
	echo ""

	runGetPerformanceInfo  ${InputYUV}   "${EncoderCommand}"   ${LogFile}  ${DataFile}
	

}



#usage
# runTest_ConstantQualityUperBRMode ${InputYUV} ${OutputFile}  ${TargetBR} ${CQLevel} ${MaxKeyFrameD} ${DataFile}
runTest_ConstantQualityUperBRMode()
{

	if [ ! $# -eq 6 ]
	then
		echo "not enough parameters!"
		echo "usage: runConstantQualityModeTest  \${InputYUV} \${OutputFile} \${TargetBR}  \${CQLevel} \${MaxKeyFrameD} \${DataFile}"
		return 1
	fi
	
	echo ""
	echo "Constrained Quality mod e (Achieves a given quality level subject to an upper bound on bitrate......"
	echo ""

	local InputYUV=$1
	local OutputFile=$2
	local TargetBR=$3
	local CQLevel=$4
	local MaxKeyFrameD=$5
	local DataFile=$6
	local LogFile="VP9Enc.log"

	echo "input yuv is ${InputYUV}"
	echo ""

	#get YUV detail info $picW $picH $FPS
	local PicW=""
	local PicH=""
	declare -a aYUVInfo
	aYUVInfo=(`runGetYUVInfo ${InputYUV}`)
	PicW=${aYUVInfo[0]}
	PicH=${aYUVInfo[1]}
	
	local EncoderCommand=" \
		 ${InputYUV}     \
		-o ${OutputFile}      \
		-w ${PicW} -h ${PicH} \
		--codec=vp9          \
		--psnr  --verbose  \
		--cpu-used=0  --end-usage=2    \
		--passes=1 --limit=10	\
		--cq-level=${CQLevel}          \
		--fps=10/1		\
		--target-bitrate=${TargetBR}   \
		--kf-max-dist=${MaxKeyFrameD}"


	./vpxenc ${EncoderCommand}  2>${LogFile}

	echo ""
	echo "log file info:"
	cat ${LogFile}
	echo ""
	echo ""
	echo "log file end!"
	echo ""

	runGetPerformanceInfo  ${InputYUV}   "${EncoderCommand}"   ${LogFile}  ${DataFile}
	

}




#usage  runMain  ${InputYUV}  ${MaxKeyFrameD} ${TargetBitRate}  ${CQLevel}
runMain_Small()
{

	if [ ! $# -eq 4 ]
	then
		echo "not enough parameters!"
		echo "usage: runMain  \${InputYUV}  \${MaxKeyFrameD} \${TargetBR}  \${CQLevel} "
		return 1
	fi
	

	echo ""
	echo "vp9 test....."
	echo ""

	local InputFile=$1
	local MaxKeyFrameD=$2
	local TargetBitRate=$3
	local CQLevel=$4
	local AllPerformFile="VP9Perform.csv"

	local YUVName=`runParseYUVName  ${InputFile}`
	local OutputFile="${YUVName}.vp9"

	#inital perfermance file
	echo "YUV, EncParm, BitRate(B), FPS, PSNR_OverAll, PSNR_Average, PSNR_Y">${AllPerformFile}


	echo "input file is ${InputFile}"
	echo "output file is ${OutputFile}"
	echo "max key frame distance is ${MaxKeyFrameD}"
	echo "target bitrate is ${TargetBitRate}"
	echo "cq level is ${CQLevel}"

	echo ""
	echo "run BR control mode...."

	#inital perfermance file
	echo "YUV, EncParm, BitRate(B), FPS, PSNR_OverAll, PSNR_Average, PSNR_Y">${AllPerformFile}

	#runControlBRModeTest  ${InputFile}  ${OutputFile}  ${TargetBitRate} ${MaxKeyFrameD} ${AllPerformFile}
	runConstantQualityModeTest  ${InputFile}  ${OutputFile}  ${CQLevel} ${MaxKeyFrameD}   ${AllPerformFile}
	#runConstantQualityUperBRModeTest ${InputFile}  ${OutputFile}  ${TargetBitRate} ${CQLevel} ${MaxKeyFrameD}  ${AllPerformFile}

}


#usage  runMain_VBR  
runMain_VBR()
{

	echo ""
	echo "vp9 VBR test....."
	echo ""

	local MaxKeyFrameD=9999
	local AllPerformFile="VP9Perform_VBR.csv"
	declare -a aCQLevel
	declare -a aTargetBitRate 
	declare -a aTestYUVSet
	declare -a aCPUUsed
	aCPUUsed=(0 1 2)
	aCQLevel=(10 20 30 40 50)
	aTargetBitRate=(256 512 768 1024 1536)
	aTestYUVSet=(BasketballDrillText_832x480_noDuplicate.yuv ) #   \
		  #CiscoVT_2people_640x384_25fps_900.yuv         \
		  #foreman_352x288_30                            \
		  #src_pic_in_enc_1440x912_DOC.yuv )

	local TestSetPath="/opt/VideoTest/YUV"

	local TestYUV=""
	local OutputFile=""

	#inital perfermance file
	echo "YUV, EncParm, CPUUsed,BitRate(B), FPS, PSNR_OverAll, PSNR_Average, PSNR_Y">${AllPerformFile}

	echo ""
	echo "VBR --good Test....">>${AllPerformFile}
	echo "">>${AllPerformFile}



	for YUV in ${aTestYUVSet[@]}
	do
		for TargetBitRate in ${aTargetBitRate[@]}
		do
			for CPUUsed in ${aCPUUsed[@]}
			do
				OutputFile="${YUV}_Target_${TargetBitRate}_CPU_${CPUUsed}.vp9"
				echo "input file is ${YUV}"
				echo "output file is ${OutputFile}"
				echo "max key frame distance is ${MaxKeyFrameD}"
				echo "target bitrate is ${TargetBitRate}"

				runTest_VBR  "${TestSetPath}/${YUV}"  ${OutputFile}  ${TargetBitRate} ${MaxKeyFrameD} ${CPUUsed} ${AllPerformFile} 		

			done

		done	
		

	done

}

#usage  runMain_VBR  
runMain_CQ()
{

	echo ""
	echo "vp9 CQ test....."
	echo ""

	local MaxKeyFrameD=9999
	local AllPerformFile="VP9Perform_VBR.csv"
	declare -a aCQLevel
	declare -a aTargetBitRate 
	declare -a aTestYUVSet
	declare -a aCPUUsed
	aCPUUsed=(0 1 2)
	aCQLevel=(10 20 30 40 50)
	aTargetBitRate=(256 512 768 1024 1536)
	aTestYUVSet=(BasketballDrillText_832x480_noDuplicate.yuv ) #   \
		  #CiscoVT_2people_640x384_25fps_900.yuv         \
		  #foreman_352x288_30                            \
		  #src_pic_in_enc_1440x912_DOC.yuv )

	local TestSetPath="/opt/VideoTest/YUV"

	local TestYUV=""
	local OutputFile=""

	#inital perfermance file
	echo "YUV, EncParm, CPUUsed,BitRate(B), FPS, PSNR_OverAll, PSNR_Average, PSNR_Y">${AllPerformFile}

	echo ""
	echo "VBR --good Test....">>${AllPerformFile}
	echo "">>${AllPerformFile}



	for YUV in ${aTestYUVSet[@]}
	do
		for TargetBitRate in ${aTargetBitRate[@]}
		do
			for CPUUsed in ${aCPUUsed[@]}
			do
				OutputFile="${YUV}_Target_${TargetBitRate}_CPU_${CPUUsed}.vp9"
				echo "input file is ${YUV}"
				echo "output file is ${OutputFile}"
				echo "max key frame distance is ${MaxKeyFrameD}"
				echo "target bitrate is ${TargetBitRate}"

				runTest_VBR  "${TestSetPath}/${YUV}"  ${OutputFile}  ${TargetBitRate} ${MaxKeyFrameD} ${CPUUsed} ${AllPerformFile} 		

			done

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

runMain_VBR


	

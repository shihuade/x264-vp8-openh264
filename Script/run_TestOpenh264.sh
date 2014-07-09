

#!/bin/bash
#usage
#runTest_openh264  $Option  ${InputYUV} ${OutputFile}   ${TargetBR}/${QP}   ${LogFile}
runTest_openh264()
{
	if [ ! $# -eq 5 ]
	then
		echo "not enough parameters!"
		echo "usage: runTest_openh264   \$Option  \${InputYUV} \${OutputFile}  \${TargetBR}   \${LogFile}"
		return 1
	fi
	echo ""
	echo "openh264 encoder....."
	echo ""
	local Option=$1
	local InputYUV=$2
	local OutputFile=$3
	local TargetBR=$4
	local LayerQP=$4
	local LogFile=$5
	local PerfINfo=""
	#get YUV detail info $picW $picH $FPS
	local PicW=""
	local PicH=""
	local FPS=""
	local EncoderCommand=""
	local YUVName=`echo  ${InputYUV} | awk 'BEGIN {FS="/"}  {print $FS}'`
	declare -a aYUVInfo
	aYUVInfo=(`./run_ParseYUVInfo.sh  ${InputYUV}`)
	PicW=${aYUVInfo[0]}
	PicH=${aYUVInfo[1]}
	FPS=${aYUVInfo[2]}
	
	if [ $PicW -eq 0  ]
	then 
		echo "Picture info is not right "
		exit 1
	fi
	if [ $FPS -eq 0 ]
	then 		
		let "FPS=30"
	fi
		
	if [[  "$Option" = "BR"  ]]
	then 
		EncoderCommand="welsenc.cfg  -numl 1	 -frms -1      \
						-lconfig 0 layer2.cfg   	   \
						-sw   ${PicW} -sh   ${PicH}    \
						-dw 0 ${PicW} -dh 0 ${PicH}    \
						-frout 0  ${FPS}               \
						-bf   ${OutputFile}            \
						-org  ${InputYUV}              \
						-tarb  ${TargetBR}             \
						-rc 1 -tarb  ${TargetBR}      \
						-ltarb 0 ${TargetBR}"
				
	elif [[  "$Option" =  "QP"  ]]
	then
		EncoderCommand="welsenc.cfg  -numl 1	  -frms -1     \
						-lconfig 0 layer2.cfg   	   \
						-sw   ${PicW} -sh   ${PicH}    \
						-dw 0 ${PicW} -dh 0 ${PicH}    \
						-frout 0  ${FPS}               \
						-bf   ${OutputFile}            \
						-org  ${InputYUV}              \
						-rc -1  -lqp  0 ${LayerQP}  "		
	else
		echo "encoder option is not right--BR---QP only!"
		exit 1
	fi
	
				
	echo "input yuv is ${InputYUV}"
	echo "Target BitRate is ${TargetBR} "
	echo ""
	echo ${EncoderCommand}
	./h264enc ${EncoderCommand} >${LogFile}
}
Option=$1
InputYUV=$2
OutputFile=$3
TargetBR=$4
LogFile=$5
runTest_openh264  ${Option}  ${InputYUV} ${OutputFile}   ${TargetBR}   ${LogFile}



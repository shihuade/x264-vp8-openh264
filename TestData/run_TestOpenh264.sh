
#!/bin/bash

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
	local FPS=""

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
		
	local EncoderCommand="welsenc.cfg  -numl 1	   \
					-lconfig 0 layer2.cfg   	   \
					-sw   ${PicW} -sh   ${PicH}    \
					-dw 0 ${PicW} -dh 0 ${PicH}    \
					-frout 0  ${FPS}               \
					-bf   ${OutputFile}            \
					-org  ${InputYUV}              \
					-rc 1  -ltarb 0 ${TargetBR}  "
		
	
				
	echo "input yuv is ${InputYUV}"
	echo "Target BitRate is ${TargetBR} "
	echo ""
	echo ${EncoderCommand}

	./h264enc ${EncoderCommand} >${LogFile}

}

InputYUV=$1
OutputFile=$2
TargetBR=$3
LogFile=$4

runTest_openh264  ${InputYUV} ${OutputFile}   ${TargetBR}   ${LogFile}





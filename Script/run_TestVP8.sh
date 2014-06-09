

#!/bin/bash
#usage
#runTest_VBR_Fast ${InputYUV}  ${OutputFile}   ${TargetBR}   ${LogFile} 
runTest_VBR_Fast()
{
	if [ ! $# -eq 4 ]
	then
		echo "not enough parameters!"
		echo "usage: runTest_VBR_Fast \${InputYUV} \${OutputFile}  \${TargetBR}  \${LogFile} "
		return 1
	fi
	echo ""
	echo "vp8 encoder VBR --good  mode......"
	echo ""
	local InputYUV=$1
	local OutputFile=$2
	local TargetBR=$3
	local LogFile=$4
	local PerfINfo=""
	echo "input yuv is ${InputYUV}"
	echo ""
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
	
	local EncoderCommand="   \
		 ${InputYUV} -o ${OutputFile}         \
		 --codec=vp8 -w ${PicW} -h ${PicH}    \
		 -p 1 -t 4   --good --cpu-used=3      \
		 --target-bitrate=${TargetBR}         \
		 --end-usage=vbr  --fps=${FPS}/1      \
		 --kf-min-dist=0 --kf-max-dist=1000    \
		 --token-parts=2 --static-thresh=1000 \
		  --min-q=0 --max-q=63                \
		  --psnr	--verbose "
		  
		
	echo ${EncoderCommand}
	./vpxenc ${EncoderCommand} 2>${LogFile}
}
InputYUV=$1
OutputFile=$2
TargetBR=$3
LogFile=$4
runTest_VBR_Fast  ${InputYUV}  ${OutputFile}   ${TargetBR}    ${LogFile} 




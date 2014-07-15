#!/bin/bash




#usage  runGetPerformanceInfo_VP8   ${PerformanceLogFile}
runGetPerformanceInfo_VP8()
{

	if [ ! $# -eq 1 ]
	then
		echo "usage: runGetPerformanceInfo_VP8 \${PerformanceLogFile}"
		return 1
	fi

	local PerformanceLogFile=$1

	local PSNROverAll=""
	local PSNRAverage=""
	local PSNRY=""
	local PSNRU=""
	local PSNRV=""

	local BitRate=""
	local FPS=""
	local EncodeTime=""

	while read line
	do 
		if [[ $line =~ "b/s"  ]]
		then
			#line looks like : ... Pass 1/1 frame ... Pass 1/1 frame   10/10     69355B   55484b/f 1664520b/s   19536 ms (0.51 fps)
			BitRate=`echo $line | awk 'BEGIN {FS="frame"} {print $NF}'`  #10/10     69355B   55484b/f 1664520b/s   19536 ms (0.51 fps)
			BitRate=`echo $BitRate | awk 'BEGIN {FS="b/f"}{print $2}'`   #1664520b/s   19536 ms (0.51 fps)
			BitRate=`echo $BitRate | awk 'BEGIN {FS="b/s"}{print $1}'`   #1664520

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
			PSNRU=`echo $PSNRInfo | awk '{print $4}'`
			PSNRV=`echo $PSNRInfo | awk '{print $5}'`
		fi

	done <${PerformanceLogFile}
        #use bc tool to transform to kbps
        BitRate=`echo "scale=2; ${BitRate}/1024"|bc`
	echo "${BitRate},${PSNRY},${PSNRU},${PSNRV},${FPS}, ${EncodeTime}" 
	      
}

PerformanceLogFile=$1
runGetPerformanceInfo_VP8 ${PerformanceLogFile}















#!/bin/bash

#usage  runGetPerformanceInfo   ${PerformanceLogFile}
runGetPerformanceInfo_openh264()
{

	if [ ! $# -eq 1 ]
	then
		echo "not enough parameters!"
		echo "usage: runGetPerformanceInfo_openh264 \${PerformanceLogFile}"
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
		fi

		if [[  "$line" =~ ^"encode time"  ]]
		then
			EncodeTime=`echo $line | awk '{print $3}'` 	
		fi
		
		if [[  "$line" =~ ^FPS:  ]]
		then
			FPS=`echo $line | awk ' {print $2}'` 	
		fi

	done <${PerformanceLogFile}

	echo "${BitRate},${PSNRY},${PSNRU},${PSNRV},${FPS}, ${EncodeTime} " 
	      

}

PerformanceLogFile=$1
runGetPerformanceInfo_openh264 ${PerformanceLogFile}




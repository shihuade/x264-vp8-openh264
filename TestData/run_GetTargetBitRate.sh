
#!/bin/bash


#usage:  usage  runGetTargetBitRate  $TestSequenceName
runGetTargetBitRate()
{
	if [ ! $# -eq 1 ]
	then
		echo "usage:  usage  runGetTargetBitRate  \$TestSequenceName"
		return 1
	fi
	
	local TestSequence=$1
	local PicW=""
	local PicH=""	
	local TotalPix=""
	declare -a aYUVInfo
	aYUVInfo=(`./run_ParseYUVInfo.sh  ${TestSequence}`)
	PicW=${aYUVInfo[0]}
	PicH=${aYUVInfo[1]}
	
	let "TotalPix=PicW * PicH"
	let "Flag_2K=1920*1080"
	let "Flag_1080p=1280*720"	
	let "Flag_720p=800*640"
	let "Flag_640=400*240"	
	let "Flag_320=320*200"	
	
	#for testtarget bitrate initial
	local BitRate_2K="2500  2000  1500  1000 500  200"
	local BitRate_1080p="2000 1200   800  500  200   120"
	local BitRate_720p="1500  1200   800  500  200   100"
	local BitRate_640="1200   800    400  200  100   80"
	local BitRate_320="1000   800    400  200  100   60"
	local BitRate_160="800    400    200  100  80    40"
	
	if [  ${TotalPix} -ge ${Flag_2K} ]
	then 
		echo "${BitRate_2K}"
	elif [  ${TotalPix} -ge ${Flag_1080p}  ]
	then 
		echo "${BitRate_1080p}"
	elif [  ${TotalPix} -ge ${Flag_720p} ]
	then 
		echo "${BitRate_720p}"
	elif [  ${TotalPix} -ge ${Flag_640}  ]
	then 
		echo "${BitRate_640}"
	elif [  ${TotalPix} -ge ${Flag_320} ]
	then 
		echo "${BitRate_320}"
	else
		echo "${BitRate_160}"
	fi
}

TestSequence=$1
runGetTargetBitRate   ${TestSequence}




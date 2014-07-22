#!/bin/bash
#usage runCheckProfile ${profile}
runCheckProfile()
{
	if [ ! $# -eq 1 ]
	then
		echo  "usage: runCheckProfile \${profile} "
		exit 1
	fi

	local ProfileName=$1
	local Flag=""
	local Profile=""
	let "Flag=0"
	declare -a aOptionList
	aOptionList=(baseline main  high)

	for Profile  in ${aOptionList[@]}
	do
		if [  ${ProfileName} =  ${Profile}   ]
		then
			let "Flag=1"
		fi
	done

	if [ ${Flag}  -eq 0 ]
	then
		echo "profile name is not right"
		echo "profile option should be set as :  ${aOptionList[@]}"
		exit 1
	fi
}
#usage runCheckProfile ${profile}
runCheckSpeed()
{
	if [ ! $# -eq 1 ]
	then
		echo  "usage runCheckProfile \${profile} "
		exit 1
	fi

	local SpeedName=$1
	local Flag=""
	local Speed="" 
	let "Flag=0"
	declare -a aOptionList
	aOptionList=(superfast veryfast faster fast medium slow veryslow)

	for Speed  in ${aOptionList[@]}
	do
		if [  ${SpeedName} =  ${Speed}   ]
		then
			let "Flag=1"
		fi
	done

	if [ ${Flag}  -eq 0 ]
	then
		echo "Speed  name is not right"
		echo "Speed option should be set as :  ${aOptionList[@]}"
		echo "detected by run_TestX264.sh"
		exit 1
	fi
}
#usage
#runTest_x264_BR ${profile}  ${Speed} ${InputYUV} ${OutputFile}  ${BitRate}   ${LogFile}
runTest_x264_BR()
{
	if [ ! $# -eq 6 ]
	then
		echo  "runTest_x264_BR \${profile}  \${Speed} \${InputYUV} \${OutputFile}  \${BitRate}   \${LogFile}"
		return 1
	fi
	echo ""
	echo "X264_BR encoder....."
	echo ""
	local Profile=$1
	local Speed=$2
	local InputYUV=$3
	local OutputFile=$4
	local BitRate=$5
	local LogFile=$6
	runCheckProfile  ${Profile}
	runCheckSpeed    ${Speed}

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

	local EncoderCommand="--profile ${Profile} \
				--keyint infinite      \
				--preset ${Speed}      \
				--psnr  --no-psy \
				--aq-mode 0    \
				--me dia   --slices 1  \
				--slices 1 --threads 1 \
				--bitrate ${BitRate}   \
				--deblock 0:0          \
				--fps  ${FPS}          \
				-o ${OutputFile}       \
				${InputYUV}"

	echo ""
	echo ${EncoderCommand}
	echo ""

	./x264 ${EncoderCommand} 2>${LogFile}
}

#usage
#runTest_x264_QP ${profile}  ${Speed} ${InputYUV} ${OutputFile}  ${BitRate}   ${LogFile}
runTest_x264_QP()
{
	if [ ! $# -eq 6 ]
	then
		echo  "runTest_x264_QP \${profile}  \${Speed} \${InputYUV} \${OutputFile}  \${BitRate}   \${LogFile}"
		return 1
	fi
	echo ""
	echo "X264_BR encoder....."
	echo ""
	local Profile=$1
	local Speed=$2
	local InputYUV=$3
	local OutputFile=$4
	local QP=$5
	local LogFile=$6
	runCheckProfile  ${Profile}
	runCheckSpeed    ${Speed}

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

	local EncoderCommand="--profile ${Profile}     \
				--preset ${Speed}      \
				--keyint infinite      \
				--psnr  --no-psy \
				--aq-mode 0    \
				--me dia  	--qp ${QP} \
				--slices 1 --threads 1 \
				--deblock 0:0          \
				--fps  ${FPS}          \
				-o ${OutputFile}       \
				${InputYUV}"

	echo ""
	echo ${EncoderCommand}
	echo ""

	./x264 ${EncoderCommand} 2>${LogFile}
}



#usage: runTest_x264_Index1 ${profile} ${InputYUV} ${OutputFile}  ${BitRate}   ${LogFile}
runTest_x264_Index1()
{
	if [ ! $# -eq 5 ]
	then
		echo  "usage: runTest_x264_Index1 \${profile}   \${InputYUV} \${OutputFile}  \${BitRate}   \${LogFile}"
		return 1
	fi
	echo ""
	echo "X264_Index_1 encoder-----rc-lookahead 25  veryfast<speed<faster....."
	echo ""
	local Profile=$1
	local InputYUV=$2
	local OutputFile=$3
	local BitRate=$4
	local LogFile=$5
	runCheckProfile  ${Profile}

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
    # --rc-lookahead 25  veryfast<speed<faster
	local EncoderCommand="--profile ${Profile}    \
				--no-mixed-refs  --ref 4 \
				--psnr  --no-psy \
				--rc-lookahead 15 \
                --me hex --subme 7	   \
				--aq-mode 0    \
				--slices 1 --threads 1 \
				--bitrate ${BitRate}   \
				--deblock 0:0          \
				--fps  ${FPS}          \
				-o ${OutputFile}       \
				${InputYUV}"

	echo ""
	echo ${EncoderCommand}
	echo ""

	./x264 ${EncoderCommand} 2>${LogFile}
}

#usage: runTest_x264_Index2 ${profile} ${InputYUV} ${OutputFile}  ${BitRate}   ${LogFile}
runTest_x264_Index2()
{
	if [ ! $# -eq 5 ]
	then
		echo  "usage: runTest_x264_Index2  \${profile}   \${InputYUV} \${OutputFile}  \${BitRate}   \${LogFile}"
		return 1
	fi
	echo ""
	echo "x264 encoding----rc-lookahead 25  veryfast<speed<faster"
	echo ""
	local Profile=$1
	local InputYUV=$2
	local OutputFile=$3
	local QP=$4
	local LogFile=$5
	runCheckProfile  ${Profile}

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
    # --rc-lookahead 25  veryfast<speed<faster
	local EncoderCommand="--profile ${Profile}  \
				--no-mixed-refs  --ref 4 \
				--psnr  --no-psy \
				--rc-lookahead 15 \
                --me hex --subme 7	   \
				--aq-mode 0   \
				--slices 1 --threads 1 \
				--qp ${QP}             \
				--deblock 0:0          \
				--fps  ${FPS}          \
				-o ${OutputFile}       \
				${InputYUV}"
	echo ""
	echo ${EncoderCommand}
	echo ""

	./x264 ${EncoderCommand} 2>${LogFile}
}


#usage: runMain  ${TestIndex}  ${profile}  ${Speed} ${InputYUV} ${OutputFile}  ${BitRate} ${QP}  ${LogFile}
runMain()
{
	if [ ! $# -eq 8 ]
	then
		echo  "runMain  \${TestIndex} \${profile}  \${Speed} \${InputYUV} \${OutputFile}  \${BitRate}  \${QP} \${LogFile}"
		return 1
	fi

	local TestIndex=$1
	local Profile=$2
	local Speed=$3
	local InputYUV=$4
	local OutputFile=$5
	local BitRate=$6
	local QP=$7
	local LogFile=$8

	if [ ${TestIndex} -eq 0  ]
	then
		runTest_x264_BR  ${Profile}  ${Speed} ${InputYUV} ${OutputFile}  ${BitRate}   ${LogFile}
	fi

	if [ ${TestIndex} -eq 1  ]
	then
		runTest_x264_QP  ${Profile}  ${Speed}   ${InputYUV} ${OutputFile}  ${QP}    ${LogFile}
	fi
	
	
	if [ ${TestIndex} -eq 2  ]
	then
		runTest_x264_Index1  ${Profile}  ${InputYUV} ${OutputFile}  ${BitRate}   ${LogFile}
	fi

	if [ ${TestIndex} -eq 3  ]
	then
		runTest_x264_Index2  ${Profile}  ${InputYUV} ${OutputFile}  ${QP}   ${LogFile}
	fi	

}

TestIndex=$1
Profile=$2
Speed=$3
InputYUV=$4
OutputFile=$5
BitRate=$6
QP=$7
LogFile=$8
runMain   ${TestIndex}  ${Profile}  ${Speed} ${InputYUV} ${OutputFile}  ${BitRate}  ${QP} ${LogFile}


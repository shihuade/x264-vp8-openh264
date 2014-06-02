
#!/bin/bash



#usage: runGetYUVPath  ${YUVName}  ${FindScope}
runGetYUVPath()
{
	if [ ! $# -eq 2 ]
	then
		echo "runGetYUVPath  \${YUVName}  \${FindScope} "
		return 1
	fi
	
	local YUVName=$1
	local FindScope=$2
	local YUVFullPath="" 
	local Log="find.result"
	local CurrentDir=`pwd`
	
	if [ ! -d ${FindScope} ]
	then
		echo "find scopr not right..."
		exit 1
	else
		cd ${FindScope}
		FindScope=`pwd`
		cd ${CurrentDir}
	fi
	
	find   ${FindScope}  -name  ${YUVName}>${Log}	
	while read line 
	do
		YUVFullPath=${line}
		break
	done <${Log}
	
	echo ${YUVFullPath}
	
}

YUVName=$1
FindScope=$2
runGetYUVPath  ${YUVName}  ${FindScope}



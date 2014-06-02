
#!/bin/bash

#usage: runGetYUVNameList   ${YUVFolder} 
runGetYUVNameList()
{
	if [ ! $# -eq 1 ]
	then
		echo "usage: runGetYUVNameList   \${YUVFolder} "
		return 1
	fi


	local YUVFolder=$1
	local FileName=""
	local TempLog="YUVNameList.log"
	
	if [ ! -d ${YUVFolder}  ]
	then
		echo "folder not right..."
		exit 1
	fi
	
	ls -lR ${YUVFolder}>${TempLog}
	
	
	while read line 
	do
		if [[  "${line}" =~ ".yuv" ]]
		then
			FileName=`echo  $line | awk '{print $NF }'`
			echo $FileName
		fi
	done <${TempLog}

}

YUVFolder=$1
runGetYUVNameList   ${YUVFolder} 







#!/bin/bash

#******************************************************************************************************
#  usage:     ./run_SafeDelere.sh  $DeleteItermPath
#   eg:    1  ./run_SafeDelere.sh  tempdata.info   --->delete only one file
#   eg:    2  ./run_SafeDelere.sh  ../TempDataFolder   --->delete entire folder
#			  ./run_SafeDelere.sh  /opt/TempData/ABC
#                                  ../../../ABC
#                                  ABC
#******************************************************************************************************


#******************************************************************************************************
#usage: runGetItermInfo  $FilePath
runGetFileName()
{
	#parameter check! 
	if [ ! $# -eq 1  ]
	then
		echo "usage: runGetItermInfo  \$FilePath"
		return 1
	 fi
	 
	 local PathInfo=$1
	 local FileName=""
	 
	if [[  $PathInfo  =~ ^"/"  ]]
	 then
		FileName=` echo ${PathInfo} | awk 'BEGIN {FS="/"}; {print $NF}'`
		echo "${FileName}"
		return 0
	 elif [[  $PathInfo  =~ ^".."  ]]
	 then
		FileName=` echo ${PathInfo} | awk 'BEGIN {FS="/"}; {print $NF}'`
		echo "${FileName}"
		return 0
	 else
		FileName=${PathInfo}
		echo "${FileName}"
		return 0     
	 fi	 
	 
}



#******************************************************************************************************
#usage:  runGetFileFullPath  $FilePathInfo 
#eg:  current path is /opt/VideoTest/openh264/ABC
#     runGetFileFullPath  abc.txt                  --->/opt/VideoTest/openh264/ABC
#     runGetFileFullPath  ../123.txt               --->/opt/VideoTest/openh264
#     runGetFileFullPath  /opt/VieoTest/456.txt    --->/opt/VieoTest
runGetFileFullPath()
{
	#parameter check! 
	if [ ! $# -eq 1  ]
	then
		echo "usage:  runGetFullPath  \$FilePathInfo "
		return 1
	 fi
	 
	 local PathInfo=$1
	 local FullPath=""
	 local CurrentDir=`pwd`
	 
	 if [[  $PathInfo  =~ ^"/"  ]]
	 then
		FullPath=`echo ${PathInfo} |awk 'BEGIN {FS="/"} {for (i=1;i<NF;i++) printf("%s/",$i)}'`
		cd ${FullPath}
		FullPath=`pwd`
		cd ${CurrentDir}
		echo "${FullPath}"
		return 0
	 elif [[  $PathInfo  =~ ^".."  ]]
	 then
		FullPath=`echo ${PathInfo} |awk 'BEGIN {FS="/"} {for (i=1;i<NF;i++) printf("%s/",$i)}'`
		cd ${FullPath}
		FullPath=`pwd`
		cd ${CurrentDir}
		echo "${FullPath}"
		return 0
	 else
		FullPath=${CurrentDir}
		echo "${FullPath}"
		return 0     
	 fi 
}



#******************************************************************************************************
#usage:  runGetFolderFullPath  $FolderPathInfo 
#eg:  current path is /opt/VideoTest/openh264/ABC
#     runGetFolderFullPat   SubFolder             --->/opt/VideoTest/openh264/ABC/ SubFolder 
#     runGetFolderFullPat  ../EFG              --->/opt/VideoTest/openh264/EFG  
#     runGetFolderFullPat  /opt/VieoTest/MyFolder    --->/opt/VieoTest/MyFolder
runGetFolderFullPath()
{
	#parameter check! 
	if [ ! $# -eq 1  ]
	then
		echo "usage:  runGetFullPath  \$FolderPathInfo  "
		return 1
	 fi
	 
	 local PathInfo=$1
	 local FullPath=""
	 local CurrentDir=`pwd`
	 
	 if [[  $PathInfo  =~ ^"/"  ]]
	 then	 
		FullPath=${PathInfo}
		cd ${FullPath}
		FullPath=`pwd`
		cd ${CurrentDir}
		echo "${FullPath}"
		return 0
	 elif [[  $PathInfo  =~ ^".."  ]]
	 then
		cd ${PathInfo}
		FullPath=`pwd`
		cd ${CurrentDir}
		echo "${FullPath}"
		return 0
	 else
		FullPath="${CurrentDir}/${PathInfo}"
		cd ${FullPath}
		FullPath=`pwd`
		cd ${CurrentDir}	
		echo "${FullPath}"
		return 0     
	 fi
	 
}


#******************************************************************************************************
#usage: runUserNameCheck  $whoami
runUserNameCheck()
{
	#parameter check! 
	if [ ! $# -eq 1  ]
	then
		echo "usage: runUserNameCheck  \$whoami"
		return 1
	 fi
	 
	local UserName=$1
	
	if [  ${UserName} = "root"  ]
	then 
		echo ""
		echo "*********************************************"
		echo "delete files under root is not allowed"
		echo "detected by run_SafeDelere.sh"
		return 1
	else
		echo ""
		return 0
	fi

}


#******************************************************************************************************
#usage:  runFolderLocationCheck  $FullPath
runFolderLocationCheck()
{
	#parameter check! 
	if [ ! $# -eq 1  ]
	then
		echo "usage:  runFolderLocationCheck  \$FullPath"
		return 1
	 fi
	
	local Location=$1
	local FileDirDepth=`echo ${Location} | awk 'BEGIN {FS="/"} {print NF}'`

	
	#for other non-project folder data protection
	#eg /opt/VideoTest/deleteiterm depth=4
	if [  $FileDirDepth -lt 5 ]
	then
		echo ""
		echo "*********************************************"	
		echo "FileDepth is  $FileDirDepth not matched the minimand depth(5)"
		echo "unsafe delete! try to delete non-project related files: $FileDir"
		echo "detected by run_SafeDelere.sh"
		return 1
	fi
		
	return 0

}


#******************************************************************************************************
#usage runSafeDelete $Pathinfo
runSafeDelete()
{
	#parameter check! 
	if [ ! $# -eq 1  ]
	then
		echo "usage runSafeDelete \FileFullPath"
		return 1
	 fi
	 
	local PathInfo=$1
	local UserName=`whoami`
	local FullPath=""
	local DeleteIterm=""
	local FileName=""
	
	#user validity check
	runUserNameCheck  ${UserName}
	if [ ! $? -eq 0 ]
	then
		return 1
	fi
	
	#get full path
	if [  -d $PathInfo  ]
	then
		FullPath=`runGetFolderFullPath  ${PathInfo} `
	elif [ -f $PathInfo ]
	then 
		FullPath=`runGetFileFullPath  ${PathInfo} `
	else
		echo "delete iterm is not exist"
		echo "detected by run_SafeDelere.sh"
		return 1
	fi
	echo ""
	echo "FullPath is ${FullPath}"

	#location  validity check
	runFolderLocationCheck ${FullPath}
	if [ ! $? -eq 0 ]
	then
		return 1
	fi
	
	#delete file/folder
	if [  -d $PathInfo  ]
	then
		DeleteIterm=${FullPath}
		echo "delete iterm is:  $DeleteIterm"
		rm -rf ${DeleteIterm}
	elif [ -f $PathInfo ]
	then 
		FileName=`runGetFileName ${PathInfo}`
		DeleteIterm="${FullPath}/${FileName}"
		echo "delete iterm is:  $DeleteIterm"	
		rm  ${DeleteIterm}
	fi	
	

}


PathInfo=$1
echo ""
echo "deleting ......."
echo ""
runSafeDelete $PathInfo
echo ""
echo ""






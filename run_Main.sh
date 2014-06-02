
#!/bin/bash

#usage: runMain   ${ConfigureFile} ${SequenceLocation}
runMain()
{

	if [ ! $# -eq 2 ]
	then
		echo "usage: runMain   \${ConfigureFile} \${SequenceLocation} "
		return 1
	fi

	local ConfigureFile=$1
	local SequenceLocation=$2
	
	local ScriptFolder="Script"
	local CodecFodler="Codec"
	local ConfigureFile="YUV.cfg"
	local TestDataFolder="TestData"
	local CurrentDir=`pwd`
	
	if [ -d ${TestDataFolder} ]
	then
		${ScriptFolder}/run_SafeDelete.sh  ${TestDataFolder}
	fi
	
	mkdir  ${TestDataFolder}
	
	echo ""
	echo "preparing test space.."
	cp ${ScriptFolder}/*   ${TestDataFolder}
	cp ${CodecFodler}/*   ${TestDataFolder}
    cp ${ConfigureFile}   ${TestDataFolder}
	echo ""
	
	cd ${SequenceLocation}
	SequenceLocation=`pwd`
	cd ${CurrentDir}

	echo "enter into test space.."
	echo ""
	cd  ${TestDataFolder}
	./run_AllTestSequence.sh   ${ConfigureFile} ${SequenceLocation}	
	cd ${CurrentDir}
	echo ""
	
	echo "copy final result file... "
	cp ${TestDataFolder}/*.csv  ./
	echo ""
	
	echo "all test completed!"
	
	
}

ConfigureFile=$1
SequenceLocation=$2
runMain   ${ConfigureFile} ${SequenceLocation}






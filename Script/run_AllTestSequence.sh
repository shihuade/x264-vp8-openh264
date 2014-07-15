#!/bin/bash


#usage: runAllTestSequence  ${ConfigureFile} ${SequenceLocation}
runAllTestSequence()
{

        if [ ! $# -eq 2 ]
        then
                echo "usage: runAllTestSequence \${ConfigureFile} \${SequenceLocation} "
                return 1
        fi

        local ConfigureFile=$1
        local SequenceLocation=$2
        local FinalResultFile="AllTestSequence.csv"

        local TestYUVName=""
        local TestYUV=""
        local line=""

        ./run_GenerateHeadLine.sh  ${FinalResultFile}

        while read line
        do
                if [ -n "$line"  ]
                then
                        TestYUVName="$line"
                        echo "current YUV is:  $TestYUVName"
                        TestYUV=`./run_GetYUVPath.sh  ${TestYUVName}  ${SequenceLocation}`
                        if [ -n  "${TestYUV}"  ]
                        then
                                echo "test YUV: ${TestYUVName} is under testing..."
                                echo "Test yuv full path is ${TestYUV} "
                                ./run_OneTestSequence.sh  ${TestYUV} ${FinalResultFile}
                                echo ""
                        else
                                echo "can not find Test YUV : ${YUVName}"
                        fi
                fi

        done <${ConfigureFile}




}

ConfigureFile=$1
SequenceLocation=$2

runAllTestSequence  ${ConfigureFile} ${SequenceLocation}



#!/bin/bash
#usage: runGenerateHeadLine ${FinalResultFile} 
runGenerateHeadLine()
{
	if [ ! $# -eq 1 ]
	then
		echo "usage: runGenerateHeadLine \${FinalResultFile} "
		return 1
	fi
	
	
	local FinalResultFile=$1
	local HeadLineOpenh264_1="TestSequence, openh264QP ,  ,      ,       ,   ,   , , openh264BR,  ,       ,      ,   ,   ,"
	local HeadLineOpenh264_2="            , BR,     PSNR_Y, PSNR_U,PSNR_V,FPS, ET, , BR,    PSNR_Y, PSNR_U,PSNR_V,FPS, ET,"
	
	local HeadLineX264_1="X264_Baseline_BR,  ,  ,  ,   ,   , X264_Baseline_faster_QP,  ,  ,  ,    ,  ,  X264_Baseline_veryfast_QP,  ,  ,  ,    ,   ,  X264_Baseline_superfaster_QP,  ,  ,  ,    ,  "
	local HeadLineX264_2="BR, PSNR_Y,PSNR_U,PSNR_V,	FPS,   ,  BR, PSNR_Y,PSNR_U,PSNR_V,  FPS,  ,  BR, PSNR_Y,PSNR_U,PSNR_V,  FPS,   ,  BR, PSNR_Y,PSNR_U,PSNR_V,   FPS,"
	
	
	echo "${HeadLineOpenh264_1}  ,  ${HeadLineX264_1}">${FinalResultFile}
	echo "${HeadLineOpenh264_2}  ,  ${HeadLineX264_2}">>${FinalResultFile}
	
}
FinalResultFile=$1
runGenerateHeadLine ${FinalResultFile} 



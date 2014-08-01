x264-vp8-openh264
=================

- this repositiry is about VP9 and HEVC x264 compare under linux (shell script)

- for psnr info output;
  need to enable below macro in file as264_common.h ( Ciscoopenh264 project )

      #define FRAME_INFO_OUTPUT
      #define STAT_OUTPUT
      #define ENABLE_PSNR_CALC

Usage:
-----
- ./run_Main.sh  YUV.cfg  YUVDir
-     (script will search YUV file under given YUVDir)
-     AllTestSequence.csv contain all YUV test data like psnr, bit rate, fps and encoder time.

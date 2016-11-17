;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								                                                   ;
;  This script retrieves variable data from a wrfout file and      ;
;  writes each data point as a line to a text file.                ;
;  From there, parse.py can be used to analyze data further.       ;
;								                                                   ;
;  Ryan Clare					                                       		   ;
;  17 October, 2016			                                  			   ;
;  University of Wisconsin-Madison		                      		   ;
;								                                                   ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl" 
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl" 

begin

  ; load in the wrfout file(s) 
  fList = systemfunc("ls -1 wrfout*") 
  nFiles = dimsizes(fList) 

  do iFile = 0, nFiles - 1

    filename = sprinti("slp%03d.txt",iFile)

    a = addfile(fList(iFile),"r")	

    slp = wrf_user_getvar(a,"slp",-1) 			

    asciiwrite(filename, slp)

  end do

end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                   ;
;   wrf_pv_diff.ncl reads two sets of wrfout files, with different  ;
;   naming conventions, and creates plots for the difference        ;
;   between the second and the first (which can easily be changed   ;
;   to the first minus the second).		                      		    ;
;   You need to be sure that the times between the two are properly ;
;   synced and that both sets have the same number of files before  ;
;   proceeding.	                                    						    ;
;								                                                    ;
;   Ryan Clare				                                    			    ;
;   November, 2016		                                   				    ;
;   University of Wisconsin-Madison		                       		    ;
;								                                                    ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

print("Ensure that the dates and naming conventions in the code are correct before proceeding")

fig_title = "December 16, 2007 - December 17, 2007 PV Diff"

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"

begin

; load wrfout files - wrfout* and nosno_wrfout* files.
  fList = systemfunc("ls -1 wrfout*")
  gList = systemfunc("ls -1 nosno_*")
  nFiles = dimsizes(fList) 

  do iFile = 0, nFiles - 1      ; FILE LOOP

  ; create a workstation 
    filename = sprinti("pv_diff/pv_diff%03d",iFile)
    wks = gsn_open_wks("png",filename) 

  ; Set resources
    res = True
    pltres = True
    mpres = True
    res@MainTitle = fig_title
    mpres@mpGeophysicalLineColor = "Black" 
    mpres@mpNationalLineColor = "Black" 
    mpres@mpUSStateLineColor = "Black" 

  ; open wrfout files 
    a = addfile(fList(iFile),"r")
    b = addfile(gList(iFile),"r")  

    print("wrfouts opened") 

  ; time
    times  = wrf_user_getvar(a,"times",-1) 	; get times in the file
    res@TimeLabel = times   			; Set Valid time to use on plots

  ; Get the data
    pvo_a   = wrf_user_getvar(a,"pvo",-1)
    p_a     = wrf_user_getvar(a,"pressure",-1)

    pvo_b   = wrf_user_getvar(b,"pvo",-1)
    p_b     = wrf_user_getvar(b,"pressure",-1)


  ; Interpolate to pressure
    pv_plane_a = wrf_user_intrp3d(pvo_a,p_a,"h",500.,0,False)
    pv_plane_b = wrf_user_intrp3d(pvo_b,p_b,"h",500.,0,False)

  ; Find the difference
    pv_diff = pv_plane_b - pv_plane_a

    ; Plotting options 
      opts = res                         
      opts@cnFillOn = True  
    ; May need to adjust contour parameters for each case - I suggest leaving blank initially
      opts@ContourParameters = (/ -1.6, 1.6, .4/)
      contour = wrf_contour(a,wks,pv_diff(0,:,:),opts)
      delete(opts)

    ; MAKE PLOTS                                       
      plot = wrf_map_overlays(a,wks,(/contour/),pltres,mpres)


  end do        ; END OF FILE LOOP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

end

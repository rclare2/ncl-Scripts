
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This ncl script retrieves potential vorticity and snow depth data from a list of   ;
; wrfout files and superimposes semitransparent potential vorticity over snow depth. ;
;                                                                                    ;
; Ryan Clare                                                                         ;
; September, 2016                                                                    ;
; University of Wisconsin-Madison                                                    ;
;                                                                                    ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Title will be displayed at top of figure
fig_title = "24 February - 27 February, 2008"             

; Load necessary libraries (These are probably loaded by default, anyway)
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"

begin

  fList = systemfunc("ls -1 wrfout*")                ; Load and store listed wrfout file(s) from current directory 
  nFiles = dimsizes(fList)                           ; Variable for number of files for looping purposes

  do iFile = 0, nFiles - 1                           ; Loop through each file

    filename = sprinti("pv_snow_tests/pv_snow%03d",iFile)  ; Save output as pv_snow*** to directory pv_snow_tests
    wks = gsn_open_wks("png",filename)               ; Save as a png

  ; Open individual files
    a = addfile(fList(iFile),"r")                    ; Open the wrfout file as "a"
    print("wrfout opened") 

  ; Set some basic resources
    res                     = True 
    pltres                  = True
    pltres@NoTitles         = True                   ; Avoid auto titles
    mpres                   = True
    times = wrf_user_list_times(a)    
  ;  res@MainTitle           = fig_title             ; Set fig_title as Main Title
    mpres@mpGeophysicalLineColor = "Black"
    mpres@mpNationalLineColor = "Black" 
    mpres@mpUSStateLineColor = "Black"
    res@gsnDraw             = False                  ; Don't draw plots or advance
    res@gsnFrame            = False                  ; Frame (need to overlay later)
    res@cnFillOn            = True                   ; Turn on contour fill
    res@cnInfoLabelOn       = False                  ; Turn off info label
    res@cnLineLabelsOn      = False                  ; Turn off line labels

  ; Define both plots
    snores = res                                     ; Resources for snow layer
    pvres = res                                      ; Resources for pv layer

  ; Time
    times = wrf_user_getvar(a,"times",-1)            ; Get times in the file
    snores@ValidTime = True
    snores@TimeLabel = times                         ; Set Valid time to use on plots
    snores@MainTitle = fig_title                     ; Puts fig_title onto snow (base) layer

  ; Get WRF variables
    pvo = wrf_user_getvar(a,"pvo",-1)                ; Get potential vorticity data                       
    snow = wrf_user_getvar(a,"SNOWH",-1)             ; Get physical snow depth 
    p    = wrf_user_getvar(a,"pressure",-1)          ; Get pressure data

  ; Unit conversions 
    snow	= snow * 39.3701                           ; Convert snow depth to inches
    snow@units = "in"                                ; Set snow depth units as inches

  ; Interpolate to pressure
    pv_plane = wrf_user_intrp3d(pvo,p,"h",500.,0,False)  ; Display potential vorticity at a certain pressure height


  ; Contour resources specific to snow depth (base) plot
    snores@cnLinesOn            = False              ; No contour lines
    snores@cnLevelSelectionMode = "ExplicitLevels"   ; Set explicit contour levels
    snores@cnLevels = (/ 0, .2, .4, .6, .8, 1./)     ; Set levels
    snores@cnFillPalette = "GreenYellow"             ; Set color map
    snores@gsnSpreadColorEnd = -124                  ; End 124th from the last color in color map

  ; Create the base plot
  ; base_plot = gsn_csm_contour(wks,snow(0,:,:),snores)   ; This is off because some resource commands will be nonresponsive to this command
    base_plot = wrf_contour(a,wks,snow(0,:,:),snores)     ; This is the alternative, though it has its own limitations...


  ; Contour resources specific to potential vorticity (overlay) plot
    pvres@cnLevelSelectionMode = "ManualLevels"      ; Manual setting of contour levels
    pvres@cnMinLevelValF       = 0                   ; Minimum at zero
    pvres@cnMaxLevelValF       = 3.5                 ; Max at 3.5
    pvres@cnLevelSpacingF      = 0.5                 ; Increments of .5
    pvres@cnFillPalette = "CBR_coldhot"              ; Set color map
    pvres@cnLinesOn            = False               ; Contour lines off
    pvres@lbOrientation        = "Vertical"          ; Indicate color scheme in horizontal bar below

  ; Create potential vorticity overlay
    pvres@cnFillOpacityF = 0.4                       ; Sets overlay as mostly transparent
    opaque_plot = gsn_csm_contour(wks,pv_plane(0,:,:),pvres)

  ; Now plot them one over the other with the map
    plot = wrf_map_overlays(a,wks,(/base_plot,opaque_plot/),pltres,mpres)

    print("Plot created.")

  end do                                             ; End file loop

end                                                  ; End program

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                   ;
;  This replaces major snow variable values in a file with zeros.   ;
;                                                                   ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


begin

  in = addfile("./wrfrst_d01_2007-12-16_00:00:00.nc","w")

  sn1 = wrf_user_getvar(in,"SNOWC", -1)   ;snow cover
  sn2 = wrf_user_getvar(in,"SNOW", -1)    ;snow water equivalent
  sn3 = wrf_user_getvar(in,"SNOWH", -1)   ;physical snow depth
  
  mFiles = dimsizes(sn1)
  nFiles = dimsizes(sn2)
  oFiles = dimsizes(sn3)

  snowc = new(mFiles,integer)
  snow = new(nFiles,integer)
  snowh = new(oFiles,integer)

  snowc(:,:,:) = 0
  snow(:,:,:) = 0
  snowh(:,:,:) = 0

  in->SNOWC=(/snowc/)
  in->SNOW=(/snow/)
  in->SNOWH=(/snowh/)

end

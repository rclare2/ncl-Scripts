;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                               ;
;  Takes netCDF data (of WRF model output, for example) and     ;
;  creates a new netCDF file with pressure level coordinates    ;
;  containing height and 2 m air temperature data.  This is     ;
;  helpful for examining pressure level data in WRF model       ;
;  output which instead relies on eta vertical coordinates.     ;
;  The use of height and 2 m temperature data is specifically   ;
;  for PV analysis.  Other variables can be added easily.       ;
;                                                               ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;===============================================================;
;  User inputs                                                  ;
;    The following variables should be adjusted according to    ;
;    which file you will be obtaining the data from, as well as ;
;    the domain size and the length of the date/time string.    ;
;===============================================================;

original_file = "Case12_T-0_no-alter_2005-03-06_06:00:00"
npres = 19              ; Number of desired pressure levels
nlat = 143              ; Meridional domain size
nlon = 209              ; Zonal domain size
nDSL = 19               ; Size of the DateStrLen

; Which directory the new file will be stored in
dirname = "/air/rclare/WRF_OUTs/ncl_netCDF_test/"

; Name for new file (if "False", it will auto-generate)
filename = False


;===============================================================;
;  Extract/create new data fields                               ;
;===============================================================;

; Extract data from original file
a = addfile(original_file, "r")
t = a->Times
lat = wrf_user_getvar(a, "lat", -1)
lon = wrf_user_getvar(a, "lon", -1)
z = wrf_user_getvar(a, "height", -1)
T = a->T2               ; 2 m air temperature

; Create pressure levels
Ps = new((/1,19/),"float")
Ps(0,0) = 1000.
Ps(0,1) = 950.
Ps(0,2) = 900.
Ps(0,3) = 850.
Ps(0,4) = 800.
Ps(0,5) = 750.
Ps(0,6) = 700.
Ps(0,7) = 650.
Ps(0,8) = 600.
Ps(0,9) = 550.
Ps(0,10) = 500.
Ps(0,11) = 450.
Ps(0,12) = 400.
Ps(0,13) = 350.
Ps(0,14) = 300.
Ps(0,15) = 250.
Ps(0,16) = 200.
Ps(0,17) = 150.
Ps(0,18) = 100.

; Add base pressure to pressure perturbation to get actual
pbs = a->PB
pp = a->P
P = pbs+pp

; Interpolate different 2D pressure levels
plane1000 = wrf_user_intrp3d(z,P,"h",1000.,0,False)
plane950 = wrf_user_intrp3d(z,P,"h",950.,0,False)
plane900 = wrf_user_intrp3d(z,P,"h",900.,0,False)
plane850 = wrf_user_intrp3d(z,P,"h",850.,0,False)
plane800 = wrf_user_intrp3d(z,P,"h",800.,0,False)
plane750 = wrf_user_intrp3d(z,P,"h",750.,0,False)
plane700 = wrf_user_intrp3d(z,P,"h",700.,0,False)
plane650 = wrf_user_intrp3d(z,P,"h",650.,0,False)
plane600 = wrf_user_intrp3d(z,P,"h",600.,0,False)
plane550 = wrf_user_intrp3d(z,P,"h",550.,0,False)
plane500 = wrf_user_intrp3d(z,P,"h",500.,0,False)
plane450 = wrf_user_intrp3d(z,P,"h",450.,0,False)
plane400 = wrf_user_intrp3d(z,P,"h",400.,0,False)
plane350 = wrf_user_intrp3d(z,P,"h",350.,0,False)
plane300 = wrf_user_intrp3d(z,P,"h",300.,0,False)
plane250 = wrf_user_intrp3d(z,P,"h",250.,0,False)
plane200 = wrf_user_intrp3d(z,P,"h",200.,0,False)
plane150 = wrf_user_intrp3d(z,P,"h",150.,0,False)
plane100 = wrf_user_intrp3d(z,P,"h",100.,0,False)

; Combine pressure levels into one 3D field
height_field = (/plane1000(0,:,:),plane950(0,:,:),plane900(0,:,:),\
plane850(0,:,:),plane800(0,:,:),plane750(0,:,:),plane700(0,:,:),plane650(0,:,:),\
plane600(0,:,:),plane550(0,:,:),plane500(0,:,:),plane450(0,:,:),plane400(0,:,:),\
plane350(0,:,:),plane300(0,:,:),plane250(0,:,:),plane200(0,:,:),plane150(0,:,:),\
plane100(0,:,:)/)

HEIGHT = new((/1,npres,nlat,nlon/),"float")
HEIGHT(0,:,:,:) = height_field


;===============================================================;
;  Create new netCDF file                                       ;
;===============================================================;

if (filename .eq. False) then
 strs = str_split(original_file, "_")
 case_no = strs(0)
 case_date = str_join(strs(-2:), "_")
 filo = case_no + "_" + case_date + ".nc"
else
 filo = filename
end if

diro = dirname
fout = addfile(diro + filo, "c")

setfileoption(fout,"DefineMode",True)


;===============================================================;
; Global attributes                                             ;
;===============================================================;

fAtt = True
fAtt@title = "netCDF test"
fAtt@source_file = original_file
fAtt@Conventions = "None"
fAtt@creation_date = systemfunc("date")
fileattdef(fout,fAtt)


;===============================================================;
; Variable attributes                                           ;
;===============================================================;

dimNames = (/"Time", "DateStrLen", "south_north", "west_east", "pres"/)  
dimSizes = (/ -1   ,  nDSL, nlat,  nlon, npres /) 
dimUnlim = (/ True , False, False, False, False/)   
filedimdef(fout,dimNames,dimSizes,dimUnlim)

filevardef(fout,"Time",typeof(t),getvardims(t))
filevardef(fout,"pres",typeof(Ps),(/"Time", "pres"/))
filevardef(fout,"lat",typeof(lat),getvardims(lat))
filevardef(fout,"lon",typeof(lon),getvardims(lon))
filevardef(fout,"hgt",typeof(Ps),(/"Time", "pres", "south_north", "west_east"/))
filevardef(fout,"temp",typeof(T),getvardims(T))

PresAtt=0
PresAtt@units = "hPa"
PresAtt@long_name = "Pressure Levels"
PresAtt@MemoryOrder = "XY"
PresAtt@coordinates = "XLONG XLAT XTIME"
filevarattdef(fout, "pres", PresAtt )

HgtAtt=0
HgtAtt@units = "m"
HgtAtt@long_name = "Geopotential height"
HgtAtt@MemoryOrder = "XYZ"
HgtAtt@coordinates = "XLONG XLAT XPRES XTIME"
filevarattdef(fout, "hgt", HgtAtt)

filevarattdef(fout,"Time",t)
filevarattdef(fout,"lon",lon)
filevarattdef(fout,"lat",lat)
filevarattdef(fout,"temp",T)

setfileoption(fout,"DefineMode",False)


;===============================================================;
; Writing to the new file                                       ;
;===============================================================;

fout->Time   = (/t/)
fout->lon    = (/lon/)
fout->lat    = (/lat/)
fout->pres   = (/Ps/)
fout->hgt    = (/HEIGHT/)
fout->temp   = (/T/)

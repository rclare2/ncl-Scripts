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
;  Ryan Clare                                                   ;
;  University of Wisconsin-Madison                              ;
;  February, 2019                                               ;
;                                                               ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

original_file = "NAME OF FILE TO EXTRACT FROM"
out_directory = "NAME OF DIRECTORY TO SAVE TO"
nlev = 29
npres = 19
nlat = 143
nlon = 209
nDSL = 19

a = addfile(original_file, "r")
t = a->Times
lat = wrf_user_getvar(a, "lat", -1)
lon = wrf_user_getvar(a, "lon", -1)

Ps = new((/19/),"float")
Ps(0) = 1000.
Ps(1) = 950.
Ps(2) = 900.
Ps(3) = 850.
Ps(4) = 800.
Ps(5) = 750.
Ps(6) = 700.
Ps(7) = 650.
Ps(8) = 600.
Ps(9) = 550.
Ps(10) = 500.
Ps(11) = 450.
Ps(12) = 400.
Ps(13) = 350.
Ps(14) = 300.
Ps(15) = 250.
Ps(16) = 200.
Ps(17) = 150.
Ps(18) = 100.

z = wrf_user_getvar(a, "height", -1)

opts = True
opts@extrapolate = True
opts@field_type = "z"
HEIGHT = wrf_user_vert_interp(a,z,"pres",Ps,opts)

T = a->T2


;===================================
; File name setting
; 
; This may need to be changed
; depending on your own preferences
; and naming conventions.
;===================================

strs = str_split(original_file, "_")
case_no = strs(0)
case_date = str_join(strs(3:), "_")
filo = case_no + "_" + case_date + ".nc"

fout = addfile(out_directory + filo, "c")

setfileoption(fout,"DefineMode",True)


;===================================
; Global attributes 
;===================================

fAtt = True
fAtt@title = "netCDF test"
fAtt@source_file = original_file
fAtt@Conventions = "None"
fAtt@creation_date = systemfunc("date")
fileattdef(fout,fAtt)


;===================================
; Variable attributes
;===================================

dimNames = (/"Time", "DateStrLen", "south_north", "west_east", "pres"/)  
dimSizes = (/ -1   ,  nDSL,        nlat,          nlon,        npres /) 
dimUnlim = (/ True ,  False,       False,         False,       False /)   
filedimdef(fout, dimNames, dimSizes, dimUnlim)

filevardef(fout, "Time" ,typeof(t),  getvardims(t))
filevardef(fout, "pres" ,typeof(Ps), (/"pres"/))
filevardef(fout, "lat"  ,typeof(lat),getvardims(lat))
filevardef(fout, "lon"  ,typeof(lon),getvardims(lon))
filevardef(fout, "hgt"  ,typeof(Ps), (/"Time", "pres", "south_north", "west_east"/))
filevardef(fout, "temp" ,typeof(T),  getvardims(T))

PresAtt=0
PresAtt@units = "hPa"
PresAtt@long_name = "Pressure Levels"
PresAtt@MemoryOrder = "XY"
PresAtt@coordinates = "XLONG XLAT XTIME"
filevarattdef(fout, "pres", PresAtt )

HgtAtt=0
HgtAtt@units = "m"
HgtAtt@long_name = "Geopotential height"
PresAtt@MemoryOrder = "XYZ"
PresAtt@coordinates = "XLONG XLAT XPRES XTIME"
filevarattdef(fout, "hgt", HgtAtt)

filevarattdef(fout,"Time",t)
filevarattdef(fout,"lon" ,lon)
filevarattdef(fout,"lat" ,lat)
filevarattdef(fout,"temp",T)


;===================================
; Saving to file
;===================================

setfileoption(fout,"DefineMode",False)

fout->Time   = (/t/)
fout->lon    = (/lon/)
fout->lat    = (/lat/)
fout->pres   = (/Ps/)
fout->hgt    = (/HEIGHT/)
fout->temp   = (/T/)

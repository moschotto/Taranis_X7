--[[#############################################################################
Telemetry Widget script for Taranis x7 
Copyright (C) by mosch   
License GPLv2: http://www.gnu.org/licenses/gpl-2.0.html       

"GPS last known postions v1.0"  
 
Desription:
stores GPS coordinates every second into /SCRIPTS/TELEMETRY/GPSpositions.txt
and displays the last 4 GPS positions on the telemtry screen
in case that telemetry is not available anymore (crash, power loss etc.) 
the screen won't be updated but still shows the 4 postions
if 50 postions are stored, the log will be reset and starts at 0


If the number of satellites is 0 or won't be updated check the sensors in your radio.
Depending via which sensor the satellites are reported comment or uncomment the code accordingly

=> line 137/138
gpssatId = getTelemetryId("Tmp2")
or
--gpssatId = getTelemetryId("Sats")]]

################################################################################]]

log_filename = "/SCRIPTS/TELEMETRY/GPSpositions.txt"

local gpsValue = 0
local gpsLAT = 0
local gpsLON = 0
local gpsSATS = 0
local wait_time = 100
local wait_time_read = 100
local old_time_read = 0
local old_time_write = 0
local coordinates = {}  
local coordinates_tmp = {} 
local update = true
local string_gmatch = string.gmatch
local now = 0
local ctr = 0

coordinates[1] = "0"
coordinates[2] = "0"
coordinates[3] = "0"
coordinates[4] = "0"

local function rnd(v,d)
	if d then
		return math.floor((v*10^d)+0.5)/(10^d)
	else
		return math.floor(v+0.5)
	end
end

local function write_log()
	now = getTime()    
    if old_time_write + wait_time < now then
						
		if string.len(gpsValue) <= 8 then
			gpsLAT = "not available"
			gpsLON = "not available"		
		else			
			local f = io.open(log_filename, "a")        
				io.write(f, gpsValue ,"\r\n")			
			io.close(f)				
		end		
		old_time_write = now
    end
end


local function read_log()
	ctr = 0	
	now = getTime()    
		
		if old_time_read + wait_time_read < now then

			local f2 = io.open(log_filename, "r")
				buffer = io.read(f2, 2048)
			io.close(f2)

			for line in string_gmatch(buffer, "([^\n]+)\n") do					
				ctr = ctr + 1
				coordinates_tmp[ctr] = line
			end			

			if ctr > 49 then
				local f2 = io.open(log_filename, "w")
				io.close(f2)		
			end
			
			if ctr == 1 then			
				coordinates[1] = "1: " .. coordinates_tmp[ctr]
				coordinates[2] = "2: 0" 
				coordinates[3] = "3: 0" 
				coordinates[4] = "4: 0" 
			end			
			if ctr == 2 then			
				coordinates[1] = "1: " .. coordinates_tmp[ctr-1]
				coordinates[2] = "2: " .. coordinates_tmp[ctr]
				coordinates[3] = "3: 0" 
				coordinates[4] = "4: 0" 
			end	

			if ctr == 3 then			
				coordinates[1] = "1: " .. coordinates_tmp[ctr-2]
				coordinates[2] = "2: " .. coordinates_tmp[ctr-1]
				coordinates[3] = "3: " .. coordinates_tmp[ctr]
				coordinates[4] = "4: 0" 
			end
			
			if ctr > 3 then						
				coordinates[1] = ctr-3 .. ": " .. coordinates_tmp[ctr-3]
				coordinates[2] = ctr-2 .. ": " .. coordinates_tmp[ctr-2]	
				coordinates[3] = ctr-1 .. ": " .. coordinates_tmp[ctr-1]
				coordinates[4] = ctr .. ": " .. coordinates_tmp[ctr]				
			end	
					
			old_time_read = now
		end
	
end

local function getTelemetryId(name)    
	field = getFieldInfo(name)
	if field then
		return field.id
	else
		return-1
	end
end

local function init()  
	gpsId = getTelemetryId("GPS")
		
	gpssatId = getTelemetryId("Tmp2")
	--gpssatId = getTelemetryId("Sats")]]
end

local function background()	
	
	gpsLatLon = getValue(gpsId)	
	gpsSATS = getValue(gpssatId)
	
	if (type(gpsLatLon) == "table") then 
	
		gpsValue = rnd(gpsLatLon["lat"],6) .. ", " .. rnd(gpsLatLon["lon"],6)
		gpsLAT = rnd(gpsLatLon["lat"],6)
		gpsLON = rnd(gpsLatLon["lon"],6)		
		update = true					
	else    	
		gpsValue = ""			
	end		
	
	if string.len(gpsValue) > 8 then	
		write_log()		
		update = true
	else
		gpsValue = " no gps data available"
		update = false
	end 
	
	read_log()
	
	
	if string.len(gpsSATS) > 2 then
		gpsSATS = string.sub (gpsSATS, 3,6)
		gpsSATS = "Sat:" .. gpsSATS
	end	
	
			
end
 
local function run(event)  
	lcd.clear()  
	background() 
			
	lcd.drawText(2,2,"Last GPS positions",SMLSIZE)
	lcd.drawLine(0,10, 128, 10, SOLID, FORCE)
	
	lcd.drawText(2,14, coordinates[1],SMLSIZE)
	lcd.drawText(2,26, coordinates[2],SMLSIZE)
	lcd.drawText(2,38, coordinates[3],SMLSIZE)
	lcd.drawText(2,50, coordinates[4],SMLSIZE)
	
	
	
	if update == true then
		lcd.drawText(100,2, gpsSATS, SMLSIZE + INVERS + BLINK)
				
	elseif update == false then
		lcd.drawText(100,2,"Sat:--", SMLSIZE) 
	end
	
end
 
return {init=init, run=run, background=background}

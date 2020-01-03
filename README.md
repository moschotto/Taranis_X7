# Taranis X7 GPS last positions Telemetry Screen

Telemetry Widget script for Taranis x7 v1.1

Copyright (C) by mosch   
License GPLv2: http://www.gnu.org/licenses/gpl-2.0.html       

Description:

stores GPS coordinates every second into /SCRIPTS/TELEMETRY/GPSpositions.txt and 
displays the last 4 GPS positions and GPS sattelite count on the telemetry screen.
In case that telemetry is not available anymore (crash, power loss etc.) the screen 
won't be updated but still shows the last 4 postions. If 50 postions are stored, the log 
will be reset and starts at 0.


Install:
1. copy the pre-compiled file "GPS.luac" to /SCRIPTS/TELEMETRY/
2. Rename GPS.luac to GPSc.lua 
3. create a new empty text file /SCRIPTS/TELEMETRY/GPSpositions.txt 
4. Add a new telemetry screen and select GPSc.lua


Note:

If the number of satellites won't be updated and everything else works,
edit the line in the script "GPS.lua". 


from:

gpssatId = getTelemetryId("Tmp2")

to:

gpssatId = getTelemetryId("Sats")



Remove the previous copied GPSc.lua(c) files and copy just the GPS.lua to 
the radio.


![Alt text](https://github.com/moschotto/Taranis_X7/blob/master/screenx7.png)

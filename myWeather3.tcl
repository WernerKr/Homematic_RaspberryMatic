#!/usr/bin/env tclsh
#
# Daten von Wetterstation in Homematic einbinden
# Daten werden mittels GET an den Port 2068 im
# Wunderground-Format Übertragen und in die Systemvariablen
# geschrieben
#
# Version 3.1
# Es wird geprüft ob die Software Raspberrymatic ist, wenn ja wird der Sonnenstand geschrieben.
# Die Sys-Vars werden auf jeden Fall angelegt nur nicht "gefüllt"
# Zudem wird geprüft ob die Datei "myWeather.ini" vorhanden ist um die Langzeitarchivierung zu starten
# die ini enthält nur den Pfad wo die Datei abgelegt werden soll.
# Mit "set ::_W_Temp1 0" wird der betreffende Sensor ignoriert
# Mit "set ::_W_Temp1 1" wird der betreffende Sensortext erzeugt und die dazugehörigen Werte erfasst
#
# Achtung diese Datei muss im Unix-Format mit Zeichencodierung Ansi benutzt werden, sonst werden beim Erzeugen
# der Sensortexte mit zugehörigen Einheiten die Einheiten ("°C","µg/m³") fehlerhaft dargestellt. 
#
#Um ohne Reboot zu starten über die Konsole folgendes eingeben:
#cd /www/addons/myAddons/
#tclsh myWeather3.tcl &
#exit


load tclrega.so
set ::raspi 0

puts "myWeather is running"
set x [exec cat /boot/VERSION]
# puts $x
# PRODUCT=raspmatic
# puts [string first "raspmatic" $x 0]
if {[string first "raspmatic" $x 0] > 0 } {
	 set ::raspi 1
}
#set input {GET /weatherstation/updateweatherstation.php?ID=12345678&PASSWORD=12345678&tempf=62.60&humidity=50&dewptf=43.70&windchillf=62.60&winddir=16&windspeedmph=7.38&windgustmph=13.20&rainin=0.000&dailyrainin=0.000&weeklyrainin=0.000&monthlyrainin=1.051&yearlyrainin=20.579&solarradiation=676.32&UV=6&indoortempf=71.96&indoorhumidity=48&baromin=29.831&temp2f=66.38&humidity2=43&temp3f=66.02&humidity3=46&temp4f=71.42&humidity4=50&temp5f=60.08&humidity5=67&temp6f=72.68&humidity6=48&temp7f=65.66&humidity7=56&temp8f=69.44&humidity8=43&temp9f=65.12&humidity9=51&soiltempf=62.96&soiltemp2f=71.60&soiltemp3f=52.16&soiltemp4f=-4.72&soiltemp5f=65.12&soiltemp6f=68.36&soiltemp7f=69.80&soiltemp8f=140.00&leafwetness=0&AqPM2.5=6.0&soilmoisture=55&soilmoisture2=37&soilmoisture3=38&soilmoisture4=60&soilmoisture5=19&soilmoisture6=35&soilmoisture7=53&soilmoisture8=23&lowbatt=0&dateutc=now&softwaretype=WH2650A_V1.7.6&action=updateraw&realtime=1&rtfreq=5 HTTP/1.0}
set ::zaehler 0
set ::messwerte {0 0 0 0 0 0 0 0 0 0}

set ::_W_Temp1 1
set ::_W_Temp2 1
set ::_W_Temp3 1
set ::_W_Temp4 1
set ::_W_Temp5 1
set ::_W_Temp6 1
set ::_W_Temp7 1
set ::_W_Temp8 1
set ::_W_Co2_Temp 1
set ::_W_SoilTemp1 1
set ::_W_SoilTemp2 1
set ::_W_SoilTemp3 1
set ::_W_SoilTemp4 1
set ::_W_SoilTemp5 1
set ::_W_SoilTemp6 1
set ::_W_SoilTemp7 1
set ::_W_SoilTemp8 1
set ::_W_Hum1 1
set ::_W_Hum2 1
set ::_W_Hum3 1
set ::_W_Hum4 1
set ::_W_Hum5 1
set ::_W_Hum6 1
set ::_W_Hum7 1
set ::_W_Hum8 1
set ::_W_Co2_Hum 1
set ::_W_Bodenfeuchte 1
set ::_W_Bodenfeuchte2 1
set ::_W_Bodenfeuchte3 1
set ::_W_Bodenfeuchte4 1
set ::_W_Bodenfeuchte5 1
set ::_W_Bodenfeuchte6 1
set ::_W_Bodenfeuchte7 1
set ::_W_Bodenfeuchte8 1
set ::_W_Bodenfeuchte9 1
set ::_W_Bodenfeuchte10 1
set ::_W_Bodenfeuchte11 0
set ::_W_Bodenfeuchte12 0
set ::_W_Bodenfeuchte13 0
set ::_W_Bodenfeuchte14 0
set ::_W_Bodenfeuchte15 0
set ::_W_Bodenfeuchte16 0
set ::_W_Blattfeuchte1 1
set ::_W_Blattfeuchte2 0
set ::_W_Blattfeuchte3 0
set ::_W_Blattfeuchte4 0
set ::_W_Blattfeuchte5 0
set ::_W_Blattfeuchte6 0
set ::_W_Blattfeuchte7 0
set ::_W_Blattfeuchte8 0
set ::_W_Leckage1 1
set ::_W_Leckage2 1
set ::_W_Leckage3 1
set ::_W_Leckage4 1

set ::_W_Co2 1
set ::_W_Co2in 0
set ::_W_Blitze 1
set ::_W_Blitzentfernung 1
set ::_W_Blitze_Zeit 1
set ::_W_Sonnenzeit 1

set ::_W_AqPM2p5_1 1
set ::_W_AqPM2p5_2 1
set ::_W_AqPM2p5_3 1
set ::_W_AqPM2p5_4 1
set ::_W_Co2_PM1 1
set ::_W_Co2_PM4 1
set ::_W_Co2_PM25 1
set ::_W_Co2_PM10 1

set ::_W_Vpd 1
set ::_W_Hoehe1ges 1
set ::_W_Hoehe2ges 0
set ::_W_Hoehe1 1
set ::_W_Hoehe2 0


proc auswerten {daten} {
	puts $daten

	set argument [split $daten "\?"]

#	array set res [rega_script "dom.GetObject('_V_EcowittData').State('$daten');"]


	#puts [llength $argument]
	set sysvartext ""
	if { [llength $argument] > 1} {
		set arguneu [split [lindex $argument 1] "\&"]
		for {set a 2} {$a<80} {incr a} {
			#puts [lindex $arguneu $a]
			set werte [split [lindex $arguneu $a] "="]
			set ausgabe [lindex $arguneu $a]
			switch [lindex $werte 0] {
				"indoortempf" { 
					#set ausgabe "indoortempc=[f2celsius [lindex $werte 1]]"
					writeSysvar _W_TempInnen [f2celsius [lindex $werte 1]]
				}
				"tempf"	{
#					set ausgabe "tempc=[f2celsius [lindex $werte 1]]"
					writeSysvar _W_TempAussen [f2celsius [lindex $werte 1]]
				}
				"dewptf" {
#					set ausgabe "dewptc=[f2celsius [lindex $werte 1]]"
					writeSysvar _W_Taupunkt [f2celsius [lindex $werte 1]]
				}
				"windchillf" {
#					set ausgabe "windchillc=[f2celsius [lindex $werte 1]]"
					writeSysvar _W_Windchill [f2celsius [lindex $werte 1]]
				}
				"temp2f" {if {$::_W_Temp1==1} { writeSysvar _W_Temp1 [f2celsius [lindex $werte 1]]}}
				"temp3f" {if {$::_W_Temp2==1} { writeSysvar _W_Temp2 [f2celsius [lindex $werte 1]]}}
				"temp4f" {if {$::_W_Temp3==1} { writeSysvar _W_Temp3 [f2celsius [lindex $werte 1]]}}
				"temp5f" {if {$::_W_Temp4==1} { writeSysvar _W_Temp4 [f2celsius [lindex $werte 1]]}}
				"temp6f" {if {$::_W_Temp5==1} { writeSysvar _W_Temp5 [f2celsius [lindex $werte 1]]}}
				"temp7f" {if {$::_W_Temp6==1} { writeSysvar _W_Temp6 [f2celsius [lindex $werte 1]]}}
				"temp8f" {if {$::_W_Temp7==1} { writeSysvar _W_Temp7 [f2celsius [lindex $werte 1]]}}
				"temp9f" {if {$::_W_Temp8==1} { writeSysvar _W_Temp8 [f2celsius [lindex $werte 1]]}}
				"soiltempf" {if {$::_W_SoilTemp1==1} { writeSysvar _W_SoilTemp1 [f2celsius [lindex $werte 1]]}}
				"soiltemp2f" {if {$::_W_SoilTemp2==1} { writeSysvar _W_SoilTemp2 [f2celsius [lindex $werte 1]]}}
				"soiltemp3f" {if {$::_W_SoilTemp3==1} { writeSysvar _W_SoilTemp3 [f2celsius [lindex $werte 1]]}}
				"soiltemp4f" {if {$::_W_SoilTemp4==1} { writeSysvar _W_SoilTemp4 [f2celsius [lindex $werte 1]]}}
				"soiltemp5f" {if {$::_W_SoilTemp5==1} { writeSysvar _W_SoilTemp5 [f2celsius [lindex $werte 1]]}}
				"soiltemp6f" {if {$::_W_SoilTemp6==1} { writeSysvar _W_SoilTemp6 [f2celsius [lindex $werte 1]]}}
				"soiltemp7f" {if {$::_W_SoilTemp7==1} { writeSysvar _W_SoilTemp7 [f2celsius [lindex $werte 1]]}}
				"soiltemp8f" {if {$::_W_SoilTemp8==1} { writeSysvar _W_SoilTemp8 [f2celsius [lindex $werte 1]]}}
				"tf_co2"	{if {$::_W_Co2_Temp==1} { writeSysvar _W_Co2_Temp [f2celsius [lindex $werte 1]]}}
				"windspeedmph"	{
#					set ausgabe "windspeedkmh=[kmh [lindex $werte 1]]"
					writeSysvar _W_Windgesch [kmh [lindex $werte 1]]
				}
				"windgustmph"	{
#					set ausgabe "windgustkmh=[kmh [lindex $werte 1]]"
					writeSysvar _W_Windboee [kmh [lindex $werte 1]]
				}
				"windspdmph_avg10m"	{ writeSysvar _W_Windgesch10 [kmh [lindex $werte 1]]}
				"windgustmph_max10m"	{ writeSysvar _W_Windboee10 [kmh [lindex $werte 1]]}
				"absbaromin" {
					set ausgabe "absbarombar=[mbar [lindex $werte 1]]"
				}
				
				"baromin" {
					set ausgabe "barombar=[mbar [lindex $werte 1]]"
					writeSysvar _W_Luftdruck [mbar [lindex $werte 1]]
				}
				"rainin" {
					set ausgabe "rainmm=[niederschlag [lindex $werte 1]]"
					writeSysvar _W_Niederschlag [niederschlag [lindex $werte 1]]
				}
				"dailyrainin" {
					set ausgabe "dailyrainmm=[niederschlag [lindex $werte 1]]"
					writeSysvar _W_NiederschlagTag [niederschlag [lindex $werte 1]]
				}
				"weeklyrainin" {
					set ausgabe "weeklyrainmm=[niederschlag [lindex $werte 1]]"
					writeSysvar _W_NiederschlagWoche [niederschlag [lindex $werte 1]]
				}
				"monthlyrainin" {
					set ausgabe "monthlyrainmm=[niederschlag [lindex $werte 1]]"
					writeSysvar _W_NiederschlagMonat [niederschlag [lindex $werte 1]]
				}
				"yearlyrainin" {
					set ausgabe "yearlyrainmm=[niederschlag [lindex $werte 1]]"
					writeSysvar _W_NiederschlagJahr [niederschlag [lindex $werte 1]]
				}
				"dateutc" {
					#puts [lindex $werte 1]
					set utcdate [string range [lindex $werte 1] 0 9]
					#puts $utcdate
					set utctime [string range [lindex $werte 1] 13 20]
					set ausgabe "dateutc=$utcdate\ntimeutc=$utctime"
				}
				"indoorhumidity" {writeSysvar _W_LuftfeuchteInnen [lindex $werte 1]}
				"humidity" { writeSysvar _W_LuftfeuchteAussen [lindex $werte 1]}
				"humidity2" {if {$::_W_Hum1==1} { writeSysvar _W_Hum1 [lindex $werte 1]}}
				"humidity3" {if {$::_W_Hum2==1} { writeSysvar _W_Hum2 [lindex $werte 1]}}
				"humidity4" {if {$::_W_Hum3==1} { writeSysvar _W_Hum3 [lindex $werte 1]}}
				"humidity5" {if {$::_W_Hum4==1} { writeSysvar _W_Hum4 [lindex $werte 1]}}
				"humidity6" {if {$::_W_Hum5==1} { writeSysvar _W_Hum5 [lindex $werte 1]}}
				"humidity7" {if {$::_W_Hum6==1} { writeSysvar _W_Hum6 [lindex $werte 1]}}
				"humidity8" {if {$::_W_Hum7==1} { writeSysvar _W_Hum7 [lindex $werte 1]}}
				"humidity9" {if {$::_W_Hum8==1} { writeSysvar _W_Hum8 [lindex $werte 1]}}
				"humi_co2" {if {$::_W_Co2_Hum==1} { writeSysvar _W_Co2_Hum [lindex $werte 1]}}
				"solarradiation" {
					writeSysvar _W_Solar [lindex $werte 1]
					mittelwert [lindex $werte 1]
				}
				"UV" {writeSysvar _W_UV [lindex $werte 1]}
				"soilmoisture" {if {$::_W_Bodenfeuchte==1} { writeSysvar _W_Bodenfeuchte [lindex $werte 1]}}
				"soilmoisture2" {if {$::_W_Bodenfeuchte2==1} { writeSysvar _W_Bodenfeuchte2 [lindex $werte 1]}}
				"soilmoisture3" {if {$::_W_Bodenfeuchte3==1} { writeSysvar _W_Bodenfeuchte3 [lindex $werte 1]}}
				"soilmoisture4" {if {$::_W_Bodenfeuchte4==1} { writeSysvar _W_Bodenfeuchte4 [lindex $werte 1]}}
				"soilmoisture5" {if {$::_W_Bodenfeuchte5==1} { writeSysvar _W_Bodenfeuchte5 [lindex $werte 1]}}
				"soilmoisture6" {if {$::_W_Bodenfeuchte6==1} { writeSysvar _W_Bodenfeuchte6 [lindex $werte 1]}}
				"soilmoisture7" {if {$::_W_Bodenfeuchte7==1} { writeSysvar _W_Bodenfeuchte7 [lindex $werte 1]}}
				"soilmoisture8" {if {$::_W_Bodenfeuchte8==1} { writeSysvar _W_Bodenfeuchte8 [lindex $werte 1]}}
				"soilmoisture9" {if {$::_W_Bodenfeuchte9==1} { writeSysvar _W_Bodenfeuchte9 [lindex $werte 1]}}
				"soilmoisture10" {if {$::_W_Bodenfeuchte10==1} { writeSysvar _W_Bodenfeuchte10 [lindex $werte 1]}}
				"soilmoisture11" {if {$::_W_Bodenfeuchte11==1} { writeSysvar _W_Bodenfeuchte11 [lindex $werte 1]}}
				"soilmoisture12" {if {$::_W_Bodenfeuchte12==1} { writeSysvar _W_Bodenfeuchte12 [lindex $werte 1]}}
				"soilmoisture13" {if {$::_W_Bodenfeuchte13==1} { writeSysvar _W_Bodenfeuchte13 [lindex $werte 1]}}
				"soilmoisture14" {if {$::_W_Bodenfeuchte14==1} { writeSysvar _W_Bodenfeuchte14 [lindex $werte 1]}}
				"soilmoisture15" {if {$::_W_Bodenfeuchte15==1} { writeSysvar _W_Bodenfeuchte15 [lindex $werte 1]}}
				"soilmoisture16" {if {$::_W_Bodenfeuchte16==1} { writeSysvar _W_Bodenfeuchte16 [lindex $werte 1]}}
			
				"leafwetness" {if {$::_W_Blattfeuchte1==1} { writeSysvar _W_Blattfeuchte1 [lindex $werte 1]}}
				"leafwetness2" {if {$::_W_Blattfeuchte2==1} { writeSysvar _W_Blattfeuchte2 [lindex $werte 1]}}
				"leafwetness3" {if {$::_W_Blattfeuchte3==1} { writeSysvar _W_Blattfeuchte3 [lindex $werte 1]}}
				"leafwetness4" {if {$::_W_Blattfeuchte4==1} { writeSysvar _W_Blattfeuchte4 [lindex $werte 1]}}
				"leafwetness5" {if {$::_W_Blattfeuchte5==1} { writeSysvar _W_Blattfeuchte5 [lindex $werte 1]}}
				"leafwetness6" {if {$::_W_Blattfeuchte6==1} { writeSysvar _W_Blattfeuchte6 [lindex $werte 1]}}
				"leafwetness7" {if {$::_W_Blattfeuchte7==1} { writeSysvar _W_Blattfeuchte7 [lindex $werte 1]}}
				"leafwetness8" {if {$::_W_Blattfeuchte8==1} { writeSysvar _W_Blattfeuchte8 [lindex $werte 1]}}

				"leak_ch1" {if {$::_W_Leckage1==1} { writeSysvar _W_Leckage1 [lindex $werte 1]}}
				"leak_ch2" {if {$::_W_Leckage2==1} { writeSysvar _W_Leckage2 [lindex $werte 1]}}
				"leak_ch3" {if {$::_W_Leckage3==1} { writeSysvar _W_Leckage3 [lindex $werte 1]}}
				"leak_ch4" {if {$::_W_Leckage4==1} { writeSysvar _W_Leckage4 [lindex $werte 1]}}
                                                
				"co2"	{if {$::_W_Co2==1} { writeSysvar _W_Co2 [lindex $werte 1]}}
				"co2in"	{if {$::_W_Co2in==1} { writeSysvar _W_Co2in [lindex $werte 1]}}
				"lightning_num"	{if {$::_W_Blitze==1} { writeSysvar _W_Blitze [lindex $werte 1]}}
				"lightning"	{if {$::_W_Blitzentfernung==1} { writeSysvar _W_Blitzentfernung [lindex $werte 1]}}
				"lightning_time"	{if {$::_W_Blitze_Zeit==1} {
				#puts "The time is: [clock format [lindex $werte 1] -format %D %H:%M:%S]"
				#writeSysvar _W_Blitze_Zeit [clock format [lindex $werte 1] -format %D %H:%M:%S]
					writeSysvar _W_Blitze_Zeit [lindex $werte 1]
				}}
				"sunhours"	{if {$::_W_Sonnenzeit==1} { writeSysvar _W_Sonnenzeit [lindex $werte 1]}}

				"AqPM2_5" { writeSysvar _W_AqPM2p5 [lindex $werte 1]}
				
				"pm25_ch1" {if {$::_W_AqPM2p5_1==1} { writeSysvar _W_AqPM2p5_1 [lindex $werte 1]}}
				"pm25_ch2" {if {$::_W_AqPM2p5_2==1} { writeSysvar _W_AqPM2p5_2 [lindex $werte 1]}}
				"pm25_ch3" {if {$::_W_AqPM2p5_3==1} { writeSysvar _W_AqPM2p5_3 [lindex $werte 1]}}
				"pm25_ch4" {if {$::_W_AqPM2p5_4==1} { writeSysvar _W_AqPM2p5_4 [lindex $werte 1]}}
				"pm1_co2" {if {$::_W_Co2_PM1==1} { writeSysvar _W_Co2_PM1 [lindex $werte 1]}}
				"pm4_co2" {if {$::_W_Co2_PM4==1} { writeSysvar _W_Co2_PM4 [lindex $werte 1]}}
				"pm25_co2" {if {$::_W_Co2_PM25==1} { writeSysvar _W_Co2_PM25 [lindex $werte 1]}}
				"pm10_co2" {if {$::_W_Co2_PM10==1} { writeSysvar _W_Co2_PM10 [lindex $werte 1]}}

				"winddir" { writeSysvar _W_Windrichtung [lindex $werte 1]}
				"winddir_avg10m" { writeSysvar _W_Windrichtung10 [lindex $werte 1]}
				"vpd_kPa" {if {$::_W_Vpd==1} { writeSysvar _W_Vpd [lindex $werte 1]}}
				"air_ch1" {if {$::_W_Hoehe1ges==1} { writeSysvar _W_Hoehe1ges [lindex $werte 1]}}
				"air_ch2" {if {$::_W_Hoehe2ges==1} { writeSysvar _W_Hoehe2ges [lindex $werte 1]}}
				"depth_ch1" {if {$::_W_Hoehe1==1} { writeSysvar _W_Hoehe1 [lindex $werte 1]}}
				"depth_ch2" {if {$::_W_Hoehe2==1}  {writeSysvar _W_Hoehe2 [lindex $werte 1]}}

				"lowbatt" { writeSysvar _V_LowBatt [lindex $werte 1]}
				"softwaretype" { writeSysvar _V_Softwaretype [lindex $werte 1]}
				
			}
			
				
#		puts $ausgabe
			
		}
		if {$::raspi==1} {
			array set res [rega_script "var x=system.SunAzimuth().Round(2); dom.GetObject('_V_Azimut').State(x.ToString(2));"]
			#puts $res(x)
			array set res [rega_script "var x=system.SunAltitude().Round(2); dom.GetObject('_V_Elevation').State(x.ToString(2));"]
			#puts $res(x)
			#array set res [rega_script "Write('Hallo');"]
			#puts $res(STDOUT)
		}
	}
}

proc mittelwert {thiswert} {
	set ::messwerte [lreplace $::messwerte $::zaehler $::zaehler $thiswert]
	set thismittelwert [expr ([join $::messwerte +]) / 10.0]
	set thismittelwert [format "%.2f" $thismittelwert]
	incr ::zaehler
	if { $::zaehler > 9} {
		set ::zaehler 0
	}
	writeSysvar _W_SolarAV $thismittelwert
}

proc f2celsius {fahrenheit} {
	set nullinger [expr $fahrenheit - 32]
	set f2celsius [expr $nullinger * 0.555555555555555555]
	return [format "%.1f" $f2celsius]
}


proc kmh {meilen} {
	return [format "%.2f" [expr $meilen * 1.60934]]
}

proc mbar {baroin} {
	return [format "%.1f" [expr $baroin / 0.0295301]]
}

proc rainmm {dailyrainin} {
	return [format "%.2f" [expr $dailyrainin / 0.03937]]
}

proc niederschlag {rainin} {
	return [format "%.2f" [expr $rainin * 25.4]]
}


proc check_sysvars {sysvarname} {
	set comm {
		string  svName = "}
	append comm $sysvarname
	append comm {";
		object  svObj  = dom.GetObject(svName);
	
		if (!svObj){   
			object svObjects = dom.GetObject(ID_SYSTEM_VARIABLES);
			svObj = dom.CreateObject(OT_VARDP);
			svObjects.Add(svObj.ID());
			svObj.Name(svName);   
			svObj.ValueType(ivtFloat);
			svObj.ValueSubType(istGeneric);
			svObj.DPInfo("Daten von Wetterstation");
			svObj.ValueUnit("");
			svObj.ValueMin(-10000);
			svObj.ValueMax(10000);
			svObj.State(0);
			svObj.Internal(false);
			svObj.Visible(true);
			dom.RTUpdate(false);
		}
	
	}
#	puts $comm
	array set res [rega_script $comm]	
}

proc check_sysvars_temp {sysvarname} {
	set comm {
		string  svName = "}
	append comm $sysvarname
	append comm {";
		object  svObj  = dom.GetObject(svName);
	
		if (!svObj){   
			object svObjects = dom.GetObject(ID_SYSTEM_VARIABLES);
			svObj = dom.CreateObject(OT_VARDP);
			svObjects.Add(svObj.ID());
			svObj.Name(svName);   
			svObj.ValueType(ivtFloat);
			svObj.ValueSubType(istGeneric);
			svObj.DPInfo("Daten von Wetterstation");
			svObj.ValueUnit("°C");
			svObj.ValueMin(-40);
			svObj.ValueMax(70);
			svObj.State(0);
			svObj.Internal(false);
			svObj.Visible(true);
			dom.RTUpdate(false);
		}
	
	}
#	puts $comm
	array set res [rega_script $comm]	
}

proc check_sysvars_hum {sysvarname} {
	set comm {
		string  svName = "}
	append comm $sysvarname
	append comm {";
		object  svObj  = dom.GetObject(svName);
	
		if (!svObj){   
			object svObjects = dom.GetObject(ID_SYSTEM_VARIABLES);
			svObj = dom.CreateObject(OT_VARDP);
			svObjects.Add(svObj.ID());
			svObj.Name(svName);   
			svObj.ValueType(ivtFloat);
			svObj.ValueSubType(istGeneric);
			svObj.DPInfo("Daten von Wetterstation");
			svObj.ValueUnit("%");
			svObj.ValueMin(0);
			svObj.ValueMax(100);
			svObj.State(0);
			svObj.Internal(false);
			svObj.Visible(true);
			dom.RTUpdate(false);
		}
	
	}
#	puts $comm
	array set res [rega_script $comm]	
}

proc check_sysvars_luftdruck {sysvarname} {
	set comm {
		string  svName = "}
	append comm $sysvarname
	append comm {";
		object  svObj  = dom.GetObject(svName);
	
		if (!svObj){   
			object svObjects = dom.GetObject(ID_SYSTEM_VARIABLES);
			svObj = dom.CreateObject(OT_VARDP);
			svObjects.Add(svObj.ID());
			svObj.Name(svName);   
			svObj.ValueType(ivtFloat);
			svObj.ValueSubType(istGeneric);
			svObj.DPInfo("Daten von Wetterstation");
			svObj.ValueUnit("hPa");
			svObj.ValueMin(700);
			svObj.ValueMax(1300);
			svObj.State(0);
			svObj.Internal(false);
			svObj.Visible(true);
			dom.RTUpdate(false);
		}
	
	}
#	puts $comm
	array set res [rega_script $comm]	
}


proc check_sysvars_wind {sysvarname} {
	set comm {
		string  svName = "}
	append comm $sysvarname
	append comm {";
		object  svObj  = dom.GetObject(svName);
	
		if (!svObj){   
			object svObjects = dom.GetObject(ID_SYSTEM_VARIABLES);
			svObj = dom.CreateObject(OT_VARDP);
			svObjects.Add(svObj.ID());
			svObj.Name(svName);   
			svObj.ValueType(ivtFloat);
			svObj.ValueSubType(istGeneric);
			svObj.DPInfo("Daten von Wetterstation");
			svObj.ValueUnit("km/h");
			svObj.ValueMin(0);
			svObj.ValueMax(255);
			svObj.State(0);
			svObj.Internal(false);
			svObj.Visible(true);
			dom.RTUpdate(false);
		}
	
	}
#	puts $comm
	array set res [rega_script $comm]	
}

proc check_sysvars_height {sysvarname} {
	set comm {
		string  svName = "}
	append comm $sysvarname
	append comm {";
		object  svObj  = dom.GetObject(svName);
	
		if (!svObj){   
			object svObjects = dom.GetObject(ID_SYSTEM_VARIABLES);
			svObj = dom.CreateObject(OT_VARDP);
			svObjects.Add(svObj.ID());
			svObj.Name(svName);   
			svObj.ValueType(ivtFloat);
			svObj.ValueSubType(istGeneric);
			svObj.DPInfo("Daten von Wetterstation");
			svObj.ValueUnit("mm");
			svObj.ValueMin(0);
			svObj.ValueMax(500);
			svObj.State(0);
			svObj.Internal(false);
			svObj.Visible(true);
			dom.RTUpdate(false);
		}
	
	}
#	puts $comm
	array set res [rega_script $comm]	
}

proc check_sysvars_rain {sysvarname} {
	set comm {
		string  svName = "}
	append comm $sysvarname
	append comm {";
		object  svObj  = dom.GetObject(svName);
	
		if (!svObj){   
			object svObjects = dom.GetObject(ID_SYSTEM_VARIABLES);
			svObj = dom.CreateObject(OT_VARDP);
			svObjects.Add(svObj.ID());
			svObj.Name(svName);   
			svObj.ValueType(ivtFloat);
			svObj.ValueSubType(istGeneric);
			svObj.DPInfo("Daten von Wetterstation");
			svObj.ValueUnit("mm");
			svObj.ValueMin(0);
			svObj.ValueMax(65000);
			svObj.State(0);
			svObj.Internal(false);
			svObj.Visible(true);
			dom.RTUpdate(false);
		}
	
	}
#	puts $comm
	array set res [rega_script $comm]	
}

proc check_sysvars_solar {sysvarname} {
	set comm {
		string  svName = "}
	append comm $sysvarname
	append comm {";
		object  svObj  = dom.GetObject(svName);
	
		if (!svObj){   
			object svObjects = dom.GetObject(ID_SYSTEM_VARIABLES);
			svObj = dom.CreateObject(OT_VARDP);
			svObjects.Add(svObj.ID());
			svObj.Name(svName);   
			svObj.ValueType(ivtFloat);
			svObj.ValueSubType(istGeneric);
			svObj.DPInfo("Daten von Wetterstation");
			svObj.ValueUnit("W/m²");
			svObj.ValueMin(0);
			svObj.ValueMax(2000);
			svObj.State(0);
			svObj.Internal(false);
			svObj.Visible(true);
			dom.RTUpdate(false);
		}
	
	}
#	puts $comm
	array set res [rega_script $comm]	
}

proc check_sysvars_uv {sysvarname} {
	set comm {
		string  svName = "}
	append comm $sysvarname
	append comm {";
		object  svObj  = dom.GetObject(svName);
	
		if (!svObj){   
			object svObjects = dom.GetObject(ID_SYSTEM_VARIABLES);
			svObj = dom.CreateObject(OT_VARDP);
			svObjects.Add(svObj.ID());
			svObj.Name(svName);   
			svObj.ValueType(ivtFloat);
			svObj.ValueSubType(istGeneric);
			svObj.DPInfo("Daten von Wetterstation");
			svObj.ValueUnit("index");
			svObj.ValueMin(0);
			svObj.ValueMax(30);
			svObj.State(0);
			svObj.Internal(false);
			svObj.Visible(true);
			dom.RTUpdate(false);
		}
	
	}
#	puts $comm
	array set res [rega_script $comm]	
}

proc check_sysvars_leak {sysvarname} {
	set comm {
		string  svName = "}
	append comm $sysvarname
	append comm {";
		object  svObj  = dom.GetObject(svName);
	
		if (!svObj){   
			object svObjects = dom.GetObject(ID_SYSTEM_VARIABLES);
			svObj = dom.CreateObject(OT_VARDP);
			svObjects.Add(svObj.ID());
			svObj.Name(svName);   
			svObj.ValueType(ivtFloat);
			svObj.ValueSubType(istGeneric);
			svObj.DPInfo("Daten von Wetterstation");
			svObj.ValueUnit("");
			svObj.ValueMin(0);
			svObj.ValueMax(5);
			svObj.State(0);
			svObj.Internal(false);
			svObj.Visible(true);
			dom.RTUpdate(false);
		}
	
	}
#	puts $comm
	array set res [rega_script $comm]	
}

proc check_sysvars_AqPM2p5 {sysvarname} {
	set comm {
		string  svName = "}
	append comm $sysvarname
	append comm {";
		object  svObj  = dom.GetObject(svName);
	
		if (!svObj){   
			object svObjects = dom.GetObject(ID_SYSTEM_VARIABLES);
			svObj = dom.CreateObject(OT_VARDP);
			svObjects.Add(svObj.ID());
			svObj.Name(svName);   
			svObj.ValueType(ivtFloat);
			svObj.ValueSubType(istGeneric);
			svObj.DPInfo("Daten von Wetterstation");
			svObj.ValueUnit("µg/m³");
			svObj.ValueMin(0);
			svObj.ValueMax(5000);
			svObj.State(0);
			svObj.Internal(false);
			svObj.Visible(true);
			dom.RTUpdate(false);
		}
	
	}
#	puts $comm
	array set res [rega_script $comm]	
}

proc check_sysvars_string {sysvarname} {
	set comm {
		string  svName = "}
	append comm $sysvarname
	append comm {";
		object  svObj  = dom.GetObject(svName);
		if (!svObj){   
			object svObjects = dom.GetObject(ID_SYSTEM_VARIABLES);
			svObj = dom.CreateObject(OT_VARDP);
			svObjects.Add(svObj.ID());
			svObj.Name(svName);   
			svObj.ValueType(ivtString);
			svObj.ValueSubType(istChar8859);
			svObj.DPInfo("Daten von Wetterstation");
			svObj.ValueUnit("");
			svObj.State("");
			svObj.Internal(false);
			svObj.Visible(true);
			dom.RTUpdate(false);
		}
	
	}
#	puts $comm
	array set res [rega_script $comm]	
}

proc check_sysvars_grad {sysvarname} {
	set comm {
		string  svName = "}
	append comm $sysvarname
	append comm {";
		object  svObj  = dom.GetObject(svName);
	
		if (!svObj){   
			object svObjects = dom.GetObject(ID_SYSTEM_VARIABLES);
			svObj = dom.CreateObject(OT_VARDP);
			svObjects.Add(svObj.ID());
			svObj.Name(svName);   
			svObj.ValueType(ivtFloat);
			svObj.ValueSubType(istGeneric);
			svObj.DPInfo("Daten von Wetterstation");
			svObj.ValueUnit("°");
			svObj.ValueMin(-360);
			svObj.ValueMax(360);
			svObj.State(0);
			svObj.Internal(false);
			svObj.Visible(true);
			dom.RTUpdate(false);
		}
	
	}
#	puts $comm
	array set res [rega_script $comm]	
}

proc check_sysvar_co2 {sysvarname} {
	set comm {
		string  svName = "}
	append comm $sysvarname
	append comm {";
		object  svObj  = dom.GetObject(svName);
	
		if (!svObj){   
			object svObjects = dom.GetObject(ID_SYSTEM_VARIABLES);
			svObj = dom.CreateObject(OT_VARDP);
			svObjects.Add(svObj.ID());
			svObj.Name(svName);   
			svObj.ValueType(ivtFloat);
			svObj.ValueSubType(istGeneric);
			svObj.DPInfo("Daten von Wetterstation");
			svObj.ValueUnit("ppm");
			svObj.ValueMin(0);
			svObj.ValueMax(5000);
			svObj.State(0);
			svObj.Internal(false);
			svObj.Visible(true);
			dom.RTUpdate(false);
		}
	
	}
#	puts $comm
	array set res [rega_script $comm]	
}


proc check_sysvar_vpd {sysvarname} {
	set comm {
		string  svName = "}
	append comm $sysvarname
	append comm {";
		object  svObj  = dom.GetObject(svName);
	
		if (!svObj){   
			object svObjects = dom.GetObject(ID_SYSTEM_VARIABLES);
			svObj = dom.CreateObject(OT_VARDP);
			svObjects.Add(svObj.ID());
			svObj.Name(svName);   
			svObj.ValueType(ivtFloat);
			svObj.ValueSubType(istGeneric);
			svObj.DPInfo("Daten von Wetterstation");
			svObj.ValueUnit("kPa");
			svObj.ValueMin(0);
			svObj.ValueMax(10);
			svObj.State(0);
			svObj.Internal(false);
			svObj.Visible(true);
			dom.RTUpdate(false);
		}
	
	}
#	puts $comm
	array set res [rega_script $comm]	
}

proc check_sysvar_sunhours {sysvarname} {
	set comm {
		string  svName = "}
	append comm $sysvarname
	append comm {";
		object  svObj  = dom.GetObject(svName);
	
		if (!svObj){   
			object svObjects = dom.GetObject(ID_SYSTEM_VARIABLES);
			svObj = dom.CreateObject(OT_VARDP);
			svObjects.Add(svObj.ID());
			svObj.Name(svName);   
			svObj.ValueType(ivtFloat);
			svObj.ValueSubType(istGeneric);
			svObj.DPInfo("Daten von Wetterstation");
			svObj.ValueUnit("Std");
			svObj.ValueMin(0);
			svObj.ValueMax(24);
			svObj.State(0);
			svObj.Internal(false);
			svObj.Visible(true);
			dom.RTUpdate(false);
		}
	
	}
#	puts $comm
	array set res [rega_script $comm]	
}

proc check_sysvar_lightning {sysvarname} {
	set comm {
		string  svName = "}
	append comm $sysvarname
	append comm {";
		object  svObj  = dom.GetObject(svName);
	
		if (!svObj){   
			object svObjects = dom.GetObject(ID_SYSTEM_VARIABLES);
			svObj = dom.CreateObject(OT_VARDP);
			svObjects.Add(svObj.ID());
			svObj.Name(svName);   
			svObj.ValueType(ivtFloat);
			svObj.ValueSubType(istGeneric);
			svObj.DPInfo("Daten von Wetterstation");
			svObj.ValueUnit("km");
			svObj.ValueMin(0);
			svObj.ValueMax(100);
			svObj.State(0);
			svObj.Internal(false);
			svObj.Visible(true);
			dom.RTUpdate(false);
		}
	
	}
#	puts $comm
	array set res [rega_script $comm]	
}


proc writeSysvar {wsysvarname wvalue} {
	array set res [rega_script "Write(dom.GetObject('$wsysvarname').State('$wvalue'));"]
	puts "Write(dom.GetObject('$wsysvarname').State('$wvalue'));"
}

proc Server {channel clientaddr clientport} {
set input [gets $channel]
   puts $channel "HTTP/1.1 200 OK\nConnection: close\nContent-Type: text/plain\n"
   puts $channel "OK!"	
   close $channel
#   puts "Connection $clientaddr registered"
	array set res [rega_script "dom.GetObject('_V_EcowittData').State('$input');"]


   auswerten $input
#	puts $input
	if {[file exists myWeather.ini]} {
		exec tclsh myW_tabelle.tcl
	}

}

# Programm

	
check_sysvars_string _V_EcowittData
check_sysvars_string _V_Softwaretype
check_sysvars _V_LowBatt
check_sysvars_luftdruck _W_Luftdruck
check_sysvars_uv _W_UV
check_sysvars_AqPM2p5 _W_AqPM2p5

set mylist "_W_TempInnen _W_TempAussen _W_Taupunkt _W_Windchill"
for {set a 0} {$a< [llength $mylist] } {incr a} {check_sysvars_temp  [lindex $mylist $a]}
if {$::_W_Temp1==1} {check_sysvars_temp _W_Temp1}
if {$::_W_Temp2==1} {check_sysvars_temp _W_Temp2}
if {$::_W_Temp3==1} {check_sysvars_temp _W_Temp3}
if {$::_W_Temp4==1} {check_sysvars_temp _W_Temp4}
if {$::_W_Temp5==1} {check_sysvars_temp _W_Temp5}
if {$::_W_Temp6==1} {check_sysvars_temp _W_Temp6}
if {$::_W_Temp7==1} {check_sysvars_temp _W_Temp7}
if {$::_W_Temp8==1} {check_sysvars_temp _W_Temp8}
if {$::_W_Co2_Temp==1} {check_sysvars_temp _W_Co2_Temp}

#set mylist "_W_SoilTemp1 _W_SoilTemp2 _W_SoilTemp3 _W_SoilTemp4 _W_SoilTemp5 _W_SoilTemp6 _W_SoilTemp7 _W_SoilTemp8"
#for {set a 0} {$a< [llength $mylist] } {incr a} {check_sysvars_temp  [lindex $mylist $a]}
if {$::_W_SoilTemp1==1} {check_sysvars_temp _W_SoilTemp1}
if {$::_W_SoilTemp2==1} {check_sysvars_temp _W_SoilTemp2}
if {$::_W_SoilTemp3==1} {check_sysvars_temp _W_SoilTemp3}
if {$::_W_SoilTemp4==1} {check_sysvars_temp _W_SoilTemp4}
if {$::_W_SoilTemp5==1} {check_sysvars_temp _W_SoilTemp5}
if {$::_W_SoilTemp6==1} {check_sysvars_temp _W_SoilTemp6}
if {$::_W_SoilTemp7==1} {check_sysvars_temp _W_SoilTemp7}
if {$::_W_SoilTemp8==1} {check_sysvars_temp _W_SoilTemp8}

set mylist "_W_LuftfeuchteInnen _W_LuftfeuchteAussen"
for {set a 0} {$a< [llength $mylist] } {incr a} {check_sysvars_hum  [lindex $mylist $a]}
if {$::_W_Hum1==1} {check_sysvars_hum _W_Hum1}
if {$::_W_Hum2==1} {check_sysvars_hum _W_Hum2}
if {$::_W_Hum3==1} {check_sysvars_hum _W_Hum3}
if {$::_W_Hum4==1} {check_sysvars_hum _W_Hum4}
if {$::_W_Hum5==1} {check_sysvars_hum _W_Hum5}
if {$::_W_Hum6==1} {check_sysvars_hum _W_Hum6}
if {$::_W_Hum7==1} {check_sysvars_hum _W_Hum7}
if {$::_W_Hum8==1} {check_sysvars_hum _W_Hum8}
if {$::_W_Co2_Hum==1} {check_sysvars_hum _W_Co2_Hum}

#set mylist "_W_Bodenfeuchte _W_Bodenfeuchte2 _W_Bodenfeuchte3 _W_Bodenfeuchte4 _W_Bodenfeuchte5 _W_Bodenfeuchte6 _W_Bodenfeuchte7 _W_Bodenfeuchte8 _W_Bodenfeuchte9 _W_Bodenfeuchte10 _W_Bodenfeuchte11 _W_Bodenfeuchte12 _W_Bodenfeuchte13 _W_Bodenfeuchte14 _W_Bodenfeuchte15 _W_Bodenfeuchte16"
#for {set a 0} {$a< [llength $mylist] } {incr a} {check_sysvars_hum  [lindex $mylist $a]}
if {$::_W_Bodenfeuchte==1} {check_sysvars_hum _W_Bodenfeuchte}
if {$::_W_Bodenfeuchte2==1} {check_sysvars_hum _W_Bodenfeuchte2}
if {$::_W_Bodenfeuchte3==1} {check_sysvars_hum _W_Bodenfeuchte3}
if {$::_W_Bodenfeuchte4==1} {check_sysvars_hum _W_Bodenfeuchte4}
if {$::_W_Bodenfeuchte5==1} {check_sysvars_hum _W_Bodenfeuchte5}
if {$::_W_Bodenfeuchte6==1} {check_sysvars_hum _W_Bodenfeuchte6}
if {$::_W_Bodenfeuchte7==1} {check_sysvars_hum _W_Bodenfeuchte7}
if {$::_W_Bodenfeuchte8==1} {check_sysvars_hum _W_Bodenfeuchte8}
if {$::_W_Bodenfeuchte9==1} {check_sysvars_hum _W_Bodenfeuchte9}
if {$::_W_Bodenfeuchte10==1} {check_sysvars_hum _W_Bodenfeuchte10}
if {$::_W_Bodenfeuchte11==1} {check_sysvars_hum _W_Bodenfeuchte11}
if {$::_W_Bodenfeuchte12==1} {check_sysvars_hum _W_Bodenfeuchte12}
if {$::_W_Bodenfeuchte13==1} {check_sysvars_hum _W_Bodenfeuchte13}
if {$::_W_Bodenfeuchte14==1} {check_sysvars_hum _W_Bodenfeuchte14}
if {$::_W_Bodenfeuchte15==1} {check_sysvars_hum _W_Bodenfeuchte15}
if {$::_W_Bodenfeuchte16==1} {check_sysvars_hum _W_Bodenfeuchte16}

#set mylist "_W_Blattfeuchte1 _W_Blattfeuchte2 _W_Blattfeuchte3 _W_Blattfeuchte4 _W_Blattfeuchte5 _W_Blattfeuchte6 _W_Blattfeuchte7 _W_Blattfeuchte8"
#for {set a 0} {$a< [llength $mylist] } {incr a} {check_sysvars_hum  [lindex $mylist $a]}
if {$::_W_Blattfeuchte1==1} {check_sysvars_hum _W_Blattfeuchte1}
if {$::_W_Blattfeuchte2==1} {check_sysvars_hum _W_Blattfeuchte2}
if {$::_W_Blattfeuchte3==1} {check_sysvars_hum _W_Blattfeuchte3}
if {$::_W_Blattfeuchte4==1} {check_sysvars_hum _W_Blattfeuchte4}
if {$::_W_Blattfeuchte5==1} {check_sysvars_hum _W_Blattfeuchte5}
if {$::_W_Blattfeuchte6==1} {check_sysvars_hum _W_Blattfeuchte6}
if {$::_W_Blattfeuchte7==1} {check_sysvars_hum _W_Blattfeuchte7}
if {$::_W_Blattfeuchte8==1} {check_sysvars_hum _W_Blattfeuchte8}

#set mylist "_W_Leckage1 _W_Leckage2 _W_Leckage3 _W_Leckage4"
#for {set a 0} {$a< [llength $mylist] } {incr a} {check_sysvars_leak  [lindex $mylist $a]}
if {$::_W_Leckage1==1} {check_sysvars_leak _W_Leckage1}
if {$::_W_Leckage2==1} {check_sysvars_leak _W_Leckage2}
if {$::_W_Leckage3==1} {check_sysvars_leak _W_Leckage3}
if {$::_W_Leckage4==1} {check_sysvars_leak _W_Leckage4}

set mylist "_W_Windgesch _W_Windboee _W_Windgesch10 _W_Windboee10"
for {set a 0} {$a< [llength $mylist] } {incr a} {check_sysvars_wind  [lindex $mylist $a]}

set mylist "_W_Windrichtung  _W_Windrichtung10 _V_Azimut _V_Elevation"
for {set a 0} {$a< [llength $mylist] } {incr a} {check_sysvars_grad  [lindex $mylist $a]}

set mylist "_W_Solar _W_SolarAV"	
for {set a 0} {$a< [llength $mylist] } {incr a} {check_sysvars_solar  [lindex $mylist $a]}

set mylist "_W_Niederschlag _W_NiederschlagTag _W_NiederschlagWoche _W_NiederschlagMonat _W_NiederschlagJahr"
for {set a 0} {$a< [llength $mylist] } {incr a} {check_sysvars_rain  [lindex $mylist $a]}

if {$::_W_AqPM2p5_1==1} {check_sysvars_AqPM2p5 _W_AqPM2p5_1}
if {$::_W_AqPM2p5_2==1} {check_sysvars_AqPM2p5 _W_AqPM2p5_2}
if {$::_W_AqPM2p5_3==1} {check_sysvars_AqPM2p5 _W_AqPM2p5_3}
if {$::_W_AqPM2p5_4==1} {check_sysvars_AqPM2p5 _W_AqPM2p5_4}
if {$::_W_Co2_PM1==1} {check_sysvars_AqPM2p5 _W_Co2_PM1}
if {$::_W_Co2_PM4==1} {check_sysvars_AqPM2p5 _W_Co2_PM4}
if {$::_W_Co2_PM25==1} {check_sysvars_AqPM2p5 _W_Co2_PM25}
if {$::_W_Co2_PM10==1} {check_sysvars_AqPM2p5 _W_Co2_PM10}
if {$::_W_Co2==1} {check_sysvar_co2 _W_Co2}
if {$::_W_Co2in==1} {check_sysvar_co2 _W_Co2in}
if {$::_W_Vpd==1} {check_sysvar_vpd _W_Vpd}
if {$::_W_Sonnenzeit==1} {check_sysvar_sunhours _W_Sonnenzeit}
if {$::_W_Blitzentfernung==1} {check_sysvar_lightning _W_Blitzentfernung}
if {$::_W_Blitze==1} {check_sysvars _W_Blitze}
if {$::_W_Blitze_Zeit==1} {check_sysvars_string _W_Blitze_Zeit}
if {$::_W_Hoehe1ges==1} {check_sysvars_height _W_Hoehe1ges}
if {$::_W_Hoehe2ges==1} {check_sysvars_height _W_Hoehe2ges}
if {$::_W_Hoehe1==1} {check_sysvars_height _W_Hoehe1}
if {$::_W_Hoehe2==1} {check_sysvars_height _W_Hoehe2}


socket -server Server 2068
#auswerten $input	
	

vwait forever
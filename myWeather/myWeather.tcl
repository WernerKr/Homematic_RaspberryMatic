#!/usr/bin/env tclsh
#
# Daten von Wetterstation in Homematic einbinden
# Daten werden mittels GET an den Port 2068 im
# Wunderground-Format Übertragen und in die Systemvariablen
# geschrieben
#
# Version 1.1
# Es wird geprüft ob die Software Raspberrymatic ist, wenn ja wird der Sonnenstand geschrieben.
# Die Sys-Vars werden auf jeden Fall angelegt nur nicht "gefüllt"
# Zudem wird geprüft ob die Datei "myWeather.ini" vorhanden ist um die Langzeitarchivierung zu starten
# die ini enthält nur den Pfad wo die Datei abgelegt werden soll.
#
#Um ohne Reboot zu starten über die Konsole folgendes eingeben:
#cd /www/addons/myAddons/
#tclsh myWeather.tcl &
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
#set input {GET /weatherstation/updateweatherstation.php?ID=dehâ–’&PASSWORD=tttt&indoortempf=66.2&tempf=63.0&dewptf=46.0&windchillf=63.0&indoorhumidity=50&humidity=54&windspeedmph=0.9&windgustmph=1.1&winddir=47&absbaromin=29.522&baromin=29.802&rainin=0.000&dailyrainin=0.000&weeklyrainin=0.000&monthlyrainin=0.000&solarradiation=211.64&UV=2&dateutc=2019-09-22%2008:13:00&softwaretype=EasyWeatherV1.4.2&action=updateraw&realtime=1&rtfreq=5 HTTP/1.0}
set ::zaehler 0
set ::messwerte {0 0 0 0 0 0 0 0 0 0}


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
				"windspeedmph"	{
#					set ausgabe "windspeedkmh=[kmh [lindex $werte 1]]"
					writeSysvar _W_Windgesch [kmh [lindex $werte 1]]
				}
				"windgustmph"	{
#					set ausgabe "windgustkmh=[kmh [lindex $werte 1]]"
					writeSysvar _W_Windboee [kmh [lindex $werte 1]]
				}
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
				"indoorhumidity" {
					writeSysvar _W_LuftfeuchteInnen [lindex $werte 1]
				}
				"humidity" {
					writeSysvar _W_LuftfeuchteAussen [lindex $werte 1]
				}
				"solarradiation" {
					writeSysvar _W_Solar [lindex $werte 1]
					mittelwert [lindex $werte 1]
				}
				"UV" {
					writeSysvar _W_UV [lindex $werte 1]
				}
				"soilmoisture" {
					writeSysvar _W_Bodenfeuchte [lindex $werte 1]
				}
				"soilmoisture2" {
					writeSysvar _W_Bodenfeuchte2 [lindex $werte 1]
				}
				"AqPM2.5" {
					writeSysvar _W_AqPM2p5 [lindex $werte 1]
				}
				"winddir" {
					writeSysvar _W_Windrichtung [lindex $werte 1]
				}
				"lowbatt" {
					writeSysvar _V_LowBatt [lindex $werte 1]
				}
				"softwaretype" {
					writeSysvar _V_Softwaretype [lindex $werte 1]
				}
				
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

set mylist "_W_LuftfeuchteInnen _W_LuftfeuchteAussen _W_Bodenfeuchte _W_Bodenfeuchte2"	
for {set a 0} {$a< [llength $mylist] } {incr a} {check_sysvars_hum  [lindex $mylist $a]}

set mylist "_W_Windgesch _W_Windboee"	
for {set a 0} {$a< [llength $mylist] } {incr a} {check_sysvars_wind  [lindex $mylist $a]}

set mylist "_W_Windrichtung _V_Azimut _V_Elevation"	
for {set a 0} {$a< [llength $mylist] } {incr a} {check_sysvars_grad  [lindex $mylist $a]}

set mylist "_W_Solar _W_SolarAV"	
for {set a 0} {$a< [llength $mylist] } {incr a} {check_sysvars_solar  [lindex $mylist $a]}

set mylist "_W_Niederschlag _W_NiederschlagTag _W_NiederschlagWoche _W_NiederschlagMonat _W_NiederschlagJahr"	
for {set a 0} {$a< [llength $mylist] } {incr a} {check_sysvars_rain  [lindex $mylist $a]}


#set mylist "_W_TempInnen _W_LuftfeuchteInnen _W_Luftdruck _W_TempAussen _W_LuftfeuchteAussen _W_Taupunkt _W_Windchill _W_Windgesch _W_Windboee _W_Windrichtung _W_Niederschlag _W_NiederschlagTag _W_NiederschlagWoche _W_NiederschlagMonat _W_NiederschlagJahr _W_UV _W_Solar _W_Azimut _W_Elevation"	
#for {set a 0} {$a< [llength $mylist] } {incr a} {
#	check_sysvars  [lindex $mylist $a]
#}	

socket -server Server 2068
#auswerten $input	
	

vwait forever
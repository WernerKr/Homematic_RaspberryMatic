#!/usr/bin/env tclsh
#
# Systemvariablen auslagern in CSV Tabelle
# V1.1
# ist myWeather.ini da Pfad auslesen
# für tmp-Verzeichnis muss in ini nur /tmp/ eingetragen werden (mit slashes)

load tclrega.so
if {[file exists myWeather.ini]} {
	set fp [open "myWeather.ini" r]
	set mySysvarsdateiname [read $fp]
	append mySysvarsdateiname "mySysvars[clock format [clock seconds] -format {_%m_%Y}].csv"

	set hm_script ""

	if {[file exists $mySysvarsdateiname] == 0} {
		
		set hm_script {

			object oSysVar;
			string sSysVarName;
			string sSysVarId;
			string sShowText=false;
			Write("Datum/Zeit");
			Write(";");
			foreach (sSysVarName, dom.GetObject(ID_SYSTEM_VARIABLES).EnumUsedNames()) {
				if(sSysVarName.Find("_W_")>=0) {	       
					oSysVar=dom.GetObject(sSysVarName);                                              
					Write( oSysVar.Name() );               
					Write(";");
				}
			}
			WriteLine("");
		} 
		set datei [open $mySysvarsdateiname w]	
	} else {
		set datei [open $mySysvarsdateiname a]
	}
	
}

append hm_script {

		object oSysVar;
		string sSysVarName;
		string sSysVarId;
		string sSysVarVal;
		string sShowText=false;
		Write(system.Date("%d.%m.%Y %T"));
		Write(";");
		foreach (sSysVarName, dom.GetObject(ID_SYSTEM_VARIABLES).EnumUsedNames()) {
			if(sSysVarName.Find("_W_")>=0) {	       
		      		oSysVar=dom.GetObject(sSysVarName);
				sSysVarVal = oSysVar.Value().ToString(1);                                             
				Write(sSysVarVal);               
				Write(";");
			}
		}
		Write("");
	}
array set res [rega_script $hm_script]
puts $datei $res(STDOUT)
close $datei

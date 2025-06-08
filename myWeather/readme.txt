
Nutzung auf eigene Gefahr!

Hallo,
eine neue Version. Diese �berpr�ft auf welchem System die Software l�uft, ist dies eine raspi-Version wird die 
Sonnenstandsberechnung durchgef�hrt und in den Systemvariablen abgespeichert. 
Die Systemvariablen werde auf jedem Fall angelegt.

Die Langzeitarchivierung muss nun durch Anlegen einer Datei "myWeather.ini" explizit eingeschaltet werden.
Ist diese Datei vorhanden und leer wird das Archiv im localen Verzeichnis angelegt. 
Man kann durch Angabe eines Pfades in der ini-Datei den Speicherort w�hlen. 
Es darf nur der Pfad dirn stehen zB. /tmp/ sonst nix ;)

Die Nutzung der Software ist auf eigene Gefahr! 
Die Langzeitarchive werden recht gro�, diese sind auf ein geeignetes Medium zu kopieren und auf
der CCU regelm��ig zu l�schen.

"Installations" Anleitung

Unter /usr/local/etc/config/addons/www das Verzeichnis myAddons erstellen.

In dem Verzeichnis myAddons die Dateien myWeather.tcl und myW_tabelle.tcl speichern.

Hier kann eine Datei mit dem Namen "myWeather.ini" angelegt werden. 
Ist diese vorhanden und leer wird im lokalen Verzeichnis die CSV-Tabelle gespeichert.
!! Stre� f�r die SD-Karte !!
Um das zu umgehen kann in der ini-Datei der Pfad angegeben werden (nur der Pfad!) wo die Datei gespeichert werden soll, zB. /tmp/


In dem Verzeichnis /usr/local/etc/config/rc.d die Datei myAddons speichern. 
Diese startet nach einem Reboot automatisch den Server.


Um ohne Reboot zu starten �ber die Konsole folgendes eingeben:
cd /www/addons/myAddons/
tclsh myWeather.tcl &
exit

tclsh myWeather3.tcl &
exit

Unterschied myWeather.tcl und myWeather3.tcl:
myWeather.tcl ist die Original-Version aus dem Jahr 2021
myWeather3.tcl wurde von mir erweitert um die aktuellen Sensoren der Ecowitt Konsolen/Gateways
man kann in dieser Datei einstellen, welche Sensoren ausgewertet werden sollen
z.B.:
set ::_W_Co2_Temp 1	dieser Sensor wird ausgewertet und eine entsprechende Systemvariable angelegt wenn nicht vorhanden.
		die Systemvariable wird auch angelegt, wenn es daf�r keine Werte gibt!
set ::_W_Co2in 0	dieser Sensor wird nicht ausgewertet und auch keine Systemvariable dazu angelegt.

Es ist unbedingt in der Firewall der Homematic der Port:2068 freizugeben ;)
Der Server lauscht nun auf dem Port 2068.
-> socket -server Server 2110

Wenn RaspberryMatic CCU auf Home Assistant l�uft, muss ein Port extra freigegeben werden,
der Port 2068 kann hier nicht verwendet werden!
Port 2110/tcp funktioniert!
und dieser muss dann in der Datei myWeather.tcl bzw. myWeather3.tcl entsprechend ge�ndert werden:
socket -server Server 2110

Die Wetterstation ist mittels der Config App WS View unter
Menu -> Device List -> Station ausw�hlen,
dann kann man die einzelnen Wettservices ausw�hlen.

Solange NEXT dr�cken bis Customized -Y Enable,
Protocol Wunderground, Server IP Ip Adresse der CCU,
Station ID irgendwas, Station Key auch irgendwas,
Port:2068, Upload Interval 60 -> Save
bzw.
Port:2110, Upload Interval 60 -> Save

und schon sendet die Station die Daten an die CCU.


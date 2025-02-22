#!/usr/bin/env bash
#x_shellcheck disable=all
# :: Erzeugt csv Dateien aus ods Dateien
  # :name: csv
  # :type: module
#
#
# SOURCES:
  #shellcheck source-path=./Framework
. "$(dirname "${BASH_SOURCE[0]}")/fus.sh"
#
_exit_for_root
#
# :: Gibt die Hilfe aus
  # :name: help_csv
  # :type: procedure
  # :scop: readonly
help_csv () {
    local description
    read -r -d '' description <<- 'DESCRIPTION'
	AUFRUF:   ./Framework/csv.sh -h
	          ./Framework/csv.sh [-dv] SCHEMA
	OPTIONEN: -h --help      diese Hilfe
	          -d --dry       nur simulieren, nichts tun (sinnvoll mit verbose)
	          -v --verbose   anzeigen, was getan wird

	Erstellt csv Dateien aus allen ods Dateien im Verzeichnis SCHEMA neu
	(löscht alte);
	SCHEMA.txt ist die Steuerungsdatei, SCHEMA ist ein Verzeichnis.
	Die csv Dateien werden pro Sheet zusammengehängt ins aktuelle
	Verzeichnis kopiert.
	DESCRIPTION

    _help "${description}"
};readonly -f help_csv
#
# :: Gibt zurück, ob alle Voraussetzungen für das Script erfüllt sind
  # :name: requirements_are_met_csv
  # :type: func
  # :pars: PARA Alle Parameter des Aufrufs des Scripts
  # :para: 1/SCHEMA - Name des schemas ohne Erweiterung
  # :desc: Tests für alle Voraussetzungen, die erfüllt sein müssen, damit eine
  #        Funktion  ausgeführt werden kann, werden hier mit den an die
  #        aufrufenden Funktion übergebenden Argumenten ausgeführt.
  #        Ist eine Voraussetzung nicht erfüllt, wird eine Fehlermeldung
  #        ausgegeben und ein Fehlerstatus zurückgegeben. Nachfolgende Tests
  #        werden nicht ausgeführt.
  #        Wenn alle Tests bestanden wurden, wird der Status 0 zurückgegeben
  # :stat: 0, falls ok
  #        2, falls Anzahl ARGS nicht 1 ist
  #        2, falls SCHEMA kein String ist
  #        2, falls SCHEMA.schema keine Datei ist
  #        2, falls db/SCHEMA.txt keine Datei ist
  #        2, falls db/SCHEMA kein Verzeichnis ist
  #        1, falls soffice.bin als Prozess läuft
  # :retu: falls nicht ok, wird eine Fehlermeldung aus-/zurück-gegeben
  # :scop: readonly
function requirements_are_met_csv {
    _number_of_args_is 1 "$@"
    _error $? "-nr_args_needed" 1 || return 2

    _is_string "$1"
    _error $? "-no_string" "$1" || return 2

    _is_file "${PROJECT_DIR}/$1.schema"
    _error $? "-no_file" "${PROJECT_DIR}/$1.schema" || return 2

    _is_file "${PROJECT_DIR}/db/$1.txt"
    _error $? "-no_file" "${PROJECT_DIR}/db/$1.txt" || return 2

    _is_dir "${PROJECT_DIR}/db/$1"
    _error $? "-no_dir" "${PROJECT_DIR}/db/$1" || return 2

    _is_not_running_cmd "soffice.bin"
    _error $? "soffice_runs" || return 1

    return 0
}; readonly -f requirements_are_met_csv
#
# :: Tut die Arbeit
  # :name: main_csv
  # :type: procedure
  # :scop: readonly
function main_csv {
  # Variablen
    local tag="${Grey}${blue}csv.sh >> ${clr}"
    local dbg="${Yellow}${red}"
    local dbg0="${clr}"
    local dry=0
    local verbose=0
    local SCHEMA feldTrenner textTrenner zeichensatz first_line ctrl_file
    local ods_dir ods_file nr file_nr ctrl_str csv_file
    local sheet_csv clean_sheet zwiFile1 zwiFile2 pattern main_file
  #
  # Optionen und Argumente
    #shellcheck disable=2046 disable=2312
    set -- $( _long2short_opts "$@" )
    while getopts :dhv opt; do { case ${opt} in
        d) dry=1;;
        h) help_csv; exit;;
        v) verbose=1;;
        ?) help_csv; exit 2;;
        *) help_csv; exit 2;; # für shellcheck
    esac } done
    shift $((OPTIND-1))

    requirements_are_met_csv "$@"  || exit $?
  : <<- DESCRIPTION_CMD_LINE_LIBRE_OFFICE
		Optionen für libreoffice --convert-to
		Quelle: https://help.libreoffice.org/\
				latest/km/text/shared/guide/csv_params.html?&DbPAR=SHARED&System=UNIX
		Argumentstring für libreoffice --convert-to
		1. feldTrenner,
		feldTrenner=59 # 44 Komma,; 59/9 Strichpunkt und TAB ;
		2. textTrenner,
		textTrenner=34 #  34 for double quotes and 39 for single quotes. ;
		3. Zeichensatz,
		zeichensatz=0 # 0 System; 76 Unicode (UTF-8);
		4. Zeile
		first_line=1 # Nummer der ersten Zeile, startet mit 1 - funktioniert nicht
		               in libre office 7.4.7.2
		5. Formatierungen von Spalten NrSpalte/formatSpalte/NrSpalte/formatSpalte,
		   Formate sind:
		   1	Standard
		   2	Text
		   3	MM/DD/YY
		   4	DD/MM/YY
		   5	YY/MM/DD
		   6	–
		   7	–
		   8	–
		   9	ignore field (do not import) (Funktioniert wohl nicht für Export)
		   10	US-English
		6 : Language identifier, wenn 0 oder weggelassen, wird UI Sprache benutzt
		7 This token is the equivalent of the check box "Quote all text cells".
		  false or true. Default value : false.
		8 This token has no UI equivalent. If true, the number cells are stored as
		  numbers. If false, the numbers are stored as text, with text delimiters.
		9 This token is the equivalent of the check box "Save cell contents as
		  shown". false or true. Default value : true.
		10 Export cell formulas. String, either false or true.
		   Default value : false.
		11 not used
		11 das letzte Argument auf -1 gesetzt gibt alle Tabellenblätter aus, auf
		   die Blattnummer gesetzt kann man die Sheet Ausgabe steuern
		DESCRIPTION_CMD_LINE_LIBRE_OFFICE
  #
  # Vor Schleife über Quelldateien
    SCHEMA="${1}"
    feldTrenner=59
    textTrenner=34
    zeichensatz=0
    first_line=1
    ctrl_file="./db/${SCHEMA}.txt" # db/my.txt
    ods_dir="./db/${SCHEMA}" # db/my
    file_nr=0
    pattern='([^/_]+)(_.*-)([^-]+\.csv)'

    #shellcheck disable=2312
    if (( verbose )); then
        echo -e "${tag}cd ${ods_dir}; "
        echo -e "rm -f *.csv"
    fi;
    if (( ! dry )); then
        cd "${ods_dir}" || exit
        rm -f "*.csv";
    fi;
  #
  # Schleife über alle Quelldateien des Schemas
    for ods_file in *.ods; do
      # Dateinummer weiterzählen
        # Wir befinden uns im Verzeichnis db/SCHEMA/
        ((file_nr++))
        nr=0
        if (( verbose )); then
          echo -en "  ${dbg}For FILE_NR:${file_nr};${dbg0} ";
          echo "ODS_FILE:${ods_file}; CTRL_FILE:${ctrl_file};";
        fi
      # Schleife über alle Zeilen im ctrl_file
        # IFS auf leer setzen, eine Eingabezeile lesen
        # von wo lesen steht hinter done:  < ../../${ctrl_file}
        # UND die Zeile ist nicht leer
        while IFS= read -r line  && [[ -n "${line}" ]]; do
          # Zeile weiterzählen
            ((nr++))
            ctrl_str=${line}
            if [[ "${ctrl_str}" == "skip" ]]; then
                if (( verbose )); then
                    echo -e "    ${dbg}SKIP nr:${nr};${dbg0}";
                fi
                continue
            fi
            if [[ "${ctrl_str}" == "run" ]]; then
                ctrl_str=""
            fi
            if (( verbose )); then
                echo -e "    ${dbg}WHILE nr:${nr};${dbg0} LINE:${line};";
            fi
          # csv Datei erzeugen und Namen der erzeugten Datei erhalten
            # libreoffice --convert-to "csv:Text - txt - csv (StarCalc):
            #     59,34,0,1,1/2/2/1/3/2/4/2/5/2,0,false,true,false,false,
            #     false,2" SCHEMA/SCHEMA_quelle.ods
            # gibt aus:
            #   Writing sheet SHEET -> PRJ_DIR/db/SCHEMA/SCHEMA_quelle-SHEET.csv
            # oder:
            #   Writing sheet SHEET -> PRJ_DIR/db/SCHEMA/SCHEMA_quelle-SHEET.csv
            #   Overwriting: PRJ_DIR/db/SCHEMA/SCHEMA_quelle-SHEET.csv
            # Deswegen schicke ich die Ausgabe über den awk um den
            # Namen der erzeugten Datei zu erhalten
            if (( verbose )); then
                echo -ne "    ${tag}libreoffice --convert-to "
                echo -n "\"csv:Text - txt - csv (StarCalc): "
                echo -n "${feldTrenner},${textTrenner},${zeichensatz},"
                echo -n "${first_line},${ctrl_str},0,false,true,"
                echo -n "false,false,false,${nr}\" \"${ods_file}\" | "
                echo "awk -F'([>:] )' 'BEGIN {fn=\"\"}{fn=\$NF}END {print fn}'"
            fi;
            if (( !  dry )); then
                #shellcheck disable=2312 disable=2250
                sheet_csv="$(libreoffice --convert-to \
                    "csv:Text - txt - csv (StarCalc): \
                    $feldTrenner,$textTrenner,$zeichensatz,\
                    $first_line,$ctrl_str,0,false,true,\
                    false,false,false,$nr" "$ods_file" | \
                    awk -F'([>:] )' 'BEGIN {fn=""}{fn=$NF}END {print fn}')"
            fi;
            if (( dry ));
                # sheet_csv wird dry nicht erzeugt, von den folgenden
                # Befehlen aber gebraucht
                then continue;
            fi;
          #
          # Namen überprüfen und Variablennamen bereitstellen
            if [[ ! ${sheet_csv} =~ ${pattern} ]]; then
                echo -e "${dbg}!!!!Hier stimmt was mit dem ods file Namen nicht";
            fi
            # BASH_REMATCH wurde durch den pattern Vergleich oben erzeugt.
            zwiFile1="z1_${BASH_REMATCH[1]}${BASH_REMATCH[2]}${BASH_REMATCH[3]}"
            zwiFile2="z2_${BASH_REMATCH[1]}${BASH_REMATCH[2]}${BASH_REMATCH[3]}"
            clean_sheet="_${BASH_REMATCH[1]}${BASH_REMATCH[2]}${BASH_REMATCH[3]}"
            csv_file="${BASH_REMATCH[1]}_${BASH_REMATCH[3]}"
            if (( file_nr == 1 )); then
                if (( verbose )); then
                    echo -e "    ${tag}rm -f ../${csv_file}";
                fi
                rm -f ../"${csv_file}"
            fi
          #
          # Leere Sheets zu wirklich leeren csv Dateien verändern
            # libreoffice konvertiert ein leeres Sheet zu einer csv Datei mit
            # einem Zeichen. Damit kann MariaDb nicht umgehen.
            # Eine leere Datei ist in Ordnung.
            fileSize=$(stat -c%s "${sheet_csv}")
            #shellcheck disable=2292
            if [ "${fileSize}" -eq 1 ]; then
                if (( verbose )); then
                    echo -en "    ${tag}rm ${sheet_csv}; "
                    echo "touch ${sheet_csv}";
                fi;
                rm "${sheet_csv}"
                touch "${sheet_csv}"
            fi
            fileSize=$(stat -c%s "${sheet_csv}")
          #
          # CSV syntaktisch an Mariadb anpassen
            # Kommentare weg; Dezimaltrenner Komma; Quellen zusammenführen
            #shellcheck disable=2291 disable=2028
            if (( verbose )); then
                echo -e "    ${tag}sed '/^#.*/d' ${sheet_csv} > ${zwiFile1}";
                echo -e "    ${tag}sed 's/#.*$//g' ${zwiFile1} > ${zwiFile2}";
                echo -ne "    ${tag}sed "
                echo -n           "'s/\([[:digit:]]\)\,\([[:digit:]]\)/\1.\2/g'"
                echo -e             " ${zwiFile2} > ${dbg}${clean_sheet}${clr}"
                echo -e "    ${tag}rm ${zwiFile1}";
                echo -e "    ${tag}rm ${zwiFile2}";
            fi
            # Kommentare entfernen, zuerst ganze Zeilen, dann bis zum Zeilenende
            sed '/^#.*/d' "${sheet_csv}" > "${zwiFile1}"
            sed 's/#.*$//g' "${zwiFile1}" > "${zwiFile2}"
            # Trenner für Dezimalzahlen von Komma zu Punkt
            sed 's/\([[:digit:]]\)\,\([[:digit:]]\)/\1.\2/g' \
                                "${zwiFile2}" > "${clean_sheet}"
            rm "${zwiFile1}"
            rm "${zwiFile2}"
          #
          # Den Output zur gesammelten Ausgabedatei hinzufügen
            #Es wurden für jede Tabelle jeder Quelle je eine csv Datei erzeugt
            #1 Quelle quelle für schema, Sheets main und de
            #  schema_main.csv <= schema_quelle-main.csv
            #  schema_de.csv <= schema_quelle-de.csv
            #2 Quellen quelle und any für schema, Sheet de
            #  schema_de.csv <= age_quelle-de.csv age_any-de.csv
            # Alle Quellen (pro Sheet) in eine Datei
            if (( verbose )); then
                echo -e "    ${tag}cat ${clean_sheet} >> ../${csv_file}";
            fi;
            cat "${clean_sheet}" >> ../"${csv_file}"
          # Sicherstellen, daß ../SCHEMA_main.csv existiert
            #Makefile braucht eine ../SCHEMA_main.csv
            #Manche Schema nennen das Haupt Tabellenblatt SCHEMA
            #Dann wurde ../SCHEMA_SCHEMA.csv erzeugt
            #Diese nach ../SCHEMA_main.csv soft verlinken
            if [[ "${csv_file}" == "${SCHEMA}_${SCHEMA}.csv" ]]; then
                main_file="${SCHEMA}_main.csv"
                if (( verbose )); then
                    echo -e "        ${tag}pushd .. >/dev/null"
                    echo -e "        ${tag}ln -sf ${csv_file} ${main_file}"
                    echo -e "        ${tag}popd >/dev/null"
                fi;
                pushd .. >/dev/null
                ln -sf "${csv_file}" "${main_file}"
                #shellcheck disable=2164
                popd >/dev/null
            fi
        done < ../../"${ctrl_file}" # Für jede Tabelle
    done # Für alle Quellen
  #
  # Nach Schleife über Quelldateien
    if (( verbose )); then
        echo -e "${tag}cd ../..";
    fi;
    cd ../..
}; readonly -f main_csv
#
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  # Wird nur aufgerufen, wenn die Datei direkt als Skript gestartet wird.
  # Wir weder aufgerufen, wenn sie inkludiert wird, noch wenn sie getestet wird.
    main_csv "$@"
fi


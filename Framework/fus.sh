#!/usr/bin/env bash
#x_shellcheck disable=all
# :: Funktionssammlung für Framework txt2db
  # :name: fus
  # :type: module
  # :desc: Enthält Funktionen, die für mehrere Skripte dieses Projekts nützlich
  #        sind
  # :deps: SCRIPT_DIR/fus4sh/base.sh (mit colors.dat u. messages.dat)
#
# SOURCES: fus4sh inkludieren; MSG und MSG_MAP füllen und exportieren
  # :impl: Die Reihenfolge ist zu beachten.
  #        MSG und MSG_MAP werden in base.sh deklariert
  #           in msgs.dat gefüllt
  #           hier readonly gesetzt
  #
  # Der folgende source-path funktioniert falls fus4sh ins Projekt gelinkt ist
  # Möglicherweise muß man ihn direct über die SOURCE Anweisung verschieben
  # shellcheck source-path=SCRIPTDIR/../fus4sh
  show_functions=1
  root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
  root_dir="${root_dir%/Framework}" # entfernt trailing "/Framework"
  script_dir="$(printenv SCRIPT_DIR)"  || :
  if [[ -f "${script_dir}/fus4sh/include/base.sh" ]]; then
    # SCRIPT_DIR ist unabhängig von diesem Projekt
    # Shellcheck kann nicht mit Variablen
    # Es liest Direktiven auch aus Konfigurationsdateien .shellcheckrc
    # Wir geben die nötigen Direktiven aus, fall kein .shellcheckrc existiert
    if ! [[ -f "${root_dir}/.shellcheckrc" ]]; then
        echo "fus4sh wird durch \"SCRIPT_DIR\" als \"${SCRIPT_DIR}/fus4sh\""
        echo "eingebunden. Shellcheck kann Pfade nicht über Variablen auflösen."
        echo "Es kann diese Pfade aus seiner Konfigurationsdatei lesen."
        echo ""
        echo "Dieses Script mit der Option -c aufgerufen erstellt sie:"
        echo "${root_dir}/Framework/fus.sh -c"
        echo ""
        echo "Manuell können Sie so verfahren:"
        echo "Legen Sie eine Datei \"${root_dir}/.shellcheckrc\" an."
        echo "Schreiben Sie folgende zwei Textzeilen in diese Datei: "
        echo ""
        echo "source-path=${SCRIPT_DIR}"
        echo "source-path=${SCRIPT_DIR}/fus4sh"
        echo ""
        show_functions=0
    fi
  else # fus4sh ist in die Projektwurzel verlinkt
      script_dir="${root_dir}"
  fi
  #script_dir="/home/user/Skripte"                   # Direkte Anpassung
  #shellcheck source-path=/home/user/Skripte         # Direkte Anpassung
  #shellcheck source-path=/home/user/Skripte/fus4sh  # Direkte Anpassung
. "${script_dir}/fus4sh/include/base.sh"
  unset script_dir
  unset root_dir
. "./Framework/msgs.dat"
    #shellcheck disable=2090
    export MSG;export MSG_MAP
#
# :: erzeugt aus Statements in sql shell script
  # :name: write_sql_script
  # :type: procedure
  # :para  1/SQL_CMD (String) nur SELECT implementiert
  #        2/SQL_FILE (String)
  #        3/SCRIPT_FILE (String)
  # :stat: 0 - falls alles ok
  #        1 - falls SQL_CMD nicht gleich SELECT
  #        2 - falls zu wenig Argumente oder zu viele Argumente
  # :desc: Jedes SQL Statement aus SQL_FILE bis zu  einem Strichpunkt
  #        (einschließlich) wird in eine neue Zeile von SCRIPT_FILE geschrieben.
  #        Davor wird der Aufruf von mariadb mit den Werten
  #        für user, password und database geschrieben,
  #        die mittels _value_of  ermittelt werden. Das Statement
  #        selbst wird in einfache Anführungszeichen eingeschlossen.
  # :scop: readonly
write_sql_script() {
    (( $# != 3 )) && return 2

    local str db user pwd statements
    local stm=$1
    local sql_file=${2}
    local script_file=$3

    if [[ ${stm} != "SELECT" ]]; then return 1; fi

    rm -f "${script_file}"
    touch "${script_file}"
    chmod 770 "${script_file}"

    statements=$(awk '/SELECT/,/;/' "${sql_file}")

    db="$(_value_of db_db)"
    user="$(_value_of db_user)"
    pwd="$(_value_of db_password)"

    #shellcheck  disable=2292
    while [ "${statements}" != "${str}" ]; do
        str=${statements%%;*}
        statements="${statements#"${str}";}"

        #shellcheck disable=2292
        if [ "${statements}" == "${str}" ]; then break; fi
        str+=";"
        #shellcheck disable=2312
        statement=$(echo "${str}" | tr "\n" " " | xargs) # line break 2 spaces
        echo -n "mariadb --user=${user} --password=${pwd} ">>"${script_file}"
        echo "--database=${db} -e '""${statement}""'" >>"${script_file}"
    done
}; readonly -f write_sql_script
#
# :: gibt alle Tabellennamen aus der Datei SCHEMA.schema zurück
  # :name: tables_of_schema
  # :type: function
  # :para: 1/SCHEMA/string
  # :stat: 0 - falls alles ok
  #        1 - falls die Datei SCHEMA.schema nicht existiert
  #        2 - falls zu wenig Argumente oder zu viele Argumente
  # :retu: Wert (String) falls alles ok
  # :desc: Sucht nach CREATE TABLE in der Datei SCHEMA.schema und gibt das
  #        darauf folgende Wort zurück. CREATE TABLE muß jeweils am Beginn der
  #        Zeile stehen, whitespace ist davor erlaubt.
  # :scop: readonly
function tables_of_schema { # SCHEMA
    (( $# != 1 )) && return 2
    if ! [[ -f $1.schema ]]; then return 1; fi

    local SCHEMA_FILE x TABLES

    SCHEMA_FILE=$1.schema
    x=$(awk '/CREATE TABLE/ {print $3}' "${SCHEMA_FILE}") # x=tbl1( tbl2(
    TABLES=$(echo "${x}" | tr -d "(")                     # remove all (

    #shellcheck disable=2312
    echo "${TABLES}" | tr "\n" " " | xargs                # linebreak to space
}; readonly -f tables_of_schema
#
# :: Gibt das Level von SCHEMA zurück
  # :name: write_sql_script
  # :type: function
  # :para  1/SCHEMA (String)
  # :desc: Gibt das Level von SCHEMA zurück
  #        Die letzte Ziffer in der Datei wird als Level betrachtet
  # :stat: 0 - falls alles ok
  #        1 - falls Datei .db/SCHEMA.lvl nicht existiert
  #        1 - falls Datei .db/SCHEMA.lvl keine Ziffer enthält
  #        1 - falls Datei .db/SCHEMA.lvl mehr als eine Ziffer enthält
  #        2 - falls zu wenig Argumente oder zu viele Argumente
  # :retu: Level von SCHEMA (Ziffer)
  # :scop: readonly
function schema2level {
    (( $# != 1 )) && return 2
    if ! [[ -f "db/$1.lvl" ]]; then return 1; fi

    local schema level level_file m number
    schema="$1"
    level_file="./db/${schema}.lvl"
    level=$(grep -Eo '[0-9]' "${level_file}")
    if [[ -z "${level}" ]]; then return 1; fi
    #shellcheck disable=2034
    for number in ${level}; do
      if [[ -v m ]]; then
        return 1;
      fi;
      m=1;
    done
    echo "${level}"
};readonly -f schema2level
#
# :: Gibt eine (evtl leere) Liste aus Schema Namen zurück
  # :name: level2schemas
  # :type: function
  # :para  1/LEVEL (Ziffer)
  # :desc: Gibt alle Schema des Levels zurück
  # :stat: 0 - falls alles ok
  #        2 - falls zu wenig Argumente oder zu viele Argumente
  # :retu: Schemas von LEVEL (String list)
  # :scop: readonly
function level2schemas {
    # Argument 1 ist eine Ziffer außer 0
    #
    (( $# != 1 )) && return 2
    level="$1"
    files=""
    schemas=( )
    #shellcheck disable=2312
    files=$(find  ./db -maxdepth 1 -name "*.lvl"  -print0 | \
                                               xargs --null grep -l "${level}")
    for f in ${files};   do
        f2="${f%.*}"
        schema="${f2##*/}"
        if [[  -f "${PROJECT_DIR}/${schema}.schema" ]]; then
            schemas+=("${schema}")
        fi
    done
    echo "${schemas[@]}"
};readonly -f level2schemas
#
# :: Gibt Namen aller Schema sortiert nach level aufsteigend zurück
  # :name: sort_schemas
  # :type: function
  # :desc: Gibt Namen aller Schema sortiert nach level aufsteigend zurück
  # :stat: 0 - falls alles ok
  #        1 - falls keine Datei *.schema existiert
  #        1 - falls schema2level für eine existierende *.schema fehlschlägt
  #        2 - falls Argument(e)
  # :retu: Liste von Namen von Schemas sortiert (list of words)
  # :scop: readonly
function sort_schemas {
    (( $# != 0 )) && return 2
    if ! ls ./*.schema &>/dev/null; then return 1; fi

    local schemas sorted i schema level
    # shellcheck disable=2012 disable=2312 disable=2035
    # todo disables überprüfen
    schemas=$(ls -1 *.schema | sed -e 's/\.schema$//')

    sorted=""
    for ((i = 1 ; i < 10 ; i++ )); do
        for schema in ${schemas};do
            level=$(schema2level "${schema}")
            if [[ ${level} == "" ]]; then return 1; fi
            if ((level==i)); then
                sorted+="${schema} "
            fi
        done
    done

    echo "${sorted}"
};readonly -f sort_schemas
#
# :: Ersetzt in FILE alle Placeholder mit in Vars gefundenen Werten
  # :name: replace_placeholders
  # :type: procedure
  # :para  1/FILE (File)
  # :desc: Ersetzt alle %%key%% in FILE mit den entsprechenden %%value%%
  #        aus Vars für alle key;value; Paare aus Vars
  # :stat: 0 - falls alles ok
  #        2 - falls nicht genau 1 Argument
  #        2 - falls FILE keine Datei ist
  #        1 - falls Vars nicht existiert
  # :scop: readonly
replace_placeholders() {
    (( $# != 1 )) && return 2
    if [[ ! -f "$1" ]]; then return 2; fi
    if [[ ! -f "Vars" ]]; then return 1; fi

    local file line key value
    file=$1
    # shellcheck disable=2162
    while read line; do # Backslashes sollen wirken, drum kein -r
        if [[ -n ${line} ]] && [[ ${line} != "#"*  ]]; then
            key=${line%%;*}
            value="$(_value_of "${key}")"
            sed -i -e "s/%%${key}%%/${value}/g" "${file}"
        fi
    done <Vars
};readonly -f replace_placeholders
#
# :: Ersetzt in FILE alle funktionalen Placeholder mit dem Ergebnis
  # :name: replace_placeholders
  # :type: replace_placeholder_functions
  # :para  1/SCHEMAS (String list)
  # :para  2/SCHEMA (String)
  # :para  3/TABLE (String)
  # :para  4/SELECT_FILE (File)
  # :para  5/FILE (File)
  # :desc: Ersetzt alle (%fu%) in FILE mit dem Ergebnis der Funktion
  #        create_fu. Parameter 1-4 werden an die Funktion Placeholder
  #        Funktion übergeben, Parameter 5 ist die Datei in der ersetzt
  #        wird.
  #        Die Placeholder Funktion wird in der Datei tmpl_fus.sh
  #        gesucht. Falls sie dort nicht ist, wird nicht ersetzt.
  # :stat: 0 - falls alles ok
  #        2 - falls nicht genau 5 Argumente
  #        1 - falls FILE keine Datei ist
  # :scop: readonly
replace_placeholder_functions() {
    (( $# != 5 )) && return 2
    if [[ ! -f "$5" ]]; then return 1; fi
    local SCHEMAS SCHEMA TABLE SELECT_FILE php_file
    local fus fu placeholder_function placeholder command replacement
    SCHEMAS=$1
    SCHEMA=$2
    TABLE=$3
    SELECT_FILE=$4
    php_file=$5
    #shellcheck disable=2046
    #todo untersuche disables
    fus=$(grep "function create_" $(dirname "${BASH_SOURCE[0]}")/tmpl_fus.sh)
    while read -r fu; do # Backslashes egal, drum -r für shellcheck
        placeholder_function="${fu%% \{*}"
        placeholder_function="${placeholder_function##*function }"
        placeholder="${placeholder_function##*create_}"
        if grep "${placeholder}" "${php_file}" > /dev/null; then
            command="replacement=\"\$(${placeholder_function} \
            3 \"${SCHEMAS}\" \"${SCHEMA}\" \"${TABLE}\" \"${SELECT_FILE}\" )\""
            #shellcheck disable=2086
            eval ${command}
#set -x
            sed -i -e "s/(%${placeholder}%)/${replacement}/g" "${php_file}"
#set +x
        fi
    done <<< "${fus}"
};readonly -f replace_placeholder_functions
#
# :: Liefert Einrückung von IND mal DEPTH zurück
  # :name: i
  # :type: function
  # :para: 1/IND/string
  # :para: 2/DEPTH/number
  # :desc: Gibt IND DEPTH mal zusammengehängt zurück
  # :stat: 0 - falls alles ok
  #        2 - falls nicht genau 2 Argument
  #        2 - falls IND kein String ist
  #        2 - falls DEPTH keine positive ganze Zahl ist
  #        1 - falls Vars nicht existiert
  # :retu: INDxDEPTH (String)
  # :scop: readonly
function i() {
    (( $# != 2 )) && return 2
    if ! _is_string "$1"; then return 2; fi
    if ! _is_number "$2"; then return 2; fi

    local ind="$1" depth="$2" ret=""
    while (( depth > 0 )); do
        ((depth--))
        ret+="${ind}"
    done
    echo "${ret}"
};readonly -f i
#
# :: Schreibt .shellcheckrc
  # :name: create_config
  # :type: procedure
create_config() {
    cfg_file="${PROJECT_DIR}/.shellcheckrc"
    if [[ -f "${cfg_file}" ]]; then
        echo "Schreibe ${cfg_file} neu"
    else
        echo "Erzeuge ${cfg_file}"
    fi
    echo "source-path=${SCRIPT_DIR}" > "${cfg_file}"
    echo "source-path=${SCRIPT_DIR}/fus4sh" >> "${cfg_file}"

}
#
# :: Gibt die Hilfe aus
  # :name: help_fus
  # :type: procedure
  # :scop: readonly
help_fus() {
  local description
  read -r -d '' description <<- DESCRIPTION
	AUFRUF: fus.sh -h
	        fus.sh --help
	        fus.sh -c create config, erzeugt die Shellcheck Konfiguration
	        fus.sh

	BESCHREIBUNG
	    Diese Datei ist in erster Linie eine Funktionssammlung. Dazu wird sie
	    in andere Scripte inkludiert.

	    Als Funktionssammlung verlinkt sie in "fus4sh", ein weiteres Projekt
	    der Moncastry-Suite. Dieses wird über die Umgebungsvariable "SCRIPT_DIR"
	    gefunden oder über einen symbolischen Link:
	        ln -s ${SCRIPT_DIR}/fus4sh ${PROJECT_DIR}

	    Bei Aufruf mit der Option -c wird die Shellcheck Konfigurationsdatei
	    ${PROJECT_DIR}/.shellcheckrc (neu) erzeugt. Eine vorhandene
	    .shellcheckrc wird dabei überschrieben. .shellcheckrc wird nur gebraucht,
	    wenn Scripte dieses Projektes mit shellcheck überprüft werden sollen und
	    dann nur, falls fus4sh über die Umgebungsvariable "SCRIPT_DIR" eingebunden
	    ist.

	    Wenn diese Datei als Script aufgerufen wird, zeigt sie die implementierten
	    Funktionen mit einer Kurzbeschreibung an.
	DESCRIPTION

  _help "${description}"
};readonly -f help_fus
#
# :: Gibt den Namen der Datei aus und alle implementierten Funktionen
  # :name: main_fus
  # :type: procedure
  # :desc: Gibt den Namen der Datei aus und gibt danach die Namen aller
  #        implementierten Funktionen mit einer Kurzbeschreibung aus.
  # :impl: Das Einlesen des Heredoc mit der Umleitung "<<-" bewirkt, dass
  #        die Tabulatoren am Zeilenanfang entfernt werden.
main_fus() {
  # shellcheck disable=2046 disable=2312
  set -- $( _long2short_opts "$@" )
  while getopts ch opt; do { case ${opt} in
      c) create_config; exit;;
      h) help_fus; exit;;
      ?) help_fus; exit 2;;
      *) help_fus; exit 2;; # für shellcheck
  esac } done
  shift $((OPTIND-1))

  if ((show_functions > 0 )); then
  echo "in fus.sh"

  cat <<- AUSGABE
	Funktionen in dieser Sammlung
	=============================
	replace_placeholder_functions:   Löst in FILE alle (%x%) durch create_x auf
	replace_placeholders FILE:       Ersetzt in FILE alle %%key%% durch Vars Werte
	schema2level SCHEMA:             Gibt Level für SCHEMA zurück
	sort_schemas:                    gibt alle Tabellen aus NAME.schema zurück
	tables_of_schema NAME:           gibt schemas sortiert nach level zurück
	write_sql_script STMTS FILE:     schreibt STMTS als mariadb Befehle in FILE
	AUSGABE
  fi
}; readonly -f main_fus
#
if [[ ${BASH_SOURCE[0]} == "$0" ]]; then
  # Wird nur aufgerufen, wenn die Datei direkt als Skript gestartet wird.
  # Wir weder aufgerufen, wenn sie inkludiert wird, noch wenn sie getestet wird.
    main_fus "$@"
fi
#!/usr/bin/env bash
#x_shellcheck disable=all
# :: Zerlegt eine SCHEMA Datei
  # :name: splitschema
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
  # :name: help_splitschema
  # :type: procedure
  # :scop: readonly
help_splitschema () {
    local description
    read -r -d '' description <<- 'DESCRIPTION'
	AUFRUF: splitschema.sh [-dhv] SCHEMA (mit SCHEMA.schema in akt. Verzeichnis)

	Teilt eine Datei an den ersten 7 Zeilen die mit "### ---" beginnen und
	erzeugt aus den letzten 6 Teilen neue Dateien.

	Das Grundgerüst der Datei:
	    ### --- Kommentare                  => erzeugt keine Datei
	    Kommentar
	    ### --- Abfragen                    => db/SCHEMA_select.sql
	    SELECT ... FROM  TABLE;             => db/SCHEMA_test.sh
	    ### --- Level                       => db/SCHEMA.lvl
	    kcal 2
	    ### --- Schema Definition           => db/SCHEMA_create.sql
	    CREATE TABLE ...;
	    ### --- Remove Table(s)             => db/SCHEMA_drop.sql
	    DROP TABLE IF EXISTS ...
      ### --- Remove Data                 => db/SCHEMA_delete.sql
      DELETE FROM `x`, `y` USING ...
	    ### --- Read Data in                => db/SCHEMA_loaddata.sql
	    SHOW WARNINGS;
	    LOAD DATA LOCAL ...;
	    ### --- CSV Control (*)             => db/SCHEMA.txt
	    1/2/2/1/3/2/4/2/5/2

	Wenn die Datei "example.schema"  heisst werden folgende 7 Dateien erzeugt:
	    "db/example_select.sql" (1.Teil)
	    "db/example.lvl" (2.Teil)
	    "db/example_create.sql" (3.Teil)
	    "db/example_drop.sql" (4.Teil)
	    "db/example_delete.sql" (5.Teil)
	    "db/example_loaddata.sql" (6.Teil)
	    "db/example.txt" (7.Teil)
	Die Originaldatei bleibt unverändert erhalten.

	(*) Die Anzahl der Zeilen nach dem letzten Trenner "### --- CSV Control"
	    muß der Anzahl der Tabellenblätter entsprechen, aus denen "db/csv.sh" csv
	    Dateien erzeugen soll. Die erste Zeile entspricht dem ersten Tabellenblatt
	    in der ods Datei, die zweite dem zweiten, ...
	DESCRIPTION

    _help "${description}"
};readonly -f help_splitschema
#
# :: Gibt zurück, ob alle Voraussetzungen für das Script erfüllt sind
  # :name: requirements_are_met_splitschema
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
  #        2, falls SCHEMA".schema" keine Datei ist
  # :retu: falls nicht ok, wird eine Fehlermeldung aus-/zurück-gegeben
  # :scop: readonly
function requirements_are_met_splitschema {
    _number_of_args_is 1 "$@"
    _error $? "-nr_args_needed" 1 || return 2

    _is_string "$1"
    _error $? "-no_string" 1 || return 2

    _is_file "${PROJECT_DIR}/$1.schema"
    _error $? "-no_file" "${PROJECT_DIR}/$1.sh" || return 2

    return 0
}; readonly -f requirements_are_met_splitschema
#
# :: Tut die Arbeit
  # :name: main_splitschema
  # :type: procedure
  # :scop: readonly
function main_splitschema {
    local tag="${Grey84}${blue}splitschema>> ${clr}"
    local dry=0
    local verbose=0
    local SCHEMA fn test_file target last_split_idx

    #shellcheck disable=2046 disable=2312
    set -- $( _long2short_opts "$@" )
    while getopts :dhv opt; do { case ${opt} in
        d) dry=1;;
        h) help_splitschema; exit;;
        v) verbose=1;;
        ?) help_splitschema; exit 2;;
        *) help_splitschema; exit 2;; # für shellcheck
    esac } done
    shift $((OPTIND-1))

    requirements_are_met_splitschema "$@"  || exit $?

    SCHEMA="${1}"
    fn="${SCHEMA}.schema"

  # Splittet Datei fn ab dem 2. Vorkommen von "###" an 8 Zeilen die mit "###"
    # beginnen. Erzeugt daraus die Dateien SCHEMA0 SCHEMA1 SCHEMA2 SCHEMA3
    # SCHEMA4 SCHEMA5 SCHEMA6
    if (( verbose )); then echo -en "${tag}"
        echo -n "csplit -s -f \"${SCHEMA}\" -n 1 \"${fn}\" '%^###%'"
        echo " '%^###%' '/^###/' '/^###/' '/^###/' '/^###/' '/^###/' '/^###/1'"
    fi;
    if (( ! dry )); then
        csplit -s -f  "${SCHEMA}" -n 1  "${fn}"  '%^###%' \
        '%^###%' '/^###/' '/^###/' '/^###/' '/^###/' '/^###/' '/^###/1';
    fi
  #
  last_split_idx=6
    # Möglicherweise hat der letzte Splitter keinen Zeilenumbruch am Ende
    # Eine Leerzeile ranhängen
      echo "" >> "${SCHEMA}${last_split_idx}"

  # Die Splitterdateien umbenennen
    target[0]="_select.sql"    # SCHEMA0 -> db/SCHEMA_select.sql
    target[1]=".lvl"           # SCHEMA2 -> db/SCHEMA.lvl
    target[2]="_create.sql"    # SCHEMA3 -> db/SCHEMA_create.sql
    target[3]="_drop.sql"      # SCHEMA4 -> db/SCHEMA_drop.sql
    target[4]="_delete.sql"    # SCHEMA5 -> db/SCHEMA_delete.sql
    target[5]="_loaddata.sql"  # SCHEMA6 -> db/SCHEMA_loaddata.sql
    target[last_split_idx]=".txt"           # SCHEMA7 -> db/SCHEMA.txt

    for i in "${!target[@]}"; do
        if (( verbose )); then
            echo -e "${tag}mv \"${SCHEMA}${i}\" \"db/${SCHEMA}${target[i]}\""
        fi
        if (( ! dry )); then
            mv "${SCHEMA}${i}" "db/${SCHEMA}${target[i]}"
        fi
    done
  #
  # Test Script aus SELECT statements erstellen
    test_file="db/${SCHEMA}_test.sh"
    if (( verbose )); then
        echo -en "${tag}write_sql_script \"SELECT\" "
        echo "\"db/${SCHEMA}_select.sql\" \"${test_file}\""
    fi
    if (( ! dry )); then
        write_sql_script "SELECT" "db/${SCHEMA}_select.sql" "${test_file}"
    fi
}; readonly -f main_splitschema
#
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  # Wird nur aufgerufen, wenn die Datei direkt als Skript gestartet wird.
  # Wir weder aufgerufen, wenn sie inkludiert wird, noch wenn sie getestet wird.
    main_splitschema "$@"
fi

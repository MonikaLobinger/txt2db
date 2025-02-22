#!/usr/bin/env bash
#x_shellcheck disable=all
# :: Erzeugt und füllt die Datenbanktabellen
  # :name: db
  # :type: module
#
#
# SOURCES:
  #shellcheck source-path=./Framework
. "$(dirname "${BASH_SOURCE[0]}")/fus.sh"
#
_exit_for_root
#
# Dateiglobale Variablen
    tag="${Grey84}${darkBlue}db.sh --db>>${clr}"
    dbg="${Yellow}${red}"
    dbg0="${clr}"
    verbose=0
    dry=0
#
# :: Gibt die Hilfe aus
  # :name: help_db
  # :type: procedure
  # :scop: readonly
help_db () {
    local description
    read -r -d '' description <<- 'DESCRIPTION'
	AUFRUF: db.sh -h
	        db.sh --help
	        db.sh -v verbose
	        db.sh -d dry - only show what would be done
	        db.sh -0 Show tree
	        db.sh SCHEMA - Level bis hoch zu SCHEMA neu erstellen
	        db.sh SCHEMA drop - Level bis runter zu SCHEMA löschen
	        (Für 2 müssen wir auch 9-3 löschen)
	        db.sh -I Level 9 und löschen
	        db.sh -H Level 8 und drüber löschen
	        db.sh -G Level 7 und drüber löschen
	        db.sh -F Level 6 und drüber löschen
	        db.sh -E Level 5 und drüber löschen
	        db.sh -D Level 4 und drüber löschen
	        db.sh -C Level 3 und drüber löschen
	        db.sh -B Level 2 und drüber löschen
	        db.sh -A Alles löschen.
	        db.sh -1 level 1 neu erstellen
	        db.sh -2 level 1-2 neu erstellen, recreate evtl gelöschte Dependants
	        db.sh -3 level 1-3 neu erstellen, recreate evtl gelöschte Dependants
	        db.sh -4 level 1-4 neu erstellen, recreate evtl gelöschte Dependants
	        db.sh -5 level 1-5 neu erstellen, recreate evtl gelöschte Dependants
	        db.sh -6 level 1-6 neu erstellen, recreate evtl gelöschte Dependants
	        db.sh -7 level 1-7 neu erstellen, recreate evtl gelöschte Dependants
	        db.sh -8 level 1-8 neu erstellen, recreate evtl gelöschte Dependants
	        db.sh -9 level 1-9 neu erstellen, recreate evtl gelöschte Dependants
	--- Erstellt Tabellen in Datenbank neu.
	--- Daten für die Datenbank werden der Datei Vars entnommen
	--- SCHEMA und drop haben Priorität vor A-I und 1-9, falls beides gegeben
	--- Vor dem Erzeugen wird eine Tabelle gelöscht, falls sie existiert
        so kann sie mit anderer Definition und/oder anderen Daten gebildet
        werden
	--- dry ist fürs Erzeugen nicht immer informativ, da die Tabelle nicht
        wirklich gelöscht wurde.
	DESCRIPTION

    _help "${description}"
};readonly -f help_db
#
function showTree {
    level=9
    drops=("A" "B" "C" "D" "E" "F" "G" "H" "I")
    echo ""
    while ((level>0)); do
        schemas="$(level2schemas "${level}")"
        if ((${#schemas} > 0)); then
            ((idx=level-1))
            echo "Level ${level} (${drops[${idx}]})    ${schemas}"
            echo ""
        fi
        ((level--))
    done
};readonly -f showTree
#
function delete_table {
  # Variablen
    local level user pwd db db_str schemas schema sql_file1 sql_file2 t
    level="$1"
    user="$(_value_of db_user)"
    pwd="$(_value_of db_password)"
    db="$(_value_of db_db)"
    db_str="--user=${user} --password=${pwd} --database=${db}"
    schemas=$(level2schemas "${level}")
    declare -n ret_val=$2
  # Schleife
    #shellcheck disable=2086
    for schema in ${schemas};   do
        sql_file1="./db/${schema}_delete.sql"
        sql_file2="./db/${schema}_drop.sql"
        t="$(mariadb ${db_str} -e 'show tables LIKE "'"${schema}"'"';)"
        if [[ -n "${t}" ]]; then
            ret_val="${level}"
            if (( verbose )); then
                echo -ne "${tag}${dbg}-${level}${dbg0} "
                echo "mariadb ${db_str} < \"${sql_file1}\""
                echo -ne "${tag}${dbg}-${level}${dbg0} "
                echo "mariadb ${db_str} < \"${sql_file2}\""
            fi
            if (( ! dry )); then
                mariadb ${db_str} < "${sql_file1}"
                mariadb ${db_str} < "${sql_file2}"
            fi
            if (( verbose )); then
                echo -e "${tag}rm -f \"./db/${schema}.db\""
            fi
            if (( ! dry )); then
                rm -f "./db/${schema}.db"
            fi
        fi
    done
}; readonly -f delete_table
#
function create_table {
  # Variablen
    local level user pwd db db_str schemas  sql_file1 sql_file2 t
    level="$1"
    user="$(_value_of db_user)"
    pwd="$(_value_of db_password)"
    db="$(_value_of db_db)"
    db_str="--user=${user} --password=${pwd} --database=${db}"
    schemas=$(level2schemas "${level}")
    declare -n ret_val=$2
  # Schleife
    #shellcheck disable=2086
    for schema in ${schemas};   do
        sql_file1="./db/${schema}_create.sql"
        sql_file2="./db/${schema}_loaddata.sql"
        t="$(mariadb ${db_str} -e 'show tables LIKE "'"${schema}"'"';)"
        if [[ -z "${t}" ]]; then
            #shellcheck disable=2034
            ret_val="${level}"
            if (( verbose )); then
                echo -ne "${tag}${dbg}+${level}${dbg0} "
                echo "mariadb ${db_str} < \"${sql_file1}\""
                echo -ne "${tag}${dbg}+${level}${dbg0} "
                echo "mariadb ${db_str} < \"${sql_file2}\""
            fi
            if (( ! dry )); then
                mariadb ${db_str} < "${sql_file1}"
                mariadb ${db_str} < "${sql_file2}"
            fi
            if (( verbose )); then
                echo -e "${tag}touch \"./db/${schema}.db\""
            fi
            if (( ! dry )); then
                touch "./db/${schema}.db"
            fi
        fi
    done
}; readonly -f create_table
#
# :: Gibt zurück, ob alle Voraussetzungen für das Script erfüllt sind
  # :name: requirements_are_met_db
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
function requirements_are_met_db {
    _number_of_args_lt 3 "$@"
    _error $? "-nr_args_needed_lt" "1-2" || return 2

    if (( $# > 0 )); then
        _is_string "$1"
        _error $? "-no_string" "$1" || return 2

        _is_file "db/$1.lvl"
        _error $? "-no_file" "db/$1.lvl" || return 2
    fi

    if (( $# > 1 )); then
        _is_string "$2"
        _error $? "-no_string" "$2" || return 2
        if [[ $2 != "drop" ]]; then
            _ "drop"
            return 2
        fi

    fi

    return 0
}; readonly -f requirements_are_met_db
#
# :: Tut die Arbeit
  # :name: main_db
  # :type: procedure
  # :scop: readonly
function main_db {
  # Variablen
    local level create recreate changed opt
    level=1
    create=1
    recreate=0
    changed=0
  #
  # Argumente
    # shellcheck disable=2046 disable=2312
    set -- $( _long2short_opts "$@" )
    while getopts 0123456789hdvABCDEFGHI opt; do { case ${opt} in
        0) showTree; exit;;
        h) help_db; exit;;
        d) dry=1;;
        9) level=9;;
        8) level=8;;
        7) level=7;;
        6) level=6;;
        5) level=5;;
        4) level=4;;
        3) level=3;;
        2) level=2;;
        1) level=1;;
        v) verbose=1;;
        I) level=9;create=0;;
        H) level=8;create=0;;
        G) level=7;create=0;;
        F) level=6;create=0;;
        E) level=5;create=0;;
        D) level=4;create=0;;
        C) level=3;create=0;;
        B) level=2;create=0;;
        A) level=1;create=0;;
        ?) help_db; exit 2;;
        *) help_db; exit 2;; # für shellcheck
    esac } done
    shift $((OPTIND-1))

    requirements_are_met_db "$@"  || exit $?

    if [[ -n "$1" ]]; then level=$(schema2level "$1");  fi
    if [[ "$2" == "drop" ]]; then create=0; fi
  #
  # Arbeit
    # Das Framework arbeitet mit 9 Leveln
    for ((i = 9 ; i >= level ; i-- )); do
        delete_table "${i}" changed
        if((recreate==0)) && ((changed>0)); then recreate="${changed}"; fi
    done
    if (( create == 0 )); then exit; fi
    if (( recreate > level )); then level=${recreate}; fi
    for ((i = 0 ; level > i ; i++ )); do
        create_table "$((i+1))" changed
    done
}; readonly -f main_db
#
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  # Wird nur aufgerufen, wenn die Datei direkt als Skript gestartet wird.
  # Wir weder aufgerufen, wenn sie inkludiert wird, noch wenn sie getestet wird.
  main_db "$@"
fi

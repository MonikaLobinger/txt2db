#!/usr/bin/env bash
#x_shellcheck disable=all
# :: Erzeugt php Files für SCHEMA
  # :name: php
  # :type: module
  # :desc: Erzeugt php Dateien für SCHEMA. Diese können bei Aufruf auf die
  #        Datenbank zugreifen.
#
#
# SOURCES:
  #shellcheck source-path=./Framework
. "$(dirname "${BASH_SOURCE[0]}")/fus.sh"
. "$(dirname "${BASH_SOURCE[0]}")/tmpl_fus.sh"
#
_exit_for_root
#
# Dateiglobale Variablen
    tag="${Grey84}${darkBlue}php.sh >>${clr}"
    dbg="${Yellow}${red}"
    dbg0="${clr}"
    dry=0
    verbose=0
    export verbose dry tag dbg dbg0
#
# :: Gibt die Hilfe aus
  # :name: help_php
  # :type: procedure
  # :scop: readonly
help_php () {
    local description
    read -r -d '' description <<- 'DESCRIPTION'
	AUFRUF: ./scripts/createphp.sh SCHEMA

	Erzeugt eine php Datei zum Abfragen der Werte für ein Schema
	DESCRIPTION

    _help "${description}"
};readonly -f help_php
#
fill_php_file() {
    local TABLE SCHEMA tables schemas php_file SCHEMAS
    TABLE=$2
    SCHEMA=$3
    tables=$(tables_of_schema "${SCHEMA}")
    # shellcheck disable=2012 disable=2312 disable=2035
    # todo untersuche disables
    schemas="$(ls -1 *.schema | sed -e 's/\.schema$//')"
    php_file=$1
    SELECT_FILE="./db/${SCHEMA}_select.sql"

    replace_placeholders "${php_file}"
    if [[ "${SCHEMA}" == "vars" ]]; then return;  fi

    #shellcheck disable=2119
    SCHEMAS="$(sort_schemas)"
    replace_placeholder_functions \
              "${SCHEMAS}" "${SCHEMA}" "${TABLE}" "${SELECT_FILE}" "${php_file}"
    # Korrekturen
    sed -i -e 's/§/\\n/g' "${php_file}" # PHP should echo Newlines to html
    sed -i -e 's?°?/?g' "${php_file}" # PHP should echo Newlines to html
}; readonly -f fill_php_file
#
# :: Gibt zurück, ob alle Voraussetzungen für das Script erfüllt sind
  # :name: requirements_are_met_php
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
function requirements_are_met_php {
    _number_of_args_is 1 "$@"
    _error $? "-nr_args_needed" 1 || return 2

    _is_string "$1"
    _error $? "-no_string" 1 || return 2

    if [[ "${1}" == "vars" ]]; then
        _is_file "./Framework/vars.tmpl"
        _error $? "-no_file" "./Framework/vars.tmpl" || return 2
    else
        _is_file "$1.schema"
        _error $? "-no_file" "$1.schema" || return 2

        _is_file "./Framework/php.tmpl"
        _error $? "-no_file" "./Framework/php.tmpl" || return 2
    fi

    return 0
}; readonly -f requirements_are_met_php
#
# :: Macht die Arbeit
  # :name: main_php
  # :type: procedure
  # :para: 1/SCHEMA - Name des schemas ohne Erweiterung
  #                   Kann auch vars sein
  # :desc: Erzeugt eine php Datei fürs Schema und für jede Tabelle noch eine.
  #        Ausser wenn SCHEMA "vars" ist, das ist kein SCHEMA, sondern wird
  #        von allen anderen php Dateien benötigt. Da wird nur die Datei
  #        vars.php erzeugt.
  #        Zugrunde liegen der Erzeugung Template Dateien. Für vars vars.tmpl
  #        für alle anderen php.tmpl
  # :stat: 0, falls ok
  #        2, falls Anzahl ARGS nicht 1 ist
  #        2, falls SCHEMA kein String ist
  #        2, falls SCHEMA".schema" keine Datei ist
  # :scop: readonly
main_php() {
  # Variablen
    local SCHEMA php_file tables table
  #
  # Argumente
    #shellcheck disable=2046 disable=2312
    set -- $( _long2short_opts "$@" )
    while getopts :dhv opt; do { case ${opt} in
        d) dry=1;;
        h) help_php; exit;;
        v) verbose=1;;
        ?) help_php; exit 2;;
        *) help_php; exit 2;; # für shellcheck
    esac } done
    shift $((OPTIND-1))

    requirements_are_met_php "$@"  || exit $?
  #
  # Arbeit
    SCHEMA="$1"
    php_file="./www/${SCHEMA}.php"
    tables=""

    # vars sind die Datenbankeinstellungen für andere php Dateien
    if [[ "${SCHEMA}" == "vars" ]]; then
        cp --preserve=mode,ownership ./Framework/vars.tmpl "${php_file}"
    else
        cp --preserve=mode,ownership ./Framework/php.tmpl "${php_file}"
        tables="$(tables_of_schema "${SCHEMA}")"
    fi
    fill_php_file "${php_file}" "_" "${SCHEMA}"

    # Eine php Datei für jede Tabelle erzeugen
    for table in ${tables}; do
        php_file="./www/${SCHEMA}_${table}.php"
        if [[ "${SCHEMA}" == "${table}" ]]; then
            php_file="./www/${SCHEMA}_main.php";
        fi
        cp --preserve=mode,ownership ./Framework/php.tmpl "${php_file}"
        fill_php_file "${php_file}" "${table}" "${SCHEMA}"
    done
}; readonly -f main_php
#
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  # Wird nur aufgerufen, wenn die Datei direkt als Skript gestartet wird.
  # Wir weder aufgerufen, wenn sie inkludiert wird, noch wenn sie getestet wird.
    main_php "$@"
fi


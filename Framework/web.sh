#!/usr/bin/env bash
#x_shellcheck disable=all
# :: Erzeugt die Rahmen html Dateien
  # :name: web
  # :type: module
  # :desc: Braucht keine Argumente, erzeugt alle Rahmen html Dateien. Diese sind von
  #        der laufenden Datenbank unabhängig.
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
    tag="${Grey84}${darkBlue}web.sh >>${clr}"
    dbg="${Yellow}${red}"
    dbg0="${clr}"
    dry=0
    verbose=0
    templates="index version contact imprint sitemap"
#
# :: Gibt die Hilfe aus
  # :name: help_web
  # :type: procedure
  # :scop: readonly
help_web () {
    local description
    read -r -d '' description <<- 'DESCRIPTION'
		AUFRUF:   ./Framework/web.sh -h
		          ./Framework/web.sh [-dv]
		OPTIONEN: -h --help      diese Hilfe
		          -d --dry       nur simulieren, nichts tun (sinnvoll mit verbose)
		          -v --verbose   anzeigen, was getan wird

		Erzeugt die Rahmen HTML Dateien.

		Erzeugt ./www.index.html, ./www/contact.html, ./www/imprint.html und
		./www/sitemap.html
		aus ./Framework/index.tmpl, ./Framework/contact.tmpl, ./Framework/imprint.tmpl
		und ./Framework/sitemap.tmpl
		und den Werten aus./Vars.
		Variablen Placeholder %%name%% in den .tmpl Dateien werden als Schlüssel in
		Vars gesehen und durch den entsprechenden Wert aus Vars ersetzt.
		Funktionale Placeholder mit der Kennung (%name%) werden durch das Ergebnis
		der entsprechenden Funktionen create_name ersetzt.
		Die Placeholder Kennungen werden nicht mit in die html Datei übernommen.
		DESCRIPTION

    _help "${description}"
};readonly -f help_web
#
# :: Füllt die HTML Datei
  # :name: fill_web_file
  # :type: procedure
  # :para  1/FILE (file)
  # :desc: Ersetzt alle Key/Value Platzhalter in FILE die in Vars gefunden
  #        werden.
  #        Ersetzt den funktionalen Platzhalter link_tree durch das Ergebnis
  #        von create_link_tree
  # :stat: 0 - falls alles ok
  #        2 - falls nicht genau 1 Argument
  #        2 - falls FILE keine Datei ist
  # :scop: readonly
fill_web_file() {
    (( $# != 1 )) && return 2
    if ! _is_file "$1"; then return 2; fi

    local html_file schemas

    html_file=$1
    # shellcheck disable=2119
    schemas=$(sort_schemas)
    if (( verbose )); then
        echo -e "${tag}replace_placeholders ${dbg}\"${html_file}\"${dbg0}"
    fi
    if (( ! dry )); then
        replace_placeholders "${html_file}"
    fi
    #
    if (( verbose )); then
        echo -en "${tag}replace_placeholder_functions \"${schemas}\""
        echo -n " \"\" \"\" \"\" \"${html_file}\""
        echo -e "/g\" ${dbg}\"${html_file}\"${dbg0}"
    fi
    if (( ! dry )); then

        # todo IND 3 fehlt noch
      replace_placeholder_functions "${schemas}" "" "" "" "${html_file}"
    fi
};readonly -f fill_web_file
#
# :: Gibt zurück, ob alle Voraussetzungen für das Script erfüllt sind
  # :name: requirements_are_met_web
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
function requirements_are_met_web {
    _number_of_args_is 0 "$@"
    _error $? "-nr_args_needed" 1 || return 2

    for tmpl in ${templates};do
        _is_file "${PROJECT_DIR}/Framework/${tmpl}.tmpl"
        _error $? "-no_file" "${PROJECT_DIR}/Framework/${tmpl}.tmpl" || return 2
    done


    return 0
}; readonly -f requirements_are_met_web
#
# :: Macht die Arbeit
  # :name: main_web
  # :type: procedure
  # :desc: Erzeugt die html Dateien index.html contact.html imprint.html
  #        und sitemap.html.
  # :stat: 0, falls ok
  #        2, falls Anzahl ARGS nicht 1 ist
  #        2, falls SCHEMA kein String ist
  #        2, falls SCHEMA".schema" keine Datei ist
  # :scop: readonly
main_web() {
  # Variablen
    local db html_file
  #
  # Argumente
    #shellcheck disable=2046 disable=2312
    set -- $( _long2short_opts "$@" )
    while getopts :dhv opt; do { case ${opt} in
        d) dry=1;;
        h) help_web; exit;;
        v) verbose=1;;
        ?) help_web; exit 2;;
        *) help_web; exit 2;; # für shellcheck
    esac } done
    shift $((OPTIND-1))

    requirements_are_met_web "$@"  || exit $?
  #
  # Arbeit
    for tmpl in ${templates};do
        html_file="./www/${tmpl}.html"
        cp --preserve=mode,ownership \
                                "./Framework/${tmpl}.tmpl" "${html_file}"
        fill_web_file "${html_file}"
    done

}; readonly -f main_web
#
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  # Wird nur aufgerufen, wenn die Datei direkt als Skript gestartet wird.
  # Wir weder aufgerufen, wenn sie inkludiert wird, noch wenn sie getestet wird.
    main_web "$@"
fi

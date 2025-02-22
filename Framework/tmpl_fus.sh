#!/usr/bin/env bash
#x_shellcheck disable=all
# :: Funktionen zum Ersetzen von Placeholder
  # :name: tmpl_fus
  # :type: module
  # :desc: Enthält Funktionen, die Placeholder ersetzen
  #        Die Einrückung des html Codes beträgt pro Tiefe 2 Leerzeichen
  #        Die erste Zeile ist nie eingerückt
  #        Der erste Parameter IND sagt die ursprüngliche Einrückungs Tiefe an.
  #        Eine Einrückung ist zwei Leerzeichen
  #        Die Ausgabe beginnt direkt mit 0 Einrückung, es wird davon
  #        ausgegangen, daß der Placeholder eingerückt platziert ist
  #        Danach wird entsprechend der Tiefe zusätzlich eingerückt
  # :deps: fus.sh
#
#
# SOURCES: Nur Placeholder Funktionen, wer die haben will muß fus.sh selbst
#          vorher inkludieren
#
# :: Gibt einen Link Baum zurück
  # :name: create_link_tree
  # :type: function
  # :para: 1/IND/number
  # :para: 2/SCHEMAS/list of strings
  # :para: 3/egal
  # :para: 4/egal
  # :para: 5/egal
  # :desc: Erzeugt für alle SCHEMA.php aus SCHEMAS und alle TABELLE.php
  #        einen Link Baum und gibt ihn zurück
  #        Die Argumente 2 bis 4 werden nicht verwendet
  #        Eine Einrückung ist zwei Leerzeichen
  #        Die Ausgabe beginnt direkt mit <ul> mit 0 Einrückung,
  #        Das abschließende </ul> hat IND Einrückungen
  #        Dazwischen wird entsprechend der Tiefe zusätzlich eingerückt
  # :stat: 0 - falls alles ok
  #        2 - falls nicht wenigstens 2 Argumente
  #        2 - falls mehr als 5 Argumente
  #        2 - falls SCHEMAS kein String ist
  #        2 - falls IND keine Zahl ist
  # :expl: Die Ausgabe sieht z.B. so aus:
  #<ul>
  #  <li><a href="./example1.php">Example1</a></li>
  #  <ul>
  #    <li><a href="./example1_main.php">example1</a></li>
  #  </ul>
  #  <li><a href="./example2.php">Example2</a></li>
  #  <ul>
  #    <li><a href="./example2_test.php">test</a></li>
  #    <li><a href="./example2_main.php">example2</a></li>
  #  </ul>
  #  <li><a href="./example3.php">Example3</a></li>
  #  <ul>
  #    <li><a href="./example3_main.php">example3</a></li>
  #  </ul>
  #</ul>
function create_link_tree {
    (( $# < 2 )) && return 2
    (( $# > 5 )) && return 2
    if ! _is_number "$1"; then return 2; fi
    if ! _is_string "$2"; then return 2; fi

    local SCHEMAS TABLES A s t
    local i1 i2 i3 start_ind indent_width indent_str start_width

    start_ind=$1
    SCHEMAS="$2"
    indent_width=2
    indent_str=" "
    start_width=$(( start_ind * indent_width ))
    i1=$(i "${indent_str}" "${start_width}" )
    i2=${i1}; i2+=$(i "${indent_str}" "${indent_width}")
    i3=${i2}; i3+=$(i "${indent_str}" "${indent_width}")

    A="<ul>"
    for s in ${SCHEMAS}; do
        A+="\n${i2}<li><a href=\".\/${s}.php\">${s^}<\/a><\/li>";
        A+="\n${i2}<ul>";
        TABLES=$(tables_of_schema "${s}")
        for t in ${TABLES}; do
            table=$(echo "[${t}]" | tr -d "[](")
            if [[ ${table} == "${s}" ]]; then
                A+="\n${i3}<li><a href=\".\/${s}_main.php\">"
            else
                A+="\n${i3}<li><a href=\".\/${s}_${table}.php\">"
            fi
            A+="${table}<\/a><\/li>"
        done
        A+="\n${i2}<\/ul>";
    done
    A+="\n${i1}<\/ul>"

    echo "${A}"
}
#
# :: Gibt Title Attribut zurück
  # :name: create_title_attr
  # :type: function
  # :para: 1/egal
  # :para: 2/egal
  # :para: 3/SCHEMA/string
  # :para: 4/TABLE/string
  # :para: 5/egal
  # :desc: Gibt SCHEMA TABLE zurück, außer SCHEMA ist "_"
  # :stat: 0 - falls alles ok
  #        2 - falls nicht wenigstens 4 Argumente
  #        2 - falls mehr als 5 Argumente
  #        2 - falls SCHEMAS kein String ist
  #        2 - falls TABLE kein String ist
function create_title_attr {
    (( $# < 4 )) && return 2
    (( $# > 5 )) && return 2
    if ! _is_string "$3"; then return 2; fi
    if ! _is_string "$4"; then return 2; fi

    local SCHEMA TABLE A
    SCHEMA=$3
    TABLE=$4
    A=""
    A="${SCHEMA^^} ${TABLE}" # ^^ UPPERCASE
    if [[ "${TABLE}" == "_" ]]; then A="${SCHEMA^^}"; fi

    echo "${A}"
}
#
# :: Gibt Description Attribut zurück
  # :name: create_desc_attr
  # :type: function
  # :para: 1/egal
  # :para: 2/egal
  # :para: 3/egal
  # :para: 4/TABLE/string
  # :para: 5/egal
  # :desc: Gibt TABLE zurück
  # :stat: 0 - falls alles ok
  #        2 - falls nicht wenigstens 4 Argumente
  #        2 - falls mehr als 5 Argumente
  #        2 - falls TABLE kein String ist
function create_desc_attr {
    (( $# < 4 )) && return 2
    (( $# > 5 )) && return 2
    if ! _is_string "$4"; then return 2; fi

    local A TABLE
    A=""
    TABLE="$4"
    A="${TABLE}"

    echo "${A}"
}
#
# :: Gibt Keyword Attribute zurück
  # :name: create_keywords_attr
  # :type: function
  # :para: 1/egal
  # :para: 2/egal
  # :para: 3/SCHEMA/string
  # :para: 4/TABLE/string
  # :para: 5/egal
  # :desc: Gibt SCHEMA TABLE zurück, außer SCHEMA ist "_"
  # :stat: 0 - falls alles ok
  #        2 - falls nicht wenigstens 4 Argumente
  #        2 - falls mehr als 5 Argumente
  #        2 - falls SCHEMAS kein String ist
  #        2 - falls TABLE kein String ist
function create_keywords_attr {
    (( $# < 4 )) && return 2
    (( $# > 5 )) && return 2
    if ! _is_string "$3"; then return 2; fi
    if ! _is_string "$4"; then return 2; fi

    local A SCHEMA TABLE keywords

    A=""
    SCHEMA=$3
    TABLE=$4
    keywords="$(_value_of "keywords")"
    A="${keywords}, ${SCHEMA}"
    if [[ "${TABLE}" != "_" ]] && [[ "${TABLE}" != "${SCHEMA}" ]]; then
      A+=", ${TABLE}";
    fi

    echo "${A}"
}
#
# :: Gibt Keyword Attribute zurück
  # :name: create_version_info
  # :type: function
  # :para: 1/egal
  # :para: 2/egal
  # :para: 3/egal
  # :para: 4/egal
  # :para: 5/egal
  # :desc: Gibt die Version Nummer zurück
  # :stat: 0 - falls alles ok
  #        2 - falls mehr als 5 Argumente
function create_version_info {
    (( $# > 5 )) && return 2

    local A version


    A="\n<table>\n  <tr>\n"
    # git describe: # Nur annotated tags
      version="    <td>"
      version+="git describe: "
      version+="<\/td>\n    <td>"
      version+="$(git describe)"
      version+="<\/td>\n"
    A+="${version}"

    A+="  <\/tr>\n  <tr>\n"
    # git describe --abbrev=40 --dirty --always --tags:
      version="    <td>"
      version+="git describe --abbrev=40 --dirty --always --tags: "
      version+="<\/td>\n    <td>"
      version+="$(git describe --abbrev=40 --dirty --always --tags)"
      version+="<\/td>\n"
    A+="${version}"

    A+="  <\/tr>\n  <tr>\n"
    # git rev-parse HEAD:
      version="    <td>"
      version+="git rev-parse HEAD: "
      version+="<\/td>\n    <td>"
      version+="$(git rev-parse HEAD)"
      version+="<\/td>\n"
    A+="${version}"
    A+="  <\/tr>\n<\/table>\n"
    echo "${A}"
}
#
# :: Gibt Gimmeck zurück
  # :name: create_gimmecks
  # :type: function
  # :para: 1/egal
  # :para: 2/egal
  # :para: 3/SCHEMA/string
  # :para: 4/TABLE/string
  # :para: 5/egal
  # :desc: Gibt SCHEMA TABLE zurück, außer SCHEMA ist "_"
  # :stat: 0 - falls alles ok
  #        2 - falls nicht wenigstens 4 Argumente
  #        2 - falls mehr als 5 Argumente
  #        2 - falls SCHEMAS kein String ist
  #        2 - falls TABLE kein String ist
function create_gimmecks {
    (( $# < 4 )) && return 2
    (( $# > 5 )) && return 2
    if ! _is_string "$3"; then return 2; fi
    if ! _is_string "$4"; then return 2; fi

    local A SCHEMA TABLE
    A=""
    SCHEMA=$3
    TABLE=$4

    A="<p>DAS IST NUR ZUM TESTEN<\/p>\n    \
    <p><a href=\"help.html\">Hilfe<\/a><\/p>"

    echo "${A}"
}
#
# :: Gibt Breadcrumbs zurück
  # :name: create_breadcrumbs
  # :type: function
  # :para: 1/IND/number
  # :para: 2/egal
  # :para: 3/SCHEMA/string
  # :para: 4/TABLE/string
  # :para: 5/egal
  # :desc: Gibt SCHEMA TABLE zurück, außer SCHEMA ist "_"
  # :stat: 0 - falls alles ok
  #        2 - falls nicht wenigstens 4 Argumente
  #        2 - falls mehr als 5 Argumente
  #        2 - falls IND keine Zahl ist
  #        2 - falls SCHEMAS kein String ist
  #        2 - falls TABLE kein String ist
function create_breadcrumbs {
    (( $# < 4 )) && return 2
    (( $# > 5 )) && return 2
    if ! _is_string "$3"; then return 2; fi
    if ! _is_string "$4"; then return 2; fi
    if ! _is_number "$1"; then return 2; fi

    local A SCHEMA TABLE db
    local i1 i2 i3 start_ind indent_width indent_str start_width
    A=""
    SCHEMA=$3
    TABLE=$4

    start_ind=$1
    indent_width=2
    indent_str=" "
    start_width=$(( start_ind * indent_width ))
    i1=$(i "${indent_str}" "${start_width}" )
    i2=${i1}; i2+=$(i "${indent_str}" "${indent_width}")
    i3=${i2}; i3+=$(i "${indent_str}" "${indent_width}")

    #todo ist diese Variable korrekt?
    #shellcheck disable=2034
    db="$(_value_of db_db)"

    A="<li><a href=\".\/index.html\">Home<\/a><\/li>\n"
    A+="${i1}<li><a href=\".\/${SCHEMA}.php\">${SCHEMA^}<\/a><\/li>\n"
    A+="${i1}<li>${TABLE}<\/li>"
    if [[ "${TABLE}" == "_" ]]; then
      A="<li><a href=\".\/index.html\">Home<\/a><\/li>\n"
      A+="${i1}<li>${SCHEMA^}<\/li>"
    fi

    echo "${A}"
}
#
# :: Gibt Artikel zurück
  # :name: create_article
  # :type: function
  # :para: 1/IND/number
  # :para: 2/egal
  # :para: 3/SCHEMA/string
  # :para: 4/TABLE/string
  # :para: 5/SELECT_FILE/File
  # :desc: Gibt SCHEMA TABLE zurück, außer SCHEMA ist "_"
  # :stat: 0 - falls alles ok
  #        2 - falls nicht genau 5 Argumente
  #        2 - falls IND keine Zahl ist
  #        2 - falls SCHEMAS kein String ist
  #        2 - falls TABLE kein String ist
  #        2 - falls SELECT_FILE kein File ist
function create_article {
    (( $# != 5 )) && return 2
    if ! _is_string "$3"; then return 2; fi
    if ! _is_string "$4"; then return 2; fi
    if ! _is_file "$5"; then return 2; fi
    if ! _is_number "$1"; then return 2; fi

    local SCHEMA TABLE SELECT_FILE TABLE_statements st t tbl lastword
    local statements
    local i1 i2 i3 i4 start_ind indent_width indent_str start_width

    SCHEMA=$3
    TABLE=$4
    SELECT_FILE=$5
    TABLE_statements=""
    st=""
    t=""
    tbl=""
    lastword=""

    start_ind=$1
    indent_width=2
    indent_str=" "
    start_width=$(( start_ind * indent_width ))
    i1=$(i "${indent_str}" "${start_width}" )
    i2=${i1}; i2+=$(i "${indent_str}" "${indent_width}")
    i3=${i2}; i3+=$(i "${indent_str}" "${indent_width}")
    i4=${i3}; i4+=$(i "${indent_str}" "${indent_width}")
    # evtl mehrere) SELECT statements für (evtl mehrere) Tabelle(n);
    SELECT_statements="$(awk '/SELECT/,/;/' "${SELECT_FILE}")"

    statements=""
    while IFS= read -r line; do # Zeilenumbruch weg
        statements+="${line%#*} " # Kommentar weg, Leerzeichen ran
    done <<< "${SELECT_statements}"

    #statements="${SELECT_statements}"

    st=${statements%%;*} # Teil vor erstem ; incl Zeilenumbrüchen

    # Kopiere nur die Statements für TABLE in TABLE_statements
    while [[ "${st}" !=  "${statements}" ]] ;do
        # shellcheck disable=2295
        # todo untersuche disables
        statements="${statements#${st};}" # Teil nach erstem ; incl Zeilenumbrüchen

        #st="${st//$'\n'/ }" # Zeilenumbrüche zu Leerzeichen #SELECT id, food_id FROM kcal
        t="${st#*FROM}"
        # shellcheck disable=2116 disable=2086
        # todo untersuche disables
        t="$(echo ${t})"
        tbl="${t%% *}"
        if [[ "${TABLE}" == "${tbl}" ]]; then
            TABLE_statements+="${st};";  # Strichpunkt wieder ran
        fi
        st=${statements%%;*} # Teil vor erstem ; incl Zeilenumbrüchen
    done

    statements="${TABLE_statements}" # enthält keine Zeilenumbrüche
    st=${statements%%;*} # Teil vor erstem ;
    ### echo "${st}" >> ${test_file}

    if [[ "${TABLE}" == "_" ]]; then
      A="$(_value_of "schema_php")"
    else
      A="<?php\n\ "
      A+="${i1}include \'.\/vars.php\';\n\ "
      A+="${i1}try {\n\ "
      A+="${i2}\$conn = new PDO(\"mysql:host=\$servername;dbname=\$dbname\", \$username, \$password);\n\ "

      while [[ -n "${st}" ]] ;do
        # shellcheck disable=2295
        # todo untersuche disables
      statements="${statements#${st};}" # Teil nach erstem ;
      st="${st//\//\°}" # Divisionszeichen für sed Escapen
      A+="\n${i2}\$statement = \$conn->prepare("
      A+="\'${st};\'"
      A+=");\n\ "
      A+="${i2}if(\$statement->execute()) {\n\ "
      A+="${i3}echo \"§      <table>§\";\n\ "
      A+="${i3}echo \"        <thead><tr>§\";\n\ "
      cols="${st%%FROM*}"
      col="${cols%%,*}"
      lastword=""

      col_cnt=0
      while [[ -n "${cols}" ]] ;do
        # shellcheck disable=2295
        # todo untersuche disables
        if [[ "${cols}" == "${col}" ]]; then cols="";
        else cols="${cols#${col},}"; fi
        lastword="$(echo "${col}" | awk '{print $NF}')"
        # Falls AS das nehmen; auf jeden Fall Anführungsstriche weg
        # z.B.: child.name AS "abhängig von"
        lastword=${lastword##* AS } # letztes' AS ' und alles davor wegschneiden
        lastword=${lastword//\"/} # doppelte Anführungsstriche weg
        #lastword=${lastword//\'/} # einfache Anführungsstriche weg
        if [[ ${cols} !=  [0-9]* ]]; then
        A+="${i3}echo \"          <th>${lastword}<\/th>§\";\n\ "
        fi
        col="${cols%%,*}"
        (( col_cnt++ ))
      done
      A+="${i3}echo \"        <\/tr><\/thead>§\";\n\ "
      A+="${i3}echo \"        <tbody>§\";\n\ "
      A+="${i3}while(\$row = \$statement->fetch()) {\n\ "
      A+="${i4}echo \"          <tr>§\";\n\ "
      cols="${st%%FROM*}"
      col="${cols%%,*}"
      lastword=""

#set -x
#set +x
      col_no=${col_cnt}
      while [[ -n "${cols}" ]] ;do
        # shellcheck disable=2295
        # todo untersuche disables
        if [[ "${cols}" == "${col}" ]] ;then cols="";
        else cols="${cols#${col},}"; fi
        lastword="$(echo "${col}" | awk '{print $NF}')"
        lastword=$(( col_cnt - col_no-- ))

        if [[ ${cols} !=  [0-9]* ]]; then
        A+="${i4}echo \"            <td>\".\$row[\'${lastword}\'].\"<\/td>§\";\n\ "
        fi
        col="${cols%%,*}"
      done
      A+="${i4}echo \"          <\/tr>§\";\n\ "
      A+="${i3}}\n\ "
      A+="${i3}echo \"        <\/tbody>§\";\n\ "
      A+="${i3}echo \"      <\/table>§\";\n\ "
      A+="${i2}} else {\n\ "
      A+="${i3}echo \"SQL Error <br>\";\n\ "
      A+="${i3}echo \$statement->queryString.\"<br>\";\n\ "
      A+="${i3}echo \$statement->errorInfo()[2];\n\ "
      A+="${i2}}\n\ "

      st=${statements%%;*} # Teil vor erstem ; incl Zeilenumbrüchen
      done

      A+="${i1}} catch(PDOException \$e) {\n\ "
      A+="${i2}echo \'Connection failed: \' . \$e->getMessage();\n\ "
      A+="${i1}}\n\ "
      A+="${i1}?>\n\ "
    fi

    #echo "${A}" >> ${test_file}
    echo "${A}"
}
# :: Eine lokale Implementation von _long2short_opts, die nichts inkludiert wird
  # :name: long2short_opts_local
  # :pars: Alle
  # :desc: Wandelt --help, --dry und --verbose in -h, -d und -v um.
  # :impl: Da diese Datei nichts inkludiert, aber doch wie die anderen reagieren
  #        soll wurde die lokale Lösung gewählt
function long2short_opts_local {
    local arg # arg
    local args=() # args
    first=" "
    for arg in "$@"; do
        case "${arg}" in
        --dry)    args+=("-d") ;;
        --help)   args+=("-h") ;;
        --verbose)args+=("-v") ;;
        -n)       args+=("${first}""-n") ;;
        -e)       args+=("${first}""-e") ;;
        -E)       args+=("${first}""-E") ;;
        *)        args+=("${arg}") ;;
        esac
        first=""
    done
    echo "${args[@]}"

    return 0
};

# :: Gibt die Hilfe aus
  # :name: help_tmpl_fus
  # :type: procedure
help_tmpl_fus() {
  local description
  read -r -d '' description <<- DESCRIPTION
	AUFRUF: tmpl_fus.sh -h
	        tmpl_fus.sh --help
	        tmpl_fus.sh

	BESCHREIBUNG
	    Diese Datei ist eine Sammlung von Placeholder Funktionen. Dazu wird sie
	    in Scripte zur Umwandlung von Tmpl Dateien in Ausgabedateien inkludiert.


	    Wenn diese Datei als Script aufgerufen wird, zeigt sie die implementierten Funktionen mit einer Kurzbeschreibung an.
	DESCRIPTION

  _help "${description}"
}
#
# :: Gibt den Namen der Datei aus und alle implementierten Funktionen
  # :name: main_tmpl_fus
  # :type: procedure
  # :desc: Gibt den Namen der Datei aus und gibt danach die Namen aller
  #        implementierten Funktionen mit einer Kurzbeschreibung aus.
  # :impl: Das Einlesen des Heredoc mit der Umleitung "<<-" bewirkt, dass
  #        die Tabulatoren am Zeilenanfang entfernt werden.
main_tmpl_fus() {
  # shellcheck disable=2046 disable=2312
  set -- $( long2short_opts_local "$@" )
  while getopts ch opt; do { case ${opt} in
      c) create_config; exit;;
      h) help_fus; exit;;
      ?) help_fus; exit 2;;
      *) help_fus; exit 2;; # für shellcheck
  esac } done
  shift $((OPTIND-1))

  echo "in tmpl_fus.sh"

  cat <<- AUSGABE
	Funktionen in dieser Sammlung
	=============================
	create_article IND x SCHEMA TABLE SELECT_FILE : tables mit SELECT Ergebnissen
	create_breadcrumbs IND x SCHEMA TABLE         : li links
	create_desc_attr x x x TABLE x                : String
	create_gimmecks: x x SCHEMA TABLE             : <p> und Link to help
	create_link_tree IND SCHEMAS                  : ul/li geschachtelte Links
	create_title_attr x x SCHEMA TABLE            : String
  create_version_info                           : table
	AUSGABE
}
#
if [[ ${BASH_SOURCE[0]} == "$0" ]]; then
  # Wird nur aufgerufen, wenn die Datei direkt als Skript gestartet wird.
  # Wir weder aufgerufen, wenn sie inkludiert wird, noch wenn sie getestet wird.
    main_tmpl_fus "$@"
fi
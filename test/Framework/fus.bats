setup() {
    load '../test_helper/common-setup'
    _common_setup "Framework"

    source "$PROJECT_ROOT/Framework/fus.sh"
    source "$PROJECT_ROOT/Framework/tmpl_fus.sh"
}

teardown() {
    if [[ -f xxx.vars ]]; then
        echo "RÄUME xxx.vars AUF"
        mv  xxx.vars "${PROJECT_DIR}/Vars"
    fi
    if [[ -f tmpl_fus.sh.sv.xx.yy ]]; then
        echo "RÄUME tmpl_fus.sh.sv.xx.yy AUF"
        mv  tmpl_fus.sh.sv.xx.yy "${PROJECT_DIR}/Framework/tmpl_fus.sh"
    fi
}

#: << SKIP

@test "Globale Variablen" {

    # Wert von Variable ROOT_DIR ist bestimmtes Verzeichnis
    [[  -f "$ROOT_DIR/include/base.sh" ]]

    # Wert von Variable PROJECT_DIR ist bestimmtes Verzeichnis
    [[  -f "$PROJECT_DIR/Makefile" ]]
}

@test "Inklusionen" {
    [[ -v grey  ]]
    [[ -v LightSkyBlue3_1  ]]
    [[ -v clr  ]]
}

@test "Nachrichten" {

    # 2 Zu wenig Argumente
    run _
    echo "fmsg2!status 2=${status};output:=${output};"
    [[ "$status" -eq 2 ]]
    [[ "$output" == "" ]]

    # 3 Zu viele Argumente
    run _ "arg1_needed" 22
    echo "fmsg3!status 2=${status};output:=${output};"
    [[ "$status" -eq 2 ]]
    [[ "$output" == "" ]]

    # 4 ok
    run _ "arg1_needed"
    echo "fmsg4!status 0=${status};output:Es wird genau ein Argument benötigt=${output};"
    [[ "$status" -eq 0 ]]
    [[ "$output" == "Es wird genau ein Argument benötigt" ]]

    # 5 Kenner nicht da
    run _ "arg1_eeded"
        assert_failure 1
        assert_output "Nachricht für txt2db nicht gefunden"

    run _ "soffice_runs"
        assert_success
        assert_output --partial "Während Libre Office mit gui läuft"
        assert_output --partial "Libre Office gui muß beendet werden"
}

@test "_error" {

    run _error 1 "soffice_runs"
        assert_failure 1
        assert_output --partial "ERROR: Während Libre Office mit gui läuft"
        assert_output --partial "Libre Office gui muß beendet werden"
}

@test "_am_root" {
    run _am_root
}

@test "_exit_for_root" {
    run _exit_for_root
}

@test "_is_array " {
    declare -a local a
    local b=(1 2 3)
    local c=( )
    noarray=" no array"

    # 0 Readonly function
    readonly -f | grep ' _is_array$'

    # 1 Zu wenig Argumente
    run _is_array
    echo "fary1!status:2=${status};output:=${output};"
    [[ "$status" -eq 2 ]]
    [[ "$output" == "" ]]

    # 2 Zu viele Argumente
    run _is_array
    echo "fary2!status:2=${status};output:=${output};"
    [[ "$status" -eq 2 ]]
    [[ "$output" == "" ]]

    # 3 als array deklariert ok
    _is_array a

    # 4 als array zugewiesen ok
    _is_array b

    # 5 als leeres array zugewiesen ok
    _is_array c

    # 6 Wohl ein (leerer) String
    run _is_array "$c"
    echo "fary6!status:${status};output:=${output};"
    [[ "$status" -eq 1 ]]
    [[ "$output" == "" ]]

    # 7  Wohl ein (leerer) String
    run _is_array "${c[*]}"
    echo "fary7!status:${status};output:=${output};"
    [[ "$status" -eq 1 ]]
    [[ "$output" == "" ]]

    # 8 Wohl ein String "1 2 3"
    run _is_array "${b[*]}"
    echo "fary8!status:${status};output:=${output};"
    [[ "$status" -eq 1 ]]
    [[ "$output" == "" ]]

    # 9 Ein String
    run _is_array "$noarray"
    echo "fary9!status:${status};output:=${output};"
    [[ "$status" -eq 1 ]]
    [[ "$output" == "" ]]
}

@test "_long2short_opts" {

    # 1 Readonly function
    readonly -f | grep ' _long2short_opts$'

    # 2 keine Argumente
    run _long2short_opts
    echo "rlop2!status 0=${status};output:=${output};"
    [[ "$status" -eq 0 ]]
    [[ "$output" == "" ]]

    # 3 --help
    run _long2short_opts --help
    echo "rlop3!status 0=${status};output:-h=${output};"
    [[ "$status" -eq 0 ]]
    [[ "$output" == "-h" ]]

    # 4 -a
    run _long2short_opts -a
    echo "rlop4!status 0=${status};output:-a=${output};"
    [[ "$status" -eq 0 ]]
    [[ "$output" == "-a" ]]

    # 5 -E
    run _long2short_opts -E
    echo "rlop5!status 0=${status};output: -E=${output};"
    [[ "$status" -eq 0 ]]
    [[ "$output" == " -E" ]]

    # 6 -e 22
    run _long2short_opts -e 22
    echo "rlop6!status 0=${status};output: -e 22=${output};"
    [[ "$status" -eq 0 ]]
    [[ "$output" == " -e 22" ]]

    # 7 --verbose -hE 22
    run _long2short_opts --verbose -hE 22
    echo "rlop7!status 0=${status};output:-v -hE 22=${output};"
    [[ "$status" -eq 0 ]]
    [[ "$output" == "-v -hE 22" ]]

    # 8 --dry --verbose -hE -0 22 "olla" "$l"
    local l=("abc" "def" "ghi" "jkl")
    run _long2short_opts --dry --verbose -hE -0 22 "olla" ${l[@]}
    echo "rlop8!status 0=${status};output:-d -v -hE -0 22 olla ${l[@]}=${output};"
    [[ "$status" -eq 0 ]]
    [[ "$output" == "-d -v -hE -0 22 olla ${l[@]}" ]]

    run _long2short_opts -A;    [[ "$output" == "-A" ]]
    run _long2short_opts -B;    [[ "$output" == "-B" ]]
    run _long2short_opts -C;    [[ "$output" == "-C" ]]
    run _long2short_opts -D;    [[ "$output" == "-D" ]]
    run _long2short_opts -E;    [[ "$output" == " -E" ]]
    run _long2short_opts -F;    [[ "$output" == "-F" ]]
    run _long2short_opts -G;    [[ "$output" == "-G" ]]
    run _long2short_opts -H;    [[ "$output" == "-H" ]]
    run _long2short_opts -I;    [[ "$output" == "-I" ]]
    run _long2short_opts -J;    [[ "$output" == "-J" ]]
    run _long2short_opts -K;    [[ "$output" == "-K" ]]
    run _long2short_opts -L;    [[ "$output" == "-L" ]]
    run _long2short_opts -M;    [[ "$output" == "-M" ]]
    run _long2short_opts -N;    [[ "$output" == "-N" ]]
    run _long2short_opts -O;    [[ "$output" == "-O" ]]
    run _long2short_opts -P;    [[ "$output" == "-P" ]]
    run _long2short_opts -Q;    [[ "$output" == "-Q" ]]
    run _long2short_opts -R;    [[ "$output" == "-R" ]]
    run _long2short_opts -S;    [[ "$output" == "-S" ]]
    run _long2short_opts -T;    [[ "$output" == "-T" ]]
    run _long2short_opts -U;    [[ "$output" == "-U" ]]
    run _long2short_opts -V;    [[ "$output" == "-V" ]]
    run _long2short_opts -W;    [[ "$output" == "-W" ]]
    run _long2short_opts -X;    [[ "$output" == "-X" ]]
    run _long2short_opts -Y;    [[ "$output" == "-Y" ]]
    run _long2short_opts -Z;    [[ "$output" == "-Z" ]]

    run _long2short_opts -a;    [[ "$output" == "-a" ]]
    run _long2short_opts -b;    [[ "$output" == "-b" ]]
    run _long2short_opts -c;    [[ "$output" == "-c" ]]
    run _long2short_opts -d;    [[ "$output" == "-d" ]]
    run _long2short_opts -e;    [[ "$output" == " -e" ]]
    run _long2short_opts -f;    [[ "$output" == "-f" ]]
    run _long2short_opts -g;    [[ "$output" == "-g" ]]
    run _long2short_opts -h;    [[ "$output" == "-h" ]]
    run _long2short_opts -i;    [[ "$output" == "-i" ]]
    run _long2short_opts -j;    [[ "$output" == "-j" ]]
    run _long2short_opts -k;    [[ "$output" == "-k" ]]
    run _long2short_opts -l;    [[ "$output" == "-l" ]]
    run _long2short_opts -m;    [[ "$output" == "-m" ]]
    run _long2short_opts -n;    [[ "$output" == " -n" ]]
    run _long2short_opts -o;    [[ "$output" == "-o" ]]
    run _long2short_opts -p;    [[ "$output" == "-p" ]]
    run _long2short_opts -q;    [[ "$output" == "-q" ]]
    run _long2short_opts -r;    [[ "$output" == "-r" ]]
    run _long2short_opts -s;    [[ "$output" == "-s" ]]
    run _long2short_opts -t;    [[ "$output" == "-t" ]]
    run _long2short_opts -u;    [[ "$output" == "-u" ]]
    run _long2short_opts -v;    [[ "$output" == "-v" ]]
    run _long2short_opts -w;    [[ "$output" == "-w" ]]
    run _long2short_opts -x;    [[ "$output" == "-x" ]]
    run _long2short_opts -y;    [[ "$output" == "-y" ]]
    run _long2short_opts -z;    [[ "$output" == "-z" ]]

    run _long2short_opts -0;    [[ "$output" == "-0" ]]
    run _long2short_opts -1;    [[ "$output" == "-1" ]]
    run _long2short_opts -2;    [[ "$output" == "-2" ]]
    run _long2short_opts -3;    [[ "$output" == "-3" ]]
    run _long2short_opts -4;    [[ "$output" == "-4" ]]
    run _long2short_opts -5;    [[ "$output" == "-5" ]]
    run _long2short_opts -6;    [[ "$output" == "-6" ]]
    run _long2short_opts -7;    [[ "$output" == "-7" ]]
    run _long2short_opts -8;    [[ "$output" == "-8" ]]
    run _long2short_opts -9;    [[ "$output" == "-9" ]]
}

@test "_help " {

    # 1 Readonly function
    readonly -f | grep ' _help$'
    # 2 Zu wenig Argumente
    run _help
    echo "fhlp2!status 2=${status};output:=${output};"
    [[ "$status" -eq 2 ]]
    [[ "$output" == "" ]]

    # 3 Zu viele Argumente
    run _help "arg1_needed" 22
    echo "fhlp3!status 2=${status};output:=${output};"
    [[ "$status" -eq 2 ]]
    [[ "$output" == "" ]]

    # 4 ok
    run _help "arg1_needed"
    echo "fhlp4!status 0=${status};output:arg1_needed=${output};"
    [[ "$status" -eq 0 ]]
    [[ "$output" == "arg1_needed" ]]
}

@test "_value_of" {

    # 1 Readonly function
    readonly -f | grep ' _value_of$'

    # 2 Zu wenig Argumente
    run _value_of
    echo "fvlo2!status 2=${status};output:=${output};"
    [[ "$status" -eq 2 ]]
    [[ "$output" == "" ]]

    # 3 Zu viele Argumente
    run _value_of "arg1_needed" 22
    echo "fvlo3!status 2=${status};output:=${output};"
    [[ "$status" -eq 2 ]]
    [[ "$output" == "" ]]

    # 4 Datei Vars gibt es nicht - kann ich nicht testen, gibt es ja

    # 5 Eintrag gibt es nicht
    run _value_of "nicht da"
    echo "fvlo5!status 2=${status};output:=${output};"
    [[ "$status" -eq 0 ]]
    [[ "$output" == "" ]]

    # 6 ok
    run _value_of "db_server"
    echo "fvlo6!status 0=${status};output:localhost=${output};"
    [[ "$status" -eq 0 ]]
    [[ "$output" == "localhost" ]]

    run _value_of "header"
        assert_success
        assert_output "EXAMPLEDB"

    run _value_of "keywords"
        assert_success
        assert_output "Datenbankabfragen"
}

@test "tables_of_schema" {

    # 1 Readonly function
    readonly -f | grep ' tables_of_schema$'

    # 2 Zu wenig Argumente
    run tables_of_schema
    echo "ftbs2!status 2=${status};output:=${output};"
    [[ "$status" -eq 2 ]]
    [[ "$output" == "" ]]

    # 3 Zu viele Argumente
    run tables_of_schema "arg1_needed" 22
    echo "ftbs3!status 2=${status};output:=${output};"
    [[ "$status" -eq 2 ]]
    [[ "$output" == "" ]]

    # 4 Schemadatei gibt es nicht
    run tables_of_schema "nichtda"
    echo "ftbs4!status 2=${status};output:=${output};"
    [[ "$status" -eq 1 ]]
    [[ "$output" == "" ]]

    # 5 ok 1 Tabelle
    echo "CREATE TABLE   ooo(" > testxxx.schema
    run tables_of_schema "testxxx"
    echo "ftbs5!status 0=${status};output:ooo=${output};"
    [[ "$status" -eq 0 ]]
    [[ "$output" == "ooo" ]]
    rm testxxx.schema

    # 6 ok 2 Tabellen
    echo "CREATE TABLE   ooo(" > testxxx.schema
    echo "CREATE TABLE   eee(" >> testxxx.schema
    run tables_of_schema "testxxx"
    echo "ftbs6!status 0=${status};output:ooo eee=${output};"
    [[ "$status" -eq 0 ]]
    [[ ${output} == "ooo eee" ]]
    rm testxxx.schema
}

@test "write_sql_script" {
    local _user _pwd

    # 1 Readonly function
    readonly -f | grep ' write_sql_script$'

    # 2 Zu wenig Argumente
    run write_sql_script "abc" "def"
        assert_failure 2
        assert_output ""

    # 3 Zu viele Argumente
    run write_sql_script "arg1_needed" 22 "opr" "abcd"
        assert_failure 2
        assert_output ""

    # 4 ok
    _user="$(_value_of db_user)"
    _pwd="$(_value_of db_password)"

    echo "SELECT id, name FROM   example1;" > test/x.sql
    echo -n "mariadb --user=${_user} --password" > test/should_be.txt
    echo -n "=${_pwd} --database=example -e" >> test/should_be.txt
    echo " 'SELECT id, name FROM example1;'" >> test/should_be.txt

    run write_sql_script "SELECT" "test/x.sql" "test/x.sh"
        assert_success
        diff test/should_be.txt test/x.sh

    echo -n "SELECT id, name " > test/x.sql
    echo "FROM   example1;" >> test/x.sql
    echo -n "mariadb --user=${_user} --password" > test/should_be.txt
    echo -n "=${_pwd} --database=example -e" >> test/should_be.txt
    echo " 'SELECT id, name FROM example1;'" >> test/should_be.txt

    run write_sql_script "SELECT" "test/x.sql" "test/x.sh"
        assert_success
        diff test/should_be.txt test/x.sh

    echo "SELECT id, name FROM   example1;" > test/x.sql
    echo "SELECT x, y FROM   example2;" >> test/x.sql
    echo -n "mariadb --user=${_user} --password" > test/should_be.txt
    echo -n "=${_pwd} --database=example -e" >> test/should_be.txt
    echo " 'SELECT id, name FROM example1;'" >> test/should_be.txt
    echo -n "mariadb --user=${_user} --password" >> test/should_be.txt
    echo -n "=${_pwd} --database=example -e" >> test/should_be.txt
    echo " 'SELECT x, y FROM example2;'" >> test/should_be.txt

    run write_sql_script "SELECT" "test/x.sql" "test/x.sh"
        assert_success
        diff test/should_be.txt test/x.sh


    rm test/x.sql
    rm test/should_be.txt
    rm test/x.sh
}

@test "schema2level" {
    run schema2level
        assert_failure 2

    run schema2level "abc" "def"
        assert_failure 2

    run schema2level "abc"
        assert_failure 1

    local schema="abc_xzy_nkZtE4WWx"
    local level_file="${PROJECT_DIR}/db/${schema}.lvl"
    touch "${level_file}"

    echo "abc;def;" > "${level_file}"
    echo "7;" >> "${level_file}"
    echo "dsf;" >> "${level_file}"
    run schema2level "${schema}"
        assert_success
        assert_output "7"

    echo "abc;def;" > "${level_file}"
    echo "dsf;" >> "${level_file}"
    run schema2level "${schema}"
        assert_failure 1

    echo "7;" > "${level_file}"
    echo "abc;def;" >> "${level_file}"
    echo "dsf;" >> "${level_file}"
    run schema2level "${schema}"
        assert_success
        assert_output "7"

    echo "dsaf8" >> "${level_file}"
    echo "dsf;" >> "${level_file}"
    run schema2level "${schema}"
        assert_failure 1


    rm "${level_file}"


}

@test "sort_schemas" {
    run sort_schemas "abc"
        assert_failure 2

    local schema="abc_xzy_nkZtE4WWx"
    local schema_file="${PROJECT_DIR}/${schema}.schema"
    touch "${schema_file}"
    run sort_schemas
        assert_failure 1
    rm "${schema_file}"

    if [[ -f "${PROJECT_DIR}/db/example1.lvl" &&
          -f "${PROJECT_DIR}/db/example2.lvl" &&
          -f "${PROJECT_DIR}/db/example3.lvl" ]]; then
        run sort_schemas
            assert_success
            assert_output --partial "example1"
            assert_output --partial "example2"
            assert_output --partial "example3 "
    fi

}

@test "replace_placeholders" {
    run replace_placeholders
        assert_failure 2

    run replace_placeholders "abc" "def"
        assert_failure 2

    run replace_placeholders "abc"
        assert_failure 2


    local base="abc_xzy_nkZtE4WWx"
    local base_file="${PROJECT_DIR}/${base}.xxx"
    local shouldbe_file="${PROJECT_DIR}/${base}.shouldbe"
    touch "${base_file}"

    mv "${PROJECT_DIR}/Vars" xxx.vars

    run replace_placeholders "${base_file}"
        assert_failure 1

    mv  xxx.vars "${PROJECT_DIR}/Vars"
    run replace_placeholders "${base_file}"
        assert_success

    mv "${PROJECT_DIR}/Vars" xxx.vars
    echo "a;b;" > "${PROJECT_DIR}/Vars"
    echo "# Kommentar" >> "${PROJECT_DIR}/Vars"
    echo "key;value; # Kommentar" >> "${PROJECT_DIR}/Vars"
    echo "%%a%% %%key%% %%a%%" > "${base_file}"
    echo "%%a%% %%key%% %%a%%" >> "${base_file}"
    echo "b value b" > "${shouldbe_file}"
    echo "b value b" >> "${shouldbe_file}"
    run replace_placeholders "${base_file}"
        assert_success
        diff "${base_file}" "${shouldbe_file}"

    rm "${PROJECT_DIR}/Vars"
    mv  xxx.vars "${PROJECT_DIR}/Vars"

    rm "${base_file}"
    rm "${shouldbe_file}"
}

@test "replace_placeholder_functions" {
    run replace_placeholder_functions
        assert_failure 2
    run replace_placeholder_functions "abc"
        assert_failure 2
    run replace_placeholder_functions "abc" "2" "3" "4" "no_file"
        assert_failure 1



    local base="abc_xzy_nkZtE4WWx"
    local base_file="${PROJECT_DIR}/${base}.xxx"
    local shouldbe_file="${PROJECT_DIR}/${base}.shouldbe"
    touch "${shouldbe_file}"
    touch "${base_file}"
    cp --preserve=mode,ownership \
                  "${PROJECT_DIR}/Framework/tmpl_fus.sh" "tmpl_fus.sh.sv.xx.yy"


    local fus_file="${PROJECT_DIR}/Framework/tmpl_fus.sh"
    echo "" >> "$fus_file"
    echo "function create_test {" >> "$fus_file"
    echo "    echo \"====testIt====\"" >> "$fus_file"
    echo "}" >> "$fus_file"
    echo "" >> "$fus_file"
    source "$PROJECT_ROOT/Framework/tmpl_fus.sh"

    echo "xxx(%test%)yyy" > "${base_file}"
    echo "xxx====testIt====yyy" > "${shouldbe_file}"
    replace_placeholder_functions "abc" "2" "3" "4" "${base_file}"
        diff "${base_file}" "${shouldbe_file}"


    mv  tmpl_fus.sh.sv.xx.yy "${PROJECT_DIR}/Framework/tmpl_fus.sh"
    rm "${base_file}"
    rm "${shouldbe_file}"
}

@test "i" {
    run i
        assert_failure 2
    run i 2
        assert_failure 2
    run i 2 "a" "b"
        assert_failure 2
    run i "a" "a"
        assert_failure 2
    run i "a" "2"
        assert_success
        assert_output "aa"
    run i "abc" "0"
        assert_success
        assert_output ""
    run i "  " "4"
        assert_success
        assert_output "        "
    run i "- " "0"
        assert_success
        assert_output ""
    run i "- " "1"
        assert_success
        assert_output "- "
    run i "- " "2"
        assert_success
        assert_output "- - "
    run i "- " "3"
        assert_success
        assert_output "- - - "
    run i "- " "4"
        assert_success
        assert_output "- - - - "

}

#SKIP
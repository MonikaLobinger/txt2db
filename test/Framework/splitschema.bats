setup() {
    load '../test_helper/common-setup'
    _common_setup "Framework"

    source "$PROJECT_ROOT/Framework/splitschema.sh"
}

teardown() {
    :
}

@test "Inklusionen" {
    [[ -v Grey  ]]

    [[ -v deepSkyBlue4_1  ]]
}

@test "main_splitschema" {
    readonly -f | grep ' main_splitschema$'

    run main_splitschema
        assert_failure 2
        assert_output "ERROR: Benötigte Anzahl von Argumenten: 1"

    run main_splitschema 22 33
        assert_failure 2
        assert_output "ERROR: Benötigte Anzahl von Argumenten: 1"

    run main_splitschema "nichtda"
        assert_failure 2
        assert_output --partial "ERROR: Keine Datei: /home"
        assert_output --partial "/nichtda.sh"

    run main_splitschema -v "nichtda"
        assert_failure 2
        assert_output --partial "ERROR: Keine Datei: /home"
        assert_output --partial "/nichtda.sh"

    run main_splitschema -x "nichtda"
        assert_failure 2
        assert_output --partial "AUFRUF: splitschema.sh [-dhv] SCHEMA"

    run main_splitschema -h
        assert_success
        assert_output --partial "AUFRUF: splitschema.sh [-dhv] SCHEMA"

    run main_splitschema --help
        assert_success
        assert_output --partial "AUFRUF: splitschema.sh [-dhv] SCHEMA"

    run main_splitschema -d "example1"
        assert_success
        assert_output ""

    run main_splitschema --dry "example1"
        assert_success
        assert_output ""

    run main_splitschema -dv "example1"
        assert_success
        assert_output --partial "csplit -s -f \"example1\" "
        assert_output --partial "mv \"example11\" \"db/example1.lvl\""
        assert_output --partial "write_sql_script"

    run main_splitschema --dry --verbose "example1"
        assert_success
        assert_output --partial "csplit -s -f \"example1\" "
        assert_output --partial "mv \"example11\" \"db/example1.lvl\""
        assert_output --partial "write_sql_script"
}

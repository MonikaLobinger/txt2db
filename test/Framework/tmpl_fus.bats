setup() {
    load '../test_helper/common-setup'
    _common_setup "Framework"

    source "$PROJECT_ROOT/Framework/fus.sh"
    source "$PROJECT_ROOT/Framework/tmpl_fus.sh"
}

teardown() {
:
}

#: << SKIP

@test "Inklusionen" {
    [[ -v grey  ]]
    [[ -v LightSkyBlue3_1  ]]
    [[ -v clr  ]]
}

@test "Nachrichten" {
    run _ "arg1_needed"
    echo "fmsg4!status 0=${status};output:Es wird genau ein Argument benötigt=${output};"
    [[ "$status" -eq 0 ]]
    [[ "$output" == "Es wird genau ein Argument benötigt" ]]
}

@test "_error" {
    run _error 1 "soffice_runs"
        assert_failure 1
        assert_output --partial "ERROR: Während Libre Office mit gui läuft"
        assert_output --partial "Libre Office gui muß beendet werden"
}

@test "create_link_tree" {
    run create_link_tree
        assert_failure 2

    run create_link_tree 22
        assert_failure 2

    run create_link_tree "a" "b" "c" "d" "e"
        assert_failure 2

    run create_link_tree 0 "abc"
        assert_success
        assert_output "<ul>\n\
  <li><a href=\".\/abc.php\">Abc<\/a><\/li>\n\
  <ul>\n\
  <\/ul>\n<\/ul>"


    run create_link_tree 1 "abc" "schema" "table" "statements_file"
        assert_success
        assert_output "<ul>\n\
    <li><a href=\".\/abc.php\">Abc<\/a><\/li>\n\
    <ul>\n\
    <\/ul>\n\
  <\/ul>"

    run create_link_tree 1 "abc def"
        assert_success
        assert_output "<ul>\n\
    <li><a href=\".\/abc.php\">Abc<\/a><\/li>\n\
    <ul>\n\
    <\/ul>\n\
    <li><a href=\".\/def.php\">Def<\/a><\/li>\n\
    <ul>\n\
    <\/ul>\n\
  <\/ul>"

}

@test "create_title_attr" {
    run create_title_attr
        assert_failure 2
    run create_title_attr 1 2 3
        assert_failure 2
    run create_title_attr 1 2 3 4 5 6
        assert_failure 2
    run create_title_attr 1 2 "abc" 4 5
        assert_failure 2

    run create_title_attr 1 2 "abc" "def" 5
        assert_success
        assert_output "ABC def"

    run create_title_attr 1 2 "abc" "_" 5
        assert_success
        assert_output "ABC"
}
@test "create_desc_attr" {
    run create_desc_attr
        assert_failure 2
    run create_desc_attr 1 2 3
        assert_failure 2
    run create_desc_attr 1 2 3 4 5 6
        assert_failure 2
    run create_desc_attr 1 2 "abc" 4 5
        assert_failure 2

    run create_desc_attr 1 2 "abc" "def" 5
        assert_success
        assert_output "def"
}

@test "create_keywords_attr" {
    run create_keywords_attr
        assert_failure 2
    run create_keywords_attr 1 2 3
        assert_failure 2
    run create_keywords_attr 1 2 3 4 5 6
        assert_failure 2
    run create_keywords_attr 1 2 "abc" 4 5
        assert_failure 2

    run create_keywords_attr 1 2 "schema" "table" 5
        assert_success
        assert_output "Datenbankabfragen, schema, table"

    run create_keywords_attr 1 2 "schema" "_" 5
        assert_success
        assert_output "Datenbankabfragen, schema"
}
@test "create_gimmecks" {
    run create_gimmecks
        assert_failure 2
    run create_gimmecks 1 2 3
        assert_failure 2
    run create_gimmecks 1 2 3 4 5 6
        assert_failure 2
    run create_gimmecks 1 2 "abc" 4 5
        assert_failure 2

    run create_gimmecks 1 2 "schema" "table" 5
        assert_success
        assert_output --partial "<p>DAS IST NUR ZUM TESTEN<\/p>\n"

}
@test "create_breadcrumbs" {
    run create_breadcrumbs
        assert_failure 2
    run create_breadcrumbs 1 2 3
        assert_failure 2
    run create_breadcrumbs 1 2 3 4 5 6
        assert_failure 2
    run create_breadcrumbs 1 2 "abc" 4 5
        assert_failure 2

    run create_breadcrumbs 1 2 "schema" "table" "x"
        assert_success
        assert_output "<li><a href=\".\/index.html\">Home<\/a><\/li>\n  <li><a href=\".\/schema.php\">Schema<\/a><\/li>\n  <li>table<\/li>"

    run create_breadcrumbs 2 1 "schema" "_" "x"
        assert_success
        assert_output "<li><a href=\".\/index.html\">Home<\/a><\/li>\n    <li>Schema<\/li>"

}

@test "create_article" {
    run create_article
        assert_failure 2
    run create_article 1 2 3
        assert_failure 2
    run create_article 1 2 3 4 5 6
        assert_failure 2
    run create_article 1 2 "abc" 4
        assert_failure 2
    run create_article 1 2 "schema" "table" "nicht_da"
        assert_failure 2

    select_file="${PROJECT_DIR}/db/xyz_nicht_da.sql"

    echo "### --- Abfragen" > "${select_file}"
    echo "SELECT id, name FROM   tabelle;" >> "${select_file}"

    run create_article 1 2 "schema" "_" "${select_file}"
        assert_success
        assert_output "Überblickseite"

    run create_article 1 2 "schema" "tabelle" "${select_file}"
        assert_success
        assert_output --partial "\$statement = \$conn->prepare(\'SELECT id, name FROM   tabelle;\');\n"
        assert_output --partial "<td>\".\$row[\'0\'].\"<\/td>"

    rm "${select_file}"
}
#SKIP

setup() {
    load '../test_helper/common-setup'
    _common_setup "Framework"

    source "$PROJECT_ROOT/Framework/web.sh"
}

teardown() {
    :
}

@test "fill_web_file" {
    run fill_web_file
        assert_failure 2

    run fill_web_file "abc" "def"
        assert_failure 2

    run fill_web_file "abc def"
        assert_failure 2

}

@test "main_web" {
  :
}
setup() {
    load '../test_helper/common-setup'
    _common_setup "Framework"

    source "$PROJECT_ROOT/Framework/php.sh"
}

teardown() {
    :
}

@test "Globale Variablen" {

    # Wert von Variable ROOT_DIR ist bestimmtes Verzeichnis
    [[  -f "$ROOT_DIR/include/base.sh" ]]

    # Wert von Variable PROJECT_DIR ist bestimmtes Verzeichnis
    [[  -f "$PROJECT_DIR/Makefile" ]]
}

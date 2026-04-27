#!/usr/bin/env bats
#
# Tests for scripts/linux/system-report.sh
# Run with: bats tests/linux/system-report.bats

setup() {
    SCRIPT="${BATS_TEST_DIRNAME}/../../scripts/linux/system-report.sh"
    TMP_DIR="$(mktemp -d)"
}

teardown() {
    rm -rf "$TMP_DIR"
}

@test "script file exists" {
    [ -f "$SCRIPT" ]
}

@test "script is executable" {
    [ -x "$SCRIPT" ]
}

@test "script has bash shebang" {
    run head -n 1 "$SCRIPT"
    [ "$status" -eq 0 ]
    [[ "$output" == "#!/usr/bin/env bash" ]]
}

@test "default run exits with status 0" {
    run bash "$SCRIPT"
    [ "$status" -eq 0 ]
}

@test "output contains CPU section" {
    run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    [[ "$output" == *"===== CPU ====="* ]]
}

@test "output contains Memory section" {
    run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    [[ "$output" == *"===== Memory ====="* ]]
}

@test "output contains Disk section" {
    run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    [[ "$output" == *"===== Disk ====="* ]]
}

@test "output contains Uptime section" {
    run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    [[ "$output" == *"===== Uptime ====="* ]]
}

@test "output contains Services section with default services" {
    run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    [[ "$output" == *"===== Services ====="* ]]
    [[ "$output" == *"sshd"* ]]
    [[ "$output" == *"cron"* ]]
}

@test "output contains a header with the current date" {
    run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    [[ "$output" == *"System Report"* ]]
}

@test "-h flag prints usage and exits 0" {
    run bash "$SCRIPT" -h
    [ "$status" -eq 0 ]
    [[ "$output" == *"Usage:"* ]]
}

@test "--help flag prints usage and exits 0" {
    run bash "$SCRIPT" --help
    [ "$status" -eq 0 ]
    [[ "$output" == *"Usage:"* ]]
}

@test "-o flag writes report to specified file" {
    local out_file="$TMP_DIR/report.txt"
    run bash "$SCRIPT" -o "$out_file"
    [ "$status" -eq 0 ]
    [ -f "$out_file" ]
    grep -q "===== CPU =====" "$out_file"
    grep -q "===== Memory =====" "$out_file"
}

@test "-o without argument exits non-zero" {
    run bash "$SCRIPT" -o
    [ "$status" -ne 0 ]
    [[ "$output" == *"requires a file path"* ]]
}

@test "--services without argument exits non-zero" {
    run bash "$SCRIPT" --services
    [ "$status" -ne 0 ]
    [[ "$output" == *"requires a comma-separated"* ]]
}

@test "--services adds extra services to output" {
    run bash "$SCRIPT" --services nginx,mysql
    [ "$status" -eq 0 ]
    [[ "$output" == *"nginx"* ]]
    [[ "$output" == *"mysql"* ]]
}

@test "unknown option exits non-zero" {
    run bash "$SCRIPT" --bogus-flag
    [ "$status" -ne 0 ]
    [[ "$output" == *"Unknown option"* ]]
}

@test "stray environment variables do not break the script" {
    FOO=bar BAZ='value with spaces' run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    [[ "$output" == *"===== CPU ====="* ]]
}

@test "syntax check passes" {
    run bash -n "$SCRIPT"
    [ "$status" -eq 0 ]
}

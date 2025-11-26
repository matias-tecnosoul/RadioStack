#!/bin/bash
# RadioStack Test Suite
# Run this script as root to test all RadioStack functionality

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  RadioStack Test Suite"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Check if running as root
if [[ $EUID -ne 0 ]]; then
    echo -e "${RED}ERROR:${NC} This script must be run as root"
    echo "Usage: sudo ./test-radiostack.sh"
    exit 1
fi

# Test counter
TESTS_PASSED=0
TESTS_FAILED=0

# Test function
run_test() {
    local test_name=$1
    local test_command=$2

    echo -e "${BLUE}TEST:${NC} $test_name"
    if eval "$test_command" &>/dev/null; then
        echo -e "${GREEN}✓ PASS${NC}"
        ((TESTS_PASSED++))
    else
        echo -e "${RED}✗ FAIL${NC}"
        ((TESTS_FAILED++))
    fi
    echo ""
}

# ============================================================================
# PHASE 1: SYNTAX CHECKS
# ============================================================================

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Phase 1: Syntax Validation"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

run_test "Library: common.sh syntax" "bash -n scripts/lib/common.sh"
run_test "Library: storage.sh syntax" "bash -n scripts/lib/storage.sh"
run_test "Library: container.sh syntax" "bash -n scripts/lib/container.sh"
run_test "Library: inventory.sh syntax" "bash -n scripts/lib/inventory.sh"

run_test "Platform: azuracast.sh syntax" "bash -n scripts/platforms/azuracast.sh"
run_test "Platform: libretime.sh syntax" "bash -n scripts/platforms/libretime.sh"
run_test "Platform: deploy.sh syntax" "bash -n scripts/platforms/deploy.sh"

run_test "Tool: status.sh syntax" "bash -n scripts/tools/status.sh"
run_test "Tool: update.sh syntax" "bash -n scripts/tools/update.sh"
run_test "Tool: backup.sh syntax" "bash -n scripts/tools/backup.sh"
run_test "Tool: remove.sh syntax" "bash -n scripts/tools/remove.sh"
run_test "Tool: info.sh syntax" "bash -n scripts/tools/info.sh"
run_test "Tool: logs.sh syntax" "bash -n scripts/tools/logs.sh"

# ============================================================================
# PHASE 2: HELP SYSTEMS
# ============================================================================

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Phase 2: Help Systems"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

run_test "AzuraCast help" "./scripts/platforms/azuracast.sh --help"
run_test "LibreTime help" "./scripts/platforms/libretime.sh --help"
run_test "Deploy help" "./scripts/platforms/deploy.sh --help"
run_test "Status help" "./scripts/tools/status.sh --help"
run_test "Update help" "./scripts/tools/update.sh --help"
run_test "Backup help" "./scripts/tools/backup.sh --help"
run_test "Remove help" "./scripts/tools/remove.sh --help"
run_test "Info help" "./scripts/tools/info.sh --help"
run_test "Logs help" "./scripts/tools/logs.sh --help"

# ============================================================================
# PHASE 3: LIBRARY LOADING
# ============================================================================

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Phase 3: Library Loading"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

run_test "Source common.sh" "source scripts/lib/common.sh"
run_test "Source storage.sh" "source scripts/lib/storage.sh"
run_test "Source container.sh" "source scripts/lib/container.sh"
run_test "Source inventory.sh" "source scripts/lib/inventory.sh"

# ============================================================================
# PHASE 4: ENVIRONMENT CHECKS
# ============================================================================

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Phase 4: Environment Checks"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Source libraries for environment checks
source scripts/lib/common.sh

run_test "Check if running on Proxmox" "check_proxmox_version"
run_test "Check pct command exists" "check_command pct"
run_test "Check zfs command exists" "check_command zfs"
run_test "Check docker availability" "check_command docker || true"

# ============================================================================
# PHASE 5: INVENTORY SYSTEM
# ============================================================================

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Phase 5: Inventory System"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

source scripts/lib/inventory.sh

run_test "Initialize inventory" "init_inventory"
run_test "List stations (empty)" "./scripts/tools/status.sh --all"
run_test "System summary" "./scripts/tools/info.sh --summary"

# ============================================================================
# PHASE 6: VALIDATION FUNCTIONS
# ============================================================================

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Phase 6: Validation Functions"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

run_test "Validate IP: valid" "validate_ip 192.168.1.10"
run_test "Validate IP: invalid (should fail)" "! validate_ip 999.999.999.999"
run_test "Validate CTID: valid" "validate_ctid 500"
run_test "Validate CTID: invalid low (should fail)" "! validate_ctid 50"
run_test "Validate CTID: invalid high (should fail)" "! validate_ctid 9999999"

# ============================================================================
# SUMMARY
# ============================================================================

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Test Summary"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo -e "Tests Passed: ${GREEN}$TESTS_PASSED${NC}"
echo -e "Tests Failed: ${RED}$TESTS_FAILED${NC}"
echo ""

TOTAL_TESTS=$((TESTS_PASSED + TESTS_FAILED))
if [[ $TESTS_FAILED -eq 0 ]]; then
    echo -e "${GREEN}✓ All tests passed!${NC}"
    echo ""
    echo "Next steps:"
    echo "  1. Review existing containers: sudo ./scripts/tools/status.sh --all"
    echo "  2. Deploy test station: sudo ./scripts/platforms/azuracast.sh -i 999 -n test"
    echo "  3. Check deployment: sudo ./scripts/tools/info.sh --ctid 999"
    echo ""
    exit 0
else
    PASS_RATE=$((TESTS_PASSED * 100 / TOTAL_TESTS))
    echo -e "${YELLOW}⚠ Some tests failed (${PASS_RATE}% pass rate)${NC}"
    echo "Please review the failed tests above"
    echo ""
    exit 1
fi

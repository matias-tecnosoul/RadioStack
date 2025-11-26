#!/bin/bash
# Quick test to verify the count_stations bug is fixed

cd "$(dirname "$0")"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Testing count_stations Bug Fix"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Test the function directly
source scripts/lib/common.sh
source scripts/lib/inventory.sh

export INVENTORY_FILE="/tmp/test-inventory-bugfix.csv"
echo "CTID,Type,Hostname,IP,Description,Created,Status" > "$INVENTORY_FILE"

echo "Test 1: count_stations with empty inventory"
result=$(count_stations)
echo "  Result: [$result]"

if [[ "$result" == "0" ]]; then
    echo "  ✅ PASS - Returns clean '0'"
else
    echo "  ❌ FAIL - Returns: '$result'"
    exit 1
fi

echo ""
echo "Test 2: count_by_platform with empty inventory"
result=$(count_by_platform "azuracast")
echo "  Result: [$result]"

if [[ "$result" == "0" ]]; then
    echo "  ✅ PASS - Returns clean '0'"
else
    echo "  ❌ FAIL - Returns: '$result'"
    exit 1
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  ✅ All Tests Passed!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Now run with sudo to test the full commands:"
echo "  sudo ./scripts/tools/status.sh --all"
echo "  sudo ./scripts/tools/info.sh --summary"
echo "  sudo ./test-radiostack.sh"
echo ""

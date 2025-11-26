#!/bin/bash
# Verify the count_stations fix

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  ✅ Bug Fix Verification"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Test the fixed function
source scripts/lib/common.sh 2>/dev/null
source scripts/lib/inventory.sh 2>/dev/null

echo "Testing count_stations() function..."
result=$(count_stations 2>/dev/null)
echo "Result: [$result]"

if [[ "$result" == "0" ]]; then
    echo "✅ PASS - Function returns clean '0'"
else
    echo "❌ FAIL - Function returns: '$result'"
fi

echo ""
echo "To run the full test suite with proper permissions:"
echo "  sudo ./test-radiostack.sh"
echo ""
echo "To test status command:"
echo "  sudo ./scripts/tools/status.sh --all"
echo ""


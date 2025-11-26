# Bug Fix Summary - count_stations Double Output

## Problem
When running `./scripts/tools/status.sh --all` or `./scripts/tools/info.sh --summary`, the count was showing as "0\n0" instead of "0", causing a syntax error:

```
./scripts/tools/status.sh: line 41: [[: 0
0: syntax error in expression (error token is "0")
```

## Root Cause
The issue was in [scripts/lib/inventory.sh](scripts/lib/inventory.sh) in two functions:
- `count_stations()`
- `count_by_platform()`

The problem:
```bash
# BROKEN CODE:
count=$(tail -n +2 "$INVENTORY_FILE" | grep -c "^[0-9]" || echo "0")
```

**Why it produced double output:**
1. `grep -c "^[0-9]"` outputs `0` when there are no matches
2. BUT it also exits with status code 1 (error) when count is 0
3. This triggers the `|| echo "0"` to execute
4. Result: TWO zeros are output: one from grep and one from echo

## Solution
Use `|| true` instead of `|| echo "0"` to ignore the exit code without adding extra output:

```bash
# FIXED CODE:
tail -n +2 "$INVENTORY_FILE" 2>/dev/null | grep -c "^[0-9]" || true
```

## Files Modified
- `scripts/lib/inventory.sh` - Fixed both functions

## Testing
```bash
# Should now work without errors:
sudo ./scripts/tools/status.sh --all
sudo ./scripts/tools/info.sh --summary
sudo ./test-radiostack.sh
```

## Verification
```bash
bash << 'ENDTEST'
source scripts/lib/common.sh
source scripts/lib/inventory.sh

export INVENTORY_FILE="/tmp/test.csv"
echo "CTID,Type,Hostname,IP,Description,Created,Status" > "$INVENTORY_FILE"

result=$(count_stations)
echo "Result: [$result]"

if [[ "$result" == "0" ]]; then
    echo "✅ PASS"
else
    echo "❌ FAIL"
fi
ENDTEST
```

Expected output: `Result: [0]` with `✅ PASS`

---

**Status:** ✅ Fixed and ready for testing

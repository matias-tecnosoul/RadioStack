# RadioStack: Prototype to Production Migration Map

## Current Structure (Prototype)
```
/root/radio-platform/
├── scripts/
│   ├── common-functions.sh       ← All shared functions
│   ├── deploy-azuracast.sh       ← Monolithic deployment
│   ├── deploy-libretime.sh       ← Monolithic deployment
│   └── bulk-operations.sh        ← All management in one file
└── configs/
    └── container-inventory.csv
```

## Target Structure (Production)
```
/opt/radiostack/
├── install.sh                    ← Install script
├── radiostack                    ← Main CLI entry
├── README.md
├── CHANGELOG.md
├── LICENSE
│
├── docs/                         ← Documentation
│   ├── getting-started.md        ✅ Done
│   ├── deployment-guide.md       ⚠️ TODO
│   ├── azuracast.md              ⚠️ TODO
│   ├── libretime.md              ⚠️ TODO
│   ├── architecture.md           ⚠️ TODO
│   └── troubleshooting.md        ⚠️ TODO
│
├── scripts/
│   ├── radiostack-cli.sh         ← CLI router
│   │
│   ├── lib/                      ← Modular libraries
│   │   ├── common.sh             ← Logging, colors, validation
│   │   ├── container.sh          ← LXC operations
│   │   ├── storage.sh            ← ZFS operations
│   │   └── inventory.sh          ← CSV management
│   │
│   ├── platforms/                ← Platform deployments
│   │   ├── deploy.sh             ← Platform dispatcher
│   │   ├── azuracast.sh          ← AzuraCast logic
│   │   ├── libretime.sh          ← LibreTime logic
│   │   └── icecast.sh            ← Future: standalone
│   │
│   └── tools/                    ← Management commands
│       ├── status.sh             ← Show status
│       ├── update.sh             ← Update stations
│       ├── backup.sh             ← Backup operations
│       ├── remove.sh             ← Remove stations
│       ├── info.sh               ← Detailed info
│       ├── logs.sh               ← View logs
│       └── check.sh              ← System checks
│
├── configs/                      ← Configuration templates
│   ├── azuracast.conf.example
│   ├── libretime.conf.example
│   └── inventory.csv.example
│
├── templates/                    ← Config file templates
│   ├── docker-compose/
│   │   ├── azuracast.yml
│   │   └── libretime.yml
│   └── nginx/
│       ├── azuracast-proxy.conf
│       └── libretime-proxy.conf
│
├── tests/                        ← Test scripts
│   ├── test-azuracast.sh
│   └── test-libretime.sh
│
└── examples/                     ← Usage examples
    ├── basic-deployment.sh
    ├── multi-station.sh
    └── migration.sh
```

## Migration Map: Function Extraction

### From common-functions.sh → Multiple Library Files

#### → lib/common.sh
```bash
# Color codes
RED, GREEN, YELLOW, NC

# Logging
log_info()
log_warn()
log_error()

# Validation
check_root()
check_ctid_available()

# Configuration loading
load_config()
```

#### → lib/container.sh
```bash
# Container lifecycle
create_base_container()
start_container()
stop_container()
restart_container()
enter_container()

# Configuration
attach_mount_point()
setup_container_system()
configure_container_network()

# Status
wait_for_container()
check_container_status()
get_container_ip()
```

#### → lib/storage.sh
```bash
# ZFS operations
create_media_dataset()
delete_dataset()
resize_dataset()
get_dataset_usage()
check_storage_available()

# Validation
validate_storage_pool()
check_quota()
```

#### → lib/inventory.sh
```bash
# Inventory operations
add_to_inventory()
remove_from_inventory()
update_inventory()
list_stations()
get_station_info()
find_available_ctid()
export_inventory()
```

### From deploy-azuracast.sh → platforms/azuracast.sh

**Extract:**
- Platform-specific logic
- AzuraCast installation steps
- Configuration generation
- Post-install instructions

**Keep Generic:**
- Argument parsing (move to deploy.sh)
- Container creation (use lib/container.sh)
- Storage setup (use lib/storage.sh)

### From bulk-operations.sh → tools/*.sh

**Split into:**
- `tools/update.sh` - update_all_azuracast(), update_all_libretime()
- `tools/backup.sh` - backup_all(), backup_container()
- `tools/status.sh` - check_all_status(), show_container_status()
- `tools/remove.sh` - remove_container(), purge_data()

## Implementation Order

### Phase 1: Foundation (Priority ⭐⭐⭐)
```
1. Create lib/common.sh           (1h)
2. Create lib/storage.sh          (1h)
3. Create lib/container.sh        (1h)
4. Create lib/inventory.sh        (30m)
5. Test library functions         (30m)
```

### Phase 2: Platforms (Priority ⭐⭐⭐)
```
1. Refactor platforms/azuracast.sh    (1h)
2. Refactor platforms/libretime.sh    (1h)
3. Create platforms/deploy.sh         (30m)
4. Test platform deployments          (1h)
```

### Phase 3: Tools (Priority ⭐⭐)
```
1. Create tools/status.sh         (30m)
2. Create tools/update.sh         (45m)
3. Create tools/backup.sh         (45m)
4. Create tools/remove.sh         (30m)
5. Create tools/info.sh           (30m)
6. Create tools/logs.sh           (30m)
7. Create tools/check.sh          (45m)
8. Test all tools                 (1h)
```

### Phase 4: CLI & Config (Priority ⭐⭐⭐)
```
1. Complete radiostack-cli.sh     (1h)
2. Create config templates        (30m)
3. Update install.sh              (30m)
4. Test end-to-end workflow       (1h)
```

### Phase 5: Documentation (Priority ⭐⭐)
```
1. Write deployment-guide.md      (1h)
2. Write azuracast.md             (1h)
3. Write libretime.md             (1h)
4. Write troubleshooting.md       (1h)
5. Write architecture.md          (30m)
6. Review all docs                (30m)
```

### Phase 6: Polish (Priority ⭐)
```
1. Create templates/              (1h)
2. Create examples/               (1h)
3. Create tests/                  (2h)
4. Final testing                  (1h)
```

## Key Design Principles

### 1. Single Responsibility
Each script/function does ONE thing well:
- `lib/storage.sh` - Only ZFS operations
- `platforms/azuracast.sh` - Only AzuraCast deployment
- `tools/backup.sh` - Only backup operations

### 2. Composability
Library functions can be combined:
```bash
# In platforms/azuracast.sh
source "$RADIOSTACK_ROOT/scripts/lib/common.sh"
source "$RADIOSTACK_ROOT/scripts/lib/storage.sh"
source "$RADIOSTACK_ROOT/scripts/lib/container.sh"

deploy_azuracast() {
    validate_ctid "$CTID"              # from lib/common.sh
    create_media_dataset "$DATASET"    # from lib/storage.sh
    create_base_container "$CTID"      # from lib/container.sh
    # ... platform-specific logic
}
```

### 3. Error Handling
Every function returns proper exit codes:
```bash
create_media_dataset() {
    local dataset=$1
    
    if ! zfs list "$dataset" &>/dev/null; then
        if ! zfs create "$dataset"; then
            log_error "Failed to create dataset: $dataset"
            return 1
        fi
    fi
    
    return 0
}
```

### 4. Configuration First
All defaults in config, can be overridden:
```bash
# /etc/radiostack/radiostack.conf
DEFAULT_AZURACAST_CORES=6
DEFAULT_AZURACAST_MEMORY=12288

# In script
CORES=${CORES:-$DEFAULT_AZURACAST_CORES}
```

## Testing Strategy

### Unit Tests (per library)
```bash
tests/test-lib-common.sh
tests/test-lib-storage.sh
tests/test-lib-container.sh
tests/test-lib-inventory.sh
```

### Integration Tests (per platform)
```bash
tests/test-azuracast-deploy.sh
tests/test-libretime-deploy.sh
```

### End-to-End Tests
```bash
tests/test-full-workflow.sh
# - Deploy station
# - Update station
# - Backup station
# - Remove station
```

## Success Criteria

RadioStack is production-ready when:

- ✅ All library functions tested and working
- ✅ AzuraCast deployment works end-to-end
- ✅ LibreTime deployment works end-to-end
- ✅ All management tools functional
- ✅ CLI routes commands correctly
- ✅ Documentation complete
- ✅ Error handling robust
- ✅ No hardcoded values
- ✅ Passes all tests
- ✅ Ready for GitHub release

## Next Action

**Shall we start with Phase 1: Foundation?**

I can begin implementing the library files, starting with `lib/common.sh` which will be used by everything else.

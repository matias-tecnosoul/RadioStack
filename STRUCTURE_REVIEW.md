# RadioStack Repository Structure Review

## Current Status Analysis

### ✅ Files Present in Knowledge Base

#### Root Level
- `README.md` - Complete, well-structured
- `install.sh` - Complete installation script
- `CHANGELOG.md` - Not found
- `LICENSE` - Not found

#### Documentation (`docs/`)
- ✅ `getting-started.md` - Complete and comprehensive
- ⚠️ `deployment-guide.md` - Referenced but not created
- ⚠️ `azuracast.md` - Referenced but not created  
- ⚠️ `libretime.md` - Referenced but not created
- ⚠️ `architecture.md` - Referenced but not created
- ⚠️ `troubleshooting.md` - Referenced but not created
- ⚠️ `api-reference.md` - Referenced but not created

#### Scripts (`scripts/`)
**Main Entry Point:**
- ✅ `radiostack-cli.sh` - Main CLI entry point (outline only)

**Early Prototype Scripts (from TecnoSoul docs):**
- ✅ `deploy-azuracast.sh` - Working prototype, uses common-functions.sh
- ✅ `deploy-libretime.sh` - Working prototype, uses common-functions.sh
- ✅ `common-functions.sh` - Working prototype with core functions
- ✅ `bulk-operations.sh` - Working bulk operations script

**Library Structure (`scripts/lib/`):**
- ⚠️ `common.sh` - Referenced in CLI but not implemented
- ⚠️ `container.sh` - Referenced in CLI but not implemented
- ⚠️ `storage.sh` - Referenced in CLI but not implemented
- ⚠️ `inventory.sh` - Referenced in CLI but not implemented

**Platform Scripts (`scripts/platforms/`):**
- ⚠️ `deploy.sh` - Referenced in CLI but not implemented
- ⚠️ `azuracast.sh` - Need to evolve from prototype
- ⚠️ `libretime.sh` - Need to evolve from prototype
- ⚠️ `icecast.sh` - Future feature

**Tool Scripts (`scripts/tools/`):**
- ⚠️ `remove.sh` - Referenced in CLI but not implemented
- ⚠️ `update.sh` - Referenced in CLI but not implemented
- ⚠️ `backup.sh` - Referenced in CLI but not implemented
- ⚠️ `status.sh` - Referenced in CLI but not implemented
- ⚠️ `info.sh` - Referenced in CLI but not implemented
- ⚠️ `logs.sh` - Referenced in CLI but not implemented
- ⚠️ `check.sh` - Referenced in CLI but not implemented
- ⚠️ `migrate.sh` - Referenced in README but not started

#### Configuration (`configs/`)
- ⚠️ `azuracast.conf.example` - Not created
- ⚠️ `libretime.conf.example` - Not created
- ⚠️ `inventory.csv.example` - Not created

#### Templates (`templates/`)
- ⚠️ `docker-compose/azuracast.yml` - Not created
- ⚠️ `docker-compose/libretime.yml` - Not created
- ⚠️ `nginx/azuracast-proxy.conf` - Not created
- ⚠️ `nginx/libretime-proxy.conf` - Not created

#### Tests (`tests/`)
- ⚠️ `test-azuracast.sh` - Not created
- ⚠️ `test-libretime.sh` - Not created

#### Examples (`examples/`)
- ⚠️ `basic-deployment.sh` - Not created
- ⚠️ `multi-station.sh` - Not created
- ⚠️ `migration.sh` - Not created

---

## 🔄 Migration Path: Prototype → Production Structure

### Current Situation
We have **two parallel structures**:

1. **Prototype Scripts** (working but basic):
   - `deploy-azuracast.sh`
   - `deploy-libretime.sh`
   - `common-functions.sh`
   - `bulk-operations.sh`

2. **Planned Production Structure** (outlined but not implemented):
   - `scripts/lib/` - Modular libraries
   - `scripts/platforms/` - Platform-specific code
   - `scripts/tools/` - Management tools
   - `radiostack-cli.sh` - Unified CLI

### Recommended Strategy

**Phase 1: Evolve Prototypes Into Modular Structure**

1. **Split `common-functions.sh` into library modules:**
   ```
   common-functions.sh → scripts/lib/common.sh     (logging, validation)
                       → scripts/lib/container.sh   (LXC operations)
                       → scripts/lib/storage.sh     (ZFS operations)
                       → scripts/lib/inventory.sh   (CSV tracking)
   ```

2. **Refactor platform scripts:**
   ```
   deploy-azuracast.sh → scripts/platforms/azuracast.sh
   deploy-libretime.sh → scripts/platforms/libretime.sh
   ```

3. **Extract bulk operations into tool scripts:**
   ```
   bulk-operations.sh → scripts/tools/update.sh
                      → scripts/tools/backup.sh
                      → scripts/tools/status.sh
   ```

**Phase 2: Build Remaining Tools**
- Implement missing tools (remove, info, logs, check)
- Create unified CLI wrapper
- Add testing scripts

**Phase 3: Documentation & Polish**
- Complete all documentation files
- Add configuration templates
- Create example scripts

---

## 📋 Detailed File Analysis

### Working Prototypes Analysis

#### `common-functions.sh` - Functions Breakdown
```bash
# Logging (→ lib/common.sh)
- log_info()
- log_warn()
- log_error()

# Validation (→ lib/common.sh)
- check_root()
- check_ctid_available()

# Storage (→ lib/storage.sh)
- create_media_dataset()

# Container Creation (→ lib/container.sh)
- create_base_container()
- attach_mount_point()
- setup_container_system()
- wait_for_container()

# Inventory (→ lib/inventory.sh)
- add_to_inventory()
```

**Status:** Well-structured, can be cleanly split into modules

#### `deploy-azuracast.sh` - Features
- Argument parsing with defaults
- Help system
- ZFS dataset creation
- LXC container creation
- AzuraCast Docker installation
- NPM proxy instructions
- Good user feedback

**Status:** Production-ready, just needs integration with new structure

#### `deploy-libretime.sh` - Features
- Similar structure to AzuraCast script
- Docker + LibreTime setup
- Configuration file generation
- Default credentials handling

**Status:** Production-ready, needs integration

#### `bulk-operations.sh` - Features
- List containers
- Update all AzuraCast
- Update all LibreTime
- Backup all
- Status checks
- Interactive menu

**Status:** Good foundation, needs splitting into individual tools

---

## 🎯 Immediate Next Steps

### Priority 1: Library Implementation (1-2 hours)
Create modular library files by extracting and organizing from `common-functions.sh`:

1. `scripts/lib/common.sh`
   - Logging functions
   - Color codes
   - Validation functions
   - Error handling

2. `scripts/lib/container.sh`
   - create_base_container()
   - attach_mount_point()
   - setup_container_system()
   - wait_for_container()
   - Container lifecycle functions

3. `scripts/lib/storage.sh`
   - create_media_dataset()
   - ZFS operations
   - Storage validation
   - Quota management

4. `scripts/lib/inventory.sh`
   - add_to_inventory()
   - list_stations()
   - find_available_ctid()
   - CSV operations

### Priority 2: Platform Integration (1-2 hours)
Refactor deployment scripts to use new libraries:

1. `scripts/platforms/azuracast.sh`
2. `scripts/platforms/libretime.sh`
3. `scripts/platforms/deploy.sh` (dispatcher)

### Priority 3: Management Tools (2-3 hours)
Extract from `bulk-operations.sh` and create:

1. `scripts/tools/status.sh`
2. `scripts/tools/update.sh`
3. `scripts/tools/backup.sh`
4. `scripts/tools/remove.sh`
5. `scripts/tools/info.sh`
6. `scripts/tools/logs.sh`
7. `scripts/tools/check.sh`

### Priority 4: CLI Integration (1 hour)
Complete `radiostack-cli.sh` to route commands properly

### Priority 5: Documentation (2-3 hours)
Write remaining documentation files

---

## 🚨 Critical Issues to Address

### 1. Configuration Management
**Problem:** Scripts have hardcoded values
**Solution:** Create `/etc/radiostack/radiostack.conf` with defaults

### 2. Error Handling
**Problem:** Some prototype scripts don't handle all error cases
**Solution:** Add proper error trapping and rollback in library functions

### 3. Inventory Format
**Problem:** CSV location and format not standardized
**Solution:** Define schema and location in config

### 4. Testing
**Problem:** No automated tests
**Solution:** Create basic smoke tests for each platform

---

## 💡 Design Decisions to Make

### 1. Configuration File Format
- Option A: Simple bash source file (`.conf`)
- Option B: YAML/JSON (requires parsing)
- **Recommendation:** Bash source file for simplicity

### 2. Inventory Database
- Option A: CSV file (current)
- Option B: SQLite database
- **Recommendation:** Start with CSV, can migrate later

### 3. Container ID Assignment
- Option A: Auto-assign from config ranges
- Option B: User must specify
- **Recommendation:** User specifies with helper to find available

### 4. Update Strategy
- Option A: Update container OS + platform
- Option B: Platform-specific update commands only
- **Recommendation:** Both options via flags

---

## 📊 Completion Estimate

| Component | Complexity | Time Est. | Priority |
|-----------|------------|-----------|----------|
| Library scripts | Medium | 2-3h | ⭐⭐⭐ |
| Platform integration | Low | 1-2h | ⭐⭐⭐ |
| Management tools | Medium | 3-4h | ⭐⭐ |
| CLI completion | Low | 1h | ⭐⭐⭐ |
| Documentation | Medium | 3-4h | ⭐⭐ |
| Config templates | Low | 1h | ⭐ |
| Tests | Medium | 2-3h | ⭐ |
| Examples | Low | 1h | ⭐ |

**Total:** ~15-20 hours for complete production-ready system

---

## 🎯 Recommended Approach

**Session 1 (Now):**
1. Create library structure
2. Split common-functions.sh into modules
3. Test library functions

**Session 2:**
1. Refactor platform scripts
2. Complete CLI routing
3. Test deployments

**Session 3:**
1. Create management tools
2. Add system checks
3. Test all commands

**Session 4:**
1. Write documentation
2. Create templates & examples
3. Final testing

---

## Reference: LibreTime Deployment Notes

The attached "Radio Streaming Server Deployment with Proxmox: Libretime Edition" document provides:

**Useful Information:**
- ✅ Complete LibreTime Docker installation steps
- ✅ Configuration file examples (config.yml structure)
- ✅ CORS configuration patterns
- ✅ Icecast/Shoutcast output configuration
- ✅ Backup/restore procedures

**Integration Needed:**
- Incorporate CORS config into libretime.sh
- Add streaming output configuration prompts
- Include backup/restore in backup.sh tool
- Document DJ input setup in libretime.md

**Already Covered:**
- LXC container creation (we have this in common-functions.sh)
- Docker installation (we have this in setup_container_system)
- Basic deployment flow (covered in deploy-libretime.sh)

---

## Final Recommendation

**Start with modularization:** The prototype scripts work well but need proper organization. Let's:

1. ✅ Create the library structure first
2. ✅ Move working code into proper modules  
3. ✅ Build CLI on top of solid foundation
4. ✅ Add tools and documentation last

This approach ensures:
- No loss of working functionality
- Clean, maintainable code structure
- Easy to extend with new platforms
- Production-ready error handling

**Ready to start implementation?**

# RadioStack Testing Guide

## 🧪 Quick Start Testing

### Run the Automated Test Suite

```bash
cd /mnt/datos1/00-TecnoSoul/00-Servers/RadioStack
sudo ./test-radiostack.sh
```

This will test:
- ✅ All script syntax
- ✅ Help systems
- ✅ Library loading
- ✅ Proxmox environment
- ✅ Inventory system
- ✅ Validation functions

---

## 📋 Manual Testing Checklist

### 1. Test Help Systems (No Root Required)

```bash
# Platform help
./scripts/platforms/azuracast.sh --help
./scripts/platforms/libretime.sh --help
./scripts/platforms/deploy.sh --help

# Tool help
./scripts/tools/status.sh --help
./scripts/tools/update.sh --help
./scripts/tools/backup.sh --help
./scripts/tools/remove.sh --help
./scripts/tools/info.sh --help
./scripts/tools/logs.sh --help
```

### 2. Test Inventory & Status (Requires Root)

```bash
# Initialize inventory
sudo ./scripts/tools/status.sh --all

# System summary
sudo ./scripts/tools/info.sh --summary

# List existing containers
sudo pct list
```

### 3. Test Deployment (Safe Test Container)

**⚠️ IMPORTANT: Use a test container ID that doesn't conflict with production!**

```bash
# Deploy test AzuraCast (small resources)
sudo ./scripts/platforms/azuracast.sh \
  -i 999 \
  -n test-station \
  -c 2 \
  -m 4096 \
  -q 50G \
  -p 199

# Monitor deployment
sudo pct status 999
sudo ./scripts/tools/logs.sh --ctid 999 --follow
```

### 4. Test Management Tools

```bash
# Check status
sudo ./scripts/tools/status.sh --ctid 999

# Get detailed info
sudo ./scripts/tools/info.sh --ctid 999

# View logs
sudo ./scripts/tools/logs.sh --ctid 999 --type both

# Backup
sudo ./scripts/tools/backup.sh --ctid 999

# Update (if deployed successfully)
sudo ./scripts/tools/update.sh --ctid 999
```

### 5. Test Cleanup

```bash
# Remove test container (keep data)
sudo ./scripts/tools/remove.sh --ctid 999

# Remove test container AND data
sudo ./scripts/tools/remove.sh --ctid 999 --data
```

---

## 🔍 Validation Tests

### Test Container ID Validation

```bash
# Should succeed
source scripts/lib/common.sh
validate_ctid 340 && echo "Valid" || echo "Invalid"

# Should fail (too low)
validate_ctid 50 && echo "Valid" || echo "Invalid"

# Should fail (too high)
validate_ctid 9999999 && echo "Valid" || echo "Invalid"
```

### Test IP Validation

```bash
source scripts/lib/common.sh

# Valid IPs
validate_ip 192.168.1.10 && echo "Valid"
validate_ip 10.0.0.1 && echo "Valid"

# Invalid IPs
validate_ip 999.999.999.999 && echo "Valid" || echo "Invalid (expected)"
validate_ip not-an-ip && echo "Valid" || echo "Invalid (expected)"
```

### Test Storage Pool

```bash
source scripts/lib/storage.sh

# Check if pool exists
check_storage_pool hdd-pool && echo "Pool OK" || echo "Pool not found"

# List datasets
list_datasets hdd-pool
```

---

## 🚀 Production Deployment Testing

### Before Production Deployment

1. **Check Requirements:**
   ```bash
   # Verify Proxmox version
   pveversion

   # Check ZFS pools
   zpool list

   # Check available storage
   zfs list

   # Check network bridge
   ip a show vmbr1

   # Check Debian template
   pveam list local
   ```

2. **Plan Container IDs:**
   ```bash
   # Find available CTIDs
   source scripts/lib/inventory.sh

   # For AzuraCast (340-349)
   find_available_ctid 340 349

   # For LibreTime (350-359)
   find_available_ctid 350 359
   ```

3. **Review Configuration:**
   ```bash
   # Check what will be deployed
   ./scripts/platforms/azuracast.sh --help

   # Note the defaults:
   # - AzuraCast: 6 cores, 12GB RAM, 500GB storage
   # - LibreTime: 4 cores, 8GB RAM, 300GB storage
   ```

### Production Deployment Steps

1. **Deploy First Station:**
   ```bash
   sudo ./scripts/platforms/azuracast.sh \
     -i 340 \
     -n main-station \
     -c 6 \
     -m 12288 \
     -q 500G
   ```

2. **Monitor Deployment:**
   ```bash
   # Watch status
   watch -n 2 'sudo pct status 340'

   # Follow logs
   sudo ./scripts/tools/logs.sh --ctid 340 --follow
   ```

3. **Verify Deployment:**
   ```bash
   # Check container status
   sudo ./scripts/tools/status.sh --ctid 340

   # Get detailed info
   sudo ./scripts/tools/info.sh --ctid 340

   # Check if services are running
   sudo pct exec 340 -- docker ps

   # Test web access
   curl -I http://192.168.2.140
   ```

4. **Post-Deployment:**
   ```bash
   # List all stations
   sudo ./scripts/tools/status.sh --all

   # Backup immediately
   sudo ./scripts/tools/backup.sh --ctid 340 --type full

   # Verify inventory
   sudo cat /etc/radiostack/inventory/stations.csv
   ```

---

## 🐛 Troubleshooting Tests

### Test Failed Deployment Cleanup

```bash
# If deployment fails mid-way, cleanup:

# 1. Check what exists
sudo pct status 999
sudo zfs list | grep test-station

# 2. Remove container
sudo ./scripts/tools/remove.sh --ctid 999 --data

# 3. Manual cleanup if needed
sudo zfs destroy -r hdd-pool/container-data/azuracast-media/test-station
```

### Test Inventory Recovery

```bash
# Validate inventory
source scripts/lib/inventory.sh
sudo bash -c 'source scripts/lib/inventory.sh && validate_inventory'

# Cleanup orphaned entries
sudo bash -c 'source scripts/lib/inventory.sh && cleanup_inventory'
```

### Test ZFS Operations

```bash
source scripts/lib/storage.sh

# List all RadioStack datasets
sudo bash -c 'source scripts/lib/storage.sh && list_datasets'

# Get specific dataset info
sudo bash -c 'source scripts/lib/storage.sh && get_dataset_info hdd-pool/container-data'
```

---

## 📊 Expected Results

### Successful Deployment

After successful deployment, you should see:

1. **Container Running:**
   ```
   sudo pct status 340
   # Output: status: running
   ```

2. **Services Active:**
   ```
   sudo pct exec 340 -- docker ps
   # Should show multiple running containers
   ```

3. **Web Interface Accessible:**
   ```
   curl -I http://192.168.2.140
   # Should return HTTP 200 or 302
   ```

4. **In Inventory:**
   ```
   sudo ./scripts/tools/status.sh --all
   # Should show container in green (running)
   ```

5. **Storage Mounted:**
   ```
   sudo pct exec 340 -- df -h | grep azuracast
   # Should show ZFS dataset mounted
   ```

### Common Issues

| Issue | Check | Solution |
|-------|-------|----------|
| Permission denied | Running as root? | Use `sudo` |
| Pool not found | ZFS pool exists? | `zpool list` |
| CTID already exists | Container conflict? | Use different CTID |
| Network timeout | Bridge configured? | Check `ip a show vmbr1` |
| Template missing | Debian template? | `pveam list local` |

---

## ✅ Test Completion Checklist

Before considering testing complete:

- [ ] All automated tests pass
- [ ] Help systems display correctly
- [ ] Inventory system works
- [ ] Can deploy test container
- [ ] Container starts successfully
- [ ] Services running inside container
- [ ] Web interface accessible
- [ ] Management tools work (status, info, logs)
- [ ] Backup creates files
- [ ] Remove cleans up properly
- [ ] No orphaned datasets after removal

---

## 🎯 Next Steps After Testing

Once testing is complete and successful:

1. **Deploy Production Stations**
2. **Configure Nginx Proxy Manager** for public access
3. **Set up automated backups** (cron jobs)
4. **Document your specific configuration**
5. **Create runbooks** for your team

---

## 📞 Getting Help

If you encounter issues during testing:

1. Check logs: `sudo ./scripts/tools/logs.sh --ctid <ID> --type both`
2. Check container: `sudo pct status <ID>`
3. Check inventory: `sudo cat /etc/radiostack/inventory/stations.csv`
4. Review deployment output for errors
5. Open an issue on GitHub with full error output

---

**Happy Testing! 🚀**

# RadioStack Quick Reference

## 🎯 Common Commands

### Deploy New Station

```bash
# AzuraCast (default: 6 cores, 12GB RAM, 500GB storage)
sudo ./scripts/platforms/azuracast.sh -i 340 -n station-name

# LibreTime (default: 4 cores, 8GB RAM, 300GB storage)
sudo ./scripts/platforms/libretime.sh -i 350 -n station-name

# With custom resources
sudo ./scripts/platforms/azuracast.sh -i 341 -n fm-rock \
  -c 8 -m 16384 -q 1T -p 141
```

### Status & Info

```bash
# All stations
sudo ./scripts/tools/status.sh --all

# Specific platform
sudo ./scripts/tools/status.sh --platform azuracast

# Detailed info
sudo ./scripts/tools/info.sh --ctid 340

# System summary
sudo ./scripts/tools/info.sh --summary
```

### Logs

```bash
# View logs (last 50 lines)
sudo ./scripts/tools/logs.sh --ctid 340

# Follow logs (real-time)
sudo ./scripts/tools/logs.sh --ctid 340 --follow

# Container + application logs
sudo ./scripts/tools/logs.sh --ctid 340 --type both

# Specific service
sudo ./scripts/tools/logs.sh --ctid 350 --service libretime
```

### Updates

```bash
# Update single container
sudo ./scripts/tools/update.sh --ctid 340

# Update all AzuraCast
sudo ./scripts/tools/update.sh --platform azuracast

# Update all LibreTime
sudo ./scripts/tools/update.sh --platform libretime

# Update everything (with confirmation)
sudo ./scripts/tools/update.sh --all
```

### Backups

```bash
# Container backup (vzdump)
sudo ./scripts/tools/backup.sh --ctid 340

# Application backup only
sudo ./scripts/tools/backup.sh --ctid 340 --type application

# Full backup (container + ZFS snapshot)
sudo ./scripts/tools/backup.sh --ctid 340 --type full

# Backup all containers
sudo ./scripts/tools/backup.sh --all

# List backups
sudo ./scripts/tools/backup.sh --list
sudo ./scripts/tools/backup.sh --list --ctid 340
```

### Remove

```bash
# Remove container (keep data)
sudo ./scripts/tools/remove.sh --ctid 340

# Remove container AND data
sudo ./scripts/tools/remove.sh --ctid 340 --data

# Emergency: remove ALL (requires confirmation)
sudo ./scripts/tools/remove.sh --purge-all
```

---

## 📁 File Locations

```
/etc/radiostack/
├── radiostack.conf              # Main configuration
└── inventory/
    ├── stations.csv             # Station inventory
    └── backups/                 # Inventory backups

/hdd-pool/container-data/
├── azuracast-media/
│   └── station-name/           # Media storage (ZFS)
└── libretime-media/
    └── station-name/           # Media storage (ZFS)

Container installations:
├── AzuraCast: /var/azuracast
└── LibreTime: /opt/libretime
```

---

## 🔧 Container Management

### Direct Container Operations

```bash
# Status
sudo pct status 340

# Start/Stop/Restart
sudo pct start 340
sudo pct stop 340
sudo pct restart 340

# Enter container
sudo pct enter 340

# Execute command
sudo pct exec 340 -- command

# View config
sudo pct config 340
```

### Inside Container

```bash
# AzuraCast commands
cd /var/azuracast
./docker.sh update
./docker.sh backup
./docker.sh restore
./docker.sh logs

# LibreTime commands
cd /opt/libretime
docker-compose ps
docker-compose logs
docker-compose restart
```

---

## 📊 Monitoring

### Container Resources

```bash
# CPU/Memory usage
sudo pct status 340
sudo pct exec 340 -- top -bn1

# Disk usage
sudo pct exec 340 -- df -h

# Docker containers
sudo pct exec 340 -- docker ps
sudo pct exec 340 -- docker stats --no-stream
```

### ZFS Storage

```bash
# Dataset info
sudo zfs list | grep container-data

# Specific dataset
sudo zfs list hdd-pool/container-data/azuracast-media/station-name

# Compression ratio
sudo zfs get compressratio hdd-pool/container-data

# Usage with quota
sudo zfs get used,avail,quota hdd-pool/container-data/azuracast-media/station-name
```

### Network

```bash
# Get container IP
sudo ./scripts/tools/info.sh --ctid 340 | grep IP

# Test connectivity
ping 192.168.2.140
curl -I http://192.168.2.140

# Inside container
sudo pct exec 340 -- ip a
sudo pct exec 340 -- netstat -tlnp
```

---

## 🔍 Troubleshooting

### Container Won't Start

```bash
# Check status
sudo pct status 340

# Check logs
sudo journalctl -u pve-container@340

# Try start with console
sudo pct start 340 --console

# Check config
sudo pct config 340
```

### Service Not Running

```bash
# Check Docker
sudo pct exec 340 -- docker ps
sudo pct exec 340 -- systemctl status docker

# AzuraCast specific
sudo pct exec 340 -- docker-compose -f /var/azuracast/docker-compose.yml ps

# LibreTime specific
sudo pct exec 340 -- docker-compose -f /opt/libretime/docker-compose.yml ps
```

### Web Interface Not Accessible

```bash
# Check if container is running
sudo pct status 340

# Check IP
sudo ./scripts/tools/info.sh --ctid 340

# Test from host
curl -v http://192.168.2.140

# Check inside container
sudo pct exec 340 -- curl -I localhost
sudo pct exec 340 -- netstat -tlnp | grep 80
```

### Storage Issues

```bash
# Check quota
sudo zfs get quota,used,available hdd-pool/container-data/azuracast-media/station

# Check mount
sudo pct exec 340 -- df -h | grep azuracast

# Check permissions
sudo pct exec 340 -- ls -la /var/azuracast
```

---

## 📝 Default Container IDs

**Recommended ranges:**

| Platform | Range | Example |
|----------|-------|---------|
| AzuraCast | 340-349 | 340 = main, 341 = backup |
| LibreTime | 350-359 | 350 = fm, 351 = am |
| Icecast | 360-369 | 360 = relay1 |
| Test | 990-999 | 999 = testing |

---

## 🌐 Default Resources

### AzuraCast Defaults
- **Cores:** 6
- **Memory:** 12288 MB (12 GB)
- **Swap:** 3072 MB (3 GB)
- **Storage Quota:** 500G
- **Recordsize:** 128k
- **IP Pattern:** 192.168.2.{CTID}

### LibreTime Defaults
- **Cores:** 4
- **Memory:** 8192 MB (8 GB)
- **Swap:** 2048 MB (2 GB)
- **Storage Quota:** 300G
- **Recordsize:** 128k
- **IP Pattern:** 192.168.2.{CTID}

---

## 🔐 Security

### Container Credentials

**AzuraCast:**
- Created during web setup wizard
- No default credentials

**LibreTime:**
- Default: admin / admin
- **⚠️ CHANGE IMMEDIATELY!**

### Access Control

```bash
# Container is unprivileged (UID mapping)
# Host UID 100000 = Container UID 0

# Check from host
ls -ln /hdd-pool/container-data/azuracast-media/station
# Should show 100000:100000

# Inside container
sudo pct exec 340 -- ls -la /var/azuracast
# Shows as root:root
```

---

## 🚀 Performance Tuning

### CPU Priority

```bash
# Set CPU units (default: 1024)
sudo pct set 340 --cpuunits 2048  # Higher priority
```

### Memory Limits

```bash
# Increase memory
sudo pct set 340 --memory 16384

# Increase swap
sudo pct set 340 --swap 4096
```

### ZFS Tuning

```bash
# Change recordsize (better for small files)
sudo zfs set recordsize=64k hdd-pool/container-data/azuracast-media/station

# Change compression
sudo zfs set compression=zstd hdd-pool/container-data/azuracast-media/station

# Increase quota
sudo ./scripts/lib/storage.sh  # Use resize_dataset function
# Or manually:
sudo zfs set quota=1T hdd-pool/container-data/azuracast-media/station
```

---

## 🔄 Maintenance Tasks

### Daily

```bash
# Check status
sudo ./scripts/tools/status.sh --all
```

### Weekly

```bash
# Backup all stations
sudo ./scripts/tools/backup.sh --all

# Check for updates
sudo ./scripts/tools/update.sh --platform azuracast
sudo ./scripts/tools/update.sh --platform libretime
```

### Monthly

```bash
# Validate inventory
source scripts/lib/inventory.sh
sudo bash -c 'source scripts/lib/inventory.sh && validate_inventory'

# Cleanup orphaned entries
sudo bash -c 'source scripts/lib/inventory.sh && cleanup_inventory'

# Check ZFS health
sudo zpool status
sudo zpool list
```

---

## 📞 Help

```bash
# Script help
./scripts/platforms/azuracast.sh --help
./scripts/platforms/libretime.sh --help
./scripts/tools/status.sh --help
./scripts/tools/update.sh --help
./scripts/tools/backup.sh --help
./scripts/tools/remove.sh --help
./scripts/tools/info.sh --help
./scripts/tools/logs.sh --help

# Run tests
sudo ./test-radiostack.sh

# Full documentation
cat docs/getting-started.md
cat TESTING.md
```

---

**RadioStack v1.0** | Built with ❤️ for radio broadcasters

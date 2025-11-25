# Getting Started with RadioStack

This guide will walk you through installing RadioStack and deploying your first radio station.

## Prerequisites

Before installing RadioStack, ensure your Proxmox host meets these requirements:

### System Requirements

- Proxmox VE 8.0+ or 9.0+
- Root or sudo access
- Internet connectivity for downloading packages

### Storage Requirements

RadioStack uses a two-tier storage strategy:

1. **Fast Storage (NVMe/SSD)** - for container OS and applications
   - Pool name: `data` (or your fast pool)
   - Minimum: 100GB per container
   
2. **Bulk Storage (HDD)** - for media libraries and archives
   - Pool name: `hdd-pool` (or your bulk pool)
   - Minimum: 200GB per station (500GB+ recommended)

### Network Requirements

- Internal network bridge configured (typically `vmbr1`)
- IP range available for containers (e.g., 192.168.2.0/24)
- Optional: Public IP or reverse proxy for external access

### Template Requirements

Download Debian 13 LXC template:
```bash
pveam update
pveam download local debian-13-standard_13.1-2_amd64.tar.zst
```

## Installation

### Step 1: Clone Repository
```bash
cd /opt
git clone https://github.com/yourusername/radiostack.git
cd radiostack
```

### Step 2: Run Installer
```bash
chmod +x install.sh
./install.sh
```

The installer will:
- Check system requirements
- Install dependencies
- Set up configuration directory at `/etc/radiostack`
- Create symlink to `/usr/local/bin/radiostack`
- Initialize inventory database

### Step 3: Configure RadioStack

Edit the configuration file:
```bash
nano /etc/radiostack/radiostack.conf
```

Key settings to configure:
```bash
# Storage pools
FAST_STORAGE_POOL="data"          # NVMe/SSD pool
BULK_STORAGE_POOL="hdd-pool"      # HDD pool

# Network settings
NETWORK_BRIDGE="vmbr1"
NETWORK_GATEWAY="192.168.2.1"
NETWORK_SUBNET="192.168.2.0/24"
DNS_SERVERS="8.8.8.8"

# Default resources (can be overridden per deployment)
DEFAULT_AZURACAST_CORES=6
DEFAULT_AZURACAST_MEMORY=12288
DEFAULT_AZURACAST_QUOTA="500G"

DEFAULT_LIBRETIME_CORES=4
DEFAULT_LIBRETIME_MEMORY=8192
DEFAULT_LIBRETIME_QUOTA="300G"
```

### Step 4: Verify Installation
```bash
radiostack version
radiostack check
```

The `check` command validates:
- ✅ Proxmox version compatible
- ✅ Storage pools exist
- ✅ Network configured
- ✅ Templates available
- ✅ Required tools installed

## First Deployment

### Deploy AzuraCast Station
```bash
# Basic deployment (uses defaults from config)
radiostack deploy azuracast \
  --ctid 340 \
  --name main-station

# Custom deployment
radiostack deploy azuracast \
  --ctid 341 \
  --name fm-rock \
  --cores 8 \
  --memory 16384 \
  --quota 1T \
  --ip-suffix 141
```

Wait 2-3 minutes for installation to complete.

### Access Your Station
```bash
# Get station info
radiostack info --ctid 340

# Output:
# Station: main-station (AzuraCast)
# Container ID: 340
# IP Address: 192.168.2.140
# Status: Running
# Access: http://192.168.2.140
```

Open browser to `http://192.168.2.140` and complete AzuraCast setup:
1. Create super administrator account
2. Configure first radio station
3. Set base URL and HTTPS settings

### Deploy LibreTime Station
```bash
radiostack deploy libretime \
  --ctid 350 \
  --name community-radio

# Access at http://192.168.2.150
# Default credentials: admin / admin (change immediately!)
```

## Next Steps

### Configure Reverse Proxy

For public access, configure Nginx Proxy Manager:
```bash
# In NPM:
# Domain: radio.yourdomain.com
# Forward to: 192.168.2.140:80
# SSL: Request Let's Encrypt certificate
```

See [Nginx Proxy Manager Guide](nginx-proxy-manager.md) for details.

### Set Up Backups
```bash
# Configure automated daily backups
radiostack backup configure \
  --schedule daily \
  --retention 7 \
  --storage hdd-pool/backups

# Manual backup
radiostack backup --ctid 340
```

### Monitor Your Stations
```bash
# View status of all stations
radiostack status

# Monitor specific station
radiostack monitor --ctid 340

# View logs
radiostack logs --ctid 340 --follow
```

## Common Tasks

### Update Station
```bash
# Update single station
radiostack update --ctid 340

# Update all AzuraCast stations
radiostack update azuracast --all

# Update all stations
radiostack update --all
```

### Add More Stations
```bash
# Deploy multiple stations quickly
for i in {1..5}; do
  radiostack deploy azuracast \
    --ctid $((340 + i)) \
    --name "station-$i" \
    --cores 4 \
    --memory 8192
done
```

### Remove Station
```bash
# Stop and remove container (keeps data)
radiostack remove --ctid 340

# Remove container and all data (WARNING: irreversible!)
radiostack remove --ctid 340 --purge-data
```

## Getting Help

### Built-in Help
```bash
# General help
radiostack help

# Command-specific help
radiostack deploy --help
radiostack update --help
```

### Documentation

- [Deployment Guide](deployment-guide.md) - Advanced deployment patterns
- [AzuraCast Guide](azuracast.md) - AzuraCast-specific documentation
- [LibreTime Guide](libretime.md) - LibreTime-specific documentation
- [Troubleshooting](troubleshooting.md) - Common issues and solutions

### Support

- GitHub Issues: [Report bugs or request features](https://github.com/yourusername/radiostack/issues)
- Discussions: [Ask questions or share tips](https://github.com/yourusername/radiostack/discussions)
- Email: support@radiostack.io

## What's Next?

Now that you have RadioStack installed and your first station running:

1. **Explore features** - Try bulk operations, backups, monitoring
2. **Read the guides** - Deep dive into platform-specific documentation
3. **Deploy more stations** - Scale your radio infrastructure
4. **Customize** - Adapt RadioStack to your specific needs
5. **Contribute** - Share your improvements with the community

Happy broadcasting! 📻
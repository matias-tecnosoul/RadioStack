#!/bin/bash
# RadioStack Installer
# Version: 1.0.0

set -e

RADIOSTACK_DIR="/opt/radiostack"
CONFIG_DIR="/etc/radiostack"
BIN_LINK="/usr/local/bin/radiostack"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_step() { echo -e "${BLUE}[STEP]${NC} $1"; }

# Check if running as root
if [[ $EUID -ne 0 ]]; then
    log_error "This installer must be run as root"
    exit 1
fi

# Welcome banner
clear
cat << "EOF"
╦═╗┌─┐┌┬┐┬┌─┐╔═╗┌┬┐┌─┐┌─┐┬┌─
╠╦╝├─┤ ││││ │╚═╗ │ ├─┤│  ├┴┐
╩╚═┴ ┴─┴┘┴└─┘╚═╝ ┴ ┴ ┴└─┘┴ ┴
EOF

echo ""
echo "RadioStack Installer v1.0.0"
echo "Unified Radio Platform Deployment for Proxmox"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Step 1: Check requirements
log_step "Checking system requirements..."

# Check Proxmox
if ! command -v pveversion &> /dev/null; then
    log_error "Proxmox VE not detected. RadioStack requires Proxmox."
    exit 1
fi

PROXMOX_VERSION=$(pveversion | awk '{print $2}' | cut -d'/' -f1)
log_info "Proxmox VE $PROXMOX_VERSION detected"

# Check required commands
REQUIRED_COMMANDS="pct qm zfs pvesm iptables wget curl"
for cmd in $REQUIRED_COMMANDS; do
    if ! command -v $cmd &> /dev/null; then
        log_error "Required command not found: $cmd"
        exit 1
    fi
done

log_info "All required commands available"

# Step 2: Create directories
log_step "Creating directories..."

mkdir -p "$CONFIG_DIR"
mkdir -p "$CONFIG_DIR/inventory"
mkdir -p "$CONFIG_DIR/backups"

log_info "Configuration directory: $CONFIG_DIR"

# Step 3: Copy files
log_step "Installing RadioStack files..."

# Copy scripts
cp -r scripts "$RADIOSTACK_DIR/"
chmod +x "$RADIOSTACK_DIR/scripts/"*.sh
chmod +x "$RADIOSTACK_DIR/scripts/lib/"*.sh
chmod +x "$RADIOSTACK_DIR/scripts/platforms/"*.sh
chmod +x "$RADIOSTACK_DIR/scripts/tools/"*.sh

# Copy configs and templates
cp -r configs "$CONFIG_DIR/"
cp -r templates "$CONFIG_DIR/"

# Create main CLI wrapper
cat > "$RADIOSTACK_DIR/radiostack" << 'EOFCLI'
#!/bin/bash
# RadioStack CLI Entry Point
RADIOSTACK_ROOT="/opt/radiostack"
source "$RADIOSTACK_ROOT/scripts/radiostack-cli.sh" "$@"
EOFCLI

chmod +x "$RADIOSTACK_DIR/radiostack"

# Create symlink
ln -sf "$RADIOSTACK_DIR/radiostack" "$BIN_LINK"

log_info "RadioStack installed to $RADIOSTACK_DIR"
log_info "CLI available at: radiostack"

# Step 4: Initialize configuration
log_step "Initializing configuration..."

# Create default config if doesn't exist
if [[ ! -f "$CONFIG_DIR/radiostack.conf" ]]; then
    cat > "$CONFIG_DIR/radiostack.conf" << 'EOFCONF'
# RadioStack Configuration
# Edit this file to match your Proxmox setup

# Storage pools
FAST_STORAGE_POOL="data"
BULK_STORAGE_POOL="hdd-pool"

# Network settings
NETWORK_BRIDGE="vmbr1"
NETWORK_GATEWAY="192.168.2.1"
NETWORK_SUBNET="192.168.2.0/24"
DNS_SERVERS="8.8.8.8"
SEARCH_DOMAIN="tecnosoul.com.ar"

# Container ID ranges
AZURACAST_ID_START=340
LIBRETIME_ID_START=350
ICECAST_ID_START=370

# Default resources - AzuraCast
DEFAULT_AZURACAST_CORES=6
DEFAULT_AZURACAST_MEMORY=12288
DEFAULT_AZURACAST_QUOTA="500G"

# Default resources - LibreTime
DEFAULT_LIBRETIME_CORES=4
DEFAULT_LIBRETIME_MEMORY=8192
DEFAULT_LIBRETIME_QUOTA="300G"

# Backup settings
BACKUP_STORAGE="hdd-pool/backups-zfs/radiostack"
BACKUP_RETENTION_DAYS=30

# Templates
DEBIAN_TEMPLATE="debian-13-standard_13.1-2_amd64.tar.zst"
EOFCONF
    log_info "Created default configuration"
else
    log_warn "Configuration already exists, skipping"
fi

# Create inventory file
if [[ ! -f "$CONFIG_DIR/inventory/stations.csv" ]]; then
    echo "CTID,Type,Hostname,IP,Description,Created,Status" > "$CONFIG_DIR/inventory/stations.csv"
    log_info "Initialized inventory database"
fi

# Step 5: Verify installation
log_step "Verifying installation..."

"$BIN_LINK" version &> /dev/null && log_info "CLI working correctly" || log_error "CLI test failed"

# Installation complete
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
log_info "✅ RadioStack installation complete!"
echo ""
echo "Next steps:"
echo "  1. Review configuration: nano $CONFIG_DIR/radiostack.conf"
echo "  2. Check system: radiostack check"
echo "  3. Deploy first station: radiostack deploy azuracast --ctid 340 --name main"
echo ""
echo "Documentation: https://radiostack.io/docs"
echo "Get help: radiostack help"
echo ""
echo "Happy broadcasting! 📻"
echo ""
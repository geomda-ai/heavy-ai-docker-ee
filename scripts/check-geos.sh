#!/bin/bash

# Script to automatically download and install GEOS libraries
# Based on documentation for HeavyDB Release v8.4

echo "Checking GEOS libraries installation..."

# GEOS directory path using environment variable
GEOS_DIR="${HEAVY_CONFIG_BASE}/libgeos"
echo "Using GEOS directory: $GEOS_DIR"

# Function to detect OS and architecture
detect_os_arch() {
    # Detect OS
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS_NAME=$ID
        OS_VERSION=$VERSION_ID
    elif [ -f /etc/redhat-release ]; then
        OS_NAME="rhel"
        OS_VERSION=$(grep -oE '[0-9]+\.[0-9]+' /etc/redhat-release | cut -d. -f1)
    else
        OS_NAME="unknown"
        OS_VERSION="unknown"
    fi

    # Detect architecture
    ARCH=$(uname -m)
    if [ "$ARCH" = "x86_64" ]; then
        ARCH="x86_64"
    elif [ "$ARCH" = "aarch64" ] || [ "$ARCH" = "arm64" ]; then
        ARCH="aarch64"
    else
        ARCH="unknown"
    fi

    # Map OS to the closest match for GEOS packages
    if [[ "$OS_NAME" == "ubuntu" ]]; then
        if [[ "$OS_VERSION" == 22.* ]] || [[ "$OS_VERSION" == 20.* ]]; then
            OS_MAPPED="ubuntu22.04"
        else
            OS_MAPPED="ubuntu22.04"  # Default to Ubuntu 22.04 for other Ubuntu versions
        fi
    elif [[ "$OS_NAME" == "debian" ]]; then
        OS_MAPPED="ubuntu22.04"  # Use Ubuntu package for Debian
    elif [[ "$OS_NAME" == "rhel" ]] || [[ "$OS_NAME" == "centos" ]] || [[ "$OS_NAME" == "rocky" ]] || [[ "$OS_NAME" == "almalinux" ]]; then
        OS_MAPPED="rocky8.10"
    else
        # Default to Ubuntu for unknown distributions
        OS_MAPPED="ubuntu22.04"
    fi

    echo "Detected OS: $OS_NAME $OS_VERSION (mapped to $OS_MAPPED)"
    echo "Detected architecture: $ARCH"
}

# Function to download and install GEOS libraries
download_install_geos() {
    local os=$1
    local arch=$2
    local date="20250107"
    
    # Use the Rocky date for Rocky Linux
    if [ "$os" == "rocky8.10" ]; then
        date="20250113"
    fi
    
    local package_url="http://dependencies.mapd.com/lgpl/heavydb-libgeos-${os}-${arch}-${date}.tar.xz"
    local temp_dir=$(mktemp -d)
    local package_file="${temp_dir}/heavydb-libgeos.tar.xz"
    
    echo "Downloading GEOS package from: $package_url"
    
    # Check if wget is available, if not try to install it
    if ! command -v wget &> /dev/null; then
        echo "wget not found, attempting to install..."
        if command -v apt-get &> /dev/null; then
            apt-get update && apt-get install -y wget
        elif command -v yum &> /dev/null; then
            yum install -y wget
        elif command -v dnf &> /dev/null; then
            dnf install -y wget
        else
            echo "ERROR: Cannot install wget. Please install it manually and try again."
            return 1
        fi
    fi
    
    # Download the package
    if ! wget -q "$package_url" -O "$package_file"; then
        echo "ERROR: Failed to download GEOS package from $package_url"
        return 1
    fi
    
    # Create the GEOS directory if it doesn't exist
    mkdir -p "$GEOS_DIR" && chmod 755 "$GEOS_DIR"
    
    # Extract the package
    echo "Extracting GEOS package to $GEOS_DIR"
    if ! tar -xf "$package_file" -C "$GEOS_DIR"; then
        echo "ERROR: Failed to extract GEOS package"
        return 1
    fi
    
    # Clean up
    rm -rf "$temp_dir"
    
    echo "GEOS libraries successfully installed to $GEOS_DIR"
    return 0
}

# Create the GEOS directory if it doesn't exist
if [ ! -d "$GEOS_DIR" ]; then
    echo "Creating GEOS directory: $GEOS_DIR"
    mkdir -p "$GEOS_DIR" && chmod 755 "$GEOS_DIR"
fi

# Check for the presence of GEOS libraries
GEOS_LIBS_FOUND=0
if ls $GEOS_DIR/libgeos*.so* &> /dev/null; then
    GEOS_LIBS_FOUND=1
fi

if [ $GEOS_LIBS_FOUND -eq 0 ]; then
    echo "GEOS libraries not found. Attempting to download and install..."
    detect_os_arch
    
    if [ "$ARCH" == "unknown" ]; then
        echo "ERROR: Unsupported architecture. Cannot install GEOS libraries automatically."
        exit 1
    fi
    
    if download_install_geos "$OS_MAPPED" "$ARCH"; then
        echo "GEOS libraries installation completed successfully."
    else
        echo "ERROR: Failed to install GEOS libraries."
        echo "Please download and install manually:"
        echo "  - http://dependencies.mapd.com/lgpl/heavydb-libgeos-ubuntu22.04-x86_64-20250107.tar.xz (for Docker x86)"
        echo "  - http://dependencies.mapd.com/lgpl/heavydb-libgeos-ubuntu22.04-aarch64-20250107.tar.xz (for Docker ARM)"
        echo "  - http://dependencies.mapd.com/lgpl/heavydb-libgeos-rocky8.10-x86_64-20250113.tar.xz (for Red Hat 8.x)"
        exit 1
    fi
else
    echo "SUCCESS: GEOS libraries found in $GEOS_DIR."
    echo "Found the following GEOS libraries:"
    ls -la $GEOS_DIR/libgeos*.so*
fi

echo "GEOS check completed."

#!/bin/bash

echo "Creating required directories..."

# Create HeavyAI directories with proper permissions
mkdir -p "${HEAVY_STORAGE_DIR}" && chmod 755 "${HEAVY_STORAGE_DIR}"
mkdir -p "${HEAVYDB_IMPORT_PATH}" && chmod 755 "${HEAVYDB_IMPORT_PATH}"
mkdir -p "${HEAVYDB_EXPORT_PATH}" && chmod 755 "${HEAVYDB_EXPORT_PATH}"
mkdir -p "${HEAVY_IQ_LOCATION}/log" && chmod 755 "${HEAVY_IQ_LOCATION}/log"
mkdir -p "${HEAVY_IMMERSE_LOCATION}" && chmod 755 "${HEAVY_IMMERSE_LOCATION}"

# Create directories for processed configs
mkdir -p "$(dirname ${HEAVYDB_CONFIG_FILE})" && chmod 755 "$(dirname ${HEAVYDB_CONFIG_FILE})"
mkdir -p "$(dirname ${HEAVY_IMMERSE_CONFIG_FILE})" && chmod 755 "$(dirname ${HEAVY_IMMERSE_CONFIG_FILE})"
mkdir -p "$(dirname ${HEAVY_IQ_CONFIG_FILE})" && chmod 755 "$(dirname ${HEAVY_IQ_CONFIG_FILE})"
mkdir -p "$(dirname ${IMMERSE_SERVERS_JSON})" && chmod 755 "$(dirname ${IMMERSE_SERVERS_JSON})"

echo "Processing config files..."

# Process heavydb.conf
envsubst < /configs/heavydb.conf > "${HEAVYDB_CONFIG_FILE}"
chmod 644 "${HEAVYDB_CONFIG_FILE}"

# Process immerse.conf
envsubst < /configs/immerse.conf > "${HEAVY_IMMERSE_CONFIG_FILE}"
chmod 644 "${HEAVY_IMMERSE_CONFIG_FILE}"

# Process iq.conf
envsubst < /configs/iq.conf > "${HEAVY_IQ_CONFIG_FILE}"
chmod 644 "${HEAVY_IQ_CONFIG_FILE}"

# Process servers.json
envsubst < /configs/servers.json > "${IMMERSE_SERVERS_JSON}"
chmod 644 "${IMMERSE_SERVERS_JSON}"

echo "Config files processed"

# Check GEOS installation
if [ -f "/check-geos.sh" ]; then
    echo "Checking GEOS installation..."
    chmod +x /check-geos.sh
    /check-geos.sh
fi

# Keep container running
tail -f /dev/null

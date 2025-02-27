#!/bin/bash

echo "Creating required directories..."

# # Create HeavyAI directories with proper permissions
mkdir -p "${HEAVY_STORAGE_DIR}" && chmod 755 "${HEAVY_STORAGE_DIR}"
mkdir -p "${HEAVYDB_IMPORT_PATH}" && chmod 755 "${HEAVYDB_IMPORT_PATH}"
mkdir -p "${HEAVYDB_EXPORT_PATH}" && chmod 755 "${HEAVYDB_EXPORT_PATH}"
mkdir -p "${HEAVY_IQ_LOCATION}/log" && chmod 755 "${HEAVY_IQ_LOCATION}/log"
mkdir -p "${HEAVY_IMMERSE_LOCATION}" && chmod 755 "${HEAVY_IMMERSE_LOCATION}"

# # Create directories for processed configs
mkdir -p "$(dirname ${HEAVYDB_CONFIG_FILE})" && chmod 755 "$(dirname ${HEAVYDB_CONFIG_FILE})"
mkdir -p "$(dirname ${HEAVY_IMMERSE_CONFIG_FILE})" && chmod 755 "$(dirname ${HEAVY_IMMERSE_CONFIG_FILE})"
mkdir -p "$(dirname ${HEAVY_IQ_CONFIG_FILE})" && chmod 755 "$(dirname ${HEAVY_IQ_CONFIG_FILE})"
mkdir -p "$(dirname ${IMMERSE_SERVERS_JSON})" && chmod 755 "$(dirname ${IMMERSE_SERVERS_JSON})"

# echo "Processing config files..."

# # Process heavydb.conf
envsubst < /configs/heavydb.conf > "${HEAVYDB_CONFIG_FILE}"
chmod 644 "${HEAVYDB_CONFIG_FILE}"

# # Process immerse.conf
envsubst < /configs/immerse.conf > "${HEAVY_IMMERSE_CONFIG_FILE}"
chmod 644 "${HEAVY_IMMERSE_CONFIG_FILE}"

# # Process iq.conf
envsubst < /configs/iq.conf > "${HEAVY_IQ_CONFIG_FILE}"
chmod 644 "${HEAVY_IQ_CONFIG_FILE}"

# Process servers.json with custom variable substitution
process_servers_json() {
  local temp_file=$(mktemp)
  
  # Copy the original file
  cp /configs/servers.json "$temp_file"
  
  # Process variable substitutions
  # Format: "${json-object-from-file('path/to/file.json')}"
  # or: "${string-json-object-from-file(path/to/file.json)}"
  
  # Find all instances of "${json-object-from-file('...')}"
  grep -o "\"\${json-object-from-file('[^']*')}\"" "$temp_file" | while read -r match; do
    # Extract the file path
    file_path=$(echo "$match" | sed "s/\"\${json-object-from-file('\([^']*\)')}\"//")
    
    # Check if the file exists
    if [ -f "/configs/$file_path" ]; then
      # Read the file content
      file_content=$(cat "/configs/$file_path")
      
      # Replace the variable with the file content
      sed -i.bak "s|\"\${json-object-from-file('$file_path')}\"|$file_content|g" "$temp_file"
    else
      echo "Warning: File not found: /configs/$file_path"
    fi
  done
  
  # Find all instances of "${string-json-object-from-file(...)}"
  grep -o "\"\${string-json-object-from-file('[^']*')}\"" "$temp_file" | while read -r match; do
    # Extract the file path
    file_path=$(echo "$match" | sed "s/\"\${string-json-object-from-file('\([^']*\)')}\"//")
    
    # Check if the file exists
    if [ -f "/configs/$file_path" ]; then
      # Read the file content and escape it for JSON string
      file_content=$(cat "/configs/$file_path" | tr -d '\n' | sed 's/"/\\"/g')
      
      # Replace the variable with the file content
      sed -i.bak "s|\"\${string-json-object-from-file('$file_path')}\"|\"$file_content\"|g" "$temp_file"
    else
      echo "Warning: File not found: /configs/$file_path"
    fi
  done
  
  # Apply environment variable substitution
  envsubst < "$temp_file" > "${IMMERSE_SERVERS_JSON}"
  chmod 644 "${IMMERSE_SERVERS_JSON}"
  
  # Clean up
  rm -f "$temp_file" "$temp_file.bak"
}

process_servers_json

echo "Config files processed"

# Keep container running
tail -f /dev/null

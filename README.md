# HeavyAI Enterprise Docker Stack

A production-ready Docker Compose setup for HeavyAI Enterprise with JupyterHub integration. This stack provides a complete environment running HeavyDB, HeavyIQ, Immerse, and JupyterHub with GPU support.

## Key Features

- 🚀 Microservices architecture with Docker Compose
- 🔒 Built-in SSL/TLS via Caddy reverse proxy
- 🎯 Single domain with path-based routing
- 🎮 NVIDIA GPU acceleration for HeavyDB
- 📊 Integrated JupyterHub for data analysis
- 🔌 ODBC driver support for external connections
- 🔄 Automatic configuration management
- 💾 Persistent storage with Docker volumes
- ⚙️ Environment-based configuration

## Prerequisites

- Ubuntu 22.04 or later
- Docker Engine 20.10+
- Docker Compose V2 (not "docker-compose" command)
- NVIDIA GPU with drivers installed (`watch nvidia-smi`)
- NVIDIA Container Toolkit
- Domain name pointed to your server (A Record in DNS)

## Directory Structure

```
.
├── configs/                   # Configuration files
│   ├── Caddyfile             # Caddy reverse proxy config
│   ├── heavydb.conf          # HeavyDB configuration
│   ├── immerse.conf          # Immerse configuration
│   ├── iq.conf              # HeavyIQ configuration
│   ├── jupyterhub/          # JupyterHub configs
│   │   ├── Dockerfile.jupyterhub
│   │   └── jupyterhub_config.py
│   ├── servers.json         # Immerse servers configuration
│   ├── odbcinst.ini        # ODBC driver configuration
│   └── odbc.ini            # ODBC connection configuration
├── scripts/                  # Utility scripts
│   └── config-watcher.sh    # Configuration management script
├── Dockerfile.odbc          # Custom Dockerfile for ODBC support
├── docker-compose.yml       # Main compose file
├── .env.example            # Example environment variables
└── README.md              # Documentation
```

## Components and Services

| Service     | Description | Internal Port |
|------------|-------------|---------------|
| HeavyDB    | Main database engine with GPU acceleration | 6274 |
| Immerse    | Web-based visualization interface | 6273 |
| HeavyIQ    | Query engine and data processing | 6275 |
| JupyterHub | Interactive Python notebooks environment | 8000 |
| Caddy      | Reverse proxy with automatic HTTPS | 80, 443 |
| Config Watcher | Configuration management service | - |


## Quick Start

1. Clone the repository:
```bash
git clone https://github.com/geomda-ai/heavy-ai-docker-ee.git
cd heavy-ai-docker-ee
```

2. Configure your environment:
```bash
cp .env.example .env
# Edit .env with your settings
nano .env
```

3. Change your domain name and email address in the `.env` file:
```bash
DOMAIN=yourdomain.com
EMAIL=your_email_address
```
ctrl+x # Save and close nano

4. Start the stack:
```bash
docker compose up -d
```

## Services and Ports

| Service     | Internal Port | Path     |
|------------|--------------|----------|
| HeavyDB    | 6274        | -        |
| Immerse    | 6273        | /        |
| HeavyIQ    | 6275        | -        |
| JupyterHub | 8000        | /jupyter |

## Environment Variables

Key environment variables that need to be configured:

```bash
# Domain name
DOMAIN=example.com

# Heavy.AI image
HEAVYAI_IMAGE=heavyai/heavyai-ee-cuda
HEAVYAI_VERSION=latest

# GPU configuration
GPU_COUNT=all
GPU_DEVICE_IDS=0
```

See `.env.example` for all available options.

## URLs

After deployment, services will be available at:

- Immerse UI: `https://your-domain.com/`
- JupyterHub: `https://your-domain.com/jupyter`


## Security

- All services communicate over an internal Docker network
- SSL/TLS certificates are automatically managed by Caddy
- Services are not exposed directly, only through the reverse proxy
- JupyterHub uses authentication (configure in production it's dummy user based for now)

## Data Persistence

All data is stored in Docker volumes and mounted directories under `/var/lib/heavyai`:

- `/var/lib/heavyai/storage/`: Main HeavyDB storage
  - `/var/lib/(heavyai/immerse)/storage/import/`: Data import directory
  - `/var/lib/(heavyai/immerse)/storage/export/`: Data export directory
- `/var/lib/heavyai/iq/`: HeavyIQ data and configuration
- `/var/lib/heavyai/immerse/`: Immerse data and configuration

Additional volumes:
- `jupyterhub-data`: JupyterHub user data and configurations
- `caddy-data`: Caddy SSL certificates
- `caddy-config`: Caddy server configuration

These paths can be customized through environment variables in the `.env` file:
```bash
HEAVY_CONFIG_BASE=/var/lib/heavyai
HEAVY_STORAGE_DIR=${HEAVY_CONFIG_BASE}/storage
HEAVYDB_IMPORT_PATH=${HEAVY_STORAGE_DIR}/import
HEAVYDB_EXPORT_PATH=${HEAVY_STORAGE_DIR}/export
HEAVY_IQ_LOCATION=${HEAVY_CONFIG_BASE}/iq
HEAVY_IMMERSE_LOCATION=${HEAVY_CONFIG_BASE}/immerse
```

## Development

To modify configurations:

1. Edit files in the `configs/` directory
2. stop and start the affected service:
```bash
docker compose stop <service-name>
docker compose start <service-name>
```

## Production Deployment

For production deployment:

1. Use strong passwords
2. Configure proper authentication for JupyterHub
3. Set up regular backups of the data directory
4. Configure appropriate resource limits
5. Use a proper SSL provider
6. Set up monitoring and logging

## Troubleshooting

Common issues and solutions:

1. GPU not available:
   - Check NVIDIA drivers
   - Verify NVIDIA Container Toolkit
   - Check docker info for NVIDIA runtime

2. Services not starting:
   - Check logs: `docker compose logs <service>`
   - Verify configurations
   - Check port availability

3. SSL issues:
   - Verify domain DNS settings
   - Check Caddy logs
   - Ensure ports 80/443 are available

## References
- [HEAVY.AI Installation using Docker on Ubuntu](https://docs.heavy.ai/installation-and-configuration/installation/install-docker/docker-enterprise-edition-gpu)
- [Install NVIDIA Drivers and Vulkan on Ubuntu](https://docs.heavy.ai/installation-and-configuration/installation/installing-on-ubuntu/install-nvidia-drivers-and-vulkan-on-ubuntu)
- [Install Docker Engine on Ubuntu](https://docs.docker.com/engine/install/ubuntu/#install-using-the-repository)
- [Docker Compose File Reference](https://docs.docker.com/compose/compose-file/)

## Helpful Commands and Queries

- To enter to heavysql cli inside heavydb container:
```bash
docker exec -it heavydb /opt/heavyai/bin/heavysql heavyai -u admin -p 'HyperInteractive'
```
- To change password:
```bash
ALTER USER admin (password = 'YourNewPassword!!');
```

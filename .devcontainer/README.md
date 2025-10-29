# Dolibarr Development Container

This directory contains the configuration for GitHub Codespaces and Visual Studio Code Dev Containers to provide a complete development environment for Dolibarr.

## What's Included

- **PHP 8.1** with Apache web server
- **MariaDB 10.11** database server
- **MailDev** for email testing
- All required PHP extensions for Dolibarr
- Xdebug for debugging
- VS Code extensions for PHP development

## Getting Started

### Using GitHub Codespaces

1. Click the "Code" button on the GitHub repository
2. Select "Codespaces" tab
3. Click "Create codespace on [branch]"
4. Wait for the environment to build (first time may take a few minutes)
5. Once ready, open http://localhost in the browser to access Dolibarr
6. Follow the installation wizard at http://localhost/install/

### Using VS Code Dev Containers

1. Install [Docker Desktop](https://www.docker.com/products/docker-desktop)
2. Install the [Dev Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)
3. Open the repository folder in VS Code
4. When prompted, click "Reopen in Container" (or use Command Palette: "Dev Containers: Reopen in Container")
5. Wait for the container to build
6. Access Dolibarr at http://localhost

## Database Configuration

When running the Dolibarr installation wizard, use these database settings:

- **Database Type**: MariaDB/MySQL
- **Server**: `mariadb`
- **Database Name**: `dolibarr`
- **Username**: `dolibarr`
- **Password**: `dolibarrpass`
- **Root Password**: `rootpassfordev` (if needed for database creation)

## Ports

- **80**: Dolibarr web interface
- **3306**: MariaDB database (for external database tools)
- **8081**: MailDev web interface (for viewing test emails)

## Email Testing

All emails sent by Dolibarr are captured by MailDev. You can view them at http://localhost:8081

## Debugging

Xdebug is pre-configured and ready to use. The PHP Debug extension for VS Code is included, so you can set breakpoints and debug your PHP code directly in the editor.

## Persistence

- Database data is stored in a Docker volume and persists between container restarts
- The Dolibarr documents directory is also stored in a Docker volume
- Your code changes are immediately reflected in the running application

## Customization

If you need to modify the environment:

- **Dockerfile**: Customize the PHP/Apache configuration
- **docker-compose.yml**: Add or modify services
- **devcontainer.json**: Change VS Code settings or extensions
- **setup.sh**: Modify the post-create setup steps

## Troubleshooting

### Container won't start
- Check Docker Desktop is running
- Try rebuilding the container: Command Palette → "Dev Containers: Rebuild Container"

### Can't access Dolibarr
- Verify Apache is running: `sudo service apache2 status`
- Check the ports are forwarded correctly in the VS Code Ports panel
- Ensure the setup.sh script ran successfully

### Database connection errors
- Verify MariaDB is running: `docker ps` should show the mariadb container
- Check database credentials match the configuration above
- Try connecting with: `mysql -h mariadb -u dolibarr -pdolibarrpass dolibarr`

## Support

For more information about Dolibarr development, see:
- [Dolibarr Wiki](https://wiki.dolibarr.org)
- [Dolibarr Developer Documentation](https://wiki.dolibarr.org/index.php/Developer_documentation)
- [Contributing Guide](../.github/CONTRIBUTING.md)

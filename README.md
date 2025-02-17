[![Buy Me a Coffee](https://img.shields.io/badge/Buy%20Me%20a%20Coffee-donate-success?logo=buy-me-a-coffee&logoColor=white)](https://www.buymeacoffee.com/silent001)

# Game Server Template

This directory contains a template for creating Docker images for game servers. The `init.sh` script automates the process of setting up a new game server image repository based on the provided Steam app ID for the game server.

## Guidelines for All Servers

- Repositories are named in kebab-case with "-server" added to the base game name.
- The game install directory is named in PascalCase of the game name.
- `PORT`, `QUERYPORT`, and `SERVERNAME` should be consistent across all repositories.
- `RCONPORT` is the standard name if the server supports RCON and should also be consistent across all repositories.

## Usage

To create a new game server image repository, follow these steps:

1. Navigate to the `game-server-template` directory.
2. Run the `init.sh` script with the required options.

```bash
./init.sh -i <steam_app_id> [-b <image_base>]
```

### Options

- `-i`: Specify the Steam app ID of the game server.
- `-b`: (Optional) Override the image base. If not provided, the script will determine the appropriate base image based on the game's compatibility with Linux.
- `-h`: Show the help message.

## Example

```bash
./init.sh -i 294420
```

This command will create a new directory for the game server image, populate it with the necessary files, and replace placeholders with the appropriate values.

## Directory Structure

After running the `init.sh` script, the new game server image directory will have the following structure:

```
<game-server-image-name>/
├── Dockerfile
├── docker-compose.yml
├── base.Dockerfile
├── README.md
└── ...
```

## Template Variables

The following placeholders in the template files will be replaced with actual values:

- `{{GAME_APP_ID}}`: The Steam app ID of the game server.
- `{{GAME_NAME}}`: The name of the game.
- `{{GAME_NAME_PASCAL_CASE}}`: The name of the game in PascalCase.
- `{{GAME_SERVER_IMAGE_NAME}}`: The name of the game server image in kebab-case.
- `{{IMAGE_BASE}}`: The base image for the game server.

## Requirements

- `jq`: The script requires `jq` to parse JSON data. Please ensure it is installed on your system.

## Notes

- The script checks if the game server has a Linux depot. If not, it defaults to using `steamcmd-wine` as the base image.
- The script creates a new directory for the game server image and copies the template files into it, replacing the placeholders with the actual values.

For more information, refer to the comments in the `init.sh` script.

## License

This project is licensed under the [MIT License](LICENSE).

If you enjoy this project and would like to support my work, consider [buying me a coffee](https://www.buymeacoffee.com/silent001). Your support is greatly appreciated!
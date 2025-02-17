[![Docker Pulls](https://img.shields.io/docker/pulls/silentmecha/{{GAME_SERVER_IMAGE_NAME}}.svg)](https://hub.docker.com/r/silentmecha/{{GAME_SERVER_IMAGE_NAME}})
[![Image Size](https://img.shields.io/docker/image-size/silentmecha/{{GAME_SERVER_IMAGE_NAME}}/latest.svg)](https://hub.docker.com/r/silentmecha/{{GAME_SERVER_IMAGE_NAME}})
[![Buy Me a Coffee](https://img.shields.io/badge/Buy%20Me%20a%20Coffee-donate-success?logo=buy-me-a-coffee&logoColor=white)](https://www.buymeacoffee.com/silent001)

# silentmecha/{{GAME_SERVER_IMAGE_NAME}}

This repository contains the files needed to build and run a Docker image for a {{GAME_NAME}} dedicated server. This image is built on Ubuntu and is specifically designed for quickly setting up a {{GAME_NAME}} server. It uses a customized version of `steamcmd/steamcmd:ubuntu-24`, which includes additional programs, environment variables, and a dedicated USER account to ensure easy server creation and consistent configuration across instances. The image is optimized for streamlined deployment and management of **{{GAME_NAME}}** servers with all necessary dependencies and settings pre-configured.

> **Warning:** The latest version on Docker Hub may be out of date. Please check the GitHub repository for the most recent updates.

> **Note:** This image does not yet set all the settings for the server according to the ENV values. This is still a work in progress.

## Usage

This stack uses an image from [atmoz](https://github.com/atmoz). To see more on the image used visit their GitHub [https://github.com/atmoz/sftp](https://github.com/atmoz/sftp).

For more info on environment variables and what they do see [Environment Variables](#environment-variables)

### Available Tags

- `base`: Contains only the environment setup, excluding the game files.
- `latest`: Includes the game files needed for the server.

### Simplest Method

The simplest usage for this is using the `docker-compose` method to pull the `latest` image and run it.

```console
git clone https://github.com/silentmecha/{{GAME_SERVER_IMAGE_NAME}}.git {{GAME_SERVER_IMAGE_NAME}}
cd {{GAME_SERVER_IMAGE_NAME}}
cp .env.example .env
nano .env
docker-compose pull
docker-compose up -d
```

### Using the `base` tag

If you don't want to pull the entire image and don't need to keep multiple instances up to date, you can use the `base` tag.

```console
git clone https://github.com/silentmecha/{{GAME_SERVER_IMAGE_NAME}}.git {{GAME_SERVER_IMAGE_NAME}}
cd {{GAME_SERVER_IMAGE_NAME}}
cp .env.example .env
nano .env
docker-compose -f docker-compose.base.yml up -d
```

### Building Locally

If you prefer to build everything locally, you can start by building the `base` image and then the `latest` image.

```console
git clone https://github.com/silentmecha/{{GAME_SERVER_IMAGE_NAME}}.git {{GAME_SERVER_IMAGE_NAME}}
cd {{GAME_SERVER_IMAGE_NAME}}
cp .env.example .env
nano .env
docker build -f base.Dockerfile -t silentmecha/{{GAME_SERVER_IMAGE_NAME}}:base -t silentmecha/{{GAME_SERVER_IMAGE_NAME}}:latest .
docker build -f Dockerfile -t silentmecha/{{GAME_SERVER_IMAGE_NAME}}:latest .
docker-compose up -d
```

### Updating

Updating is now as simple as running a build on the `Dockerfile` or using `docker-compose build`. This will update the image without downloading all the game files again.

```console
docker-compose build
docker-compose up -d
```

### Environment Variables

| Variable Name   | Default Value         | Description                                |
|-----------------|-----------------------|--------------------------------------------|
| SERVERNAME      | <<SERVER_NAME>>       | Set Server Name                            |
| PORT            | <<SERVER_PORT>>       | Set Server Game Port                       |
| QUERYPORT       | <<SERVER_QUERY_PORT>> | Set Server Steam Query Port                |
| ADDITIONAL_ARGS |                       | Currently not used                         |
| SFT_USER        | foo                   | Username for SFTP access to edit save data |
| SFT_PASS        | pass                  | Password for SFTP access to edit save data |
| SFT_PORT        | 2222                  | Port for SFTP access (should not be 22 )   |

For more info on the usage of SFTP see [here](https://github.com/atmoz/sftp). If you do not want to use a plain text password see [encrypted-password](https://github.com/atmoz/sftp#encrypted-password)

### Ports
Currently the following ports are used.

| Port      | Type     | Default  |
|-----------|----------|----------|
| PORT      | <<TYPE>> | <<PORT>> |
| QUERYPORT | <<TYPE>> | <<PORT>> |
| SFT_PORT  | TCP      | 2222     |

All these ports must be forwarded through your router, except for <<LIST_OF_EXCLUDED PORTS>>

## License

This project is licensed under the [MIT License](LICENSE).

If you enjoy this project and would like to support my work, consider [buying me a coffee](https://www.buymeacoffee.com/silent001). Your support is greatly appreciated!
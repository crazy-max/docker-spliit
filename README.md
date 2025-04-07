<p align="center"><a href="https://github.com/crazy-max/docker-spliit" target="_blank"><img height="128" src=".github/docker-spliit.jpg"></a></p>

<p align="center">
  <a href="https://hub.docker.com/r/crazymax/spliit/tags?page=1&ordering=last_updated"><img src="https://img.shields.io/github/v/tag/crazy-max/docker-spliit?label=version&style=flat-square" alt="Latest Version"></a>
  <a href="https://github.com/crazy-max/docker-spliit/actions?workflow=build"><img src="https://img.shields.io/github/actions/workflow/status/crazy-max/docker-spliit/build.yml?label=build&logo=github&style=flat-square" alt="Build Status"></a>
  <a href="https://hub.docker.com/r/crazymax/spliit/"><img src="https://img.shields.io/docker/stars/crazymax/spliit.svg?style=flat-square&logo=docker" alt="Docker Stars"></a>
  <a href="https://hub.docker.com/r/crazymax/spliit/"><img src="https://img.shields.io/docker/pulls/crazymax/spliit.svg?style=flat-square&logo=docker" alt="Docker Pulls"></a>
  <br /><a href="https://github.com/sponsors/crazy-max"><img src="https://img.shields.io/badge/sponsor-crazy--max-181717.svg?logo=github&style=flat-square" alt="Become a sponsor"></a>
  <a href="https://www.paypal.me/crazyws"><img src="https://img.shields.io/badge/donate-paypal-00457c.svg?logo=paypal&style=flat-square" alt="Donate Paypal"></a>
</p>

## About

Docker image for [Spliit](https://github.com/spliit-app/spliit), an open source
alternative to Splitwise.

> [!TIP] 
> Want to be notified of new releases? Check out 🔔 [Diun (Docker Image Update Notifier)](https://github.com/crazy-max/diun)
> project!

___

* [Build locally](#build-locally)
* [Image](#image)
* [Environment variables](#environment-variables)
* [Ports](#ports)
* [Usage](#usage)
  * [Docker Compose](#docker-compose)
* [Upgrade](#upgrade)
* [Contributing](#contributing)
* [License](#license)

## Build locally

```shell
git clone https://github.com/crazy-max/docker-spliit.git
cd docker-spliit

# Build image and output to docker (default)
docker buildx bake

# Build multi-platform image
docker buildx bake image-all
```

## Image

| Registry                                                                                          | Image                      |
|---------------------------------------------------------------------------------------------------|----------------------------|
| [Docker Hub](https://hub.docker.com/r/crazymax/spliit/)                                           | `crazymax/spliit`          |
| [GitHub Container Registry](https://github.com/users/crazy-max/packages/container/package/spliit) | `ghcr.io/crazy-max/spliit` |

The following platforms for this image are available:

```
$ docker buildx imagetools inspect crazymax/spliit --format "{{json .Manifest}}" | \
  jq -r '.manifests[] | select(.platform.os != null and .platform.os != "unknown") | .platform | "\(.os)/\(.architecture)\(if .variant then "/" + .variant else "" end)"'

linux/amd64
linux/arm64
```

## Environment variables

* `TZ`: The timezone assigned to the container (default `UTC`)
* `POSTGRES_HOST`: Hostname of the database server (default `db`)
* `POSTGRES_PORT`: Port where the database server is reachable (default `5432`)
* `POSTGRES_USER`: Username for database (default `spliit`)
* `POSTGRES_DB`: Database name (default `spliit`)
* `POSTGRES_TIMEOUT`: Time in seconds after which we stop trying to reach the database server (default `60`)
* `POSTGRES_PASSWORD`: Password for database user (default empty)

## Ports

* `3000/tcp`: HTTP port

## Usage

### Docker Compose

Docker compose is the recommended way to run this image. You can use the
following [docker compose template](examples/compose/compose.yml), then run
the container:

```bash
docker compose up -d
docker compose logs -f
```

## Upgrade

To upgrade, pull the newer image and launch the container:

```bash
docker compose pull
docker compose up -d
```

## Contributing

Want to contribute? Awesome! The most basic way to show your support is to star
the project, or to raise issues. You can also support this project by [**becoming a sponsor on GitHub**](https://github.com/sponsors/crazy-max)
or by making a [PayPal donation](https://www.paypal.me/crazyws) to ensure this
journey continues indefinitely!

Thanks again for your support, it is much appreciated! :pray:

## License

MIT. See `LICENSE` for more details.

# Project 2 Rationale: Base Image and Service Choices

## Multi-stage Image Choice

For this project, I used `node:24` in the build stage because Node.js and npm are needed to install dependencies and run the build script. For the final stage, I chose `nginx:alpine` because the application produces a static HTML page. nginx can serve that page without needing the complete Node.js development environment.

I built both a single-stage image and a multi-stage image on my Ubuntu system using Docker. My measured results were:

| Image | Disk Usage | Content Size |
|---|---:|---:|
| Single-stage (`demo:single`) | 1.65 GB | 413 MB |
| Multi-stage (`demo:multi`) | 93.6 MB | 26.3 MB |

The multi-stage image was approximately **94.3% smaller**, or **17.6 times smaller**, based on the reported disk usage. This is a major improvement because the final image only contains nginx and the application files instead of the entire Node.js build environment.

Docker's multi-stage build documentation explains that build artifacts can be copied between stages without including all the build tools in the final image [1]. This makes the image smaller and avoids shipping unnecessary development dependencies.

## Why Redis Is a Separate Service

I used two services in `compose.yaml`: `web`, which serves the static page through nginx, and `cache`, which uses the official `redis:7-alpine` image.

Redis is kept separate because it is a different service with its own purpose and lifecycle. Instead of installing Redis inside the web container, Docker Compose allows me to use an existing Redis image and manage it independently.

I configured a Redis health check using `redis-cli ping` and `depends_on` with `condition: service_healthy`. This ensures Redis becomes healthy before the web container starts [2].

During testing, Redis returned `PONG`, and the web service returned HTTP `200`. I also confirmed that both containers were running successfully.

The demo web page does not directly communicate with Redis, so this setup demonstrates service composition and startup dependencies rather than a fully integrated caching application.

This relates to the course's discussion of IaaS and PaaS. Containers provide control over application packaging, service configuration, and dependencies without requiring a separate virtual machine for each component.

## References

[1] Docker Docs. *Multi-stage builds.* https://docs.docker.com/build/building/multi-stage/

[2] Docker Docs. *Control startup and shutdown order in Compose.* https://docs.docker.com/compose/how-tos/startup-order/

[3] Docker Docs. *Docker Compose configuration reference.* https://docs.docker.com/reference/cli/docker/compose/config/












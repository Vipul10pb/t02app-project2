# Project 2 rationale: base image and service choices

## Multi-stage image choice

I used `node:24` as a build stage because the `npm ci` and `npm run build` steps need Node.js and npm. The final image uses `nginx:alpine` because the output is a static HTML file, and nginx can serve it without Node.js, npm, source code, or build tools. The `COPY --from=build` instruction transfers only the generated `build/` directory into the runtime stage. Docker's official documentation explains that separate stages allow selecting just the artifacts needed in the final image [1]. Alpine-based nginx keeps the runtime focused on serving static assets instead of packaging the full Node toolchain. This is a packaging benefit, not a claim that all Alpine images are always more secure.

**My measured comparison** (complete after running the comparison commands; use your own `docker images demo` results, not the instructor's example):

| Image | Size measured locally |
|---|---|
| `demo:single` (`Dockerfile.single`, Node + `http-server`) | **TO FILL: ____ MB or GB** |
| `demo:multi` (`Dockerfile`, nginx:alpine final stage) | **TO FILL: ____ MB or GB** |

My measured size reduction is **TO FILL: ____ % (or ____× smaller)**. The difference comes from excluding the Node build environment and its dependencies from the image that runs in production. Record the `docker images demo` screenshot as supporting evidence; exact results vary with image releases and platform.

## Why Redis is a separate service

I used two Compose services: `web` (my built image) and `cache` (`redis:7-alpine`, a public ready-made service). Redis is its own service so its lifecycle, configuration, and health can be managed independently of the web image. This avoids baking a second server process into the nginx container. The Compose health check uses `redis-cli ping`, while `depends_on` with `condition: service_healthy` waits for the cache's health check to succeed before starting the web service. Docker documents this specific startup behavior [2].

The example HTML page does not actually read or write Redis, so the cache is a **demonstration dependency**, not a required runtime data path. As the Week 6 stop-cache test shows, the web page remains available when Redis stops. In the course's service-model framing, containers occupy a middle ground between managing an entire VM (IaaS) and surrendering most runtime control to a managed application platform (PaaS). Here I choose the nginx-based runtime and Compose wiring while accepting Redis as a prebuilt dependency instead of implementing a cache myself.

The local function illustrates a separate execution model: AWS SAM CLI can invoke a handler locally using Docker rather than keeping an HTTP server running [3]. It is part of this repository but excluded from the nginx build context by `.dockerignore`.

## Sources

[1] Docker Docs, “Multi-stage builds.” https://docs.docker.com/build/building/multi-stage/

[2] Docker Docs, “Control startup and shutdown order in Compose.” https://docs.docker.com/compose/how-tos/startup-order/

[3] AWS Docs, “AWS SAM CLI installation.” https://docs.aws.amazon.com/serverless-applicationmodel/latest/developerguide/install-sam-cli.html

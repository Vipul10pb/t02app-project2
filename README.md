# Project 2 — Containerize and Run Locally

One Git repository with (1) a multi-stage Node-to-nginx image, (2) a two-service Compose stack containing `web` and Redis `cache`, and (3) an AWS SAM function invoked locally. No AWS account is needed.

## Prerequisites

Run all commands in **Ubuntu (WSL2)** or a Linux terminal, not PowerShell. Docker Engine + Compose plugin, `git`, and AWS SAM CLI must be installed and Docker must be running (per course T00). Network access is needed on the first build to pull public images and install the comparison server. Port `8080` must be free.

## Fresh-clone verification: run commands exactly in order

Clone your submitted repository and enter it (replace the placeholder URL with the **actual URL** when you publish it):

```bash
git clone YOUR_REPOSITORY_URL t02app
cd t02app
```

If you already downloaded the submitted repository folder, open a terminal in `t02app` instead; **do not** type the placeholder Git URL.

### 1. Verify the two-stage image and Compose services

```bash
grep -c '^FROM' Dockerfile
docker compose config --services
```

Expected: `2`; and two service names, `web` and `cache` (order may differ).

### 2. Build, start, inspect, and test both services

```bash
docker build -t demo:multi .
docker compose up -d --build
docker compose ps
docker compose exec cache redis-cli ping
curl -s -o /dev/null -w '%{http_code}\n' http://localhost:8080
```

Expected: `cache` is healthy, `web` is up, Redis answers `PONG`, HTTP status is `200`. The simple static demo page does not call Redis; Redis is an explicitly modeled infrastructure dependency used to demonstrate Compose health checks and startup order.

### 3. Inspect and clean up

```bash
docker compose logs web
docker compose exec web sh -c 'nginx -v'
docker inspect $(docker compose ps -q web) --format '{{.State.Status}} started={{.State.StartedAt}} restarts={{.RestartCount}}'
docker compose down
```

Expected: nginx version, `running ... restarts=0` in a normal run; both containers stop and are removed.

### 4. Invoke the local AWS SAM function

```bash
cd local-fn
sam local invoke HelloWorldFunction
sam local invoke HelloWorldFunction -e events/event.json
cd ..
```

Expected: an invocation response with `"statusCode": 200` and body containing `"message":"hello world"`. The first invocation may download a public Lambda runtime image. This is a local Docker call, no deployment, account, or credentials required.

### 5. Compare image sizes (record your own outputs)

```bash
docker build -f Dockerfile.single -t demo:single .
docker build -t demo:multi .
docker images demo
```

**Record the `demo:single` and `demo:multi` sizes in `RATIONALE.md`.** Do not substitute sample numbers from the handout for measured values. The single-stage image installs `http-server` globally at build time, so it does not fetch packages at startup.

## Optional Week 6 dependency-failure check

Run from repository root, after bringing both services up:

```bash
docker compose up -d
docker compose stop cache
docker compose ps
curl -s -o /dev/null -w '%{http_code}\n' http://localhost:8080
docker compose down
```

The static web page should still respond `200` because `depends_on` governs startup readiness, not a continuous Redis health requirement.

## Repository structure

```text
t02app/
├── .dockerignore
├── .gitignore
├── Dockerfile
├── Dockerfile.single
├── compose.yaml
├── index.html
├── package.json
├── package-lock.json
├── README.md
├── RATIONALE.md
└── local-fn/
    ├── template.yaml
    ├── README.md
    ├── events/event.json
    └── hello-world/
        ├── app.mjs
        └── package.json
```

## References

- Docker multi-stage builds: https://docs.docker.com/build/building/multi-stage/
- Compose startup order: https://docs.docker.com/compose/how-tos/startup-order/
- Compose CLI config: https://docs.docker.com/reference/cli/docker/compose/config/
- AWS SAM CLI installation: https://docs.aws.amazon.com/serverless-applicationmodel/latest/developerguide/install-sam-cli.html

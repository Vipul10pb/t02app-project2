# Stage 1: includes Node.js tooling needed during the build.
FROM node:24 AS build
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

# Stage 2: contains only nginx and the generated static site.
FROM nginx:alpine
COPY --from=build /app/build /usr/share/nginx/html

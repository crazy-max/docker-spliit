# syntax=docker/dockerfile:1

ARG SPLIIT_VERSION=1.8.1
ARG ALPINE_VERSION=3.20

# https://github.com/spliit-app/spliit/blob/1.8.1/Dockerfile#L1
ARG NODE_VERSION=21

FROM node:${NODE_VERSION}-alpine${ALPINE_VERSION} AS base
RUN apk --update --no-cache add ca-certificates openssl
WORKDIR /usr/app
ARG SPLIIT_VERSION
ADD "https://github.com/spliit-app/spliit.git#${SPLIIT_VERSION}" .

FROM base AS build
RUN npm ci --ignore-scripts
RUN npx prisma generate
# dummy env to be able to build: https://github.com/spliit-app/spliit/blob/main/scripts/build.env
RUN cp /usr/app/scripts/build.env /usr/app/.env
ENV NEXT_TELEMETRY_DISABLED=1
RUN npm run build
RUN rm -rf .next/cache

FROM base AS deps
RUN npm ci --omit=dev --omit=optional --ignore-scripts
RUN npm install sharp
RUN npx prisma generate

FROM node:${NODE_VERSION}-alpine${ALPINE_VERSION}
RUN apk --update --no-cache add bash ca-certificates openssl postgresql-client tzdata

WORKDIR /usr/app
COPY --from=deps /usr/app/node_modules ./node_modules
COPY --from=build /usr/app/package.json /usr/app/package-lock.json /usr/app/next.config.js ./
COPY --from=build /usr/app/.next ./.next
COPY --from=build /usr/app/public ./public
COPY --from=build /usr/app/prisma ./prisma
COPY entrypoint.sh /usr/app/

ENV TZ=UTC
EXPOSE 3000/tcp

ENTRYPOINT [ "/usr/app/entrypoint.sh" ]
CMD [ "npm", "run", "start" ]

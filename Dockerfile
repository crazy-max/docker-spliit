# syntax=docker/dockerfile:1

ARG SPLIIT_VERSION=1.17.0
ARG ALPINE_VERSION=3.22

FROM alpine:${ALPINE_VERSION} AS base
RUN apk --update --no-cache add \
  bash \
  ca-certificates \
  nodejs-current \
  npm \
  openssl
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
RUN ls -al

FROM base AS deps
RUN npm ci --omit=dev --omit=optional --ignore-scripts
RUN npm install sharp
RUN npx prisma generate

FROM alpine:${ALPINE_VERSION}
RUN apk --update --no-cache add \
  bash \
  ca-certificates \
  nodejs-current \
  npm \
  openssl \
  postgresql-client \
  tzdata

WORKDIR /usr/app
COPY --from=deps /usr/app/node_modules ./node_modules
COPY --from=build /usr/app/package.json /usr/app/package-lock.json /usr/app/next.config.mjs ./
COPY --from=build /usr/app/.next ./.next
COPY --from=build /usr/app/public ./public
COPY --from=build /usr/app/prisma ./prisma
COPY entrypoint.sh /usr/app/

ENV TZ=UTC
EXPOSE 3000/tcp

ENTRYPOINT [ "/usr/app/entrypoint.sh" ]
CMD [ "npm", "run", "start" ]

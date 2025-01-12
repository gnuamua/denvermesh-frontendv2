FROM node:18-bullseye-slim AS base
FROM base AS builder

#ENV NODE_ENV production
ENV VOLTO_MAJOR=16
ENV VOLTO_MINOR=26
ENV VOLTO_PATCH=0
ENV VOLTO_PRERELEASE=
ENV VOLTO_VERSION=${VOLTO_MAJOR}.${VOLTO_MINOR}.${VOLTO_PATCH}${VOLTO_PRERELEASE}

RUN apt-get update \
    && apt-get upgrade && apt-get install -y python3 build-essential

RUN mkdir /build/ && chown -R node:node /build/
#    && npm install --no-audit --no-fund -g yo @plone/generator-volto

#RUN npm install --no-autdit --no-fund -g yo @plone/generator-volto

#USER node
WORKDIR /build/

# Generate new volto app
#RUN yo @plone/volto \
#    plone-frontend \
#    --description "Plone frontend using Volto" \
#    --skip-addons \
#    --skip-install \
#    --skip-workspaces \
#    --volto=${VOLTO_VERSION} \
#    --no-interactive

RUN mkdir volto/
COPY frontend/ volto/
RUN chown -R node:node /build/volto/
#USER root
#RUN chown -R node:node /usr/src/volto/
#RUN node --max_old_space_size=8192
RUN cd volto/ \
    && yarn install
#    && yarn add -W webpack style-loader css-loader
RUN cd volto && yarn build

FROM node:18-alpine
LABEL maintainer="Andrew Himelstieb <andrew@hoa-colors.com>" \
      org.label-schema.name="plone-frontend" \
      org.label-schema.description="Plone frontend image" \
      org.label-schema.vendor="Plone Foundation"
#RUN apk update
#RUN apt-get update \
#    && buildDeps="busybox" \
#    && apt-get install -y --no-install-recommends $buildDeps \
#    && busybox --install -s \
#    && rm -rf /var/lib/apt/lists/*

USER node
COPY --from=builder /build/volto /app/
WORKDIR /app
EXPOSE 3000
CMD ["yarn", "start:prod"]

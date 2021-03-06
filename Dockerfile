# dev stage for developers to override sources
FROM node:11.14-alpine as dev

RUN apk --no-cache add make gcc g++ python

ENV NODE_ENV=development
ENV BLUEBIRD_DEBUG=0

RUN mkdir /app
WORKDIR /app

COPY package*.json ./

RUN npm ci

COPY . .eslintrc.js ./

# ci stage for CI runner
FROM dev as ci

COPY --from=dev /app/node_modules node_modules
ARG CI=true
ENV NODE_ENV=test
# tests should be executed in parallel (on a good CI runner)
# by calling this 'ci' stage with different commands (i.e. npm run test:lint)
RUN pwd
RUN ls -als

FROM ci as clean

RUN npm prune --production

# prod stage
FROM alpine:3.9 AS prod

COPY --from=dev /usr/local/bin/node /usr/bin/
COPY --from=dev /usr/lib/libgcc* /usr/lib/libstdc* /usr/lib/

RUN mkdir /app
WORKDIR /app

COPY --from=clean /app/node_modules node_modules
COPY --from=clean /app/package.json /app/server.js ./

CMD ["node", "server.js"]
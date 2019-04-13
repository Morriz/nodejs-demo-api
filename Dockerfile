# dev stage
FROM node:11.14-alpine as dev

RUN apk --no-cache add make gcc g++ python

ENV NODE_ENV=development
ENV BLUEBIRD_DEBUG=0

RUN mkdir /home/node/app
WORKDIR /home/node/app

COPY package*.json ./

RUN npm ci

COPY . ./

# ci stage
FROM dev as ci

ARG CI=true
ENV NODE_ENV=test

# this example test is not necessary as tests should be executed in parallel (on a good CI runner)
# by calling this 'ci' stage with different commands (i.e. npm run test:lint)
RUN npm test 

RUN npm prune --production

# prod stage
FROM alpine:3.9 AS prod

COPY --from=dev /usr/local/bin/node /usr/bin/
COPY --from=dev /usr/lib/libgcc* /usr/lib/libstdc* /usr/lib/

RUN mkdir /app
WORKDIR /app

ENV NODE_ENV=production

COPY --from=ci --chown=node:node node_modules node_modules
COPY --from=ci --chown=node:node server.js .

CMD ["node", "server.js"]
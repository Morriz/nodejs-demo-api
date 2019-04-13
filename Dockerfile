# dev stage
FROM node:11.2-alpine as dev

RUN apk --no-cache add python make g++

ARG PORT=5000
ENV PORT=${PORT}
ENV NODE_ENV=development

RUN mkdir /home/node/app
WORKDIR /home/node/app

COPY package-lock.json ./
COPY package.json ./
RUN npm install
COPY . ./

# ci stage
FROM dev as ci

ARG CI=true
ENV NODE_ENV=test

RUN npm test

RUN npm prune --production

# prod stage
FROM node:11.2-alpine AS prod

ENV NODE_ENV=production

COPY --from=ci --chown=node:node /home/node/app/ ./

USER node

CMD ["npm", "start"]

EXPOSE 5000

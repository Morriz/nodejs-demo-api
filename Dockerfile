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

# prod stage
FROM ci AS prod

ENV NODE_ENV=production

RUN npm prune --production

RUN chown -R node .

USER node

CMD ["npm", "start"]

EXPOSE 5000

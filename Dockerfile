# dev stage
FROM node:11.2-alpine as dev

RUN apk --no-cache add python make g++

ARG PORT=5000
ENV PORT=${PORT}
ENV NODE_ENV=development

RUN mkdir /home/node/app
WORKDIR /home/node/app

COPY package*.json ./

RUN ls -als
RUN npm install

COPY . ./

# ci stage
FROM dev as ci

ARG CI=true
ENV NODE_ENV=test

# this example test is not necessary as tests should be executed in parallel (on a good CI runner)
# by calling this 'ci' stage with different commands (i.e. npm run test:lint)
RUN ls -als
RUN npm test 

RUN npm prune --production

# prod stage
FROM node:11.2-alpine AS prod

RUN mkdir /home/node/app
WORKDIR /home/node/app

ENV NODE_ENV=production

COPY --from=ci --chown=node:node /home/node/app .
RUN ls -als

USER node

CMD ["npm", "start"]

EXPOSE 5000

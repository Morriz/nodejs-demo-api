FROM node:8.5-alpine
RUN mkdir -p /app
WORKDIR /app
COPY package.json server.js /app/
RUN npm install
CMD ["npm", "start"]

FROM node:14-alpine3.16
WORKDIR /app
COPY . .
ENV ACCESS_TOKEN="AKIAKKJSSJJJS"
RUN npm install
CMD [ "npm", "start" ]
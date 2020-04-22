FROM node:10

WORKDIR /usr/src/app

ARG NODE_ENV
ENV NODE_ENV $NODE_ENV

COPY . /usr/src/app
RUN npm install
RUN npm run build

EXPOSE 8080
CMD [ "npm", "start" ]

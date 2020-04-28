FROM vipyangyang/jenkins-agent-nodejs-10:v3.11

WORKDIR /usr/src/app

ARG NODE_ENV
ENV NODE_ENV $NODE_ENV

COPY . /usr/src/app

RUN npm install

# --- Expose and CMD ---
EXPOSE 8080
CMD [ "npm", "start" ]

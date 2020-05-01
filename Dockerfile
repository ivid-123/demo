FROM vipyangyang/jenkins-agent-nodejs-10:v3.11

WORKDIR /usr/src/app

ARG NODE_ENV
ENV NODE_ENV $NODE_ENV

COPY . /usr/src/app

# RUN npm install
# RUN npm run build --prod

# # --- Nginx Setup ---
# COPY config/nginx/default.conf /etc/nginx/conf.d/
# RUN chmod g+rwx /var/cache/nginx /var/run /var/log/nginx
# RUN chgrp -R root /var/cache/nginx
# RUN sed -i.bak 's/^user/#user/' /etc/nginx/nginx.conf
# RUN addgroup nginx root

# --- Expose and CMD ---
EXPOSE 8080
CMD [ "npm", "start" ]


# #stage 1
# FROM vipyangyang/jenkins-agent-nodejs-10:v3.11 as build-step

# WORKDIR /usr/src/app

# COPY package.json ./
# RUN npm install
# COPY . .
# RUN npm run build --prod

# # stage 2
# FROM nginx:alpine as prod-stage
# COPY --from=build-step /usr/src/app/dist/letslearn  /usr/share/nginx/html
# EXPOSE 80
# CMD ["nginx", "-g", "daemon off;"]

# # # --- Nginx Setup ---
# # COPY config/nginx/default.conf /etc/nginx/conf.d/
# # RUN chmod g+rwx /var/cache/nginx /var/run /var/log/nginx
# # RUN chgrp -R root /var/cache/nginx
# # RUN sed -i.bak 's/^user/#user/' /etc/nginx/nginx.conf
# # RUN addgroup nginx root

# # --- Expose and CMD ---
# # EXPOSE 8080
# # CMD [ "npm", "start" ]


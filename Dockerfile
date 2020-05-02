FROM vipyangyang/jenkins-agent-nodejs-10:v3.11 as build-stage


WORKDIR /app

ARG NODE_ENV
ENV NODE_ENV $NODE_ENV

COPY . /app


# # Stage 1, based on Nginx, to have only the compiled app, ready for production with Nginx
# FROM nginx:1.15
# COPY --from=build-stage /app/dist /usr/share/nginx/html

# # Copy the default nginx.conf provided by tiangolo/node-frontend
# COPY --from=build-stage ./config/nginx/default.conf /etc/nginx/conf.d/default.conf
# # COPY ./config/nginx/default.conf /etc/nginx/conf.d/default.conf
# EXPOSE 80
# CMD ["nginx", "-g", "daemon off;"]

FROM nginx:stable

# support running as arbitrary user which belogs to the root group
RUN chmod g+rwx /var/cache/nginx /var/run /var/log/nginx
# users are not allowed to listen on priviliged ports
RUN sed -i.bak 's/listen\(.*\)80;/listen 8081;/' /etc/nginx/conf.d/default.conf
EXPOSE 8081
# comment user directive as master process is run as user in OpenShift anyhow
RUN sed -i.bak 's/^user/#user/' /etc/nginx/nginx.conf
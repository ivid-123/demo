FROM nginx:mainline-alpine

## Copy our nginx config
COPY config/nginx/ /etc/nginx/conf.d/

## Remove default nginx website
# RUN rm -rf /usr/share/nginx/html/*

## copy over the artifacts in dist folder to default nginx public folder
COPY dist/ /usr/share/nginx/html


# --- Nginx Setup ---
COPY config/nginx/default.conf /etc/nginx/conf.d/
RUN chmod g+rwx /var/cache/nginx /var/run /var/log/nginx
RUN chgrp -R root /var/cache/nginx
RUN sed -i.bak 's/^user/#user/' /etc/nginx/nginx.conf
RUN addgroup nginx root

EXPOSE 8081

CMD ["nginx", "-g", "daemon off;"]
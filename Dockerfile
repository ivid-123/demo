FROM nginx:mainline-alpine

## Copy our nginx config
COPY config/nginx/ /etc/nginx/conf.d/

## Remove default nginx website
RUN rm -rf /usr/share/nginx/html/*

## copy over the artifacts in dist folder to default nginx public folder
COPY dist/ /usr/share/nginx/html

EXPOSE 8081

CMD ["nginx", "-g", "daemon off;"]
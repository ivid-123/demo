FROM nginx:mainline-alpine

# --- Python Installation ---
# RUN apk add --no-cache python3 && \
#     python3 -m ensurepip && \
#     rm -r /usr/lib/python*/ensurepip && \
#     pip3 install --upgrade pip setuptools && \
#     if [ ! -e /usr/bin/pip ]; then ln -s pip3 /usr/bin/pip ; fi && \
#     if [[ ! -e /usr/bin/python ]]; then ln -sf /usr/bin/python3 /usr/bin/python; fi && \
#     rm -r /root/.cache

# --- Work Directory ---
WORKDIR /usr/src/app


RUN echo $(ls /)

# --- Python Setup ---
COPY ./dist /usr/src/app/dist
COPY ./config /usr/src/app/config
COPY ./Dockerfile /usr/src/app/Dockerfile

# CMD [ "ls","-1" ]
RUN echo $(ls /usr/src/app/config)

RUN echo $(ls /usr/src/app/dist)

# RUN pip install -r app/requirements.pip
RUN echo $(pwd)
RUN echo $(ls /usr/share/nginx/html)

COPY dist /usr/share/nginx/html

# Copy the default nginx.conf provided by tiangolo/node-frontend
COPY config/nginx/default.conf /etc/nginx/conf.d/default.conf

# --- Nginx Setup ---
COPY config/nginx/default.conf /etc/nginx/conf.d/
RUN chmod g+rwx /var/cache/nginx /var/run /var/log/nginx
RUN chgrp -R root /var/cache/nginx
RUN sed -i.bak 's/^user/#user/' /etc/nginx/nginx.conf
RUN addgroup nginx root

# --- Expose and CMD ---
EXPOSE 8081
CMD ["nginx", "-g", "daemon off;"]
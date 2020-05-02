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

RUN cd . && ls

# --- Python Setup ---
ADD ./dist /usr/src/app/dist
ADD ./src /usr/src/app/src
ADD ./config /usr/src/app/config
ADD ./Dockerffile /usr/src/app/Dockerffile

RUN cd /this/folder && ls

# RUN pip install -r app/requirements.pip

COPY  ./usr/src/app/dist /usr/share/nginx/html

# Copy the default nginx.conf provided by tiangolo/node-frontend
COPY  ./config/nginx/default.conf /etc/nginx/conf.d/default.conf

# --- Nginx Setup ---
COPY config/nginx/default.conf /etc/nginx/conf.d/
RUN chmod g+rwx /var/cache/nginx /var/run /var/log/nginx
RUN chgrp -R root /var/cache/nginx
RUN sed -i.bak 's/^user/#user/' /etc/nginx/nginx.conf
RUN addgroup nginx root

# --- Expose and CMD ---
EXPOSE 8081
CMD ["nginx", "-g", "daemon off;"]
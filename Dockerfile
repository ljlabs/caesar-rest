FROM jordaan0/caesar_openmpi

###############################
#      RabbitMQ
###############################
RUN apt-get update -y && apt-get install -y apt-transport-https curl gnupg

RUN curl -fsSL https://github.com/rabbitmq/signing-keys/releases/download/2.0/rabbitmq-release-signing-key.asc | apt-key add -

RUN echo "deb https://dl.bintray.com/rabbitmq-erlang/debian xenial erlang-23.x" > /etc/apt/sources.list.d/bintray.rabbitmq.list && \
    echo "deb https://dl.bintray.com/rabbitmq/debian xenial main" >> /etc/apt/sources.list.d/bintray.rabbitmq.list

RUN apt-get update -y && apt-get install -y rabbitmq-server --fix-missing

###############################
#      Celery
###############################
RUN apt-get update -y && apt-get install -y python-pip && python -m pip install pip~=20.1.1

RUN python -m pip install celery[librabbitmq,redis]

###############################
#      uwsgi
###############################
RUN python -m pip install uwsgi

###############################
#      nginx
###############################
RUN apt-get update -y && apt-get install -y gnupg2 ca-certificates

RUN curl -fsSL https://nginx.org/keys/nginx_signing.key | apt-key add -

RUN echo "deb http://nginx.org/packages/ubuntu xenial nginx" > /etc/apt/sources.list.d/nginx.list

RUN apt-get update -y && apt-get install -y nginx

###############################
#      Caesar REST
###############################
ENV INSTALL_DIR /opt/caesar-rest

RUN mkdir -p $INSTALL_DIR $INSTALL_DIR/config $INSTALL_DIR/data $INSTALL_DIR/jobs $INSTALL_DIR/logs $INSTALL_DIR/run $INSTALL_DIR/lib/python2.7/site-packages

ENV PYTHONPATH $PYTHONPATH:$INSTALL_DIR/lib/python2.7/site-packages

RUN python -m pip install itsdangerous==0.24 MarkupSafe==0.23 pyyaml

WORKDIR /root

COPY . /root/caesar-rest

RUN cd caesar-rest && \
    python setup.py sdist bdist_wheel && \
    python setup.py build && \
    python setup.py install --prefix=$INSTALL_DIR

RUN cp /root/caesar-rest/config/uwsgi/uwsgi.ini $INSTALL_DIR/config && \
    cp /root/caesar-rest/config/nginx/nginx.conf /etc/nginx/conf.d && \
    cp /root/caesar-rest/config/celery/caesar-workers /etc/default && \
    rm -rf /root/caesar-rest/

ENV PATH $INSTALL_DIR/bin:$PATH
ENV PYTHONPATH $INSTALL_DIR/lib/python2.7/site-packages:\$PYTHONPATH

RUN adduser --disabled-password --gecos "" caesar && \
    mkdir -p /home/caesar && \
    chown -R caesar:caesar /home/caesar && \
    chown -R caesar:caesar $INSTALL_DIR && \
    echo "export PYTHONPATH=$INSTALL_DIR/lib/python2.7/site-packages:\$PYTHONPATH" >> /home/caesar/.profile

EXPOSE 8080

COPY start_caesar.sh /
RUN chmod +x /start_caesar.sh
COPY init.sh /
RUN chmod +x /init.sh
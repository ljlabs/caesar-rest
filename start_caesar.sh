#!/usr/bin/env bash

# Load Celery ENV variables
source /etc/default/caesar-workers

# Start services required for Caesar REST
service rabbitmq-server start
service redis start
runuser -l caesar -c "${CELERY_BIN} multi start ${CELERYD_NODES} -A ${CELERY_APP} --pidfile=${CELERYD_PID_FILE} --logfile=${CELERYD_LOG_FILE} --loglevel=${CELERYD_LOG_LEVEL} ${CELERYD_OPTS}"
runuser -l caesar -g nginx -c "cd $INSTALL_DIR && uwsgi --wsgi-file $INSTALL_DIR/bin/run_app.py --callable app --ini $INSTALL_DIR/config/uwsgi.ini" >/var/log/uwsgi.log 2>&1 &
service nginx start

sh /init.sh
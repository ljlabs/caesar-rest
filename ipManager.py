import redis
import subprocess
import time

while True:
    ip = subprocess.check_output(['hostname', '-I']).replace(' \n', '')
    hostname = subprocess.check_output(['cat', '/etc/hostname']).replace('\n', '')
    with redis.Redis(host='redis-master', port=6379, db=1) as db:
        db.set(hostname, ip)
        db.set(hostname + "-age", time.time())
    time.sleep(15)
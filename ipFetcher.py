import redis
import time

while True:
    hosts = """"""
    with redis.Redis(host='redis-master', port=6379, db=1) as db:
        for key in db.scan_iter("*"):
            if "-age" not in key:
                if float(db.get(key+ "-age")) - time.time() < 60:
                    hosts += db.get(key) + "\n"
        with open("/workspace/hosts", "w") as f:
            f.write(hosts)

    time.sleep(15)
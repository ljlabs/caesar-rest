#! /bin/sh

/start_sshd.sh >/tmp/sshd.log 2>&1 &

# magic sleep for waiting sshd being up
sleep 5
echo "sshd started pid=$(ps auwx |grep [s]sh |  awk '{print $2}')"

/hostGenerator.sh 2>&1 &
echo "started host Generator"
/start_caesar.sh 2>&1 &
echo "started caesar"

if [ ! "z$ONE_SHOT" = "z" ]; then
  bash -c "$*"
  return_code=$?
else
  sleep infinity
  return_code=$?
fi
echo -n "$return_code" > /dev/termination-log
echo -n "$return_code" > $GUILLOTINE/execute

exit $return_code
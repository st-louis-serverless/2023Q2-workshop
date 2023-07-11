#!/bin/zsh

for i in {0..100}
do
  curl "http://hello-stls.default.127.0.0.1.sslip.io?index=$i" &
done

exit 0

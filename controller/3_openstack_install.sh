#!/bin/sh
set -e

packstack --os-controller-host=controller --os-compute-host=compute1,compute2 --gen-answer-file /root/answers.txt
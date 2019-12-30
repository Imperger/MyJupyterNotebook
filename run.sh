#!/bin/bash
user="vitaly"

docker build -t jupyter --build-arg user=${user} .

docker run -d \
    --rm \
    --name jupyter \
    --ip 192.168.0.3 \
    --network home_lan \
    -v ${PWD}/data:/home/${user} jupyter
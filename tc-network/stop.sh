#!/bin/bash

export IMAGE_TAG=1.4.4

docker-compose -f docker-compose-orderer.yaml -f docker-compose-org2.yaml -f docker-compose-org4.yaml stop

echo "Sleep 3 seconds....."
sleep 3

docker-compose -f docker-compose-orderer.yaml -f docker-compose-org2.yaml -f docker-compose-org4.yaml down

echo "Sleep 3 seconds....."
sleep 3

docker ps -a
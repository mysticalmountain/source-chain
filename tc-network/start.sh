#!/bin/bash

export IMAGE_TAG=2.1.0

docker-compose -f docker-compose-orderer.yaml -f docker-compose-org2.yaml -f docker-compose-org4.yaml up -d

echo "======================================================================================="

echo "Sleep 3 seconds....."
sleep 3

docker ps -a


#!/bin/bash
#
# Copyright IBM Corp All Rights Reserved
#
# SPDX-License-Identifier: Apache-2.0
#
# Exit on first error, print all commands.
set -e

# remove the local state
rm -f ~/.hfc-key-store/*

docker-compose -f docker-compose-orderer.yaml -f docker-compose-org2.yaml -f docker-compose-org4.yaml down --volumes --remove-orphans

echo "Sleep 5 seconds....."
sleep 5

docker rm $(docker ps -aq)
docker rmi $(docker images dev-* -q)
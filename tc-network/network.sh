#!/bin/bash


export PATH=$GOPATH/src/github.com/hyperledger/fabric/build/bin:${PWD}/./bin:${PWD}:$PATH
export FABRIC_CFG_PATH=${PWD}
export CHANNEL_NAME=twoorgschannel
export IMAGE_TAG=2.1.0
export IMAGE_CA_TAG=1.4.7

# import utils
. scripts/utils.sh



function createOrgs() {
	echo "##########################################################"
	echo "remove crypto-config and config"

	rm -fr config/*
	rm -fr crypto-config/*
	rm -fr channel-artifacts/*
	rm -fr crypto-config/*

	# generate crypto material

	echo "##########################################################"
	echo "generate crypto material orderer"
	./bin/cryptogen generate --config=./orderer/crypto-config.yaml
	if [ "$?" -ne 0 ]; then
	  echo "Failed to generate orderer material..."
	  exit 1
	fi

	echo "##########################################################"
	echo "generate crypto material org2"
	./bin/cryptogen generate --config=./org2-artifacts/crypto-config.yaml
	if [ "$?" -ne 0 ]; then
	  echo "Failed to generate org2 material..."
	  exit 1
	fi

	echo "##########################################################"
	echo "generate crypto material org4"
	./bin/cryptogen generate --config=./org4-artifacts/crypto-config.yaml
	if [ "$?" -ne 0 ]; then
	  echo "Failed to generate org4 material..."
	  exit 1
	fi

	echo "##########################################################"
	echo "Generate CCP files for Org1 and Org2"
	./ccp-generate.sh
}


# Generate orderer system channel genesis block.
function createConsortium() {
	which configtxgen
	if [ "$?" -ne 0 ]; then
		echo "configtxgen tool not found. exiting"
		exit 1
	fi

	echo "##########################################################"
	echo "generate genesis block for orderer"
	./bin/configtxgen -configPath=./orderer -profile TwoOrgOrdererGenesis -channelID sys-channel  -outputBlock ./channel-artifacts/TwoOrgOrdererGenesis.block
	if [ "$?" -ne 0 ]; then
	  echo "Failed to generate orderer genesis block..."
	  exit 1
	fi

	echo "##########################################################"
	echo "generate channel configuration transaction"
	./bin/configtxgen -configPath=./orderer -profile TwoOrgsChannel -outputCreateChannelTx ./channel-artifacts/TwoOrgsChannel.tx -channelID $CHANNEL_NAME
	if [ "$?" -ne 0 ]; then
	  echo "Failed to generate channel configuration transaction..."
	  exit 1
	fi

	echo "##########################################################"
	echo "generate anchor peer transaction org2"
	./bin/configtxgen -configPath=./orderer -profile TwoOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/TwoOrg2MSPanchors.tx -channelID $CHANNEL_NAME -asOrg Org2MSP
	if [ "$?" -ne 0 ]; then
	  echo "Failed to generate anchor peer update for Org2MSP..."
	  exit 1
	fi

	echo "##########################################################"
	echo "generate anchor peer transaction org4"
	./bin/configtxgen -configPath=./orderer -profile TwoOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/TwoOrg4MSPanchors.tx -channelID $CHANNEL_NAME -asOrg Org4MSP
	if [ "$?" -ne 0 ]; then
	  echo "Failed to generate anchor peer update for Org4MSP..."
	  exit 1
	fi

}


function networkUp() {
	createOrgs
	createConsortium
	docker-compose -f docker-compose-orderer.yaml -f docker-compose-org2.yaml -f docker-compose-org4.yaml -f docker-compose-ca.yaml up -d 2>&1
	echo "Sleep 1 seconds....."
	sleep 1
	docker ps -a
	if [ $? -ne 0 ]; then
		echo "ERROR !!!! Unable to start network"
		exit 1
	fi
}

function networkDown() {
  	docker-compose -f docker-compose-orderer.yaml -f docker-compose-org2.yaml -f docker-compose-org4.yaml -f docker-compose-ca.yaml down --volumes --remove-orphans
	#Cleanup the chaincode containers
 #    clearContainers
 #    #Cleanup images
	# removeUnwantedImages

	docker rm $(docker ps -aq)
	docker rmi $(docker images dev-* -q)
}


function createChannel() {
	echo "##########################################################"
	echo "Create channel $CHANNEL_NAME begin ..."
	docker exec cli scripts/channel.sh $CHANNEL_NAME "createChannel"
	res=$?
	verifyResult $res "Error Create channel failed"
	echo "Success !!! Create channel $CHANNEL_NAME successed"

	echo "##########################################################"
	echo "Update anchor peers on channel $CHANNEL_NAME begin ..."
	docker exec cli scripts/channel.sh $CHANNEL_NAME "updateAnchorPeers"
	res=$?
	verifyResult $res "Error !!! Update anchor peers on channel $CHANNEL_NAME failed"
	echo "Success !!! Update anchor peers on channel $CHANNEL_NAME successed"

	echo "##########################################################"
	echo "Join to channel $CHANNEL_NAME begin ..."
	docker exec cli scripts/channel.sh $CHANNEL_NAME "joinChannels"
	res=$?
	verifyResult $res "Error !!! Update anchor peers on channel $CHANNEL_NAME failed"
	echo "Success !!! Join to channel $CHANNEL_NAME successed"
}

function deployCC() {

	CHANNEL_NAME="$1"
	CC_NAME="$2"
	CC_PATH="$3"
	VERSION="$4"
	echo "CHANNEL_NAME=$CHANNEL_NAME"
	echo "CC_NAME=$CC_NAME"
	echo "CC_PATH=$CC_PATH"
	echo "VERSION=$VERSION"

	
	echo "##########################################################"
	echo "package chaincode ${CC_NAME} begin ..."
	docker exec cli scripts/chaincode.sh $CHANNEL_NAME "packageCC" $CC_NAME $CC_PATH $VERSION
	res=$?
	verifyResult $res "Error Create channel failed"
	echo "Success !!! Create channel $CHANNEL_NAME successed"

	echo "##########################################################"
	echo "Install chaincode ${CC_NAME} begin ..."
	docker exec cli scripts/chaincode.sh $CHANNEL_NAME "installCC" $CC_NAME
	res=$?
	verifyResult $res "Error Create channel failed"
	echo "Success !!! Create channel $CHANNEL_NAME successed"

	echo "##########################################################"
	echo "ApproveForMyOrg chaincode ${CC_NAME} begin ..."
	docker exec cli scripts/chaincode.sh $CHANNEL_NAME "approveForMyOrg" $CC_NAME $VERSION
	res=$?
	verifyResult $res "Error Create channel failed"
	echo "Success !!! Create channel $CHANNEL_NAME successed"

	echo "##########################################################"
	echo "ApproveForMyOrg chaincode ${CC_NAME} begin ..."
	docker exec cli scripts/chaincode.sh $CHANNEL_NAME "checkCommitReadiness" $CC_NAME $VERSION
	res=$?
	verifyResult $res "Error Create channel failed"
	echo "Success !!! Create channel $CHANNEL_NAME successed"

	echo "##########################################################"
	echo "ApproveForMyOrg chaincode ${CC_NAME} begin ..."
	docker exec cli scripts/chaincode.sh $CHANNEL_NAME "commitChaincodeDefinition" $CC_NAME $VERSION
	res=$?
	verifyResult $res "Error Create channel failed"
	echo "Success !!! Create channel $CHANNEL_NAME successed"


	echo "##########################################################"
	echo "ApproveForMyOrg chaincode ${CC_NAME} begin ..."
	docker exec cli scripts/chaincode.sh $CHANNEL_NAME "queryCommitted" $CC_NAME
	res=$?
	verifyResult $res "Error Create channel failed"
	echo "Success !!! Create channel $CHANNEL_NAME successed"

	echo "##########################################################"
	echo "ApproveForMyOrg chaincode ${CC_NAME} begin ..."
	docker exec cli scripts/chaincode.sh $CHANNEL_NAME "chaincodeInvokeInit" $CC_NAME
	res=$?
	verifyResult $res "Error Create channel failed"
	echo "Success !!! Create channel $CHANNEL_NAME successed"



}





# Obtain CONTAINER_IDS and remove them
# TODO Might want to make this optional - could clear other containers
# This function is called when you bring a network down
function clearContainers() {
  CONTAINER_IDS=$(docker ps -a | awk '($2 ~ /dev-peer.*/) {print $1}')
  if [ -z "$CONTAINER_IDS" -o "$CONTAINER_IDS" == " " ]; then
    echo "---- No containers available for deletion ----"
  else
    docker rm -f $CONTAINER_IDS
  fi
}

# Delete any images that were generated as a part of this setup
# specifically the following images are often left behind:
# This function is called when you bring the network down
function removeUnwantedImages() {
  DOCKER_IMAGE_IDS=$(docker images | awk '($1 ~ /dev-peer.*/) {print $3}')
  if [ -z "$DOCKER_IMAGE_IDS" -o "$DOCKER_IMAGE_IDS" == " " ]; then
    echo "---- No images available for deletion ----"
  else
    docker rmi -f $DOCKER_IMAGE_IDS
  fi
}

function printHelp() {
	echo "print help ......"
}


# timeout duration - the duration the CLI should wait for a response from
# another container before giving up
MAX_RETRY=5
# default for delay between commands
CLI_DELAY=3
# channel name defaults to "mychannel"



## Parse mode
if [[ $# -lt 1 ]] ; then
  printHelp
  exit 0
else
  MODE=$1
  shift
fi

if [ "${MODE}" == "up" ]; then
  networkUp
elif [ "${MODE}" == "createChannel" ]; then
  createChannel
elif [ "${MODE}" == "deployCC" ]; then
  deployCC $1 $2 $3 $4
elif [ "${MODE}" == "down" ]; then
  networkDown
elif [ "${MODE}" == "restart" ]; then
  networkDown
  networkUp
else
  # printHelp
  echo "Failed MODE not found in network ..."
  exit 1
fi



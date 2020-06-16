#!/bin/bash

# Author An 2020/6/15

createChannel() {
	echo
	echo "===================== Create ${CHANNEL_NAME} channel ===================== "
	echo
	export ORDERER_CA=${PWD}/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
	set -x
	peer channel create -c $CHANNEL_NAME -f ./channel-artifacts/TwoOrgsChannel.tx -o orderer.example.com:7050 --outputBlock ./channel-artifacts/${CHANNEL_NAME}.block --tls --cafile $ORDERER_CA >log.txt
	res=$?
	set +x
	cat log.txt
	if [ "$?" -ne 0 ]; then
	  echo "Failed to create channel ..."
	  exit 1
	fi
}

joinChannel() {
	echo
	echo "===================== Peer0 of org2 join to channel ${CHANNEL_NAME} ===================== "
	echo
	export CORE_PEER_LOCALMSPID="Org2MSP"
	export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/crypto/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
    export CORE_PEER_MSPCONFIGPATH=${PWD}/crypto/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
    export CORE_PEER_ADDRESS=peer0.org2.example.com:9051
	set -x
	peer channel join -b ./channel-artifacts/${CHANNEL_NAME}.block
	res=$?
	set +x
	if [ "$?" -ne 0 ]; then
	  echo "Failed to join channel ${CHANNEL_NAME} on Org2 ..."
	  exit 1
	fi

	echo
	echo "===================== Peer1 of org2 join to channel ${CHANNEL_NAME} ===================== "
	echo
	export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/crypto/peerOrganizations/org2.example.com/peers/peer1.org2.example.com/tls/ca.crt
    export CORE_PEER_MSPCONFIGPATH=${PWD}/crypto/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
    export CORE_PEER_ADDRESS=peer1.org2.example.com:9052
	set -x
	peer channel join -b ./channel-artifacts/${CHANNEL_NAME}.block
	res=$?
	set +x
	if [ "$?" -ne 0 ]; then
	  echo "Failed to join channel ${CHANNEL_NAME} on Org2 ..."
	  exit 1
	fi


	echo
	echo "===================== Peer0 of Org4 join to channel ${CHANNEL_NAME} ===================== "
	echo
	export CORE_PEER_LOCALMSPID="Org4MSP"
	export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/crypto/peerOrganizations/org4.example.com/peers/peer0.org4.example.com/tls/ca.crt
    export CORE_PEER_MSPCONFIGPATH=${PWD}/crypto/peerOrganizations/org4.example.com/users/Admin@org4.example.com/msp
    export CORE_PEER_ADDRESS=peer0.org4.example.com:9061
	set -x
	peer channel join -b ./channel-artifacts/${CHANNEL_NAME}.block
	res=$?
	set +x
	if [ "$?" -ne 0 ]; then
	  echo "Failed to join channel ${CHANNEL_NAME} on peer0 of Org4 ..."
	  exit 1
	fi

	echo
	echo "===================== Peer1 of Org4 join to channel ${CHANNEL_NAME} ===================== "
	echo
	export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/crypto/peerOrganizations/org4.example.com/peers/peer1.org4.example.com/tls/ca.crt
    export CORE_PEER_MSPCONFIGPATH=${PWD}/crypto/peerOrganizations/org4.example.com/users/Admin@org4.example.com/msp
    export CORE_PEER_ADDRESS=peer1.org4.example.com:9062
	set -x
	peer channel join -b ./channel-artifacts/${CHANNEL_NAME}.block
	res=$?
	set +x
	if [ "$?" -ne 0 ]; then
	  echo "Failed to join channel ${CHANNEL_NAME} on peer1 of Org4 ..."
	  exit 1
	fi
}

updateAnchorPeers() {
	echo
	echo "===================== Update anchor peer on Org2 ===================== "
	echo
 	export CORE_PEER_LOCALMSPID="Org2MSP"
    export CORE_PEER_MSPCONFIGPATH=${PWD}/crypto/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
    export ORDERER_CA=${PWD}/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

	set -x
	peer channel update -o orderer.example.com:7050 -c $CHANNEL_NAME -f ${PWD}/channel-artifacts/TwoOrg2MSPanchors.tx --tls --cafile $ORDERER_CA
	res=$?
	set +x
	if [ "$?" -ne 0 ]; then
	  echo "Failed to updateAnchorPeer channel ${CHANNEL_NAME} on Org2 ..."
	  exit 1
	fi

	echo
	echo "===================== Update anchor peer on Org4 ===================== "
	echo
	export CORE_PEER_LOCALMSPID="Org4MSP"
    export CORE_PEER_MSPCONFIGPATH=${PWD}/crypto/peerOrganizations/org4.example.com/users/Admin@org4.example.com/msp
	export ORDERER_CA=${PWD}/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

	set -x
	peer channel update -o orderer.example.com:7050 -c $CHANNEL_NAME -f ${PWD}/channel-artifacts/TwoOrg4MSPanchors.tx --tls --cafile $ORDERER_CA
	res=$?
	set +x
	if [ "$?" -ne 0 ]; then
	  echo "Failed to updateAnchorPeer channel ${CHANNEL_NAME} on Org4 ..."
	  exit 1
	fi
}

verifyResult() {
  if [ $1 -ne 0 ]; then
    echo "!!!!!!!!!!!!!!! "$2" !!!!!!!!!!!!!!!!"
    echo
    exit 1
  fi
}

CHANNEL_NAME="$1"
: ${CHANNEL_NAME:="twoorgschannel"}
MODE="$2"

if [ "${MODE}" == "createChannel" ]; then
  createChannel
elif [ "${MODE}" == "joinChannel" ]; then
  joinChannel
elif [ "${MODE}" == "updateAnchorPeers" ]; then
  updateAnchorPeers
else
  # printHelp
  echo "Failed MODE not found in createChannel ..."
  exit 1
fi


exit 0

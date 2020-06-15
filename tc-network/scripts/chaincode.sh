#!/bin/bash

verifyResult() {
  if [ $1 -ne 0 ]; then
    echo "!!!!!!!!!!!!!!! "$2" !!!!!!!!!!!!!!!!"
    echo
    exit 1
  fi
}

# export CORE_PEER_TLS_CERT_FILE=${PWD}/crypto/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/server.crt
# export CORE_PEER_TLS_KEY_FILE=${PWD}/crypto/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/server.key
# export CORE_PEER_MSPCONFIGPATH=${PWD}/crypto/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp

export PEER0_ORG2_CA=${PWD}/crypto/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
export PEER0_ORG4_CA=${PWD}/crypto/peerOrganizations/org4.example.com/peers/peer0.org4.example.com/tls/ca.crt

setEnv() {
  USING_ORG=$1
  if [ $USING_ORG -eq 2 ]; then
    export CORE_PEER_LOCALMSPID="Org2MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_ORG2_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/crypto/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
    export CORE_PEER_TLS_CERT_FILE=${PWD}/crypto/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/server.crt
    export CORE_PEER_TLS_KEY_FILE=${PWD}/crypto/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/server.key
    export CORE_PEER_ADDRESS=peer0.org2.example.com:9051
    # export CORE_PEER_ADDRESS=localhost:9051
  elif [ $USING_ORG -eq 4 ]; then
    export CORE_PEER_LOCALMSPID="Org4MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_ORG4_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/crypto/peerOrganizations/org4.example.com/users/Admin@org4.example.com/msp
    export CORE_PEER_TLS_CERT_FILE=${PWD}/crypto/peerOrganizations/org4.example.com/peers/peer0.org4.example.com/tls/server.crt
    export CORE_PEER_TLS_KEY_FILE=${PWD}/crypto/peerOrganizations/org4.example.com/peers/peer0.org4.example.com/tls/server.key
    export CORE_PEER_ADDRESS=peer0.org4.example.com:9061
    # export CORE_PEER_ADDRESS=localhost:9061
  else
    echo "================== ERROR !!! ORG Unknown =================="
  fi
}



packageChaincode() {
  CC_NAME=$1
  CC_SRC_PATH=$2
  VERSION=$3

  echo "----------------------------------------$CC_NAME--------------------$CC_SRC_PATH-------------------------$VERSION"

  if [ -n $CC_NAME ]; then
    echo "1111111"
  else
    echo "222 "
  fi

  # echo
  # echo "===================== Package chaincode fabcar on channel ${CHANNEL_NAME} ===================== "
  # echo
  # export CC_SRC_PATH="/opt/gopath/src/github.com/fabcar/go/"
  # export CC_RUNTIME_LANGUAGE=golang
  # export GO111MODULE=on
  # export GOPROXY=https://goproxy.cn
  # set -x
  # peer lifecycle chaincode package fabcar.tar.gz --path ${CC_SRC_PATH} --lang ${CC_RUNTIME_LANGUAGE} --label fabcar_${VERSION} >&log.txt
  # res=$?
  # set +x
  # cat log.txt
  # verifyResult $res "Chaincode packaging on peer0.org2 has failed"
  # echo "===================== Chaincode is packaged on peer0.Org2 ===================== "
  # echo
}

# installChaincode PEER ORG
installChaincode() {
  echo
  echo "===================== Install chaincode fabcar for peer0.org2 on channel ${CHANNEL_NAME} ===================== "
  echo
  setEnv 2
  set -x
  peer lifecycle chaincode install fabcar.tar.gz >&log.txt
  res=$?
  set +x
  cat log.txt
  verifyResult $res "Chaincode installation on peer0.org2 has failed"
  echo "===================== Chaincode is installed on peer0.org2 ===================== "
  echo

  echo
  echo "===================== Install chaincode fabcar for peer0.org4 on channel ${CHANNEL_NAME} ===================== "
  echo

  setEnv 4
  set -x
  peer lifecycle chaincode install fabcar.tar.gz >&log.txt
  res=$?
  set +x
  cat log.txt
  verifyResult $res "Chaincode installation on peer0.org2 has failed"
  echo "===================== Chaincode is installed on peer0.org4 ===================== "
  echo
}

# queryInstalled PEER ORG
queryInstalled() {

  echo
  echo "===================== Query install chaincode fabcar for peer0.org2 on channel ${CHANNEL_NAME} ===================== "
  echo
  setEnv 2
  set -x
  peer lifecycle chaincode queryinstalled >&log1.txt
  res=$?
  set +x
  cat log1.txt
	PACKAGE_ID=$(sed -n "/fabcar_${VERSION}/{s/^Package ID: //; s/, Label:.*$//; p;}" log.txt)
  verifyResult $res "Query installed on peer0.org2 has failed"
  echo PackageID is ${PACKAGE_ID}
  echo "===================== Query installed successful on peer0.org2 on channel ===================== "
  echo

  echo
  echo "===================== Query install chaincode fabcar for peer0.org4 on channel ${CHANNEL_NAME} ===================== "
  echo
  setEnv 2
  set -x
  peer lifecycle chaincode queryinstalled >&log2.txt
  res=$?
  set +x
  cat log2.txt
  PACKAGE_ID=$(sed -n "/fabcar_${VERSION}/{s/^Package ID: //; s/, Label:.*$//; p;}" log.txt)
  verifyResult $res "Query installed on peer0.org4 has failed"
  echo PackageID is ${PACKAGE_ID}
  echo "===================== Query installed successful on peer0.org2 on channel ===================== "
  echo
}

# approveForMyOrg VERSION PEER ORG
approveForMyOrg() {
  echo
  echo "===================== Approve chaincode fabcar on channel ${CHANNEL_NAME} ===================== "
  echo
  set -x
  peer lifecycle chaincode queryinstalled >&log1.txt
  res=$?
  set +x
  cat log1.txt
  export PACKAGE_ID=$(sed -n "/fabcar_${VERSION}/{s/^Package ID: //; s/, Label:.*$//; p;}" log1.txt)
  export ORDERER_CA=${PWD}/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
  

  setEnv 2
  set -x
  peer lifecycle chaincode approveformyorg --channelID $CHANNEL_NAME --name fabcar --version $VERSION --init-required --package-id $PACKAGE_ID --sequence $VERSION --tls --cafile $ORDERER_CA >&log2.txt
  set +x
  cat log2.txt
  verifyResult $res "Chaincode definition approved on peer0.org${ORG} on channel '$CHANNEL_NAME' failed"
  echo "===================== Chaincode definition approved on peer0.org${ORG} on channel '$CHANNEL_NAME' ===================== "
  echo

  echo
  echo
  echo
  setEnv 4
  set -x
  peer lifecycle chaincode approveformyorg --channelID $CHANNEL_NAME --name fabcar --version $VERSION --init-required --package-id $PACKAGE_ID --sequence $VERSION --tls --cafile $ORDERER_CA >&log3.txt
  set +x
  cat log3.txt
  verifyResult $res "Chaincode definition approved on peer0.org${ORG} on channel '$CHANNEL_NAME' failed"
  echo "===================== Chaincode definition approved on peer0.org${ORG} on channel '$CHANNEL_NAME' ===================== "
  echo

}

# checkCommitReadiness VERSION PEER ORG
checkCommitReadiness() {
  echo
  echo "===================== Approve chaincode fabcar on channel ${CHANNEL_NAME} ===================== "
  echo

  set -x
  peer lifecycle chaincode checkcommitreadiness --channelID $CHANNEL_NAME --name fabcar --version ${VERSION} --sequence ${VERSION} --output json --init-required >&log.txt
  res=$?
  set +x
  cat log.txt
  verifyResult $res ""
}

# commitChaincodeDefinition VERSION PEER ORG (PEER ORG)...
commitChaincodeDefinition() {
  echo
  echo "===================== Commit chaincode fabcar on channel ${CHANNEL_NAME} ===================== "
  echo
  export ORDERER_CA=${PWD}/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
  export ORG2_TLS_ROOTCERT_FILE=${PWD}/crypto/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
  export ORG4_TLS_ROOTCERT_FILE=${PWD}/crypto/peerOrganizations/org4.example.com/peers/peer0.org4.example.com/tls/ca.crt
  set -x
  peer lifecycle chaincode commit -o orderer.example.com:7050 --channelID $CHANNEL_NAME --name fabcar --version ${VERSION} --sequence ${VERSION} --init-required --tls --cafile $ORDERER_CA --peerAddresses peer0.org2.example.com:9051 --tlsRootCertFiles $ORG2_TLS_ROOTCERT_FILE --peerAddresses peer0.org4.example.com:9061 --tlsRootCertFiles $ORG4_TLS_ROOTCERT_FILE >&log.txt
  res=$?
  set +x
  cat log.txt
  verifyResult $res "Chaincode definition commit failed on peer0.org${ORG} on channel '$CHANNEL_NAME' failed"
  echo "===================== Chaincode definition committed on channel '$CHANNEL_NAME' ===================== "
  echo
}

# queryCommitted ORG
queryCommitted() {

  setEnv 2
  set -x
  peer lifecycle chaincode querycommitted --channelID $CHANNEL_NAME --name fabcar >&log.txt
  res=$?
  set +x
  cat log.txt
  # PACKAGE_ID=$(sed -n "/fabcar_${VERSION}/{s/^Package ID: //; s/, Label:.*$//; p;}" log.txt)
  verifyResult $res "Query installed on peer0.org2 has failed"
  # echo PackageID is ${PACKAGE_ID}
  echo "===================== Query installed successful on peer0.org${ORG} on channel ===================== "
  echo
}

chaincodeInvokeInit() {

  echo
  echo "===================== Invoke chaincode initLedger for fabcar on channel ${CHANNEL_NAME} ===================== "
  echo
  export ORDERER_CA=${PWD}/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
  export ORG2_TLS_ROOTCERT_FILE=${PWD}/crypto/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
  export ORG4_TLS_ROOTCERT_FILE=${PWD}/crypto/peerOrganizations/org4.example.com/peers/peer0.org4.example.com/tls/ca.crt
  set -x
  # peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile $ORDERER_CA -C $CHANNEL_NAME -n fabcar $PEER_CONN_PARMS --isInit -c '{"function":"initLedger","Args":[]}' >&log.txt
  peer chaincode invoke -o orderer.example.com:7050 --isInit -C $CHANNEL_NAME -n fabcar --tls --cafile $ORDERER_CA --peerAddresses peer0.org2.example.com:9051 --tlsRootCertFiles $ORG2_TLS_ROOTCERT_FILE --peerAddresses peer0.org4.example.com:9061 --tlsRootCertFiles $ORG4_TLS_ROOTCERT_FILE -c '{"Args":["InitLedger"]}' >&log.txt
  res=$?
  set +x
  cat log.txt
  verifyResult $res "Invoke execution on $PEERS failed "
  echo "===================== Invoke transaction successful on $PEERS on channel '$CHANNEL_NAME' ===================== "
  echo

}

chaincodeQuery() {

  ORG=$1
  setGlobals $ORG
  echo "===================== Querying on peer0.org${ORG} on channel '$CHANNEL_NAME'... ===================== "
	local rc=1
	local COUNTER=1
	# continue to poll
  # we either get a successful response, or reach MAX RETRY
	while [ $rc -ne 0 -a $COUNTER -lt $MAX_RETRY ] ; do
    sleep $DELAY
    echo "Attempting to Query peer0.org${ORG} ...$(($(date +%s) - starttime)) secs"
    set -x
    peer chaincode query -C $CHANNEL_NAME -n fabcar -c '{"Args":["queryAllCars"]}' >&log.txt
    res=$?
    set +x
		let rc=$res
		COUNTER=$(expr $COUNTER + 1)
	done
  echof
  cat log.txt
  if test $rc -eq 0; then
    echo "===================== Query successful on peer0.org${ORG} on channel '$CHANNEL_NAME' ===================== "
		echo
  else
    echo "!!!!!!!!!!!!!!! After $MAX_RETRY attempts, Query result on peer0.org${ORG} is INVALID !!!!!!!!!!!!!!!!"
    echo
    exit 1
  fi
}




CHANNEL_NAME="$1"
: ${CHANNEL_NAME:="twoorgschannel"}
MODE="$2"
VERSION="$3"


if [ "${MODE}" == "packageCC" ]; then
  packageChaincode $3 $4 $5
elif [ "${MODE}" == "installCC" ]; then
  installChaincode
elif [ "${MODE}" == "queryInstalled" ]; then
  queryInstalled
elif [ "${MODE}" == "approveForMyOrg" ]; then
  approveForMyOrg
elif [ "${MODE}" == "checkCommitReadiness" ]; then
  checkCommitReadiness
elif [ "${MODE}" == "commitChaincodeDefinition" ]; then
  commitChaincodeDefinition
elif [ "${MODE}" == "queryCommitted" ]; then
  queryCommitted
elif [ "${MODE}" == "chaincodeInvokeInit" ]; then
  chaincodeInvokeInit
elif [ "${MODE}" == "chaincodeQuery" ]; then
  chaincodeQuery
else
  # printHelp
  echo "Failed MODE not found ..."
  exit 1
fi

exit 0


# ## at first we package the chaincode
# packageChaincode 1

# ## Install chaincode on peer0.org1 and peer0.org2
# echo "Installing chaincode on peer0.org1..."
# installChaincode 1
# echo "Install chaincode on peer0.org2..."
# installChaincode 2

# ## query whether the chaincode is installed
# queryInstalled 1

# ## approve the definition for org1
# approveForMyOrg 1

# ## check whether the chaincode definition is ready to be committed
# ## expect org1 to have approved and org2 not to
# checkCommitReadiness 1 "\"Org1MSP\": true" "\"Org2MSP\": false"
# checkCommitReadiness 2 "\"Org1MSP\": true" "\"Org2MSP\": false"

# ## now approve also for org2
# approveForMyOrg 2

# ## check whether the chaincode definition is ready to be committed
# ## expect them both to have approved
# checkCommitReadiness 1 "\"Org1MSP\": true" "\"Org2MSP\": true"
# checkCommitReadiness 2 "\"Org1MSP\": true" "\"Org2MSP\": true"

# ## now that we know for sure both orgs have approved, commit the definition
# commitChaincodeDefinition 1 2

# ## query on both orgs to see that the definition committed successfully
# queryCommitted 1
# queryCommitted 2

# ## Invoke the chaincode
# chaincodeInvokeInit 1 2

# sleep 10

# # Query chaincode on peer0.org1
# echo "Querying chaincode on peer0.org1..."
# chaincodeQuery 1

# exit 0

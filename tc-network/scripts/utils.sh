# Author An 2020/6/15

export CC_RUNTIME_LANGUAGE=golang
export GO111MODULE=on
export GOPROXY=https://goproxy.cn

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

# verify the result of the end-to-end test
verifyResult() {
  if [ $1 -ne 0 ]; then
    echo "!!!!!!!!!!!!!!! "$2" !!!!!!!!!!!!!!!!"
    echo "========= ERROR !!! FAILED to execute End-2-End Scenario ==========="
    echo
    exit 1
  fi
}

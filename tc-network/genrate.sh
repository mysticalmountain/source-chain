export PATH=$GOPATH/src/github.com/hyperledger/fabric/build/bin:${PWD}/../bin:${PWD}:$PATH
export FABRIC_CFG_PATH=${PWD}
export CHANNEL_NAME=twoorgchannel
export IMAGE_TAG=1.4.4

echo "##########################################################"
echo "remove crypto-config and config"

rm -fr config/*
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


echo
echo "Generate CCP files for Org1 and Org2"
./ccp-generate.sh

echo "##########################################################"
echo "generate genesis block for orderer"
./bin/configtxgen -configPath=./orderer -profile TwoOrgOrdererGenesis -channelID sys-channel  -outputBlock ./config/TwoOrgOrdererGenesis.block
if [ "$?" -ne 0 ]; then
  echo "Failed to generate orderer genesis block..."
  exit 1
fi

echo "##########################################################"
echo "generate channel configuration transaction"
./bin/configtxgen -configPath=./orderer -profile TwoOrgChannel -outputCreateChannelTx ./config/TwoOrgChannel.tx -channelID $CHANNEL_NAME
if [ "$?" -ne 0 ]; then
  echo "Failed to generate channel configuration transaction..."
  exit 1
fi

echo "##########################################################"
echo "generate anchor peer transaction org2"
./bin/configtxgen -configPath=./orderer -profile TwoOrgChannel -outputAnchorPeersUpdate ./config/TwoOrg2MSPanchors.tx -channelID $CHANNEL_NAME -asOrg Org2MSP
if [ "$?" -ne 0 ]; then
  echo "Failed to generate anchor peer update for Org2MSP..."
  exit 1
fi

echo "##########################################################"
echo "generate anchor peer transaction org4"
./bin/configtxgen -configPath=./orderer -profile TwoOrgChannel -outputAnchorPeersUpdate ./config/TwoOrg4MSPanchors.tx -channelID $CHANNEL_NAME -asOrg Org4MSP
if [ "$?" -ne 0 ]; then
  echo "Failed to generate anchor peer update for Org4MSP..."
  exit 1
fi




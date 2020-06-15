export PATH=$GOPATH/src/github.com/hyperledger/fabric/build/bin:${PWD}/../bin:${PWD}:$PATH
export FABRIC_CFG_PATH=${PWD}
export CHANNEL_NAME=org2channel

echo "##########################################################"
echo "generate channel configuration transaction"
./bin/configtxgen -configPath=./orderer -profile Org2Channel -outputCreateChannelTx ./config/Org2Channel.tx -channelID $CHANNEL_NAME
if [ "$?" -ne 0 ]; then
  echo "Failed to generate channel configuration transaction..."
  exit 1
fi




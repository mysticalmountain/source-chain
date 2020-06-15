
#########################################################################
# Org2
export CHANNEL_NAME=twoorgchannel

peer channel create -c $CHANNEL_NAME -f ./config/TwoOrgChannel.tx -o orderer.example.com:7050 --outputBlock ./config/${CHANNEL_NAME}.block

peer channel join -b ./config/${CHANNEL_NAME}.block

peer channel update -o orderer.example.com:7050 -c $CHANNEL_NAME -f ./config/TwoOrg2MSPanchors.tx


peer lifecycle chaincode package abstore.tar.gz --path github.com/abstore/go --lang golang --label abstore

peer lifecycle chaincode install abstore.tar.gz

peer lifecycle chaincode queryinstalled

export CC_PACKAGE_ID=abstore:e2fc54cc201d208fda60a5830c4c1aef24593fb1264b3267d5dcddf1649b8b1c

peer lifecycle chaincode approveformyorg --channelID $CHANNEL_NAME --name abstore --version 1.0 --init-required --package-id $CC_PACKAGE_ID --sequence 1

peer lifecycle chaincode checkcommitreadiness --channelID $CHANNEL_NAME --name abstore --version 1.0 --init-required --sequence 1 --output json

peer lifecycle chaincode commit -o orderer.example.com:7050 --channelID $CHANNEL_NAME --name abstore --version 1.0 --sequence 1 --init-required --peerAddresses peer0.org2.example.com:9051 --peerAddresses peer0.org4.example.com:9061


#########################################################################
# Org4

export CHANNEL_NAME=twoorgchannel

peer channel join -b ./config/${CHANNEL_NAME}.block

peer channel update -o orderer.example.com:7050 -c $CHANNEL_NAME -f ./config/TwoOrg4MSPanchors.tx

peer lifecycle chaincode install abstore.tar.gz

peer lifecycle chaincode queryinstalled

export CC_PACKAGE_ID=abstore:e2fc54cc201d208fda60a5830c4c1aef24593fb1264b3267d5dcddf1649b8b1c

peer lifecycle chaincode approveformyorg --channelID $CHANNEL_NAME --name abstore --version 1.0 --init-required --package-id $CC_PACKAGE_ID --sequence 1

peer lifecycle chaincode checkcommitreadiness --channelID $CHANNEL_NAME --name abstore --version 1.0 --init-required --sequence 1 --output json

peer lifecycle chaincode commit -o orderer.example.com:7050 --channelID $CHANNEL_NAME --name abstore --version 1.0 --sequence 1 --init-required --peerAddresses peer0.org2.example.com:9051 --peerAddresses peer0.org4.example.com:9061


#########################################################################
# Chaincode execute

peer chaincode invoke -o orderer.example.com:7050 --isInit -C $CHANNEL_NAME -n abstore --peerAddresses peer0.org2.example.com:9051 --peerAddresses peer0.org4.example.com:9061 -c '{"Args":["Init","a","100","b","100"]}' --waitForEvent

peer chaincode query -C $CHANNEL_NAME -n abstore -c '{"Args":["query","a"]}'

peer chaincode query -C $CHANNEL_NAME -n abstore -c '{"Args":["query","b"]}'

peer chaincode invoke -o orderer.example.com:7050 -C $CHANNEL_NAME -n abstore --peerAddresses peer0.org2.example.com:9051 --peerAddresses peer0.org4.example.com:9061 -c '{"Args":["invoke","a","b","10"]}' --waitForEvent


#########################################################################
# Org2 & Org4
peer lifecycle chaincode package fabcar.tar.gz --path github.com/fabcar/go --lang golang --label fabcar

peer lifecycle chaincode install fabcar.tar.gz

peer lifecycle chaincode queryinstalled

export CC_PACKAGE_ID=fabcar:2d737a98c5cfc129cd8e8b6af123c19d97a653bad14b552b19419558e35d5ba2

peer lifecycle chaincode approveformyorg --channelID $CHANNEL_NAME --name fabcar --version 1.0 --init-required --package-id $CC_PACKAGE_ID --sequence 1

peer lifecycle chaincode checkcommitreadiness --channelID $CHANNEL_NAME --name fabcar --version 1.0 --init-required --sequence 1 --output json

peer lifecycle chaincode commit -o orderer.example.com:7050 --channelID $CHANNEL_NAME --name fabcar --version 1.0 --sequence 1 --init-required --peerAddresses peer0.org2.example.com:9051 --peerAddresses peer0.org4.example.com:9061

peer chaincode invoke -o orderer.example.com:7050 --isInit -C $CHANNEL_NAME -n fabcar --peerAddresses peer0.org2.example.com:9051 --peerAddresses peer0.org4.example.com:9061 -c '{"Args":["InitLedger"]}' --waitForEvent

peer chaincode query -C $CHANNEL_NAME -n fabcar -c '{"Args":["queryAllCars"]}'


# sacc
peer lifecycle chaincode package sacc.tar.gz --path github.com/sacc --lang golang --label sacc

peer lifecycle chaincode install sacc.tar.gz

peer lifecycle chaincode queryinstalled

peer lifecycle chaincode checkcommitreadiness --channelID $CHANNEL_NAME --name sacc --version 1.0 --init-required --sequence 3 --output json

export CC_PACKAGE_ID=sacc:dc807c9e6d089c0bebc25c0f0fdca71155d756e242f56a6f2024cbdbfce7925b

peer lifecycle chaincode approveformyorg --channelID $CHANNEL_NAME --name sacc --version 1.0 --init-required --package-id $CC_PACKAGE_ID --sequence 3

peer lifecycle chaincode commit -o orderer.example.com:7050 --channelID $CHANNEL_NAME --name sacc --version 1.0 --sequence 3 --init-required --peerAddresses peer0.org2.example.com:9051 --peerAddresses peer0.org4.example.com:9061

peer chaincode invoke -o orderer.example.com:7050 --isInit -C $CHANNEL_NAME -n sacc --peerAddresses peer0.org2.example.com:9051 --peerAddresses peer0.org4.example.com:9061 -c '{"Args":["a","10"]}' --waitForEvent

peer chaincode query -n sacc -c '{"Args":["query", "a"]}' -C $CHANNEL_NAME

peer chaincode invoke -o orderer.example.com:7050 -C $CHANNEL_NAME -n sacc --peerAddresses peer0.org2.example.com:9051 --peerAddresses peer0.org4.example.com:9061 -c '{"Args":["set", "a", "20"]}' --waitForEvent


# weather


peer lifecycle chaincode package weather.tar.gz --path github.com/weather --lang golang --label weather
peer lifecycle chaincode install weather.tar.gz

export CHANNEL_NAME=org2channel

peer channel create -c $CHANNEL_NAME -f ./config/Org2Channel.tx -o orderer.example.com:7050 --outputBlock ./config/${CHANNEL_NAME}.block

peer channel join -b ./config/${CHANNEL_NAME}.block

peer lifecycle chaincode install weather.tar.gz

peer lifecycle chaincode queryinstalled

export CC_PACKAGE_ID=weather:8ed4f9004caeb6a55a8565f98ebf56f85fba09c9fde3886294525464718edefe

peer lifecycle chaincode approveformyorg --channelID $CHANNEL_NAME --name weather --version 1.0 --init-required --package-id $CC_PACKAGE_ID --sequence 1

peer lifecycle chaincode checkcommitreadiness --channelID $CHANNEL_NAME --name weather --version 1.0 --init-required --sequence 1 --output json

peer lifecycle chaincode commit -o orderer.example.com:7050 --channelID $CHANNEL_NAME --name weather --version 1.0 --sequence 1 --init-required --peerAddresses peer0.org2.example.com:9051

peer chaincode invoke -o orderer.example.com:7050 --isInit -C $CHANNEL_NAME -n weather --peerAddresses peer0.org2.example.com:9051 -c '{"Args":[]}' --waitForEvent

peer chaincode invoke -o orderer.example.com:7050 -C $CHANNEL_NAME -n weather --peerAddresses peer0.org2.example.com:9051 -c '{"Args":["get"]}' --waitForEvent


peer lifecycle chaincode package weather2.tar.gz --path github.com/weather --lang golang --label weather

peer lifecycle chaincode install weather2.tar.gz

export CC_PACKAGE_ID=weather:0219e1e540248b6dada9e03efcfc4d21d8f3b1ba18cb3f0347dcb476ad1fb25f

peer lifecycle chaincode approveformyorg --channelID $CHANNEL_NAME --name weather2 --version 1.0 --init-required --package-id $CC_PACKAGE_ID --sequence 1

peer lifecycle chaincode checkcommitreadiness --channelID $CHANNEL_NAME --name weather2 --version 1.0 --init-required --sequence 1 --output json

peer lifecycle chaincode commit -o orderer.example.com:7050 --channelID $CHANNEL_NAME --name weather2 --version 1.0 --sequence 1 --init-required --peerAddresses peer0.org2.example.com:9051

peer chaincode invoke -o orderer.example.com:7050 --isInit -C $CHANNEL_NAME -n weather2 --peerAddresses peer0.org2.example.com:9051 -c '{"Args":[]}' --waitForEvent

peer chaincode invoke -o orderer.example.com:7050 -C $CHANNEL_NAME -n weather2 --peerAddresses peer0.org2.example.com:9051 -c '{"Args":["get"]}' --waitForEvent






peer lifecycle chaincode package cat.tar.gz --path github.com/cat --lang golang --label cat

peer lifecycle chaincode install cat.tar.gz

export CC_PACKAGE_ID=cat:f0a96a42183d923e4d455f4e74f82bc4530dae28a158ac30006dcb97d6b48c7e

peer lifecycle chaincode approveformyorg --channelID $CHANNEL_NAME --name cat1 --version 1.0 --init-required --package-id $CC_PACKAGE_ID --sequence 1

peer lifecycle chaincode checkcommitreadiness --channelID $CHANNEL_NAME --name cat1 --version 1.0 --init-required --sequence 1 --output json

peer lifecycle chaincode commit -o orderer.example.com:7050 --channelID $CHANNEL_NAME --name cat1 --version 1.0 --sequence 1 --init-required --peerAddresses peer0.org2.example.com:9051

peer chaincode invoke -o orderer.example.com:7050 --isInit -C $CHANNEL_NAME -n cat1 --peerAddresses peer0.org2.example.com:9051 -c '{"Args":[]}' --waitForEvent

peer chaincode invoke -o orderer.example.com:7050 -C $CHANNEL_NAME -n cat1 --peerAddresses peer0.org2.example.com:9051 -c '{"Args":["get"]}' --waitForEvent





peer lifecycle chaincode package petshop5.tar.gz --path github.com/petshop --lang golang --label petshop5

peer lifecycle chaincode install petshop5.tar.gz

peer lifecycle chaincode queryinstalled


export CC_PACKAGE_ID=petshop5:ede26082b3ffef8f3df9010a74fe19798df5ff704af1f5cb3783104ba8094549

peer lifecycle chaincode approveformyorg --channelID $CHANNEL_NAME --name petshop5 --version 1.0 --init-required --package-id $CC_PACKAGE_ID --sequence 1

peer lifecycle chaincode checkcommitreadiness --channelID $CHANNEL_NAME --name petshop5 --version 1.0 --init-required --sequence 1 --output json

peer lifecycle chaincode commit -o orderer.example.com:7050 --channelID $CHANNEL_NAME --name petshop5 --version 1.0 --sequence 1 --init-required --peerAddresses peer0.org2.example.com:9051 --peerAddresses peer0.org4.example.com:9061


peer chaincode invoke -o orderer.example.com:7050 --isInit -C $CHANNEL_NAME -n petshop5 --peerAddresses peer0.org2.example.com:9051 --peerAddresses peer0.org4.example.com:9061 -c '{"Args":[]}' --waitForEvent

peer chaincode invoke -o orderer.example.com:7050 -C $CHANNEL_NAME -n petshop5 --peerAddresses peer0.org2.example.com:9051 --peerAddresses peer0.org4.example.com:9061 -c '{"Args":["get"]}' --waitForEvent

peer chaincode invoke -o orderer.example.com:7050 -C $CHANNEL_NAME -n petshop5 --peerAddresses peer0.org2.example.com:9051 --peerAddresses peer0.org4.example.com:9061 -c '{"Args":["cat"]}' --waitForEvent




peer chaincode query -C $CHANNEL_NAME -n petshop5 -c '{"Args":["get"]}'

peer chaincode query -C $CHANNEL_NAME -n petshop5 -c '{"Args":["cat"]}'


#####################################################################################################################
peer channel list

peer chaincode install -n sacc -v 1.0 -p github.com/sacc

peer chaincode list --installed

peer chaincode instantiate -n sacc -v 1.0 -c '{"Args":["a","10"]}' -C $CHANNEL_NAME -o orderer.example.com:7050

peer chaincode query -n sacc -c '{"Args":["query", "a"]}' -C $CHANNEL_NAME


peer chaincode list --instantiated -C $CHANNEL_NAME


peer chaincode install -n sacc2 -v 2.0 -p github.com/sacc

peer chaincode instantiate -n sacc2 -v 2.0 -c '{"Args":["a","10"]}' -C $CHANNEL_NAME -o orderer.example.com:7050

peer chaincode invoke -n sacc2 -c '{"Args":["set", "a", "20"]}' -C $CHANNEL_NAME

peer chaincode query -n sacc2 -c '{"Args":["query", "a"]}' -C $CHANNEL_NAME



peer chaincode install -n sacc3 -v 1.0 -p github.com/sacc

peer chaincode instantiate -n sacc3 -v 1.0 -c '{"Args":["a","10"]}' -C $CHANNEL_NAME -o orderer.example.com:7050  -P "OR ('Org2MSP.peer', 'Org4SMSP.peer')"

peer chaincode invoke -n sacc3 -c '{"Args":["set", "a", "400"]}' -C $CHANNEL_NAME

peer chaincode query -n sacc3 -c '{"Args":["query", "a"]}' -C $CHANNEL_NAME


peer chaincode install -n sacc4 -v 1.0 -p github.com/sacc

peer chaincode instantiate -n sacc4 -v 1.0 -c '{"Args":["a","10"]}' -C $CHANNEL_NAME -o orderer.example.com:7050  -P "AND ('Org2MSP.peer', 'Org4MSP.peer')"

peer chaincode invoke -n sacc4 -c '{"Args":["set", "a", "20"]}' -C $CHANNEL_NAME

peer chaincode query -n sacc4 -c '{"Args":["query", "a"]}' -C $CHANNEL_NAME

peer chaincode invoke -n sacc4 -c '{"Args":["set", "a", "20"]}' -C $CHANNEL_NAME



peer chaincode install -n sacc5 -v 1.0 -p github.com/sacc

peer chaincode instantiate -n sacc5 -v 1.0 -c '{"Args":["a","10"]}' -C $CHANNEL_NAME -o orderer.example.com:7050  -P "AND ('Org2MSP.peer', 'Org4MSP.peer')"

peer chaincode query -n sacc5 -c '{"Args":["query", "a"]}' -C $CHANNEL_NAME

peer chaincode invoke -o orderer.example.com:7050 -n sacc5 -C $CHANNEL_NAME --peerAddresses peer0.org2.example.com:9051 --peerAddresses peer0.org4.example.com:9061 -c '{"Args":["set", "a", "200"]}'



peer chaincode install -n fabcar -v 1.0 -p github.com/fabcar/go

peer chaincode instantiate -n fabcar -v 1.0 -c '{"Args":["init"]}' -C $CHANNEL_NAME -o orderer.example.com:7050  -P "OR ('Org2MSP.peer', 'Org4MSP.peer')"



export GO111MODULE=on


# System chaincode

export CHANNEL_NAME=twoorgchannel


peer chaincode query -C "twoorgchannel" -n cscc -c '{"Args":["GetConfigBlock", "twoorgchannel"]}'

peer channel fetch -o orderer.example.com:7050 config -c twoorgchannel

peer chaincode query -C "twoorgchannel" -n lscc -c '{"Args":["getdepspec", "twoorgchannel"]}'

peer chaincode query -C "twoorgchannel" -n lscc -c '{"Args":["getchaincodes"]}'

peer chaincode query -C "twoorgchannel" -n lscc -c '{"Args":["getInstalledChaincodes"]}'


peer chaincode query -C "twoorgchannel" -n lscc -c '{"Args":["getinstalledchaincodes"]}'


peer chaincode query -C "twoorgchannel" -n qscc -c '{"Args":["GetBlockByNumber", "twoorgchannel", "3"]}'



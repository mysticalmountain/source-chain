# source-chain

peer lifecycle chaincode commit -o orderer.example.com:7050 --channelID $CHANNEL_NAME --name fabcar --version 1.0 --sequence 3 --init-required --peerAddresses peer0.org2.example.com:9051 --peerAddresses peer0.org4.example.com:9061


peer lifecycle chaincode commit -o orderer.example.com:7050 --channelID $CHANNEL_NAME --name mycc --version 1.0 --sequence 1 --init-required --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem --peerAddresses peer0.org1.example.com:7051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt --peerAddresses peer0.org2.example.com:9051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt

peer lifecycle chaincode commit -o orderer.example.com:7050 --channelID twoorgschannel --name fabcar --version 1 --sequence 1 --init-required --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem --peerAddresses peer0.org2.example.com:9051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt --peerAddresses peer0.org4.example.com:9061 /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org4.example.com/peers/peer0.org4.example.com/tls/ca.crt







../chaincode/fabcar/go

docker exec cli scripts/deployCC.sh twoorgschannel packageCC abstore "/opt/gopath/src/github.com/abstore/go" 1

sh network.sh twoorgschannel packageCC abstore "/opt/gopath/src/github.com/abstore/go" 1





sh network.sh deployCC twoorgschannel abstore "/opt/gopath/src/github.com/abstore/go" 1











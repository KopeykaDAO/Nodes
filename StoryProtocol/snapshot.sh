sudo systemctl stop story 
sudo systemctl stop geth

# backup priv_validator_state.json
cp $HOME/.story/story/data/priv_validator_state.json $HOME/.story/story/priv_validator_state.json.backup

# remove old data and unpack Story snapshot
rm -rf $HOME/.story/story/data
curl https://server-3.itrocket.net/testnet/story/story_2024-10-11_1344141_snap.tar.lz4 | lz4 -dc - | tar -xf - -C $HOME/.story/story

# restore priv_validator_state.json
mv $HOME/.story/story/priv_validator_state.json.backup $HOME/.story/story/data/priv_validator_state.json

# delete geth data and unpack Geth snapshot
rm -rf $HOME/.story/geth/iliad/geth/chaindata
curl https://server-3.itrocket.net/testnet/story/geth_story_2024-10-11_1344141_snap.tar.lz4 | lz4 -dc - | tar -xf - -C $HOME/.story/geth/iliad/geth

# restart node and check logs
sudo systemctl restart story
sudo systemctl restart geth
sudo journalctl -u geth -u story -f

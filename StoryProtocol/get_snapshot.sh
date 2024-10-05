sudo systemctl stop geth                         
sudo systemctl stop story

# Back up your validator state
cp $HOME/.story/story/data/priv_validator_state.json $HOME/.story/priv_validator_state.json.backup

# Delete previous geth chaindata and story data folders
sudo rm -rf $HOME/.story/geth/iliad/geth/chaindata
sudo rm -rf $HOME/.story/story/data

# Download story-geth and story snapshots
wget -O geth_snapshot.lz4 https://snapshots2.mandragora.io/story/geth_snapshot.lz4
wget -O story_snapshot.lz4 https://snapshots2.mandragora.io/story/story_snapshot.lz4

# Decompress story-geth and story snapshots
lz4 -c -d geth_snapshot.lz4 | tar -xv -C $HOME/.story/geth/iliad/geth
sudo rm -v geth_snapshot.lz4
lz4 -c -d story_snapshot.lz4 | tar -xv -C $HOME/.story/story

# Delete downloaded story-geth and story snapshots
sudo rm -v story_snapshot.lz4

# Restore your validator state
cp $HOME/.story/priv_validator_state.json.backup $HOME/.story/story/data/priv_validator_state.json

# Start your story-geth and story nodes
sudo systemctl start geth
sudo systemctl start story

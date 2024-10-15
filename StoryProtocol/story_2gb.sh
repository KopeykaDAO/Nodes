sudo systemctl stop story geth
rm -rf $HOME/.story/geth/iliad/geth/chaindata
cp $HOME/.story/story/data/priv_validator_state.json $HOME/.story/story/priv_validator_state.json.backup
rm -rf $HOME/.story/story/data
curl -o - -L https://story.snapshot.stavr.tech/story-snap.tar.lz4 | lz4 -c -d - | tar -x -C $HOME/.story/story/
curl -o - -L https://story.snapshot.stavr.tech/story_geth-snap.tar.lz4 | lz4 -c -d - | tar -x -C $HOME/.story/geth/iliad/geth/
mv $HOME/.story/story/priv_validator_state.json.backup $HOME/.story/story/data/priv_validator_state.json
wget -O $HOME/.story/story/config/addrbook.json "https://raw.githubusercontent.com/111STAVR111/props/main/Story/addrbook.json"
sudo systemctl restart geth story
sudo journalctl -f -u story -u geth

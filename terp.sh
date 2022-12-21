#!/bin/bash
GREEN_COLOR='\033[0;32m'
RED_COLOR='\033[0;31m'
NO_COLOR='\033[0m'
BLOCK=1497396
VERSION=v0.2.0
echo -e "$GREEN_COLOR ВАША НОДА БУДЕТ ОБНОВЛЕНА ДО (YOUR NODE WILL BE UPDATED TO VERSION): $VERSION НА БЛОКЕ (ON BLOCK) №: $BLOCK $NO_COLOR\n"
for((;;)); do
	height=$(terpd status |& jq -r ."SyncInfo"."latest_block_height")
	if ((height>=$BLOCK)); then

		sudo systemctl stop terpd
		cd $HOME && rm -rf terp-core
		git clone https://github.com/terpnetwork/terp-core.git
		cd terp-core
		git checkout v0.2.0
		make install
		curl -s  https://raw.githubusercontent.com/terpnetwork/test-net/master/athena-2/0.2.0/genesis.json > ~/.terp/config/genesis.json
		sudo systemctl restart terpd && journalctl -fu terpd -o cat

		for (( timer=60; timer>0; timer-- )); do
			printf "* second restart after sleep for ${RED_COLOR}%02d${NO_COLOR} sec\r" $timer
			sleep 1
		done
		height=$(terpd status |& jq -r ."SyncInfo"."latest_block_height")
		if ((height>$BLOCK)); then
			echo -e "$GREEN_COLOR ВАША НОДА ПОЛНОСТЬЮ ОБНОВЛЕНА ДО ВЕРСИИ (YOUR NODE WAS SUCCESFULLY UPDATED TO VERSION:): $VERSION $NO_COLOR\n"
		fi
		terpd version --long | head
		break
	else
		echo -e "${GREEN_COLOR}$height${NO_COLOR} ($(( BLOCK - height  )) Блоков осталось(blocks left) )"
	fi
	sleep 5
done

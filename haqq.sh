#!/bin/bash
GREEN_COLOR='\033[0;32m'
RED_COLOR='\033[0;31m'
NO_COLOR='\033[0m'
BLOCK=1412300
VERSION=v1.3.0
echo -e "$GREEN_COLOR ВАША НОДА БУДЕТ ОБНОВЛЕНА ДО (YOUR NODE WILL BE UPDATED TO VERSION): $VERSION НА БЛОКЕ (ON BLOCK) №: $BLOCK $NO_COLOR\n"
for((;;)); do
	height=$(haqqd status |& jq -r ."SyncInfo"."latest_block_height")
	if ((height>=$BLOCK)); then

		sudo systemctl stop haqqd
		cd $HOME && rm -rf haqq
		git clone https://github.com/haqq-network/haqq.git
		cd haqq
		git checkout $VERSION
		make build
		sudo mv ./build/haqqd $(which haqqd)
		sudo systemctl restart haqqd && journalctl -fu haqqd -o cat

		for (( timer=60; timer>0; timer-- )); do
			printf "* second restart after sleep for ${RED_COLOR}%02d${NO_COLOR} sec\r" $timer
			sleep 1
		done
		height=$(haqqd status |& jq -r ."SyncInfo"."latest_block_height")
		if ((height>$BLOCK)); then
			echo -e "$GREEN_COLOR ВАША НОДА ПОЛНОСТЬЮ ОБНОВЛЕНА ДО ВЕРСИИ (YOUR NODE WAS SUCCESFULLY UPDATED TO VERSION:): $VERSION $NO_COLOR\n"
		fi
		haqqd version --long | head
		break
	else
		echo -e "${GREEN_COLOR}$height${NO_COLOR} ($(( BLOCK - height  )) блоков осталось(blocks left) )"
	fi
	sleep 5
done

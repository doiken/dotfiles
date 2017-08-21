#/bin/bash

init_key_repeat=14 # normal minimum is 15 (225 ms)
key_repeat=1 # normal minimum is 2 (30 ms)

boost () {
  defaults write -g InitialKeyRepeat -int $init_key_repeat
  defaults write -g KeyRepeat -int $key_repeat
}

if [ $(defaults read -g InitialKeyRepeat) -eq $init_key_repeat ]; then
  exit 0
fi

echo -n "key repeat not boosted. boost it?[y/n]: "
read yn

if [ $yn == 'y' ]; then
  boost
fi

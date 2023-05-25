#!/bin/bash

METAMOD=https://mms.alliedmods.net/mmsdrop/1.11/mmsource-1.11.0-git1148
SOURCEMOD=https://sm.alliedmods.net/smdrop/1.11/sourcemod-1.11.0-git6934
MMOUT=metamod
SMOUT=sourcemod

if [[ "$1" = "win" ]]; then
  SUFFIX=-windows.zip
  COMPILE=./compile.exe
  UNZIP=unzip
  dos2unix ./sourcemod/scripting/disabled.txt
else
  SUFFIX=-linux.tar.gz
  COMPILE=./compile.sh
  UNZIP=tar\ xvf
fi

METAMOD=$METAMOD$SUFFIX
SOURCEMOD=$SOURCEMOD$SUFFIX
MMOUT=$MMOUT$SUFFIX
SMOUT=$SMOUT$SUFFIX

# clear old build
rm -r build
mkdir build

# download metamod
curl -o ./build/$MMOUT $METAMOD
cd ./build
$UNZIP $MMOUT
cd ..

# download sourcemod
curl -o ./build/$SMOUT $SOURCEMOD
cd ./build
$UNZIP $SMOUT
cd ..

# clean up zips
rm ./build/*$SUFFIX

# merge repo in
cp -r -u ./sourcemod/* ./build/addons/sourcemod

# move disabled plugins
cat ./sourcemod/scripting/disabled.txt | while read line
do
  mv ./build/addons/sourcemod/scripting/$line.sp ./build/addons/sourcemod/scripting/disabled
done

# compile
cd ./build/addons/sourcemod/scripting
$COMPILE
cd ../../../..

# move compiled plugins
mv ./build/addons/sourcemod/scripting/compiled/* ./build/addons/sourcemod/plugins

# move completed sourcemod into sm
mkdir ./build/_sm
mv ./build/* ./build/_sm || true

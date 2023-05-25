METAMOD=https://mms.alliedmods.net/mmsdrop/1.11/mmsource-1.11.0-git1148
SOURCEMOD=https://sm.alliedmods.net/smdrop/1.11/sourcemod-1.11.0-git6934
MMOUT=metamod
SMOUT=sourcemod

if [[ "$1" = "win" ]]; then
  SUFFIX=-windows.zip
  COMPILE=./compile.exe
  dos2unix ./tf/addons/sourcemod/scripting/disabled.txt
else
  SUFFIX=-linux.tar.gz
  COMPILE=./compile.sh
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
unzip $MMOUT
cd ..

# download sourcemod
curl -o ./build/$SMOUT $SOURCEMOD
cd ./build
unzip $SMOUT
cd ..

# merge repo in
cp -r -u ./tf/addons/sourcemod/* ./build/addons/sourcemod

# move disabled plugins
test -e ./build/addons/sourcemod/scripting/disabled || mkdir ./build/addons/sourcemod/scripting/disabled
cat ./tf/addons/sourcemod/scripting/disabled.txt | while read line
do
  mv ./build/addons/sourcemod/scripting/$line.sp ./build/addons/sourcemod/scripting/disabled
done

# compile
cd ./build/addons/sourcemod/scripting
$COMPILE
cd ../../../..

# move compiled plugins
mv ./build/addons/sourcemod/scripting/compiled/* ./build/addons/sourcemod/plugins

# clean up
rm ./build/*$SUFFIX

# move in current config
cp -r ./tf/* ./build
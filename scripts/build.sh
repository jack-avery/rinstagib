METAMOD=https://mms.alliedmods.net/mmsdrop/1.11/mmsource-1.11.0-git1148-linux.tar.gz
SOURCEMOD=https://sm.alliedmods.net/smdrop/1.11/sourcemod-1.11.0-git6934-linux.tar.gz

# clear old build
test -e build || rm -r build
mkdir build

# download latest metamod
curl -o ./build/metamod.tar.gz $METAMOD
cd ./build
tar xvf metamod.tar.gz

# download latest sourcemod
curl -o ./build/sourcemod.tar.gz $SOURCEMOD
cd ./build
tar xvf sourcemod.tar.gz

# merge repo in
cd ..
cp -r -u ./tf/addons/sourcemod/* ./build/addons/sourcemod

# move disabled plugins
test -e ./build/addons/sourcemod/scripting/disabled || mkdir ./build/addons/sourcemod/scripting/disabled 
cat ./build/addons/sourcemod/scripting/disabled.txt | while read line
do
  mv "./build/addons/sourcemod/scripting/$line.sp" "./build/addons/sourcemod/scripting/disabled"
done

# compile
cd ./build/addons/sourcemod/scripting
./compile.sh
cd ../../../..

# move compiled plugins
mv ./build/addons/sourcemod/scripting/compiled/* ./build/addons/sourcemod/plugins

# clean up
rm ./build/*.tar.gz

# move in current config
cp -r ./tf/* ./build

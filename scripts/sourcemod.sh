METAMOD = https://mms.alliedmods.net/mmsdrop/1.11/mmsource-1.11.0-git1148-linux.tar.gz
SOURCEMOD = https://sm.alliedmods.net/smdrop/1.11/sourcemod-1.11.0-git6934-linux.tar.gz

# download latest sourcemod
curl -o ./build/sourcemod.tar.gz $SOURCEMOD
cd ./build
tar xvf sourcemod.tar.gz

# merge repo in
cd ..
cp -r -u ./tf/addons/sourcemod/* ./build/addons/sourcemod

# compile
cd ./build/addons/sourcemod/scripting
./compile.sh
# nimTexturePacker
simple texture packer

for now this generates json files compatible with 
https://babylonjs.com/

```
nim c -r -d:release --opt:speed ./texturepacker
texturepacker --cols=4 -o=/tmp/out.png /home/user/assets/*.png

$ ls /tmp/out*
/tmp/out.json  /tmp/out.png

```

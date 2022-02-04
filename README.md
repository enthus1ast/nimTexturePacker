# nimTexturePacker
simple texture packer

for now this generates json files compatible with 
https://doc.babylonjs.com/divingDeeper/sprites/sprite_map

```
nimble build -d:release
texturepacker --cols=4 -o=/tmp/out.png /home/user/assets/*.png

$ ls /tmp/out*
/tmp/out.json  /tmp/out.png

```

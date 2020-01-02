import imageman
import tables
import json
import os

type
  TexPack = object
    textures: Table[string, Image[ColorRGBAF]]
    outImage: Image[ColorRGBAF]
    outPath: string
    outWidth: int
    outHeight: int

proc newTexPack(): TexPack =
  result = TexPack()

proc pack(texPack: var TexPack, output: string, paths: seq[string]) =
  var images = newSeq[Image[ColorRGBAF]]()
  var maxWidth: int = 0 
  var maxHeight: int = 0
  var width: int = 0
  for path in paths:
    echo "[+] ", path
    var image: Image[ColorRGBAF] = loadImage[ColorRGBAF](path)
    images.add image
    width += image.width
    if maxWidth < image.width:
      maxWidth = image.width
    if maxHeight < image.height:
      maxHeight = image.height
    texPack.textures[path.extractFilename()] = image
  texPack.outPath = output
  texPack.outWidth = width
  texPack.outHeight = maxHeight
  texPack.outImage = initImage[ColorRGBAF](width, maxHeight)
  var curWidth: int = 0
  for image in images:
    blit(texPack.outImage, image, curWidth, 0)
    curWidth.inc image.width
  savePng[ColorRGBAF](texPack.outImage, output)

proc serializeBabylon(texPack: TexPack): string =
  ## babylon.js compatible
  var json: JsonNode = %* {}
  json["frames"] = %* {}
  var curWidth: int = 0
  for (name, texture) in texPack.textures.pairs():
    json["frames"][name] = %* {
      "frame": %* {
        "x": % curWidth,
        "y": % 0,
        "w": % texture.width,
        "h": % texture.height
      }
    }
    curWidth.inc(texture.width)
  json["meta"] = %* {
    "image": texPack.outPath.extractFilename(),
    "size": {
      "w": texPack.outImage.width,
      "h": texPack.outImage.height
    }
  }
  return $json

proc main(output: string, paths: seq[string]) =
  var texPack = newTexPack()
  texPack.pack(output, paths)
  var data: string = texPack.serializeBabylon()
  let pathSplit = splitFile(output)
  var jsonPath: string = pathSplit.dir / pathSplit.name & ".json"
  echo "[>] ", output
  echo "[>] ", jsonPath
  writeFile(jsonPath, data)


when isMainModule:
  import cligen
  # pack(
  #   "out.png",
  #   @[
  #     "/home/david/quark/src/public/assets/nebulas/Nebula1.png", 
  #     "/home/david/quark/src/public/assets/nebulas/Nebula2.png",
  #     "/home/david/quark/src/public/assets/nebulas/Nebula3.png"
  #   ]
  # )
  dispatch main
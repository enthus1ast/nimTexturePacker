import pixie
import vmath
import tables
import json
import os

type
  Texture = ref object
    path: string
    img: Image
    pos: IVec2
  Textures = seq[Texture]
  TexPack = object
    textures: Textures
    textureMap: seq[seq[Texture]]
    outImage: Image
    outPath: string
    outWidth: int32
    outHeight: int32
    drawPos: IVec2

proc newTexPack(): TexPack =
  result = TexPack()

proc expectedDistribute[T](dats: seq[T], cols: int): seq[seq[T]] =
  var cnt: seq[T] = @[]
  for dat in dats:
    cnt.add dat
    if cnt.len == cols:
      result.add cnt
      cnt = @[]
  if cnt.len > 0:
    result.add cnt

proc maxHeight(textures: Textures): int =
  for texture in textures:
    result = max(texture.img.height, result)

proc maxHeight(texture: Texture): int =
  texture.img.height

proc maxWidth(textures: Textures): int =
  for texture in textures:
    result += max(texture.img.width, result)

proc width(textures: Textures): int =
  for texture in textures:
    result += texture.img.width

proc maxWidth(texture: Texture): int =
    texture.img.width

proc getOutputDimension(texPack: TexPack, cols: int): IVec2 =
  var dist = texPack.textures.expectedDistribute(cols)
  for row in dist:
    result.x = max(row.width, result.x).int32
    result.y += row.maxHeight().int32

proc load(texPack: var TexPack, paths: seq[string]) =
  for path in paths:
    texPack.textures.add Texture(path: path, img: readImage(path), pos: ivec2(0, 0))

proc pack(texPack: var TexPack, outPath: string, paths: seq[string], cols: int) =
  texPack.load(paths)
  texPack.textureMap = texPack.textures.expectedDistribute(cols)
  var dimension = texPack.getOutputDimension(cols)
  texPack.outImage = newImage(dimension.x, dimension.y)
  var distTextures = texPack.textures.expectedDistribute(cols)

  for row in distTextures:
    for col in row:
      draw(texPack.outImage, col.img, translate(vec2(texPack.drawPos.x.float, texPack.drawPos.y.float)))
      echo "[+] ", col.path
      col.pos = texPack.drawPos
      texPack.drawPos.x.inc(col.img.width)
    texPack.drawPos.x = 0
    texPack.drawPos.y.inc(row.maxHeight)
  writeFile(texPack.outImage, outPath)

proc serializeBabylon(texPack: TexPack): string =
  ## babylon.js compatible
  var json: JsonNode = %* {}
  json["frames"] = %* {}
  for texture in texPack.textures:
    json["frames"][texture.path.extractFilename()] = %* {
      "frame": %* {
        "x": % texture.pos.x,
        "y": % texture.pos.y,
        "w": % texture.img.width,
        "h": % texture.img.height
      }
    }
  json["meta"] = %* {
    "image": texPack.outPath.extractFilename(),
    "size": {
      "w": texPack.outImage.width,
      "h": texPack.outImage.height
    }
  }
  return $json

proc main(output: string, cols = 2, paths: seq[string]) =
  var texPack = newTexPack()
  texPack.pack(output, paths, cols)
  var data: string = texPack.serializeBabylon()
  let pathSplit = splitFile(output)
  var jsonPath: string = pathSplit.dir / pathSplit.name & ".json"
  echo "[>] ", output
  echo "[>] ", jsonPath
  writeFile(jsonPath, data)


when isMainModule:
  import cligen
  # var texPack = newTexPack()
  # texPack.pack(
  #   "out.png",
  #   @[
  #     "/home/david/Downloads/ch4tcode0.png",
  #     "/home/david/Downloads/592-shinto-shrine.png",
  #     "/home/david/quark/src/public/assets/nebulas/Nebula1.png", 
  #     "/home/david/quark/src/public/assets/nebulas/Nebula2.png",
  #     "/home/david/quark/src/public/assets/nebulas/Nebula3.png"
  #   ],
  #   1
  # )
  dispatch main
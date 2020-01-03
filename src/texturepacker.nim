import imageman
import tables
import json
import os
import sequtils
import glm/vec
import algorithm

type
  Img = Image[ColorRGBAF]
  Texture = tuple[path: string, img: Img]
  Textures = seq[Texture]
  TexPack = object
    textures: Textures
    textureMap: seq[seq[Texture]]
    outImage: Img
    outPath: string
    outWidth: int
    outHeight: int
    drawPos: Vec2[int]

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

proc getOutputDimension(texPack: TexPack, cols: int): Vec2[int] =
  var dist = texPack.textures.expectedDistribute(cols)
  for row in dist:
    result.x = max(row.width, result.x)
    result.y += row.maxHeight()

proc load(texPack: var TexPack, paths: seq[string]) =
  for path in paths:
    texPack.textures.add (path, loadImage[ColorRGBAF](path))

proc savePng(texPack: TexPack, path: string) =
  savePng[ColorRGBAF](texPack.outImage, path)

proc pack(texPack: var TexPack, outPath: string, paths: seq[string], cols: int) =
  texPack.load(paths)
  texPack.textureMap = texPack.textures.expectedDistribute(cols)

  # var cols = 1
  # var rows = (texPack.textures.len / cols).ceil.int
  # var rows = (texPack.textures.len mod cols)  + (texPack.textures.len div cols)
  # echo rows
  # echo expectedDistribute(@[1,2,3,4,5], cols)
  var dimension = texPack.getOutputDimension(cols)
  texPack.outImage = initImage[ColorRGBAF](dimension.x, dimension.y)
  # texPack.outImage = initImage[ColorRGBAF](2_000, 3_000)
  var distTextures = texPack.textures.expectedDistribute(cols)
  # echo distTextures.mapit(it.path)

  for row in distTextures:
    for col in row:
      blit(texPack.outImage, col.img, texPack.drawPos.x, texPack.drawPos.y)
      texPack.drawPos.x.inc(col.img.width)
    texPack.drawPos.x = 0
    texPack.drawPos.y.inc(row.maxHeight)
  savePng[ColorRGBAF](texPack.outImage, outPath)
    # curWidth.inc image.width


  # echo dist
  # echo texPack.images
  # echo toSeq(texPack.textures.keys())[0]
  # echo texPack.images()[0..1].maxHeight()
  # var maxWidth: int = 0 
  # var maxHeight: int = 0
  # var width: int = 0
  # for path in paths:
  #   echo "[+] ", path
  #   var image: Img = loadImage[ColorRGBAF](path)
  #   images.add image
  #   width += image.width
  #   if maxWidth < image.width:
  #     maxWidth = image.width
  #   if maxHeight < image.height:
  #     maxHeight = image.height
  #   # texPack.images[path.extractFilename()] = image
  # texPack.outPath = output
  # texPack.outWidth = width
  # texPack.outHeight = maxHeight
  # texPack.outImage = initImage[ColorRGBAF](width, maxHeight)
  # var curWidth: int = 0
  # for image in texPack.images:
  #   blit(texPack.outImage, image, curWidth, 0)
  #   curWidth.inc image.width
  # savePng[ColorRGBAF](texPack.outImage, output)

# proc serializeBabylon(texPack: TexPack): string =
#   ## babylon.js compatible
#   var json: JsonNode = %* {}
#   json["frames"] = %* {}
#   var curWidth: int = 0
#   for (name, texture) in texPack.textures.pairs():
#     json["frames"][name] = %* {
#       "frame": %* {
#         "x": % curWidth,
#         "y": % 0,
#         "w": % texture.width,
#         "h": % texture.height
#       }
#     }
#     curWidth.inc(texture.width)
#   json["meta"] = %* {
#     "image": texPack.outPath.extractFilename(),
#     "size": {
#       "w": texPack.outImage.width,
#       "h": texPack.outImage.height
#     }
#   }
#   return $json

# proc main(output: string, paths: seq[string]) =
#   var texPack = newTexPack()
#   texPack.pack(output, paths, 3)
#   # var data: string = texPack.serializeBabylon()
#   # let pathSplit = splitFile(output)
#   # var jsonPath: string = pathSplit.dir / pathSplit.name & ".json"
#   # echo "[>] ", output
#   # echo "[>] ", jsonPath
#   # writeFile(jsonPath, data)


when isMainModule:
  import cligen
  var texPack = newTexPack()
  texPack.pack(
    "out.png",
    @[
      "/home/david/Downloads/ch4tcode0.png",
      "/home/david/Downloads/592-shinto-shrine.png",
      "/home/david/quark/src/public/assets/nebulas/Nebula1.png", 
      "/home/david/quark/src/public/assets/nebulas/Nebula2.png",
      "/home/david/quark/src/public/assets/nebulas/Nebula3.png"
    ],
    1
  )
  # dispatch main
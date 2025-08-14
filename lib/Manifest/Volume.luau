--!strict

local Meta = require('@develfish-repo.utils/lib/Meta')
local ComposeVolume = require('../Compose/Volume')

local Volume = {}

export type Volume = typeof(Volume) & VolumeProps

export type VolumeProps = {
  volume: ComposeVolume.Volume?,
  source: string?,
  path: string,
}

function Volume:new(o: VolumeProps): Volume
  return Meta:type(o, self, 'Manifest.Volume')
end

function Volume:from_volume(volume: ComposeVolume.Volume, path: string): Volume
  assert(volume ~= nil)
  assert(path ~= nil)
  return Volume:new({
    volume = volume,
    path = path,
  })
end

function Volume:from_source(source: string, path: string): Volume
  assert(source ~= nil)
  assert(path ~= nil)
  return Volume:new({
    source = source,
    path = path,
  })
end

return Volume

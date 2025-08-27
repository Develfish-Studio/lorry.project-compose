--!strict

local Meta = require('@lorry.utils/lib/Meta')

local Volume = {}

export type Volume = typeof(Volume) & VolumeProps

export type VolumeProps = {
  name: string,
  data: VolumeData,
}

export type VolumeData = {
  external: boolean?,
  name: string?,
  driver: string?,
  driver_opts: {[string]: string}?,
}

function Volume:new(o: VolumeProps): Volume
  return Meta:type(o, self, 'Compose.Volume')
end

function Volume:from(name: string): Volume
  return Volume:new({
    name = name,
    data = {}
  })
end

function Volume:with_external(external: boolean?): Volume
  local this = self::Volume
  this.data.external = external
  return self
end

function Volume:with_actual_name(name: string?): Volume
  local this = self::Volume
  this.data.name = name
  return self
end

function Volume:with_driver(driver: string?): Volume
  local this = self::Volume
  this.data.driver = driver
  return self
end

function Volume:with_driver_opts(driver_opts: {[string]: string}?): Volume
  local this = self::Volume
  this.data.driver_opts = driver_opts
  return self
end

return Volume

--!strict

local Meta = require('@develfish-repo.utils/lib/Meta')
local Link = require('./manifest/Link')
local DependsOn = require('./manifest/DependsOn')
local EnvVariable = require('./manifest/EnvVariable')
local Volume = require('./manifest/Volume')
local Network = require('./manifest/Network')

local Manifest = {
  Link = Link,
  DependsOn = DependsOn,
  EnvVariable = EnvVariable,
  Volume = Volume,
  Network = Network,
}

export type Manifest = typeof(Manifest)

export type ManifestProps = {
  image: string?,
  environment: {EnvVariable.EnvVariable},
  depends_on: {DependsOn.DependsOn},
  links: {Link.Link},
  volumes: {Volume.Volume},
  networks: {Network.Network},
}

export type ManifestImpl = Manifest & ManifestProps

export type AnyChild = Link.Link | DependsOn.DependsOn | EnvVariable.EnvVariable | Volume.Volume | Network.Network;

export type Environment = {
  [string]: any
}

export type Unwrapped = {
  image: string?,
  environment: Environment?,
  depends_on: {string}?,
  links: {string}?,
  volumes: {string}?,
  networks: {string}?,
}

function Manifest:new(o: ManifestProps): Manifest
  return Meta:type(o, self, 'Manifest')
end

function Manifest:from_empty(): Manifest
  return Manifest:new {
    environment = Meta:array {},
    depends_on = Meta:array {},
    links = Meta:array {},
    volumes = Meta:array {},
    networks = Meta:array {}
  }
end

function Manifest:setup(children: {AnyChild}): Manifest
  local this = self::ManifestImpl
  children = children or Meta:array {}

  for _, child in children do
    this:with_child(child)
  end

  return this
end

function Manifest:with_child(child: AnyChild): Manifest
  local this = self::ManifestImpl
  local tag = Meta:typeof(child)
  if tag == 'Manifest.Link' then
    this.links[#this.links + 1] = child::Link.Link
  elseif tag == 'Manifest.DependsOn' then
    this.depends_on[#this.depends_on + 1] = child::DependsOn.DependsOn
  elseif tag == 'Manifest.EnvVariable' then
    this.environment[#this.environment + 1] = child::EnvVariable.EnvVariable
  elseif tag == 'Manifest.Volume' then
    this.volumes[#this.volumes + 1] = child::Volume.Volume
  elseif tag == 'Manifest.Network' then
    this.networks[#this.networks + 1] = child::Network.Network
  end
  return this
end

function Manifest:with_image(image: string?): Manifest
  local this = self::ManifestImpl
  this.image = image
  return this
end

function Manifest:with_env_variable(name: string, value: string?): Manifest
  local this = self::ManifestImpl
  this.environment[#self.environment + 1] = EnvVariable:from(name, value)
  return this
end

-- function Manifest:with_depends_on(dependency: DependsOn.DependsOn): Manifest
--   local this = self::ManifestImpl
--   this.depends_on[#this.depends_on + 1] = dependency
--   return this
-- end

-- function Manifest:with_link(link: Link.Link): Manifest
--   local this = self::ManifestImpl
--   this.links[#this.links + 1] = link
--   return this
-- end

function Manifest:unwrap(): Unwrapped
  local this = self::ManifestImpl
  return {
    image = this.image,
    environment = this:unwrap_environment(),
    depends_on = this:unwrap_depends_on(),
    links = this:unwrap_links(),
    volumes = this:unwrap_volumes(),
    networks = this:unwrap_networks(),
  }
end

function Manifest:unwrap_volumes(): {string}?
  local this = self::ManifestImpl
  if (#this.volumes == 0) then
    return nil
  end
  local result = Meta:array {}
  for _, v in this.volumes do
    if v.volume ~= nil then
      result[#result + 1] = v.volume.name .. ':' .. v.path
    elseif v.source ~= nil then
      result[#result + 1] = v.source .. ':' .. v.path
    end
  end
  return result
end

function Manifest:unwrap_networks(): {string}?
  local this = self::ManifestImpl
  if (#this.networks == 0) then
    return nil
  end
  local result = Meta:array {}
  for _, n in this.networks do
    result[#result + 1] = n.network.name
  end
  return result
end

function Manifest:unwrap_depends_on(): {string}?
  local this = self::ManifestImpl
  if (#this.depends_on == 0) then
    return nil
  end
  local result = Meta:array {}
  for _, v in this.depends_on do
    result[#result + 1] = v.service
  end
  return result
end

function Manifest:unwrap_links(): {string}?
  local this = self::ManifestImpl
  if (#this.links == 0) then
    return nil
  end
  local result = Meta:array {}
  for _, v in this.links do
    if v.alias == nil then
      result[#result + 1] = v.service
    else
      result[#result + 1] = v.service .. ':' .. v.alias
    end
  end
  return result
end

function Manifest:unwrap_environment(): {[string]: any}?
  local this = self::ManifestImpl
  if (#this.environment == 0) then
    return nil
  end
  local result = Meta:table {}
  for _, v in this.environment do
    result[v.name] = v.value
  end
  return result
end

return Manifest

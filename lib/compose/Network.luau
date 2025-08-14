--!strict

local Meta = require('@develfish-repo.utils/lib/Meta')

local Network = {}

export type Network = typeof(Network) & NetworkProps

export type NetworkProps = {
  name: string,
  data: NetworkData,
}

export type NetworkData = {
  driver: string?,
  driver_opts: {[string]: string}?,
}

function Network:new(o: NetworkProps): Network
  return Meta:type(o, self, 'Compose.Network')
end

function Network:from(name: string): Network
  return Network:new({
    name = name,
    data = {}
  })
end

function Network:with_driver(driver: string?): Network
  local this = self::Network
  this.data.driver = driver
  return self
end

function Network:with_driver_opts(driver_opts: {[string]: string}?): Network
  local this = self::Network
  this.data.driver_opts = driver_opts
  return self
end

return Network

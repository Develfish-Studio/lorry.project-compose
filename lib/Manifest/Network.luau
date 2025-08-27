--!strict

local Meta = require('@lorry.utils/lib/Meta')
local ComposeNetwork = require('../Compose/Network')

local Network = {}

export type Network = typeof(Network) & NetworkProps

export type NetworkProps = {
  network: ComposeNetwork.Network,
}

function Network:new(o: NetworkProps): Network
  return Meta:type(o, self, 'Manifest.Network')
end

function Network:from(network: ComposeNetwork.Network): Network
  assert(network ~= nil)
  return Network:new({
    network = network,
  })
end

return Network

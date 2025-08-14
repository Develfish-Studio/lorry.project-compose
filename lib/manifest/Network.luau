--!strict

local Meta = require('@develfish-repo.utils/lib/Meta')
local ComposeNetwork = require('../compose/Network')

local Network = {}

export type Network = typeof(Network) & NetworkProps

export type NetworkProps = {
  network: ComposeNetwork.Network,
}

function Network:new(o: NetworkProps): Network
  return Meta:type(o, self, 'Manifest.Network')
end

function Network:from(network: ComposeNetwork.Network): Network
  assert(Network ~= nil)
  return Network:new({
    network = network,
  })
end

return Network

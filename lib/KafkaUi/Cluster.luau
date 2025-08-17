local Meta = require('@develfish-repo.utils/lib/Meta')
local Wrapper = require('@develfish-repo.project/lib/Wrapper')

local Cluster = {}

export type Cluster = typeof(Cluster) & ClusterProps & Wrapper.Unwrappable<Unwrapped>

export type ClusterProps = {
  name: string,
  bootstrap_servers: string,
}

export type Unwrapped = ClusterProps

export type Datasource = { uri: string?, username: string?, password: string? }

function Cluster:new(o: ClusterProps): Cluster
  return Meta:type(o, self, 'KafkaUi.Cluster')
end

function Cluster:from(name: string, bootstrap_servers: string): Cluster
  assert(name ~= nil)
  assert(bootstrap_servers ~= nil)
  return Cluster:new({
    name = name,
    bootstrap_servers = bootstrap_servers,
  })
end

function Cluster: unwrap(): Unwrapped
  local this = self::Cluster
  return {
    name = this.name,
    bootstrap_servers = this.bootstrap_servers
  }
end

return Cluster

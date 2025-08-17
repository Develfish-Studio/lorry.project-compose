local Meta = require('@develfish-repo.utils/lib/Meta')
local Lorry = require('@develfish-repo.utils/lib/Lorry')
local KafkaUi = require('@root/lib/KafkaUi/KafkaUi')
local Cluster = require('@root/lib/KafkaUi/Cluster')

local variables: KafkaUi.Unwrapped = Lorry:variables()
local service = variables.service
local manifest = service.manifest

local config = {
  services = {
    [service.name] = {
      image = Meta:coalesce(manifest.image, 'bitnami/kafka'),
      restart ='unless-stopped',
      deploy = {
        resources = {
          limits = {
            memory = '500M'
          }
        }
      },
      environment = Meta:merge(
        Meta:to_sequence(
          Meta:map_array(
            service.clusters or {},
            function (cluster: Cluster.Cluster, index)
              return {
                [`KAFKA_CLUSTERS_{index - 1}_NAME`] = cluster.name,
                [`KAFKA_CLUSTERS_{index - 1}_BOOTSTRAPSERVERS`] = cluster.bootstrap_servers,
              }
            end
          )
        ),
        manifest.environment
      ),
      profiles = manifest.profiles,
      ports = manifest.ports,
      networks = manifest.networks,
      volumes = manifest.volumes,
      depends_on = manifest.depends_on,
      links = manifest.links
    }
  }
}

Lorry.Template:print(Lorry.Yaml:stringify(config))

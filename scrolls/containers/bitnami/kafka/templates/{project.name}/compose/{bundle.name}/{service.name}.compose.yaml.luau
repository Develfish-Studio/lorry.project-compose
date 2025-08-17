local Meta = require('@develfish-repo.utils/lib/Meta')
local Lorry = require('@develfish-repo.utils/lib/Lorry')
local Kafka = require('@root/lib/Kafka')

local variables: Kafka.Unwrapped = Lorry:variables()
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
      environment = Meta:append(manifest.environment) {
        ALLOW_PLAINTEXT_LISTENER = 'yes',
        KAFKA_CFG_ADVERTISED_LISTENERS = `CLIENT://{service.name}:29092,CLIENT_LOCAL://localhost:9092`,
        KAFKA_CFG_BROKER_ID = 1,
        KAFKA_CFG_CONTROLLER_LISTENER_NAMES = 'CONTROLLER',
        KAFKA_CFG_CONTROLLER_QUORUM_VOTERS = `1@{service.name}:9093`,
        KAFKA_CFG_LISTENERS = 'CLIENT://:29092,CLIENT_LOCAL://:9092,CONTROLLER://:9093',
        KAFKA_CFG_LISTENER_SECURITY_PROTOCOL_MAP = 'CLIENT:PLAINTEXT,CLIENT_LOCAL:PLAINTEXT,CONTROLLER:PLAINTEXT',
        KAFKA_CFG_NODE_ID = 1,
        KAFKA_CFG_PROCESS_ROLES = 'broker,controller',
        KAFKA_ENABLE_KRAFT = 'yes',
        KAFKA_INTER_BROKER_LISTENER_NAME = 'CLIENT_LOCAL',
        KAFKA_KRAFT_CLUSTER_ID = service.cluster_id
      },
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

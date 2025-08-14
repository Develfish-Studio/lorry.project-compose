--!strict

local Meta = require('@develfish-repo.utils/lib/Meta')
local Service = require('./Service')

local Kafka = {}

export type Kafka = typeof(Kafka) & Service.Service

return Meta:type(Service, Kafka, 'Kafka')::Kafka

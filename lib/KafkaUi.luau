--!strict

local Meta = require('@develfish-repo.utils/lib/Meta')
local Service = require('./Service')

local KafkaUi = {}

export type KafkaUi = typeof(KafkaUi) & Service.Service

return Meta:type(Service, KafkaUi, 'KafkaUi')::KafkaUi

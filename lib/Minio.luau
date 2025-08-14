--!strict

local Meta = require('@develfish-repo.utils/lib/Meta')
local Service = require('./Service')

local Minio = {}

export type Minio = typeof(Minio) & Service.Service

return Meta:type(Service, Minio, 'Minio')::Minio

--!strict

local Meta = require('@develfish-repo.utils/lib/Meta')
local URI = require('@develfish-repo.utils/lib/URI')
local Path = require('@develfish-repo.utils/lib/Path')
local Wrapper = require('@develfish-repo.project/lib/Wrapper')

local Database = {}

export type Database = typeof(Database) & DatabaseProps & Wrapper.Unwrappable<Unwrapped>

export type DatabaseProps = {
  name: string,
  username: string,
  password: string?,
}

export type Unwrapped = DatabaseProps

export type Datasource = { url: string, username: string?, password: string? }

function Database:new(o: DatabaseProps): Database
  return Meta:type(o, self, 'Database')
end

function Database:from_datasource(datasource: Datasource): Database
  assert(datasource.url ~= nil)
  local uri = URI:parse_jdbc(datasource.url)
  local database = uri.path ~= nil and Path:parse(uri.path):normalize():path() or "postgres"
  return Database:new({
    name = database,
    username = datasource.username ~= nil and datasource.username or "postgres",
    password = datasource.password,
  })
end

function Database:unwrap(): Unwrapped
  local this = self::Database
  return {
    name = this.name,
    username = this.username,
    password = this.password
  }
end

return Database

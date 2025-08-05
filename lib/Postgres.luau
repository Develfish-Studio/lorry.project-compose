local Meta = require('@develfish-repo.utils/lib/Meta')
local Wrapper = require('@develfish-repo.project/lib/Wrapper')
local Project = require('@develfish-repo.project/lib/Project')
local Database = require('@root/lib/postgres/Database')

export type Postgres = {
  project: Project.Project,
  databases: {Database.Database},

  with_rules: (self: Postgres, children: {any}) -> Postgres,
} & Wrapper.Unwrappable<Unwrapped>

export type Unwrapped = {
  project: Project.UnwrappedProject,
  databases: {Database.Unwrapped},
}

local Postgres = {
  Database = Database,

  project = nil,
  databases = nil,
}

function Postgres:new(o): Postgres
  return Meta:type(o, self, 'Postgres')
end

function Postgres:from(project: Project.Project): Postgres
  assert(project ~= nil)
  return Postgres
    :new({
      project = project,
      databases = Meta:array {}
    })
end

function Postgres.with_rules(self: Postgres, children: {any}): Postgres
  children = children or {}

  for _, child in children do
    if child.__type == 'Database' then
      self.databases[#self.databases + 1] = child::Database.Database
    end
  end

  return self
end

function Postgres.unwrap(self: Postgres): Unwrapped
  return {
    project = self.project:unwrap_project(),
    databases = Wrapper:unwrap_array(self.databases),
  }
end

return Postgres

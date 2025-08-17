--!strict

local Meta = require('@develfish-repo.utils/lib/Meta')
local Wrapper = require('@develfish-repo.project/lib/Wrapper')

local SpringDatasource = {}

export type SpringDatasource = typeof(SpringDatasource)

export type SpringDatasourceProps = {
  url: string,
  username: string?,
  password: string?,
}

export type Unwrapped = SpringDatasourceProps

export type SpringDatasourceImpl = SpringDatasource & SpringDatasourceProps & Wrapper.Unwrappable<Unwrapped>


function SpringDatasource:new(o: SpringDatasourceProps): SpringDatasource
  return Meta:type(o, self, 'SpringApp.SpringDatasource')
end

function SpringDatasource:from(props: SpringDatasourceProps): SpringDatasource
  return SpringDatasource:new(props)
end

function SpringDatasource:unwrap(): Unwrapped
  local this = self::SpringDatasourceImpl
  return {
    url = this.url,
    username = this.username,
    password = this.password,
  }
end

return SpringDatasource

--!strict

local describe = require("@lorry.testing/lib/describe")
local Meta = require("@lorry.utils/lib/Meta")
local Project = require("@lorry.project/lib/Project")
local Postgres = require("@root/lib/Postgres")

describe("Postgres Record") (
  function (it)
    it("should provide ability to construct Postgres record") (
      function (check)
        local project = Project:from("example_project")

        local postgres = Postgres
          :from(project, "test-postgres")
          :with_datasource({ url = 'jdbc:postgresql://localhost:5432/example', username = 'ExampleUser', password = 'ExamplePa$$w0rd' })

        check.eq(Meta:typeof(postgres), "Postgres")

        local unwrapped = postgres:unwrap()

        check.eq(unwrapped.project.name, "example_project")

        local databases = check.required(unwrapped.service.databases)
        check.eq(#databases, 1)
        check.eq(databases[1].name, 'example')
        check.eq(databases[1].username, 'ExampleUser')
        check.eq(databases[1].password, 'ExamplePa$$w0rd')
      end
    )
  end
)

return {}
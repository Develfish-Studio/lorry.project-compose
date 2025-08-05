local describe = require("@develfish-repo.testing/lib/describe")
local Project = require("@develfish-repo.project/lib/Project")
local Postgres = require("@root/lib/Postgres")

describe("Postgres Record") (
  function (it)
    it("should provide ability to construct Postgres record") (
      function (check)
        local project = Project:from("example_project")

        local postgres = Postgres
          :from(project)
          :with_rules({
            Postgres.Database:from_datasource({ uri = 'jdbc:postgresql://localhost:5432/example', username = 'ExampleUser', password = 'ExamplePa$$w0rd' }),
          })

        check.eq(postgres.__type, "Postgres")
        check.eq(postgres.project, project)

        local unwrapped = postgres:unwrap()

        check.eq(unwrapped.project.name, "example_project")
        check.eq(#unwrapped.databases, 1)
        check.eq(unwrapped.databases[1].name, 'example')
        check.eq(unwrapped.databases[1].username, 'ExampleUser')
        check.eq(unwrapped.databases[1].password, 'ExamplePa$$w0rd')
      end
    )
  end
)

return {}
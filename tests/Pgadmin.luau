local describe = require("@develfish-repo.testing/lib/describe")
local Project = require("@develfish-repo.project/lib/Project")
local Pgadmin = require("@root/lib/Pgadmin")

describe("Pgadmin Record") (
  function (it)
    it("should provide ability to construct Pgadmin record") (
      function (check)
        local project = Project:from("example_project")

        local pgadmin = Pgadmin
          :from(project)
          :with_rules({
            Pgadmin.Server:from_datasource({ uri = 'jdbc:postgresql://env-postgres:5432/one', username = 'one', password = 'one' }),
            Pgadmin.Server:from_datasource({ uri = 'jdbc:postgresql://env-postgres:5432/two', username = 'two', password = 'two' }),
          })

        check.eq(pgadmin.__type, "Pgadmin")
        check.eq(pgadmin.project, project)

        local unwrapped = pgadmin:unwrap()

        check.eq(unwrapped.project.name, "example_project")
        check.eq(#unwrapped.servers, 2)
        check.eq(unwrapped.servers[1].Host, 'env-postgres')
        check.eq(unwrapped.servers[1].Name, 'one')
        check.eq(unwrapped.servers[1].Port, 5432)
        check.eq(unwrapped.servers[1].Group, 'Default')
        check.eq(unwrapped.servers[1].SSLMode, 'prefer')
        check.eq(unwrapped.servers[1].MaintenanceDB, 'one')
      end
    )
  end
)

return {}
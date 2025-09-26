--!strict

local describe = require("@lorry.testing/lib/describe")
local Meta = require("@lorry.utils/lib/Meta")
local Project = require("@lorry.project/lib/Project")
local Pgadmin = require("@root/lib/Pgadmin/Pgadmin")

return describe("Pgadmin Record") (
  function (it)
    it("should provide ability to construct Pgadmin record") (
      function (check)
        local project = Project:from("example_project")

        local pgadmin = Pgadmin
          :from(project, "test-postgres")
          :with_datasource({ url = 'jdbc:postgresql://test-postgres:5432/one', username = 'one', password = 'one' })
          :with_datasource({ url = 'jdbc:postgresql://test-postgres:5432/two', username = 'two', password = 'two' })

        check.eq(Meta:typeof(pgadmin), "Pgadmin")

        local unwrapped = pgadmin:unwrap()

        check.eq(unwrapped.project.name, "example_project")

        local servers = check.required(unwrapped.service.servers)

        check.eq(#servers, 2)
        check.eq(servers[1].Host, 'test-postgres')
        check.eq(servers[1].Name, 'one')
        check.eq(servers[1].Port, 5432)
        check.eq(servers[1].Group, 'Default')
        check.eq(servers[1].SSLMode, 'prefer')
        check.eq(servers[1].MaintenanceDB, 'one')
      end
    )
  end
)

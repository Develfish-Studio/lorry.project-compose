local describe = require("@develfish-repo.testing/lib/describe")
local Project = require("@develfish-repo.project/lib/Project")
local Haproxy = require("@root/lib/Haproxy")

describe("Haproxy Record") (
  function (it)
    it("should provide ability to construct Haproxy record") (
      function (check)
        local project = Project:from("example_project")

        local haproxy = Haproxy
          :from(project)
          :with_rules({
            Haproxy.Route
              :from_arrow('http://service-1.example.com', 'http://service-1:8080');
            Haproxy.Route
              :from_arrow('http://service-2.example.com', 'http://service-2:8080');
          })

        check.eq(haproxy.__type, "Haproxy")
        check.eq(haproxy.project, project)

        local unwrapped = haproxy:unwrap()

        check.eq(unwrapped.project.name, "example_project")
        -- check.eq(#unwrapped.servers, 2)
        -- check.eq(unwrapped.servers[1].Host, 'env-postgres')
        -- check.eq(unwrapped.servers[1].Name, 'one')
        -- check.eq(unwrapped.servers[1].Port, 5432)
        -- check.eq(unwrapped.servers[1].Group, 'Default')
        -- check.eq(unwrapped.servers[1].SSLMode, 'prefer')
        -- check.eq(unwrapped.servers[1].MaintenanceDB, 'one')
      end
    )
  end
)

return {}
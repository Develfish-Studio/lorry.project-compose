--!strict

local describe = require("@lorry.testing/lib/describe")
local Meta = require("@lorry.utils/lib/Meta")
local Project = require("@lorry.project/lib/Project")
local Haproxy = require("@root/lib/Haproxy/Haproxy")

return describe("Haproxy Record") (
  function (it)
    it("should provide ability to construct Haproxy record") (
      function (check)
        local project = Project:from("example_project")

        local haproxy = Haproxy
          :from(project, "text-haproxy")
          :with_arrow('http://service-1.example.com', 'http://service-1:8080')
          :with_arrow('http://service-2.example.com', 'http://service-2:8080')

        check.eq(Meta:typeof(haproxy), "Haproxy")

        local unwrapped = haproxy:unwrap()

        check.eq(unwrapped.project.name, "example_project")

        local routes = check.required(unwrapped.service.routes)

        check.eq(#routes, 2);
        check.eq(routes[1].hostname, 'service-1.example.com');
      end
    )
  end
)

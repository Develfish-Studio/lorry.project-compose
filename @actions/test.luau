local Suite = require('@lorry.testing/lib/suite')

Suite("Compose Lib") {
  require("@root/tests/Pgadmin"),
  require("@root/tests/Postgres"),
  require("@root/tests/Haproxy"),
}

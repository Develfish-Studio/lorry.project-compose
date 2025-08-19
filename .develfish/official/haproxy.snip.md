# Generate haproxy service description

> The contents of this file are used to provide text completions in editors. Please do not alter section titles or code block types.

## Description

Description of Haproxy service based on `haproxy` container.

`project` is a reference to your project definition.\
`service` is a name of your service.

## Context

> These settings are used to trigger code suggestions.

```yaml
keywords: [haproxy, proxy, container]
```

## Imports

> These imports should be added to the beginning of your script.

```lua
local Lorry = require('@develfish-repo.utils/lib/Lorry')
```

```lua
local Haproxy = require('@develfish-repo.project-compose/lib/Haproxy/Haproxy')
```

## Content

> This snippet may be suggested to the user.

```lua
Lorry:generate "@develfish-repo.project-compose/containers/official/haproxy" {
  target = '@',
  variables = Haproxy
    :from(${1:project}, "${2:service}")
    :with_arrow('http://kafka-ui.local.example.com', 'http://env-kafka-ui:8080')
    :with_arrow('http://pgadmin.local.example.com', 'http://env-pgadmin:80')
}
```

# Generate bitnami/keycloak service description

> The contents of this file are used to provide text completions in editors. Please do not alter section titles or code block types.

## Description

Description of Keycloak service based on `bitnami/keycloak` container.

`project` is a reference to your project definition.\
`service` is a name of your service.\
`datasource` is a database connection config.

## Context

> These settings are used to trigger code suggestions.

```yaml
keywords: [keycloak, openid, container]
```

## Imports

> These imports should be added to the beginning of your script.

```lua
local Lorry = require('@lorry.utils/lib/Lorry')
```

```lua
local Keycloak = require('@lorry.project-compose/lib/Keycloak/Keycloak')
```

## Content

> This snippet may be suggested to the user.

```lua
Lorry:generate "@lorry.project-compose/containers/bitnami/keycloak" {
  target = '@',
  variables = Keycloak
    :from(${1:project}, "${2:service}")
    :with_datasource(${3:datasource})
}
```

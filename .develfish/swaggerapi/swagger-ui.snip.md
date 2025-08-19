# Generate swaggerapi/swagger-ui service description

> The contents of this file are used to provide text completions in editors. Please do not alter section titles or code block types.

## Description

Description of Swagger UI service based on `swaggerapi/swagger-ui` container.

`project` is a reference to your project definition.\
`service` is a name of your service.

## Context

> These settings are used to trigger code suggestions.

```yaml
keywords: [swagger-ui, swagger, container]
```

## Imports

> These imports should be added to the beginning of your script.

```lua
local Lorry = require('@develfish-repo.utils/lib/Lorry')
```

```lua
local SwaggerUi = require('@develfish-repo.project-compose/lib/SwaggerUi/SwaggerUi')
```

## Content

> This snippet may be suggested to the user.

```lua
Lorry:generate "@develfish-repo.project-compose/containers/swaggerapi/swagger-ui" {
  target = '@',
  variables = SwaggerUi
    :from(project, "env-swagger-ui")
    :with_entry("Assembly Web", "http://api.local.example.com/api/assembly_web/v3/api-docs")
}
```

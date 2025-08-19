# Generate top-level compose file

> The contents of this file are used to provide text completions in editors. Please do not alter section titles or code block types.

## Description

Top-level compose file with references to dependant services, networks and volumes.

`project` is a reference to your project definition.\
`bundle` is a name of directory (for example: env or app).\
`service` is a name of your service.

## Context

> These settings are used to trigger code suggestions.

```yaml
keywords: [compose]
```

## Imports

> These imports should be added to the beginning of your script.

```lua
local Lorry = require('@develfish-repo.utils/lib/Lorry')
```

```lua
local Compose = require('@develfish-repo.project-compose/lib/Compose/Compose')
```

## Content

> This snippet may be suggested to the user.

```lua
Lorry:generate "@develfish-repo.project-compose/compose" {
  target = '@',
  variables = Compose
    :from(${1:project})
    :with_include "compose/${2:bundle}/${3:service}.compose.yaml"
}
```

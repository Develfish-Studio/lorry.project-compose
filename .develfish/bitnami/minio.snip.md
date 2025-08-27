# Generate bitnami/minio service description

> The contents of this file are used to provide text completions in editors. Please do not alter section titles or code block types.

## Description

Description of Minio service based on `bitnami/minio` container.

`project` is a reference to your project definition.\
`service` is a name of your service.

## Context

> These settings are used to trigger code suggestions.

```yaml
keywords: [minio, container]
```

## Imports

> These imports should be added to the beginning of your script.

```lua
local Lorry = require('@lorry.utils/lib/Lorry')
```

```lua
local Minio = require('@lorry.project-compose/lib/Minio/Minio')
```

## Content

> This snippet may be suggested to the user.

```lua
Lorry:generate "@lorry.project-compose/containers/bitnami/minio" {
  target = '@',
  variables = Minio
    :from(${1:project}, "${2:service}")
    :with_admin("minioadmin", "minioadmin")
}
```

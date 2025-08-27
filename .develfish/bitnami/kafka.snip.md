# Generate bitnami/kafka service description

> The contents of this file are used to provide text completions in editors. Please do not alter section titles or code block types.

## Description

Description of Kafka service based on `bitnami/kafka` container.

`project` is a reference to your project definition.\
`service` is a name of your service.

## Context

> These settings are used to trigger code suggestions.

```yaml
keywords: [kafka, container]
```

## Imports

> These imports should be added to the beginning of your script.

```lua
local Lorry = require('@lorry.utils/lib/Lorry')
```

```lua
local Kafka = require('@lorry.project-compose/lib/Kafka/Kafka')
```

## Content

> This snippet may be suggested to the user.

```lua
Lorry:generate "@lorry.project-compose/containers/bitnami/kafka" {
  target = '@',
  variables = Kafka
    :from(${1:project}, "${2:service}")
}
```

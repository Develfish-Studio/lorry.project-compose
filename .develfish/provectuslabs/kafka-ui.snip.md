# Generate provectuslabs/kafka-ui service description

> The contents of this file are used to provide text completions in editors. Please do not alter section titles or code block types.

## Description

Description of Kafka UI service based on `provectuslabs/kafka-ui` container.

`project` is a reference to your project definition.\
`service` is a name of your service.

## Context

> These settings are used to trigger code suggestions.

```yaml
keywords: [kafka-ui, container]
```

## Imports

> These imports should be added to the beginning of your script.

```lua
local Lorry = require('@lorry.utils/lib/Lorry')
```

```lua
local KafkaUi = require('@lorry.project-compose/lib/KafkaUi/KafkaUi')
```

## Content

> This snippet may be suggested to the user.

```lua
Lorry:generate "@lorry.project-compose/containers/provectuslabs/kafka-ui" {
  target = '@',
  variables = KafkaUi
    :from(${1:project}, "${2:service}")
    :with_cluster("local", "env-kafka:29092")
}
```

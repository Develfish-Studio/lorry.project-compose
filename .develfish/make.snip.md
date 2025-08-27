# Generate Makefile with compose shorthands

> The contents of this file are used to provide text completions in editors. Please do not alter section titles or code block types.

## Description

Makefile with compose shorthands

`project` is a reference to your project definition.

## Context

> These settings are used to trigger code suggestions.

```yaml
keywords: [make, makefile]
```

## Imports

> These imports should be added to the beginning of your script.

```lua
local Lorry = require('@lorry.utils/lib/Lorry')
```

```lua
local Make = require('@lorry.project-compose/lib/Make/Make')
```

## Content

> This snippet may be suggested to the user.

```lua
Lorry:generate "@lorry.project-compose/make" {
  target = '@',
  variables = Make
    :from(${1:project})
    :with_profile 'env'
    :with_profile 'app'
}
```

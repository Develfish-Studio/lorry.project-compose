# Generate keycloak admin (kcadm) service description

> The contents of this file are used to provide text completions in editors. Please do not alter section titles or code block types.

## Description

Description of `kcadm` service based on `bitnami/keycloak` container.

`project` is a reference to your project definition.\
`service` is a name of your service.\
`realm` is a name of security realm.

## Context

> These settings are used to trigger code suggestions.

```yaml
keywords: [kcadm, keycloak, admin, container]
```

## Imports

> These imports should be added to the beginning of your script.

```lua
local Lorry = require('@lorry.utils/lib/Lorry')
```

```lua
local Kcadm = require('@lorry.project-compose/lib/Kcadm/Kcadm')
```

## Content

> This snippet may be suggested to the user.

```lua
Lorry:generate "@lorry.project-compose/containers/bitnami/kcadm" {
  target = '@',
  variables = Kcadm
    :from(${1:project}, "${2:service}", "${3:realm}")
    :with_remote(openid_client.url, 'master', user_admin.username, user_admin.password)
    :with_client(openid_client)
    :with_realm_role 'admin'
    :with_realm_role 'support'
    :with_group 'admin'
    :with_group 'support'
    :with_user('admin@example.com', 'Qwerty123')
    :with_user('support01@example.com', 'Qwerty123')
    :with_user('support02@example.com', 'Qwerty123')
    :with_user('user01@example.com', 'Qwerty123')
    :with_user('user02@example.com', 'Qwerty123')
    :with_member('admin', 'admin')
    :with_member('support01', 'support')
    :with_member('support02', 'support')
    :with_grant('group:admin', 'realm:admin')
    :with_grant('group:admin', 'realm:support')
    :with_grant('group:support', 'realm:support')
}
```

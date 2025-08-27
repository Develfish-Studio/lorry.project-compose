# @lorry.project-compose

The contents of this file are used to provide text completions in editors. Each snippet should be marked with the snippet keyword immediately after the code block definition. The name of the closest heading, along with all text between that heading and the code block, will be used as the snippet description.

## Generate top-level compose file

Top-level compose file with references to dependant services, networks and volumes.

`project` is a reference to your project definition.\
`bundle` is a name of directory (for example: _env_ or _app_).\
`service` is a name of your service.

```lua snippet Lorry:generate "@lorry.project-compose/compose"
Lorry:generate "@lorry.project-compose/compose" {
  target = '@',
  variables = Compose
    :from(${1:project})
    :with_include "compose/${2:bundle}/${3:service}.compose.yaml"
}
```

## Generate kafka service description

Description of Kafka service based on `bitnami/kafka` container.

`project` is a reference to your project definition.\
`service` is a name of your service.

```lua snippet Lorry:generate "@lorry.project-compose/containers/bitnami/kafka"
Lorry:generate "@lorry.project-compose/containers/bitnami/kafka" {
  target = '@',
  variables = Kafka
    :from(${1:project}, "${2:service}")
}
```

## Generate minio service description

Description of Minio service based on `bitnami/minio` container.

`project` is a reference to your project definition.\
`service` is a name of your service.

```lua snippet Lorry:generate "@lorry.project-compose/containers/bitnami/minio"
Lorry:generate "@lorry.project-compose/containers/bitnami/minio" {
  target = '@',
  variables = Minio
    :from(${1:project}, "${2:service}")
    :with_admin("minioadmin", "minioadmin")
}
```

## Generate keycloak service description

Description of Keycloak service based on `bitnami/keycloak` container.

`project` is a reference to your project definition.\
`service` is a name of your service.\
`datasource` is a database connection config.\

```lua snippet Lorry:generate "@lorry.project-compose/containers/bitnami/keycloak"
Lorry:generate "@lorry.project-compose/containers/bitnami/keycloak" {
  target = '@',
  variables = Keycloak
    :from(${1:project}, "${2:service}")
    :with_datasource(${3:datasource})
}
```

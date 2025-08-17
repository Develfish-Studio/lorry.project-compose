# @develfish-repo.project-compose

The contents of this file are used to provide text completions in editors. Each snippet should be marked with the snippet keyword immediately after the code block definition. The name of the closest heading, along with all text between that heading and the code block, will be used as the snippet description.

## Generate top-level compose file

Top-level compose file with references to dependant services, networks and volumes.

`project` is a reference to your project definition.\
`bundle` is a name of directory (for example: _env_ or _app_).\
`service` is a name of your service.

```lua snippet Lorry:generate "@develfish-repo.project-compose/compose"
Lorry:generate "@develfish-repo.project-compose/compose" {
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

```lua snippet Lorry:generate "@develfish-repo.project-compose/containers/bitnami/kafka"
Lorry:generate "@develfish-repo.project-compose/containers/bitnami/kafka" {
  target = '@',
  variables = Kafka:from(${1:project}, "${3:service:env-kafka}")
```

## Generate Minio Container

```lua snippet Lorry:generate "@develfish-repo.project-compose/minio"
Lorry:generate "@develfish-repo.project-compose/minio" {
  target = '@',
  variables = Minio
    :from(project)
    :with_link('env-haproxy:minio.local.example.com')
    :unwrap()
}
```

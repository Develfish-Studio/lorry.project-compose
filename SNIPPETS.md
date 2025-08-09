# @develfish-repo.project-compose

The contents of this file are used to provide text completions in editors. Each snippet should be marked with the snippet keyword immediately after the code block definition. The name of the closest heading, along with all text between that heading and the code block, will be used as the snippet description.

## Generate Spring Applicaiton Container

Generate docker container definitions for spring applicaiton.

```lua snippet Lorry:generate "@develfish-repo.project-compose/app"
Lorry:generate "@develfish-repo.project-compose/app" {
  target = '@',
  variables = App
    :from(${1:project}, '${2:app-assembly}', '${3:example/assembly:1.0-SNAPSHOT}')
    :unwrap()
}
```

## Generate Kafka Container

Generate docker container definitions for kafka.

```lua snippet Lorry:generate "@develfish-repo.project-compose/kafka"
Lorry:generate "@develfish-repo.project-compose/kafka" {
  target = '@',
  variables = Kafka
    :from(${1:project})
    :unwrap()
}
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

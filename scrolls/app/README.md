# @develfish-repo.project-compose/app

```lua snippet Lorry:generate @develfish-repo.project-compose/app
Lorry:generate "@develfish-repo.project-compose/app" {
  target = '@',
  variables = App
    :from(${project}, '${name}', '${image}')
    :unwrap()
}
```

```lua snippet Lorry:generate @develfish-repo.project-compose/kafka
Lorry:generate "@develfish-repo.project-compose/kafka" {
  target = '@',
  variables = Kafka
    :from(${project}, ${name})
    :unwrap()
}
```

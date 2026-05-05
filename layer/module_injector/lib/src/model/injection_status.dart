enum InjectionStatus {
  start, // when the dependency injection has started
  register, // registering the dependencies in dependency graph
  postRegister, // additional setup after registering the dependencies in dependency graph
  finished, // all dependencies have been registered successfully
}

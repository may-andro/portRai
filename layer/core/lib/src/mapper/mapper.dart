abstract interface class Mapper<From, To> {
  To map(From from);
}

abstract interface class BiMapper<From, To> {
  To to(From from);

  From from(To from);
}

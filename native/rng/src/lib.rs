use rand::prelude::*;

#[rustler::nif]
fn int() -> i64 {
    random::<i64>()
}

// Equivalent to rand.uniform(n)
#[rustler::nif]
fn int_range(max: i64) -> i64 {
    random::<i64>() % max // todo - 1 since range starts at 1?
}

// Equivalent to rand.uniform()
#[rustler::nif]
fn float() -> f64 {
    random::<f64>()
}

rustler::init!("Elixir.Genetic.Rng", [int, int_range, float]);

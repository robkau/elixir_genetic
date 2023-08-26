use rand::prelude::*;

#[rustler::nif]
fn int() -> i64 {
    random::<i64>()
}

// Equivalent to rand.uniform(n)
// Returns 1 <= n <= max
#[rustler::nif]
fn int_range(max: i64) -> i64 {
    match max {
        0 => 1,
        _ => thread_rng().gen_range(0..max) + 1,
    }
}

// Equivalent to rand.uniform()
// Returns 0.0 =< n < 1.0
#[rustler::nif]
fn float() -> f64 {
    random::<f64>()
}

rustler::init!("Elixir.Genetic.Rng", [int, int_range, float]);

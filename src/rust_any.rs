use std::any::Any;
use std::hint::black_box;

trait Pet {
    fn say(&self) -> usize;
}

struct Dog(usize);

impl Pet for Dog {
    #[inline(never)]
    fn say(&self) -> usize {
        self.0
    }
}

static DOG: Dog = Dog(7);

#[inline(never)]
fn call(p: &dyn Pet, a: &dyn Any) -> usize {
    let n = p.say();
    if a.is::<Dog>() { n + 1 } else { n }
}

#[inline(never)]
fn run() -> usize {
    call(black_box(&DOG), black_box(&DOG))
}

fn main() {
    let run_fn = black_box(run as fn() -> usize);
    black_box(run_fn());
}

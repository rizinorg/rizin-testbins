// rustc --edition 2021 -C opt-level=z -C lto=fat -C codegen-units=1 -C panic=abort -C strip=symbols src/rust_stripped.rs -o elf/rust_stripped
// rustc --edition 2021 --target x86_64-pc-windows-gnu -C linker=x86_64-w64-mingw32-gcc -C opt-level=z -C lto=fat -C codegen-units=1 -C panic=abort -C strip=symbols src/rust_stripped.rs -o pe/rust_stripped.exe

use std::hint::black_box;

trait Greeter {
    fn greet(&self) -> &str;
    fn tag(&self) -> u32;
}

struct Alpha {
    id: u32,
}

struct Beta {
    id: u32,
}

impl Greeter for Alpha {
    #[inline(never)]
    fn greet(&self) -> &str {
        "alpha_greeting_str"
    }
    #[inline(never)]
    fn tag(&self) -> u32 {
        self.id.wrapping_add(1)
    }
}

impl Greeter for Beta {
    #[inline(never)]
    fn greet(&self) -> &str {
        "beta_greeting_str"
    }
    #[inline(never)]
    fn tag(&self) -> u32 {
        self.id.wrapping_add(2)
    }
}

#[inline(never)]
fn dispatch(g: &dyn Greeter, flag: bool) -> u32 {
    if flag {
        panic!("explicit panic trigger");
    }
    let s = black_box(g.greet());
    (s.len() as u32).wrapping_add(g.tag())
}

fn main() {
    let args: Vec<String> = std::env::args().collect();
    let flag = black_box(args.len() > 2);
    let a = Alpha { id: black_box(args.len() as u32) };
    let b = Beta { id: black_box(7) };
    let items: [&dyn Greeter; 2] = [black_box(&a), black_box(&b)];
    let mut sum = 0u32;
    for item in items {
        sum = sum.wrapping_add(dispatch(item, flag));
    }
    let utf8_note = black_box("rust_utf8_café");
    if black_box(sum) == 0xdead_beef {
        println!("{} {}", utf8_note, args.get(99).unwrap());
    }
}

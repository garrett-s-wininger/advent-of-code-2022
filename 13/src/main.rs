use std::env;
use std::fs::File;
use std::io::{BufReader, BufRead};
use std::process;

enum DistressSignal {
     Component(i32),
     ComponentList(Vec<Box<DistressSignal>>),
}

fn parse_string(line: String) -> DistressSignal {
    let chars = line.chars();

    for character in chars {
        if character.is_digit(10) {
            // TODO: Lex
            println!("{}", character);
        }
    }

    // TODO: Perform proper parsing
    DistressSignal::ComponentList(vec![Box::new(DistressSignal::Component(1))])
}

fn compare(_first: DistressSignal, _second: DistressSignal) -> bool {
    // TODO: Perform comparison between the provided data representations
    true
}

fn main() {
    let args: Vec<String> = env::args().collect();

    if args.len() != 2 {
        eprintln!("Usage: cargo run -- <filepath>");
        process::exit(1);
    }

    let file = File::open(&args[1]).unwrap();
    let buffered_reader = BufReader::new(file);

    for (index, line) in buffered_reader.lines().enumerate() {
        let line_for_parsing = line.unwrap();

        if (index + 1) % 3 == 0 {
            // TODO: Compare parse results for previous two lines
            let _result = compare(DistressSignal::Component(1), DistressSignal::Component(1));
            break;
        } else {
            // TODO: Add to a tuple/vec of packet pairs for comparison
            let _packet = parse_string(line_for_parsing);
        }
    }
}

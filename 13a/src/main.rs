use std::cmp;
use std::cmp::Ordering;
use std::env;
use std::fs::File;
use std::io::{BufReader, BufRead};
use std::process;

#[derive(Debug)]
enum SignalToken {
    ListStart,
    ListEnd,
    Integer(i32),
}

#[derive(Debug)]
enum Packet {
     Component(i32),
     ComponentList(Vec<Box<Packet>>),
}

fn lex_string(line: String) -> Vec<SignalToken> {
    let mut tokens = Vec::<SignalToken>::new();
    let mut numeric_token_start = -1;

    for (index, character) in line.chars().enumerate() {
        if character.is_digit(10) && numeric_token_start == -1 {
            numeric_token_start = index as i32;
        } else {
            if numeric_token_start != -1 {
                tokens.push(
                    SignalToken::Integer(
                        line[numeric_token_start as usize..index]
                            .parse::<i32>().unwrap()
                    ));
                numeric_token_start = -1;
            }

            if character == '[' {
                tokens.push(SignalToken::ListStart);
            } else if character == ']' {
                tokens.push(SignalToken::ListEnd);
            }
        }
    }

    tokens
}

fn parse_tokens(tokens: &[SignalToken]) -> Packet {
    let mut result = Vec::<Box<Packet>>::new();
    let mut idx = 0;

    while idx < tokens.len() {
        match tokens[idx] {
            SignalToken::Integer(x) => {
                result.push(Box::<Packet>::new(Packet::Component(x)));
                idx += 1;
            },
            SignalToken::ListStart => {
                let mut list_stack = Vec::<SignalToken>::new();
                list_stack.push(SignalToken::ListStart);

                for i in idx + 1..tokens.len() {
                    match tokens[i] {
                        SignalToken::ListStart => {
                            list_stack.push(SignalToken::ListStart);
                        },
                        SignalToken::ListEnd => {
                            list_stack.pop();

                            if list_stack.is_empty() {
                                result.push(
                                    Box::<Packet>::new(
                                        parse_tokens(&tokens[idx + 1..i])
                                    )
                                );

                                idx += i - idx + 1;
                                break;
                            }
                        }
                        _ => (),
                    }
                }
            },
            _ => idx += 1,
        }
    }

    Packet::ComponentList(result)
}

// FIXME: Missing some correct matches, too low
fn compare_packets(first: &Packet, second: &Packet) -> cmp::Ordering {
    match (first, second) {
        (Packet::ComponentList(x), Packet::ComponentList(y)) => {
            let x_len = x.len();
            let y_len = y.len();
            let mut idx = 0;

            while idx < cmp::min(x_len, y_len) {
                let x_value = &x[idx];
                let y_value = &y[idx];

                match compare_packets(x_value, y_value) {
                    Ordering::Less => return Ordering::Less,
                    Ordering::Equal => idx += 1,
                    Ordering::Greater => return Ordering::Greater,
                }
            }

            if x_len == y_len {
                return Ordering::Equal;
            } else if x_len < y_len {
                return Ordering::Less;
            } else {
                return Ordering::Greater;
            }
        },
        (Packet::Component(x), Packet::Component(y)) => {
            x.cmp(y)
        },
        (Packet::Component(x), Packet::ComponentList(_)) => {
            compare_packets(
                &Packet::ComponentList(
                    vec![Box::<Packet>::new(Packet::Component(*x))]
                ),
                second
            )
        },
        (Packet::ComponentList(_), Packet::Component(x)) => {
            compare_packets(
                first,
                &Packet::ComponentList(
                    vec![Box::<Packet>::new(Packet::Component(*x))]
                )
            )
        }
    }
}

fn main() {
    let args: Vec<String> = env::args().collect();

    if args.len() != 2 {
        eprintln!("Usage: cargo run -- <filepath>");
        process::exit(1);
    }

    let file = File::open(&args[1]).unwrap();
    let buffered_reader = BufReader::new(file);

    let mut pair_idx = 0;
    let mut proper_pairs = Vec::<u32>::new();
    let mut pair = vec![Packet::Component(0), Packet::Component(0)];

    for (index, line) in buffered_reader.lines().enumerate() {
        let line_for_parsing = line.unwrap();

        if (index + 1) % 3 == 0 {
            pair_idx += 1;

            if compare_packets(&pair[0], &pair[1]) == Ordering::Less {
                proper_pairs.push(pair_idx);
            }
        } else {
            let tokens = lex_string(line_for_parsing);
            let packet = parse_tokens(&tokens[1..tokens.len() - 1]);
            
            if (index + 1) % 3 == 2 {
                pair[1] = packet;
            } else {
                pair[0] = packet;
            }
        }
    }

    pair_idx += 1;

    if compare_packets(&pair[0], &pair[1]) == Ordering::Less {
        proper_pairs.push(pair_idx);
    }

    println!("Sum ordered pair indicies: {}", proper_pairs.iter().sum::<u32>());
}

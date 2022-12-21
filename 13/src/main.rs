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

// TODO: Remove when parsing is implemented
#[allow(dead_code)]
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
                        line[numeric_token_start as usize..index].parse::<i32>().unwrap()
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

fn parse_tokens(_tokens: Vec<SignalToken>) -> Packet {
    // TODO: Eval tokens to form proper value
    Packet::Component(1)
}

fn packets_in_order(_first: &Packet, _second: &Packet) -> bool {
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

    let mut pair_idx = 0;
    let mut proper_pairs = Vec::<u32>::new();
    let mut pair = vec![Packet::Component(0), Packet::Component(0)];

    for (index, line) in buffered_reader.lines().enumerate() {
        let line_for_parsing = line.unwrap();

        if (index + 1) % 3 == 0 {
            pair_idx += 1;

            if packets_in_order(&pair[0], &pair[1]) {
                proper_pairs.push(pair_idx);
            }
        } else {
            let tokens = lex_string(line_for_parsing);
            let packet = parse_tokens(tokens);
            
            if (index + 1) % 3 == 2 {
                pair[1] = packet;
            } else {
                pair[0] = packet;
            }
        }
    }

    println!("Total of ordered pair indicies: {}", proper_pairs.iter().sum::<u32>());
}

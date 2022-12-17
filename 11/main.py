#!/usr/bin/env python3

import sys

from math import floor
from typing import Callable, List, TextIO

class Monkey:
    def __init__(
        self, 
        items: List[int], 
        operation: Callable[[int], int], 
        test: Callable[[int], int]
    ) -> None:
        self.inspection_count = 0
        self.items = items
        self.operation = operation
        self.test = test

def parse_items(line: str) -> List[int]:
    return [int(item) for item in line.split("Starting items: ")[-1].split(", ")]

def parse_operation(line: str) -> Callable[[int], int]:
    operation_components = line.split("Operation: new = old ")[-1].split(" ")

    if operation_components[0] == "+":
        if not "old" in operation_components[1]:
            return lambda x: x + int(operation_components[1])
        else:
            return lambda x: x + x
    elif operation_components[0] == "*":
        if not "old" in operation_components[1]:
            return lambda x: x * int(operation_components[1])
        else:
            return lambda x: x * x
    else:
        return lambda x: x

def parse_test(lines: List[str]) -> Callable[[int], int]:
    divisor = int(lines[0].split("divisible by ")[-1])
    true_destination = int(lines[1].split("throw to monkey ")[-1])
    false_destination = int(lines[2].split("throw to monkey ")[-1])

    return lambda x: true_destination if x % divisor == 0 else false_destination

def read_monkeys(input_file: TextIO) -> List[Monkey]:
    monkeys: List[Monkey] = []
    lines = input_file.readlines()

    for x in range(0, len(lines), 7):
        definition = lines[x:x+7]
        monkeys.append(
            Monkey(
                parse_items(definition[1]), 
                parse_operation(definition[2]), 
                parse_test(definition[3:6])
            )
        )

    return monkeys

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: ./main.py <filename>", file=sys.stderr)

    with open(sys.argv[1], "r") as input_file:
        monkeys = read_monkeys(input_file)

    for i in range(20):
        for monkey in monkeys:
            for idx in range(len(monkey.items)):
                monkey.inspection_count += 1
                monkey.items[idx] = monkey.operation(monkey.items[idx])
                monkey.items[idx] = monkey.items[idx] // 3
                monkeys[monkey.test(monkey.items[idx])].items.append(monkey.items[idx])

            monkey.items = []

    top_inspections = sorted(
        [monkey.inspection_count for monkey in monkeys], 
        key=lambda x: x, 
        reverse=True
    )
    
    print(f"Total Monkey Business: {top_inspections[0] * top_inspections[1]}")

package main

import (
	"bufio"
	"fmt"
	"os"
	"strconv"
	"strings"
)

type ParsingStage int

const (
	StackPopulation ParsingStage = iota
	StackMovement
)

func main() {
	if len(os.Args) != 2 {
		fmt.Fprintf(os.Stderr, "Usage: go run main.go <filepath>\n")
		os.Exit(1)
	}

	file, _ := os.Open(os.Args[1])
	defer file.Close()

	scanner := bufio.NewScanner(file)
	stage := StackPopulation
	stacks := [][]rune{}

	for scanner.Scan() {
		line := scanner.Text()

		if strings.IndexRune(line, '1') == 1 {
			continue
		}

		if line == "" {
			stage = StackMovement
			continue
		}

		if stage == StackPopulation {
			for pos, char := range line {
				if char >= 'A' && char <= 'Z' {
					stack_index := (pos - 1) / 4

					if stack_index >= len(stacks) {
						for i := len(stacks) - 1; i < stack_index; i++ {
							stacks = append(stacks, []rune{})
						}
					}

					stacks[stack_index] = append(stacks[stack_index], char)
				}
			}
		} else if stage == StackMovement {
			command := strings.Split(line, " ")
			amount, _ := strconv.Atoi(command[1])
			source_index, _ := strconv.Atoi(command[3])
			destination_index, _ := strconv.Atoi(command[5])

			source_index -= 1
			destination_index -= 1

			transfer := stacks[source_index][0:amount]
			new_capacity := len(transfer) + len(stacks[destination_index])
			new_stack := make([]rune, new_capacity)

			for i := 0; i < new_capacity; i++ {
				if i < len(transfer) {
					new_stack[i] = transfer[i]
				} else {
					new_stack[i] = stacks[destination_index][i-len(transfer)]
				}
			}

			stacks[source_index] = stacks[source_index][amount:]
			stacks[destination_index] = new_stack
		}
	}

	for idx, stack := range stacks {
		fmt.Printf("Top of stack %d: %c\n", idx, stack[0])
	}
}

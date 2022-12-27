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
					stackIndex := (pos - 1) / 4

					if stackIndex >= len(stacks) {
						for i := len(stacks) - 1; i < stackIndex; i++ {
							stacks = append(stacks, []rune{})
						}
					}

					stacks[stackIndex] = append(stacks[stackIndex], char)
				}
			}
		} else if stage == StackMovement {
			command := strings.Split(line, " ")
			amount, _ := strconv.Atoi(command[1])
			sourceIndex, _ := strconv.Atoi(command[3])
			destinationIndex, _ := strconv.Atoi(command[5])

			sourceIndex -= 1
			destinationIndex -= 1

			transfer := stacks[sourceIndex][0:amount]
			newCapacity := len(transfer) + len(stacks[destinationIndex])
			newStack := make([]rune, newCapacity)

			for i := 0; i < newCapacity; i++ {
				if i < len(transfer) {
					newStack[i] = transfer[i]
				} else {
					newStack[i] = stacks[destinationIndex][i-len(transfer)]
				}
			}

			stacks[sourceIndex] = stacks[sourceIndex][amount:]
			stacks[destinationIndex] = newStack
		}
	}

	for idx, stack := range stacks {
		fmt.Printf("Top of stack %d: %c\n", idx, stack[0])
	}
}

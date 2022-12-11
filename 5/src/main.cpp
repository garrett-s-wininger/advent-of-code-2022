#include <deque>
#include <fstream>
#include <iostream>
#include <sstream>
#include <string>
#include <string_view>
#include <vector>

int main(int argc, char **argv) {
  if (argc != 2) {
    std::cerr << "Usage: ./main <filepath>" << std::endl;
    return EXIT_FAILURE;
  }

  std::ifstream input(argv[1]);
  std::vector<std::deque<char>> container_stacks;
  container_stacks.push_back(std::deque<char>());

  for (std::string line; std::getline(input, line);) {
    if (line.starts_with(std::string_view(" 1"))) {
      break;
    }

    for (unsigned int i = 0; i < line.length(); i += 4) {
      if (line[i] != '[') {
        continue;
      }

      const unsigned int destination_stack = i / 4;
      const unsigned int max_stack_index = container_stacks.size() - 1;

      if (destination_stack > max_stack_index) {
        for (unsigned int i = 0; i < destination_stack - max_stack_index; ++i) {
          container_stacks.push_back(std::deque<char>());
        }
      }

      container_stacks[destination_stack].push_back(line[i + 1]);
    }
  }

  for (std::string line; std::getline(input, line);) {
    if (line.size() == 0) {
      continue;
    }

    std::istringstream stream(line);
    std::string command_part;
    unsigned int movement_count;
    unsigned int source_stack;
    unsigned int destination_stack;

    stream >> command_part;
    stream >> movement_count;
    stream >> command_part;
    stream >> source_stack;
    stream >> command_part;
    stream >> destination_stack;

    for (unsigned int i = 0; i < movement_count; ++i) {
      char item = container_stacks[source_stack - 1].front();

      container_stacks[source_stack - 1].pop_front();
      container_stacks[destination_stack - 1].push_front(item);
    }
  }

  for (const auto &stack : container_stacks) {
    std::cout << "Top Element: " << stack.front() << std::endl;
  }

  return EXIT_SUCCESS;
}

#!/usr/bin/env ruby

if ARGV.length != 1
    STDERR.puts "Usage: ./main.rb <filepath>"
    exit
end

def compare_packets(first, second)
    if first.is_a?(Integer) && second.is_a?(Integer)
        if first < second
            return :less
        elsif first == second
            return :equal
        else
            return :greater
        end
    elsif first.is_a?(Integer) && second.is_a?(Array)
        return compare_packets([first], second)
    elsif first.is_a?(Array) && second.is_a?(Integer)
        return compare_packets(first, [second])
    elsif first.is_a?(Array) && second.is_a?(Array)
        for idx in 0..[first.length, second.length].min
            result = compare_packets(first[idx], second[idx])

            if result == :less
                return :less
            elsif result == :greater
                return :greater
            end
        end

        if first.length < second.length
            return :less
        elsif first.length == second.length
            return :equal
        else
            return :greater
        end
    end
end

line_number = 0
pair_idx = 1
pair = [nil, nil]
ordered_pairs = []

File.open(ARGV[0]).each do |line|
    line_number += 1

    if line_number % 3 == 0
        if compare_packets(pair[0], pair[1]) == :less
            ordered_pairs.push pair_idx
        end

        pair_idx += 1
    elsif line_number % 3 == 1
        pair[0] = eval line
    else
        pair[1] = eval line
    end
end

puts "Sum of ordered pair indicies: #{ordered_pairs.sum}"

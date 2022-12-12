<?php

function directory_size(array $directory): int {
    $subdirs = array_filter($directory["contents"], fn($item) => array_key_exists("contents", $item));
    $files = array_filter($directory["contents"], fn($item) => array_key_exists("size", $item));
    $total_size = 0;

    foreach ($files as $file) {
        $total_size += $file["size"];   
    }

    foreach ($subdirs as $subdir) {
        $total_size += directory_size($subdir);
    }

    return $total_size;
}

function sizes_below_threshold(array $directory, int $threshold, array &$accumulator): array {
    $subdirs = array_filter($directory["contents"], fn($item) => array_key_exists("contents", $item));

    foreach ($subdirs as $subdir) {
        sizes_below_threshold($subdir, $threshold, $accumulator);
    }

    $top_level_size = directory_size($directory);
    
    if ($top_level_size <= $threshold) {
        $accumulator[] = $top_level_size;
    }

    return $accumulator;
}

if (count($argv) != 2) {
    fwrite(STDERR, "Usage: ./main <filepath>\n");
    exit(1);
}

$handle = @fopen($argv[1], "r");

if (!$handle) {
    fwrite(STDERR, "Unable to open requested file\n");
    exit(1);
}

$filesystem = [];
$cwd = null;

while (($line = fgets($handle))) {
    $output = explode(" ", $line);

    if ($output[0] === "$") {
        if ($output[1] === "cd") {
            $destination = trim($output[2]);

            if (empty($filesystem) && $destination === "/") {
                $filesystem = ["name" => $destination, "contents" => [], "parent" => null];
                $cwd =& $filesystem;
            } else {
                if ($destination !== "..") {
                    $idx = 0;

                    for (; $idx < count($cwd["contents"]); ++$idx) {
                        if ($cwd["contents"][$idx]["name"] === $destination) {
                            break;
                        }
                    }

                    $new_cwd =& $cwd["contents"][$idx];
                    unset($cwd);
                    $cwd =& $new_cwd;
                } else {
                    $new_cwd =& $cwd["parent"];
                    unset($cwd);
                    $cwd =& $new_cwd;
                }
            }
        }
    } else {
        $name = trim($output[1]);

        if ($output[0] === "dir") {
            $cwd["contents"][] = ["name" => $name, "contents" => [], "parent" => &$cwd];
        } else {
            $cwd["contents"][] = ["name" => $name, "size" => intval($output[0])];
        }
    }
}

fclose($handle);

$threshold_sizes = [];
sizes_below_threshold($filesystem, 100_000, $threshold_sizes);
echo "Total: " . array_sum($threshold_sizes) . "\n";

?>


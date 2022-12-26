#!/usr/bin/octave

if (length(argv()) != 1)
    fprintf(stderr(), "Usage: ./main.m <filepath>\n")
    exit(1)
endif

fd = fopen(argv(){1});
line = fgetl(fd);
total = 0;

while (line != -1)
    range_components = strsplit(line, {",", "-"});
    range1_start = str2num(range_components{1});
    range1_end = str2num(range_components{2});
    range2_start = str2num(range_components{3});
    range2_end = str2num(range_components{4});

    if (range1_start >= range2_start && range1_start <= range2_end)
        total += 1;
    elseif (range1_start <= range2_start && range1_end >= range2_start)
        total += 1;
    endif

    line = fgetl(fd);
endwhile

fclose(fd);
printf("Total overlapping ranges: %d\n", total);

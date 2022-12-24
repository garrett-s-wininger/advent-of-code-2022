import java.io.IOException;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.Files;
import java.util.concurrent.atomic.AtomicInteger;

public class Main {
    public static void main(String[] args) throws IOException {
        if (args.length != 1) {
            System.err.println("Usage: java main -- <filepath>");
            System.exit(1);
        }

        AtomicInteger currentLine = new AtomicInteger(0);
        Path filepath = Paths.get(args[0]);

        String[] rucksackGroup = new String[3];
        AtomicInteger badgePrioritySum = new AtomicInteger(0);

        Files.lines(filepath).forEach(line -> {
            currentLine.incrementAndGet();
            
            switch (currentLine.intValue() % 3) {
                case 1:
                    rucksackGroup[0] = line;
                    break;
                case 2:
                    rucksackGroup[1] = line;
                    break;
                case 0:
                    rucksackGroup[2] = line;

                    for (Character character : rucksackGroup[0].toCharArray()) {
                        if (
                            rucksackGroup[1].indexOf(character) != -1 && 
                            rucksackGroup[2].indexOf(character) != -1
                        ) {
                            if (character >= 'a') {
                                badgePrioritySum.addAndGet(character - 96);
                            } else {
                                badgePrioritySum.addAndGet((character - 64) + 26);
                            }

                            break;
                        }
                    }

                    break;
            }
        });

        System.out.println(
            "Total sum of badge priorities: " +
            Integer.valueOf(badgePrioritySum.intValue()).toString()
        );
    }
}

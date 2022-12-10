open System.IO

let readRucksacks (filePath: string) = seq {
    use sr = new StreamReader(filePath)
    
    while not sr.EndOfStream do
        yield sr.ReadLine ()
}

let itemToPriority (item: char) =
    let lowerCaseSubValue = 96
    let upperCaseSubValue = 38

    if int item >= int 'a' && int item <= int 'z' then int item - lowerCaseSubValue
    elif int item >= int 'A' && int item <= int 'Z' then int item - upperCaseSubValue
    else failwith "itemToPriority provided with a value outside the range of a-z or A-Z"
     
let matchItems ((left, right): string*string) =
    List.filter (fun item -> List.contains item (Seq.toList right)) (Seq.toList left) |> Set.ofList

[<EntryPoint>]
let main args =
    if args.Length <> 1 then failwith "Usage: dotnet run <filepath>"

    let rucksackCompartments = readRucksacks(args[0]) |> Seq.map (fun ruck ->
        let splitIdx = (ruck.Length / 2) - 1
        
        (ruck[0..splitIdx], ruck[splitIdx + 1..])
    ) 
    
    let sharedItems = rucksackCompartments |> Seq.map (fun compartmentPair ->
        matchItems(compartmentPair)
    ) 

    let priorities = sharedItems |> Seq.map (fun sharedItemSet ->
        sharedItemSet |> Set.map (fun sharedItem ->
            itemToPriority sharedItem
        )
    )

    let prioritySums = priorities |> Seq.map (fun prioritySet ->
        Set.fold (+) 0 prioritySet
    )

    let totalSum = Seq.fold (+) 0 prioritySums

    printfn "Total sum: %d" totalSum

    0


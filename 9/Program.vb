Imports System
Imports System.IO

Module Program
    Function IsConnected(head As (Integer, Integer), tail As (Integer, Integer)) As Boolean
        Dim overlapping = (head.Item1 = tail.Item1) And (head.Item2 = tail.Item2)
        Dim northSouthConnection = (head.Item1 = tail.Item1) And (Math.Abs(head.Item2 - tail.Item2) = 1)
        Dim eastWestConnection = (Math.Abs(head.Item1 - tail.Item1) = 1) And (head.Item2 = tail.Item2)
        Dim diagonalConnection = (Math.Abs(head.Item1 - tail.Item1) = 1) And (Math.Abs(head.Item2 - tail.Item2) = 1)

        IsConnected = overlapping Or northSouthConnection Or eastWestConnection Or diagonalConnection
    End Function
    
    Sub Main(args As String())
        If args.Length() <> 1
            Console.Error.WriteLine("Usage: dotnet run <filename>")
            Environment.Exit(1)
	End If

        Dim headLastPosition As (Integer, Integer) = (0, 0)
        Dim headPosition As (Integer, Integer) = (0, 0)
        Dim tailPosition As (Integer, Integer) = (0, 0)
        Dim visited as HashSet(Of (Integer, Integer)) = New HashSet(Of (Integer, Integer))

        visited.Add(tailPosition)
    
        Using reader As StreamReader = New StreamReader(args(0))
            Dim line as String = reader.ReadLine

            Do While (Not line Is Nothing)
                Dim commandInput As String() = line.Split({" "c}) 
                
                For i = 1 To Val(commandInput(1))
                    headLastPosition = headPosition

                    Select Case commandInput(0)
                        Case "U"
                            headPosition.Item2 += 1
                        Case "D"
                            headPosition.Item2 -= 1
                        Case "L"
                            headPosition.Item1 -= 1
                        Case "R"
                            headPosition.Item1 += 1
                    End Select

                    If Not IsConnected(headPosition, tailPosition) Then
                        tailPosition = headLastPosition
                        visited.Add(tailPosition)
                    End If
                Next

                line = reader.ReadLine
            Loop
        End Using

        Console.WriteLine($"Total Visited Locations: {visited.Count}")
    End Sub
End Module

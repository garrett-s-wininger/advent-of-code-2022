with Ada.Command_Line; use Ada.Command_Line;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Ada.Text_IO; use Ada.Text_IO;

procedure Main is
    Input_File_Path: Unbounded_String;
    Input_File: File_Type;

    Current_Sum: Natural := 0;
    Top_3: array(1..3) of Natural := (0, 0, 0);
begin
    if Argument_Count /= 1 then
        Put_Line (Standard_Error, "Usage: ./main <filepath>");
        Set_Exit_Status (Failure);
    else
        Input_File_Path := To_Unbounded_String (Argument (1));
        Open (File => Input_File, Mode => In_File, Name => To_String (Input_File_Path));
        
        while not End_Of_File (Input_File) loop
            declare
                Line: String := Get_Line (Input_File);
            begin
                if Line /= "" then
                    Current_Sum := Current_Sum + Integer'Value(Line);
                else
                    declare
                        Min_Idx: Positive := 1;
                        Min: Natural := Top_3(Min_Idx);
                    begin
                        For I in 2 .. 3 loop
                            if Top_3(I) < Min then
                                Min_Idx := I;
                                Min := Top_3(I);
                            end if;
                        end loop;

                        if Current_Sum > Min then
                            Top_3(Min_Idx) := Current_Sum;
                        end if;
                    end;

                    Current_Sum := 0;
                end if;
            end;
        end loop;

        declare
            Min_Idx: Positive := 1;
            Min: Natural := Top_3(Min_Idx);
        begin
            For I in 2 .. 3 loop
                if Top_3(I) < Min then
                    Min_Idx := I;
                    Min := Top_3(I);
                end if;
            end loop;

            if Current_Sum > Min then
                Top_3(Min_Idx) := Current_Sum;
            end if;
        end;

        declare
            Total: Natural := 0;
        begin
            For I in 1 .. 3 loop
                Total := Total + Top_3(I);
            end loop;

            Put_Line ("Total of top 3 counts" & Total'Image);
        end;

        Close (Input_File);
    end if;
end Main;

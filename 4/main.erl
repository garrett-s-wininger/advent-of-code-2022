-module(main).
-export([main/1]).

is_overlapping([Start1, End1, Start2, End2]) when Start1 =< Start2, End1 >= End2 -> true;
is_overlapping([Start1, End1, Start2, End2]) when Start2 =< Start1, End2 >= End1 -> true;
is_overlapping(_) -> false.

main(FileName) ->
	{ok, Data} = file:read_file(FileName),
	
	Lines = [X || 
		 X <- binary:split(Data, [<<"\n">>], [global]), byte_size(X) > 0],
	
	RangeStrings = [binary:split(X, [<<",">>]) || X <- Lines],
	
	Ranges = [binary:split(lists:nth(1, X), [<<"-">>]) ++ binary:split(lists:nth(2, X), [<<"-">>]) || 
		  X <- RangeStrings],

	IntegerRanges = [[list_to_integer(binary_to_list(Y)) || Y <- X] || X <- Ranges],
	Overlapping = [X || X <- IntegerRanges, is_overlapping(X)],
	
	io:format("Found ~p overlapping ranges.~n", [length(Overlapping)]).


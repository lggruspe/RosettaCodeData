def verify: if cocktailSort == sort then empty else . end;

([],
 [1],
 [1,1],
 [3, 14],
 [33, 14],
 [3, 14, 1, 5, 9, 2, 6, 3],
 [23,76,99,58,97,57,35,89,51,38,95,92,24,46,31,24,14,12,57,78,4],
 [88,18,31,44,4,0,8,81,14,78,20,76,84,33,73,75,82,5,62,70,12,7,1],
 [1.5, -1.5],
 ["cocktail", ["sort"], null, {}]
) | verify

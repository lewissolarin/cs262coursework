/*
1. YES
2. YES
3. YES
4. YES
5. YES
6. NO
7. YES
8. NO 
9. NO 
10. YES
*/

% Define precedence of operators
:- op(140, fy, neg).
:- op(160, xfy, and).
:- op(160, xfy, or).
:- op(160, xfy, imp).
:- op(160, xfy, revimp).
:- op(160, xfy, uparrow).
:- op(160, xfy, downarrow).
:- op(160, xfy, notimp).
:- op(160, xfy, notrevimp).
:- op(160, xfy, equiv).
:- op(160, xfy, notequiv).

% Logical operators

neg(X) :- not(X).
or(X,Y) :- X;Y.
and(X,Y) :- X,Y.
imp(X,Y) :- or(neg(X),Y).
revimp(X,Y) :- or(X,neg(Y)).
uparrow(X,Y) :- neg(and(X,Y)).
downarrow(X,Y) :- neg(or(X,Y)).
notimp(X,Y) :- neg(imp(X,Y)).
notrevimp(X,Y) :- neg(revimp(X,Y)).
equiv(X,Y) :- (X imp Y) and (X revimp Y).
notequiv(X,Y) :- neg(equiv(X,Y)).

unary(neg neg _).
unary(neg true).
unary(neg false).

equiv_operator(_ equiv _).
equiv_operator(neg(_ equiv _)).
equiv_operator(_ notequiv _).
equiv_operator(neg(_ notequiv _)).

% conjunctive (X) :- X is an alpha formula.

conjunctive(_ and _).
conjunctive(neg(_ or _)).
conjunctive(neg(_ imp _)).
conjunctive(neg(_ revimp _)).
conjunctive(neg(_ uparrow _)).
conjunctive(_ downarrow _).
conjunctive(_ notimp _).
conjunctive(_ notrevimp _).

% % disjunctive (X) :- X is a beta formula.

disjunctive(neg(_ and _)).
disjunctive(_ or _).
disjunctive(_ imp _).
disjunctive(_ revimp _).
disjunctive(_ uparrow _).
disjunctive(neg(_ downarrow _)).
disjunctive(neg(_ notimp _)).
disjunctive(neg(_ notrevimp _)).

% % components (X, Y, Z) :- Y and Z are the components of the formula X, as defined in the alpha and beta table.

components(X and Y, X, Y).
components(neg(X and Y), neg X, neg Y).
components(X or Y, X, Y).
components(neg(X or Y), neg X, neg Y).
components(X imp Y, neg X, Y).
components(neg(X imp Y), X, neg Y).
components(X revimp Y, X, neg Y).
components(neg(X revimp Y), neg X, Y).
components(X uparrow Y, neg X, neg Y).
components(neg(X uparrow Y), X, Y).
components(X downarrow Y, neg X, neg Y).
components(neg(X downarrow Y), X, Y).
components(X notimp Y, X, neg Y).
components(neg(X notimp Y), neg X, Y).
components(X notrevimp Y, neg X, Y).
components(neg(X notrevimp Y), X, neg Y).

% % component(X, Y) :- Y is the component of the unary formula X.

component(neg neg X, X).
component(neg X, neg X).
component(neg true, false).
component(neg false, true).

equiv_component(X equiv Y, (X imp Y) and (X revimp Y)).
equiv_component(X notequiv Y, neg(X equiv Y)).
equiv_component(neg(X equiv Y), neg((X imp Y) and (X revimp Y))).
equiv_component(neg(X notequiv Y), X equiv Y).


% member(Element, List) :- Check if item occurs in list

member(X, [X | _]).
member(X, [_ | Tail]) :- member(X, Tail).

% remove(Item, List, Newlist) :- Remove all instances of item from list, result in newlist

remove(_, [], []).
remove(X, [X | Tail], Newtail) :-
    remove(X, Tail, Newtail).
remove(X, [Head | Tail], [Head | Newtail]) :-
    remove(X, Tail, Newtail).

% remove_duplicates(List, NewList) :- Removes any elements that already appear in the list
remove_duplicates([], []).
remove_duplicates([Head | Tail], Result) :-
    member(Head, Tail), !,
    remove_duplicates(Tail, Result).
remove_duplicates([Head | Tail], [Head | Result]) :-
    remove_duplicates(Tail, Result).


% atomic_formula(X) - Check X is an atomic formula
atomic_formula(X) :- 
    atom(X).

atomic_formula(neg X) :-
    atom(X).


% Unary conversions
resolutionstep([Disjunction | Rest], New) :-
    % Select formula from this disjunction
    member(Formula, Disjunction),
    % Check if the formula is a unary formula
    unary(Formula),
    % Convert the formula 
    component(Formula, NewFormula),
    % Remove the original formula from the disjunction
    remove(Formula, Disjunction, Temporary),
    % Add the new formula to remaining part of the disjunction
    NewDisjunction = [NewFormula | Temporary],
    % Add the new disjunction to the rest of the conjunction
    New = [NewDisjunction | Rest].


% Equivalent conversions
resolutionstep([Disjunction | Rest], New) :-
    % Select formula from this disjunction
    member(Formula, Disjunction),
    % Check if the formula uses the equivalence operator or its negation
    equiv_operator(Formula),
    % Convert the formula 
    equiv_component(Formula, NewFormula),
    % Remove the original formula from the disjunction
    remove(Formula, Disjunction, Temporary),
    % Add the new formula to remaining part of the disjunction
    NewDisjunction = [NewFormula | Temporary],
    % Remove any duplicate formulas from the disjunction
    remove_duplicates(NewDisjunction, NewNewDisjunction),
    % Add the new disjunction to the rest of the conjunction
    New = [NewNewDisjunction | Rest].

 
% Beta rule - More efficent to always do these first

resolutionstep([Disjunction | Rest], New) :-
    % Select formula from this disjunction
    member(Beta, Disjunction),
    % Check it is an beta formula
    disjunctive(Beta),
    % Split the beta formula into BetaOne and BetaTwo
    components(Beta, Betaone, Betatwo),
    % Get the disjunction without the original beta formula
    remove(Beta, Disjunction, Temporary),
    % Add the two new beta formulas to the remaining part of the disjunction
    NewDisjunction = [Betaone, Betatwo | Temporary],
    % Remove any duplicate formulas from the disjunction
    remove_duplicates(NewDisjunction, NewNewDisjunction),
    % Add the new disjunction to the rest of the conjunction
    New = [NewNewDisjunction | Rest].


% Alpha rule

resolutionstep([Disjunction | Rest], New) :-
    % Select formula from this disjunction
    member(Alpha, Disjunction),
    % Check it is an alpha formula
    conjunctive(Alpha),
    % Split the alpha formula into AlphaOne and AlphaTwo
    components(Alpha, Alphaone, Alphatwo),
    % Get the disjunction without the original alpha formula
    remove(Alpha, Disjunction, Temporary),
    % Create two new disjunctions, one starting with AlphaOne and the other starting with AlphaTwo, following by the rest of the disjunction
    NewDisjunctionOne = [Alphaone | Temporary],
    NewDisjunctionTwo = [Alphatwo | Temporary],
    % Remove any duplicate formulas from the new disjunctions
    remove_duplicates(NewDisjunctionOne, NewNewDisjunctionOne),
    remove_duplicates(NewDisjunctionTwo, NewNewDisjunctionTwo),
    % Add the two new disjunctions to the rest of the conjuction
    New = [NewNewDisjunctionOne, NewNewDisjunctionTwo | Rest].




% Resolution Rule

resolutionstep([Disjunction | Rest], New) :-
    % Select formula from this disjunction
    member(Formula, Disjunction),
    atomic_formula(Formula),
    % Get negation of formula
    component(neg(Formula), Negation),
    % Select another disjunction where Negation is in it
    member(OtherDisjunction, Rest),
    % Check formula is atomic
    member(Negation, OtherDisjunction),
    % Remove formula and negation from disjunction 
    remove(Formula, Disjunction, TemporaryOne),
    remove(Negation, TemporaryOne, NewTemporaryOne),
    % Remove formula and negation from other disjunction 
    remove(Formula, OtherDisjunction, TemporaryTwo),
    remove(Negation, TemporaryTwo, NewTemporaryTwo), 
    % Combine formulas from each disjunction excluding the formula that the rule is being applied to, and its negation
    append([NewTemporaryOne,NewTemporaryTwo], NewDisjunction),
    % Efficiency - remove any duplicate variables
    remove_duplicates(NewDisjunction, Resolvent),
    sort(Resolvent, SortedResolvent),
    % Add the original disjunction back to the rest of the conjunction
    append(Rest, [Disjunction], NewRest),
    % Check the resolvent isn't already in the Disjunction
    not(member(SortedResolvent, NewRest)),
    % Add the new resolvent to the end of the conjunction
    append(NewRest, [SortedResolvent], New).


resolutionstep([Disjunction|Rest], [Disjunction|Newrest]) :-
    resolutionstep(Rest, Newrest).


resolution(Conjunction, Newconjunction) :-
    resolutionstep(Conjunction, Temp),
    resolution(Temp, Newconjunction).

resolution(Conjunction, Conjunction).

clauseform(X, Y) :- resolution([[X]], Y).


% Test for closure
closed(Conjunction) :- member([], Conjunction).
closed(Conjunction) :- member([X], Conjunction), member([neg X], Conjunction).

if_then_else(P,Q,R) :- P,!,Q.
if_then_else(P,Q,R) :- R.

% Check if conjunction is closed
resolutionstep_and_close(Conjunction, PreviousConjunctions) :-
    closed(Conjunction).

% Check if conjunction has already been tried, this will indicate that there is no proof
resolutionstep_and_close(Conjunction, PreviousConjunctions) :-
    sort(Conjunction, SortedConjunction),
    member(SortedConjunction, PreviousConjunctions),
    !,
    false.

resolutionstep_and_close(Conjunction, PreviousConjunctions) :-
    sort(Conjunction, SortedConjunction),
    NewPreviousConjunctions = [SortedConjunction | PreviousConjunctions],
    remove_duplicates(Conjunction, ConjunctionWithNoDuplicates),
    write(ConjunctionWithNoDuplicates),
    write('\n'),
    resolutionstep(ConjunctionWithNoDuplicates, NewConjunction), !,
    resolutionstep_and_close(NewConjunction, NewPreviousConjunctions).

test(X) :-
    if_then_else(resolutionstep_and_close([[neg X]], []), yes, no).

yes :- write('YES'), nl.
no :- write('NO'), nl.












my_test:-test(YES).
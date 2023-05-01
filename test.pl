/*
1. YES
2. YES
3. YES
4. YES
7. YES
8. NO 
9. YES CHECK AGAIN
10. YES
*/

% My workings out
% 1. YES
% 2. YES
% 3. YES
% 7. YES
% 8. NO 
% 9. YES CHECK AGAIN
% 10. YES


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
% conjunctive(_ equiv _).

% % disjunctive (X) :- X is a beta formula.

disjunctive(neg(_ and _)).
disjunctive(_ or _).
disjunctive(_ imp _).
disjunctive(_ revimp _).
disjunctive(_ uparrow _).
disjunctive(neg(_ downarrow _)).
disjunctive(neg(_ notimp _)).
disjunctive(neg(_ notrevimp _)).
% disjunctive(_ notequiv _).


% % components (X, Y, Z) :- Y and Z are the components
% % of the formula X, as defined in the alpha and
% % beta table.

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
% components(X equiv Y, X imp Y, Y imp X).
% components(X notequiv Y, X notimp Y, Y notimp X).



% % component(X, Y) :- Y is the component of the
% % unary formula X.

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

remove_duplicates([], []).

remove_duplicates([Head | Tail], Result) :-
    member(Head, Tail), !,
    remove_duplicates(Tail, Result).

remove_duplicates([Head | Tail], [Head | Result]) :-
    remove_duplicates(Tail, Result).


% Unary conversions
resolutionstep([Disjunction | Rest], Used, New, NewUsed) :-
    member(Formula, Disjunction),
    unary(Formula),
    component(Formula, NewFormula),
    remove(Formula, Disjunction, Temporary),
    NewDisjunction = [NewFormula | Temporary],
    write('Unary \n'),
    write(NewDisjunction), write('\n \n'),
    NewUsed = Used,
    New = [NewDisjunction | Rest].


% Equivalent conversions
resolutionstep([Disjunction | Rest], Used, New, NewUsed) :-
    member(Formula, Disjunction),
    equiv_operator(Formula),
    equiv_component(Formula, NewFormula),
    remove(Formula, Disjunction, Temporary),
    NewDisjunction = [NewFormula | Temporary],
    write('Equivalent \n'),
    write(NewDisjunction), write('\n \n'),
    NewUsed = Used,
    New = [NewDisjunction | Rest].

 
% Beta rule - More efficent to always do these first

resolutionstep([Disjunction | Rest], Used, New, NewUsed) :-
    member(Beta, Disjunction),
    disjunctive(Beta),
    components(Beta, Betaone, Betatwo),
    remove(Beta, Disjunction, Temporary),
    Newdis = [Betaone, Betatwo | Temporary],
    write('Beta \n'),
    write(Newdis), write('\n \n'),
    NewUsed = Used,
    New = [Newdis | Rest].

% Alpha rule

resolutionstep([Disjunction | Rest], Used, New, NewUsed) :-
    member(Alpha, Disjunction),
    conjunctive(Alpha),
    components(Alpha, Alphaone, Alphatwo),
    remove(Alpha, Disjunction, Temporary),
    Newdisone = [Alphaone | Temporary],
    Newdistwo = [Alphatwo | Temporary],
    write('Alpha \n'),
    write(Newdisone), write('\n'),
    write(Newdistwo), write('\n \n'),
    NewUsed = Used,
    New = [Newdisone, Newdistwo | Rest].




% Resolution Rule

resolutionstep([Disjunction | Rest], Used, New, NewUsed) :-
    % write('Resolution Rule Check - '), write(Disjunction), write('\n'),
    % Select literal from this disjunction
    write('Finding literal in disjunction \n'),
    member(Literal, Disjunction),
    % Get negation of literal
    component(neg(Literal), Negation),
    % Select another disjunction where Negation is in it
    write('Finding another disjunction \n'),
    member(OtherDisjunction, Rest),
    % write('Other - '), write(OtherDisjunction), write('\n'),
    % write(Literal), write('\n'),
    write('Finding negation in other disjunction \n'),
    % write('Looking for - '),write(Negation), write('\n'),
    member(Negation, OtherDisjunction),
    % member(neg(Literal), OtherDisjunction),


    write('Remove literal and negation from disjunction \n'),
    remove(Literal, Disjunction, TemporaryOne),
    remove(Negation, TemporaryOne, NewTemporaryOne),
    % remove(component(neg(Literal)), OtherDisjunction, TemporaryTwo), 
    write('Removing literal and negation from other disjunction \n'),
    remove(Literal, OtherDisjunction, TemporaryTwo),
    remove(Negation, TemporaryTwo, NewTemporaryTwo), 
    write('Creating resolvent \n'),
    append([NewTemporaryOne,NewTemporaryTwo], Resolvent),

    
    % remove(Literal, Disjunction, TemporaryOne),
    % % remove(component(neg(Literal)), OtherDisjunction, TemporaryTwo), 
    
    % remove(Negation, OtherDisjunction, TemporaryTwo), 
    
    % append([TemporaryOne,TemporaryTwo], Resolvent),

    % remove(OtherDisjunction, Rest, NewConjunction),
    

    write('Addign original disjunction back to rest \n'),
    append(Rest, [Disjunction], NewRest),
    % sort
    % !  Having a cut here will make it work for NO instances
    % Need a way to stop running infintely
    write('Checking resolvent is not found later in disjunction \n'),
    not(member(Resolvent, NewRest)),
    write('Checking disjunction and other have not already been resolved \n'),
    not(member([Disjunction, OtherDisjunction], Used)),
    write('Checking other and disjunction have not already been resolved \n'),
    not(member([OtherDisjunction, Disjunction], Used)),
    NewUsed = [[Disjunction, OtherDisjunction] | Used],
    write(Used),
    write('\n'),

    write('Resolution \n'),
    write(Resolvent), write('\n \n'),
    % append([Resolvent], NewRest, NewNewRest),
    append(NewRest, [Resolvent], New).
    

    % New = [NewDisjunction | NewRest].

resolutionstep([Disjunction|Rest], Used, [Disjunction|Newrest], NewUsed) :-
    resolutionstep(Rest, Used, Newrest, NewUsed).


% resolution(Conjunction, Newconjunction) :-
%     resolutionstep(Conjunction, Temp),
%     resolution(Temp, Newconjunction).

% resolution(Conjunction, Conjunction).

% clauseform(X, Y) :- resolution([[X]], Y).


% Test for closure
closed(Conjunction) :- member([], Conjunction), write('Closed with [] \n \n').
closed(Conjunction) :- member([X], Conjunction), member([neg X], Conjunction), write('Closed with '), write([X]), write(' and '), write([neg X]), write('\n \n').

if_then_else(P,Q,R) :- P,!,Q.
if_then_else(P,Q,R) :- R.

resolutionstep_and_close(Resolution, Used) :-
    closed(Resolution).

resolutionstep_and_close(Resolution, Used) :-
    resolutionstep(Resolution, Used, Newresolution, NewUsed),
    !,
    resolutionstep_and_close(Newresolution, NewUsed).

test(X) :-
    if_then_else(resolutionstep_and_close([[neg X]],[]), yes, no).



yes :- write('YES'), nl.
no :- write('NO'), nl.












my_test:-test((neg (z notrevimp y) revimp x) imp ((x or w) imp ((y imp z) or w))).
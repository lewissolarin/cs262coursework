resolutionstep([Disjunction | Rest], New) :-
    member(Literal, Disjunction),
    member(OtherDisjunction, Rest),
    member(neg(Literal), OtherDisjunction),

    % Need to remove the whole disjunctions from the overall conjunction not just the literals

    % remove(Literal, Disjunction, TemporaryOne),
    % remove(neg(Literal), OtherDisjunction, TemporaryTwo),  % i think there is a problem here
    % append([TemporaryOne,TemporaryTwo], NewDisjunction),

    remove(OtherDisjunction, Rest, NewConjunction)
    % New = [NewDisjunction | NewConjunction].
    New = NewConjunction.



    
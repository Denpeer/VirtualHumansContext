
:- dynamic stakeholders/1.
:- dynamic settings/1.
:- dynamic functions/1.
:- dynamic buildings/1.
:- dynamic indicator/3.
:- dynamic indicatorWeight/3.

% we have a building if the building list has at least 1 element.
havebuilding :- buildings([X|Y]).

% Get indicator
getIndicator(Name, Weight, CurrentValue, TargetValue) :- 
	indicatorWeight(ID,Name,Weight), indicator(ID, CurrentValue, TargetValue).
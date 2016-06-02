:- dynamic stakeholders/1.
:- dynamic settings/1.
:- dynamic functions/1.
:- dynamic buildings/1.
:- dynamic zones/1.
:- dynamic indicator/3.
:- dynamic indicatorWeight/3.
:- dynamic planned/3.
:- dynamic self/1.
:- dynamic stakeholder/2.
:- dynamic relevant_areas/2.

% Get indicator
%indicator names: "Astand TUDelft", "Bouw DUWO", "Budget DUWO", "Ruimtelijke kwaliteit", "Variatie Woonruimte"
getIndicator(ID, Name, Weight, CurrentValue, TargetValue) :-
	indicatorWeight(ID,Name,Weight), indicator(ID, CurrentValue, TargetValue).

% Only build houses when our current value < target value.
needStudentHousing :-
	getIndicator(ID,'Bouw DUWO', Weight, CurrentValue, TargetValue),
	CurrentValue < TargetValue.

goalBuildStudentHousing :-
	needStudentHousing.

% Budget predicates that the bot can use to either stop building or build more carefully (raising a value needed per building for example)
% These predicates expect DUWO to keep its target budget as a minimum (since DUWO can't raise it's budget by other means than selling property)
lowBudget :-
	getIndicator(ID,'Budget DUWO', Weight, CurrentValue, TargetValue),
	CurrentValue < 1.2*TargetValue.

noBudget :-
	getIndicator(ID,'Budget DUWO', Weight, CurrentValue, TargetValue),
	CurrentValue < TargetValue.

goalReachBudgetTarget :-
	not(lowBudget),
	not(noBudget).

% Get a multipolygon as a sqaure with X, Y, Width and Height as coordinates.
getPolygon(X, Y, Width, Height, Square) :-
	XAndWidth is X+Width,
	YAndHeight is Y+Height,
	format(atom(A), "MULTIPOLYGON(((~w ~w, ~w ~w, ~w ~w, ~w ~w, ~w ~w)))",
	[X,Y,XAndWidth,Y, XAndWidth, YAndHeight,X, YAndHeight, X, Y]),
	Square = multipolygon(A).
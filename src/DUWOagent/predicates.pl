:- dynamic stakeholders/1.
:- dynamic settings/1.
:- dynamic functions/1.
:- dynamic buildings/1.
:- dynamic zones/1.
:- dynamic indicator/4.
:- dynamic indicatorWeight/3.
:- dynamic planned/3.
:- dynamic self/1.
:- dynamic stakeholder/2.
:- dynamic relevant_areas/2.
:- dynamic goalDemolish/0.
:- dynamic demolished/1.
:- dynamic sell_proposal/2.
:- dynamic buildableStudent/2.
:- dynamic buildableStudentList/1.
:- dynamic cheapHousingIds/1.
:- dynamic mediumHousingIds/1.
:- dynamic luxuryHousingIds/1.

% A predicate containing a building that doesn't influence our building indicators
nonStudentBuilding(Bid,Name) :- 
		buildings(Y),
		self(OwnId),
		member(building(Bid,Name,OwnId,Year,Cat,_,_,_),Y),
		not(member('STUDENT',Cat)).
		
getBuilding(Bid, Type) :- 
		buildings(Y),
		self(OwnId),
		member(building(Bid,Name,OwnId,Year,Cat,_,_,_),Y),
		member(Type, Cat).

% create a predicate with the Id's of all buildable houses of type student, so that the agent can dynamically choose what kind of building to build
buildableStudentList([]).

buildableStudent(Id,Name) :- functions(FS), 
		member([Name,Id,L],FS),
		member('STUDENT',L).

% Get indicator
%indicator names: "Astand TUDelft", "Bouw DUWO", "Budget DUWO", "Ruimtelijke kwaliteit", "Variatie Woonruimte"
getIndicator(ID, Name, Weight, CurrentValue, TargetValue, ZoneLink) :-
	indicatorWeight(ID,Name,Weight), indicator(ID, CurrentValue, TargetValue, ZoneLink).

% Gets all of the amounts at once, splitted in cheap, medium and luxury.
amountHousingAll(AmountCheap, AmountMedium, AmountLuxury) :-
	amountCheapHousing(AmountCheap),
	amountMediumHousing(AmountMedium),
	amountLuxuryHousing(AmountLuxury).

% Gets the amount of housing.
% KindOfHousing tells which kind of housing type,
% 0 = cheap housing, 1 = medium, 2 = luxury
amountHousing(KindOfHousing, Amount) :-
	getIndicator(ID,'Variatie Woonruimte', Weight, CurrentValue, TargetValue, ZoneLink),
	member(HousingType, ZoneLink),
	HousingType = zone_link(KindOfHousing,ID,Amount,_).

% Gets the amount of cheap housing.
amountCheapHousing(Amount) :-
	amountHousing(0, Amount).

% Gets the amount of medium housing.
amountMediumHousing(Amount) :-
	amountHousing(1, Amount).

% Gets the amount of luxury housing.
amountLuxuryHousing(Amount) :-
	amountHousing(2, Amount).

% Only build houses when our current value < target value.
needStudentHousing :-
	getIndicator(ID,'Bouw DUWO', Weight, CurrentValue, TargetValue, ZoneLink),
	CurrentValue < TargetValue.

goalBuildStudentHousing :-
	not(needStudentHousing).

% Budget predicates that the bot can use to either stop building or build more carefully (raising a value needed per building for example)
% These predicates expect DUWO to keep its target budget as a minimum (since DUWO can't raise it's budget by other means than selling property)
lowBudget :-
	getIndicator(ID,'Budget DUWO', Weight, CurrentValue, TargetValue, ZoneLink),
	CurrentValue < 1.2*TargetValue.

noBudget :-
	getIndicator(ID,'Budget DUWO', Weight, CurrentValue, TargetValue, ZoneLink),
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
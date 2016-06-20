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
:- dynamic relevant_areas/3.
:- dynamic filtered_percepts/1.
:- dynamic goalDemolish/0.
:- dynamic sell_proposal/2.
:- dynamic buildableStudent/2.
:- dynamic buildableStudentList/1.
:- dynamic cheapHousingIds/1.
:- dynamic mediumHousingIds/1.
:- dynamic luxuryHousingIds/1.
:- dynamic goalBuildCheapHousing/0.
:- dynamic goalBuildMediumHousing/0.
:- dynamic goalBuildLuxuryHousing/0.
:- dynamic demolished/1.
:- dynamic sell_denied/2.
:- dynamic sold/1.
:- dynamic sell_accepted/2.
:- dynamic sell_request/4.
:- dynamic buy_request/4.
:- dynamic requests/1.
:- dynamic request/10.
:- dynamic gardensBuilt/0.

% A predicate containing a building that doesn't influence our building indicators
nonStudentBuilding(Bid,Name) :- 
	buildings(Buildings)
	, self(OwnId)
	, member(building(Bid,Name,OwnId,Year,Cat,_,_,_,_,_),Buildings)
	, not(member('STUDENT',Cat)).

getBuilding(Bid, Type) :- 
	buildings(Buildings)
	, self(OwnId)
	, member(building(Bid,Name,OwnId,Year,Cat,_,_,_,_,_),Buildings)
	, member(Type, Cat).

% create a predicate with the Id's of all buildable houses of type student, so that the agent can dynamically choose what kind of building to build
buildableStudentList([]).

buildableStudent(BuildingID,Name) :- 
	functions(AllFunctions)
	, member([Name,BuildingID,Catergory],AllFunctions)
	, member('STUDENT',Catergory).

% Get indicator
%indicator names: "Astand TUDelft", "Bouw DUWO", "Budget DUWO", "Ruimtelijke kwaliteit", "Variatie Woonruimte"
getIndicator(ID, Name, Weight, CurrentValue, TargetValue, ZoneLink) :-
	indicatorWeight(ID,Name,Weight)
	, indicator(ID, CurrentValue, TargetValue, ZoneLink).

% Gets all of the amounts at once, splitted in cheap, medium and luxury.
amountHousingAll(AmountCheap, AmountMedium, AmountLuxury) :-
	amountCheapHousing(AmountCheap)
	, amountMediumHousing(AmountMedium)
	, amountLuxuryHousing(AmountLuxury).

% Gets the amount of housing.
% KindOfHousing tells which kind of housing type,
% 0 = cheap housing, 1 = medium, 2 = luxury
amountHousing(KindOfHousing, Amount) :-
	getIndicator(ID,'Variatie Woonruimte', Weight, CurrentValue, TargetValue, ZoneLink)
	, member(HousingType, ZoneLink)
	, HousingType = zone_link(KindOfHousing,ID,Amount,_).

% Gets the amount of cheap housing.
amountCheapHousing(Amount) :-
	amountHousing(0, Amount).

% Gets the amount of medium housing.
amountMediumHousing(Amount) :-
	amountHousing(1, Amount).

% Gets the amount of luxury housing.
amountLuxuryHousing(Amount) :-
	amountHousing(2, Amount).

% Only build cheap student houses when the amount of cheap housing is lower than medium or luxury,
needCheapHousing :-
	not(CurrentValue == TargetValue)
	, amountHousingAll(AmountCheap, AmountMedium, AmountLuxury)
	, AmountCheap < AmountMedium
	, AmountCheap < AmountLuxury.

% Only build medium student houses when the amount of medium housing is lower than cheap or luxury.
needMediumHousing :-
	not(CurrentValue == TargetValue)
	, amountHousingAll(AmountCheap, AmountMedium, AmountLuxury)
	, AmountMedium < AmountCheap
	, AmountMedium < AmountLuxury.

% Only build luxury student houses when the amount of luxury housing is lower than cheap or medium.
needLuxuryHousing :-
	not(CurrentValue == TargetValue)
	, amountHousingAll(AmountCheap, AmountMedium, AmountLuxury)
	, AmountLuxury < AmountCheap
	, AmountLuxury < AmountMedium.

% Only build houses when our current amount of housing is lower than the target amount of housing.
needStudentHousing :-
	getIndicator(ID,'Bouw DUWO', Weight, CurrentValue, TargetValue, ZoneLink)
	, CurrentValue < TargetValue.

goalBuildStudentHousing :-
	not(needStudentHousing).

% Budget predicates that the bot can use to either stop building or build more carefully (raising a value needed per building for example)
% These predicates expect DUWO to keep its target budget as a minimum (since DUWO can't raise it's budget by other means than selling property)
lowBudget :-
	getIndicator(ID,'Budget DUWO', Weight, CurrentValue, TargetValue, ZoneLink)
	, CurrentValue < 1.2*TargetValue.

noBudget :-
	getIndicator(ID,'Budget DUWO', Weight, CurrentValue, TargetValue, ZoneLink)
	, CurrentValue < TargetValue.

goalReachBudgetTarget :-
	not(lowBudget)
	, not(noBudget).

% Get a multipolygon as a sqaure with X, Y, Width and Height as coordinates.
getPolygon(X, Y, Width, Height, Square) :-
	XAndWidth is X+Width
	, YAndHeight is Y+Height
	, format(atom(A), "MULTIPOLYGON(((~w ~w, ~w ~w, ~w ~w, ~w ~w, ~w ~w)))"
	, [X,Y,XAndWidth,Y, XAndWidth, YAndHeight,X, YAndHeight, X, Y])
	, Square = multipolygon(A).
	
	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PREDICATES USED FOR DEMOLISING %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


 % Get a buildings id and area by category.
getAreaOwnBuilding(BuildingID, Category, Poly, Area, TS):- 
	self(OwnID)
	, buildings(AllBuildings)
	, member(building(BuildingID,_Name,OwnID,_Year,Categories,_,_,Poly,Area, TS),AllBuildings)
	, member(Category, Categories).

% Create a list with the id and area of all buildings
% In the form of:
% [[BuildingIdD,Area1],[BuildingID2,Area2], ...]
allBuildings(Category, AllBuildings):-
	findall([BuildingID,Area], getAreaOwnBuilding(BuildingID, Category, _, Area, _),AllBuildings). 
 
% Find the maximum area.
maxArea([[BuildingID,Area]],BuildingID, Area).
maxArea([[_BuildingID,Area]|RestList], BuildingIDFromMax, Max):-
	maxArea(RestList, BuildingIDFromMax, Max)
	, Max >= Area,!.
maxArea([[BuildingID,Area]|RestList],BuildingID,Area):-
	maxArea(RestList, _, Max)
	, Area > Max,!.

getFloors(Area, [9,10,11]):-
	Area < 200.
getFloors(Area, [7,8,9]):-
	Area >= 200, Area < 400.
getFloors(Area, [5,6,7]):-
	Area >= 400, Area < 600.
getFloors(Area, [3,4,5,6,7]):-
	Area >= 600, Area < 800.
getFloors(Area, [3,4,5]):-
	Area >=	800, Area < 1000.
getFloors(Area, [2,3,4]):-
	Area >= 1000.
	
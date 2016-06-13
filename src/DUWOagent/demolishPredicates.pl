[predicates].
 
:- dynamic getAreaOwnBuilding/2.
:- dynamic maxArea/3.
:- dynamic buildingAreas/2.
:- dynamic demolished/1.
:- dynamic self/1.
:- dynamic buildings/1.
 
getAreaOwnBuilding(BuildingID, Category, Area):- 
	self(OwnID),
	buildings(AllBuildings),
	member(building(BuildingID,_Name,OwnID,_Year,Cat,_,_,_Poly,Area),AllBuildings),
	member(Category, Cat).

allBuildings(Category, List):-
	findall([BuildingID,Area],getAreaOwnBuilding(BuildingID, Category, Area),List). 
 
maxArea([[BuildingID,Area]],BuildingID, Area).
maxArea([[_BuildingID,Area]|RestList], BuildingIDFromMax, Max):-
	maxArea(RestList, BuildingIDFromMax, Max),
	Max >= Area,!.
maxArea([[BuildingID,Area]|RestList],BuildingID,Area):-
	maxArea(RestList, _, Max),
	Area > Max,!. 	
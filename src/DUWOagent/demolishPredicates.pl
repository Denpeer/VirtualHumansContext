:- dynamic getAreaOwnBuilding/2.
:- dynamic maxArea/3.
:- dynamic buildingAreas/2.
:- dynamic demolished/1.
:- dynamic self/1.
:- dynamic buildings/1.
 
 % Get a buildings id and area by catergory.
getAreaOwnBuilding(BuildingID, Category, Area):- 
	self(OwnID),
	buildings(AllBuildings),
	member(building(BuildingID,_Name,OwnID,_Year,Cat,_,_,_Poly,Area),AllBuildings),
	member(Category, Cat).

% Create a list with the id and area of all buildings
% In the form of:
% [[BuildingIdD,Area1],[BuildingID2,Area2], ...]
allBuildings(Category, AllBuildings):-
	findall([BuildingID,Area],getAreaOwnBuilding(BuildingID, Category, Area),AllBuildings). 
 
% Find the maximum area.
maxArea([[BuildingID,Area]],BuildingID, Area).
maxArea([[_BuildingID,Area]|RestList], BuildingIDFromMax, Max):-
	maxArea(RestList, BuildingIDFromMax, Max),
	Max >= Area,!.
maxArea([[BuildingID,Area]|RestList],BuildingID,Area):-
	maxArea(RestList, _, Max),
	Area > Max,!. 	
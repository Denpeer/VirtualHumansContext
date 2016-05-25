
:- dynamic stakeholders/1.
:- dynamic settings/1.
:- dynamic functions/1.
:- dynamic buildings/1.
:- dynamic indicator/3.
:- dynamic indicatorWeight/3.
:- dynamic planned/3.

%Goals
% we have a building if the building list has at least 1 element.
havebuilding :- buildings([X|Y]).
% Build houses when certain predicates are true
goalBuildStudentHousing :- needStudentHousing.

%Predicates
% Get indicator
getIndicator(Name, Weight, CurrentValue, TargetValue) :- 
	indicatorWeight(ID,Name,Weight), indicator(ID, CurrentValue, TargetValue).
	
% Only build houses when our current value < target value.
needStudentHousing:- 
	getIndicator('Bouw DUWO', Weight, CurrentValue, TargetValue),
	CurrentValue < TargetValue.
	

	
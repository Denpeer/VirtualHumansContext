
:- dynamic stakeholders/1.
:- dynamic settings/1.
:- dynamic functions/1.
:- dynamic buildings/1.
:- dynamic indicator/3.
:- dynamic indicatorWeight/3.
:- dynamic planned/3.



% Get indicator
%indicator names: "Astand TUDelft", "Bouw DUWO", "Budget DUWO", "Ruimtelijke kwaliteit", "Variatie Woonruimte"
getIndicator(Name, Weight, CurrentValue, TargetValue) :- 
	indicatorWeight(ID,Name,Weight), indicator(ID, CurrentValue, TargetValue).
	
% Only build houses when our current value < target value.
needStudentHousing:- 
	getIndicator('Bouw DUWO', Weight, CurrentValue, TargetValue),
	CurrentValue < TargetValue.
	
goalBuildStudentHousing.
	
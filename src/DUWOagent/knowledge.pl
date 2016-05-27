:- dynamic stakeholders/1.
:- dynamic settings/1.
:- dynamic functions/1.
:- dynamic buildings/1.
:- dynamic indicator/3.
:- dynamic indicatorWeight/3.
:- dynamic planned/3.



% Get indicator
%indicator names: "Astand TUDelft", "Bouw DUWO", "Budget DUWO", "Ruimtelijke kwaliteit", "Variatie Woonruimte"
getIndicator(Name, Weight, CurrentValue, TargetValue, ID) :- 
	indicatorWeight(ID,Name,Weight), indicator(ID, CurrentValue, TargetValue).
	
% Only build houses when our current value < target value.
needStudentHousing:- 
	getIndicator('Bouw DUWO', Weight, CurrentValue, TargetValue, ID),
	CurrentValue < TargetValue.
	
goalBuildStudentHousing.

% Budget predicates that the bot can use to either stop building or build more carefully (raising a value needed per building for example)
% These predicates expect DUWO to keep its target budget as a minimum (since DUWO can't raise it's budget by other means than selling property)
lowBudget:-
	getIndicator('Budget DUWO', Weight, CurrentValue, TargetValue, ID),
	CurrentValue < 1.2*TargetValue.
	
noBudget:-
	getIndicator('Budget DUWO', Weight, CurrentValue, TargetValue, ID),
	CurrentValue < TargetValue.
	
goalReachBudgetTarget.	
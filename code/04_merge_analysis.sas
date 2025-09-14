/*MERGING DATSETS*/

data merge_visits;
	merge patients_final(in=a) encounters_final(in=b);
	by PatientsID;
	if a and b;
run;

proc print data = merge_visits;
run;

/*CALCULATING AGE*/

data merge_visits;
set merge_visits;
	Age = intck('year',DateOfBirth,VisitDate);
run;
proc print data = merge_visits;
run;

/*SUMMARIZATION AND ANALYSIS*/
/*1. FREQUENCY TABLE*/

proc freq data = merge_visits;
	tables Department*Sex / nocum nopercent;
run;

/*2. MEAN CHARGES BY DEPARTMENT*/

proc means data = merge_visits mean std min max maxdec=2;
	class Department;
	var Charges;
run;

/*creating variable PaidFlag*/

data merge_visits;
set merge_visits;
	if status in ("Yes", "Completed") then PaidFlag = 1;
	else if status in ("No", "Cancelled") then PaidFlag = 0;
	else PaidFlag = .;
run;

proc print data = merge_visits;
run;

proc freq data = merge_visits;
	tables PaidFlag / nocum nopercent;
run;

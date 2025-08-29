/*STEP.1 IMPORTING RAW DATA*/

proc import datafile="C:\Users\Fazil Ansari\Documents\patient_raw.csv"
			dbms=csv
			out=patients_raw replace;
			getnames=yes;
run;

proc contents data=patients_raw; run;
proc print data=patients_raw; run;

proc import datafile="C:\Users\Fazil Ansari\Documents\encounters_raw.csv"
            dbms=csv out=encounters_raw replace;
			getnames=yes;
run;

proc contents data=encounters_raw; run;
proc print data=encounters_raw; run;

/*STEP.2 CLEANING RAW DATA*/

/*PATIENTS
1. patient_id*/
data patient_clean_id;
    set patients_raw;

    cleaned_id = strip(upcase(patient_id));
    cleaned_id = compress(cleaned_id, , 'kad');

    if substr(cleaned_id,1,1) ne "P" then
        cleaned_id = cats("P", put(input(cleaned_id, 8.), z3.));

    else do;
        num = input(substr(cleaned_id,2), 8.);
        cleaned_id = cats("P", put(num, z3.));
    end;

    drop num;
run;

proc print data=patient_clean_id;
    var patient_id cleaned_id;
run;

/*2.dob*/

data patient_clean_dob;
	set patient_clean_id;
	clean_dob = input(strip(upcase(dob)), anydtdte10.);

	if missing(clean_dob) then clean_dob = input(strip(upcase(dob)), date9.);
	if missing(clean_dob) then clean_dob = input(strip(upcase(dob)), ddmmyy10.);
	format clean_dob date9.;
	if dob = "31/02/1987" then clean_dob = '27FEB1987'd;

	run;
	proc print data=patient_clean_dob;
	var patient_id cleaned_id dob clean_dob;
run;

/*	3.sex*/

data patient_clean_sex;
	set patient_clean_dob;
	clean_sex = upcase(sex);
	if clean_sex in ("M", "MALE") then clean_sex = "M";
	else if clean_sex in ("F", "FEMALE") then clean_sex = "F";
	else clean_sex = "U";

run;

	proc print data = patient_clean_sex;
	var patient_id cleaned_id dob clean_dob sex clean_sex;
run;

/*4.PHONE*/

data patient_clean_phone;
	set patient_clean_sex;
	clean_phone = compress (phone, , 'kd');
	if length(clean_phone)>= 10 then
	clean_phone = substr(clean_phone, length(clean_phone)-9, 10);
	else clean_phone = " ";

run;
proc print data = patient_clean_phone;
var patient_id cleaned_id dob clean_dob sex clean_sex phone clean_phone;
run;

PROC PRINT DATA = PATIENTS_RAW;
RUN;

/*5.CITY*/

data patient_city_clean;
	set patient_clean_phone;
	city_clean = propcase(city);
	if city_clean in ("Mum")then city_clean = "Mumbai";
run;

proc print data = patient_city_clean;
	var patient_id cleaned_id dob clean_dob sex clean_sex phone clean_phone city city_clean;
run;

/*SAVING CLEANED FILE	*/

data patients_clean;
	set patient_city_clean;
	keep cleaned_id clean_dob clean_sex clean_phone city_clean;
run;
proc print data = patients_clean;
run;

/*RENAMING VARIABLE NAMES FOR BETTER READABLITY*/

data patients_final;
	set patients_clean;
	rename
	cleaned_id = PatientsID
	clean_dob = DateOfBirth
	clean_sex = Sex
	clean_phone = Phone
	city_clean = City
	;
run;
proc print data = patients_final;
run;

/*EXPOTING THE CLEANED PATIENTS DATA*/

proc export outfile="D:\Learners\PROJECT 1\patients_final.csv"
	dbms=csv
	replace;
run;

/*ENCOUNTERS*/
/*1.patient_id*/

data id_encounters_clean;
set encounters_raw;
	cleaned_id = upcase(strip(patient_id));
	cleaned_id = compress(cleaned_id, , 'kd');
	if cleaned_id ne " " then cleaned_id = cats("P", put(input(cleaned_id, 8.),z3.));
run;

proc print data = id_encounters_clean;
var visit_date patient_id cleaned_id;
run;

/*2.date*/
data vd_encounters_clean;
set id_encounters_clean;
	vd_clean = input(visit_date, anydtdte10.);
	format vd_clean date9.;
run;

proc print data = vd_encounters_clean;
	var visit_date vd_clean;
run;

proc contents data = vd_encounters_clean;
run;

/*3.departement*/

data dp_encounters_clean;
set vd_encounters_clean;
	length dp_clean $20.;
	select (upcase(strip(department)));
	when ("ORTHO", "ORTHOPEDICS") dp_clean = "Orthopedics";
	when ("ENT") dp_clean = "ENT";
	OTHERWISE dp_clean = propcase(department);
	end;
run;

proc print data = dp_encounters_clean;
	var department dp_clean;
run;

/*4.charges*/

data ch_encounters_clean;
set dp_encounters_clean;
    charges_clean = compress(charges, '.', 'kd');
    charges_num = input(charges_clean, best12.);
    format charges_num 8.2;
run;
proc print data = ch_encounters_clean noobs;
run;

/*5.status*/

data status_encounters_clean;
set ch_encounters_clean;
length clean_status $15.;
	select (upcase(strip(status)));
	when ("Y", "YES") clean_status = "Yes";
	otherwise clean_status = propcase(status);
	end;
run;

proc print data = status_encounters_clean;
run;

data encounters_final;
set status_encounters_clean;
	keep cleaned_id vd_clean dp_clean charges_num clean_status;
	rename
	cleaned_id = PatientsID
	vd_clean = VisitDate
	dp_clean = Department
	charges_num = Charges
	clean_status = Status
	;
run;
proc print data = encounters_final;
run;

proc export outfile="D:\Learners\PROJECT 1\encounters_final.csv"
	dbms=csv
	replace;
run;

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

/*EXPORTING*/
/*PATIENTS*/
proc export outfile="D:\Learners\PROJECT 1\patients_final.csv"
	dbms=csv
	replace;
run;

/*ENCOUNTERS*/

proc export outfile="D:\Learners\PROJECT 1\encounters_final.csv"
	dbms=csv
	replace;
run;

/*MERGED*/

proc export outfile="D:\Learners\Sas_Data_Cleaning_Project\merge_visits.csv"
	dbms=csv replace;
run;















































































	



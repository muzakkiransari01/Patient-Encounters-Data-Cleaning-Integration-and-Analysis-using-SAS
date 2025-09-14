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

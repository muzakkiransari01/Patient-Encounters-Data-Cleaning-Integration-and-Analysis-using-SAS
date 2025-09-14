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

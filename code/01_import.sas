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

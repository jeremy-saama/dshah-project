/**-------------------------------------------------------------------------------------------**
** PROGRAM:    LVS81.SAS 
** CREATED:    December 2019
** PURPOSE:    Create Vital Sign Listing 8.1
** PROGRAMMER: Deepti Shah
** INPUT:      adsllib.advs
** OUTPUT:     Listing 8.1 (VS_L81.rtf)
** PROTOCOL:   PROD-124
**-------------------------------------------------------------------------------------------**/
/* ----------- SAS University Edition 9.4 ----------- */


/*	Fetch data from ADVS dataset	*/

 
data lvs;
	set adsllib.advs;
run;


data sysbp(keep=usubjid trt01p trt01pn avisit avisitn aval chg rename=(aval=sysval chg=syschg));
	set lvs(where=(vstestcd="SYSBP"));
run;

data diabp(keep=usubjid trt01p trt01pn avisit avisitn aval chg rename=(aval=diaval chg=diachg));
	set lvs(where=(vstestcd="DIABP"));
run;

data HRate(keep=usubjid trt01p trt01pn avisit avisitn aval chg rename=(aval=hrval chg=hrchg));
	set lvs(where=(vstestcd="HR"));
run;

data OSat(keep=usubjid trt01p trt01pn avisit avisitn aval chg rename=(aval=oxval chg=oxchg));
	set lvs(where=(vstestcd="O2SAT"));
run;

/**----------- merge for final listing ----------------**/;

proc sort data=sysbp;
	by usubjid avisitn avisit trt01pn trt01p;
run;

proc sort data=diabp;
	by usubjid avisitn avisit trt01pn trt01p;
run;

proc sort data=HRate;
	by usubjid avisitn avisit trt01pn trt01p;
run;

proc sort data=Osat;
	by usubjid avisitn avisit trt01pn trt01p;
run;

data lvs_f;
	merge 	sysbp(in=insys) 
			diabp(in=india)
			hrate
			osat
    ;

	attrib tpt length = $80;

	by usubjid avisitn avisit trt01pn trt01p;

	if AVISIT = "STUDY DAY 1" then tpt = "Screening";
	else if AVISIT = "STUDY DAY 2" then tpt = "Study Day 2";
	else if AVISIT = "STUDY DAY 1 -5 min" then tpt = "-5 min";
	else if AVISIT = "STUDY DAY 1 0 min" then tpt = "0 min";
	else if AVISIT = "STUDY DAY 1 5 min" then tpt = "Baseline^{super c}";
	else if AVISIT = "STUDY DAY 1 1 HOUR AFTER INFUSION PERIOD #2" then tpt = "+105 min";
	else tpt = "+"||substr(avisit,13);
run;

proc sort data=lvs_f out=lvs_s;
		by usubjid avisitn avisit trt01pn trt01p;
run;

data lvs_fin;
	set lvs_s;

	format syschgc diachgc oxchgc hrchgc $10.;
	syschgc = strip(put(syschg,best12.));
	diachgc = strip(put(diachg,best12.));
	hrchgc  = strip(put(hrchg,best12.));
	oxchgc  = strip(put(oxchg,best12.));

	
	if tpt in ("Screening" "-5 min" "0 min" "Baseline^{super c}") then do;
		syschgc = "n/a";
		diachgc = "n/a";
		hrchgc  = "n/a";
		oxchgc  = "n/a";

	end;

run;


**-------------------------------------------------------------------------------**;
**              Create Report Listing 8.1 for Vital Signs                            **;
**-------------------------------------------------------------------------------**;

/**----- RTF SETUP -----**/;
options nodate nonumber orientation=landscape;
ods listing close ;
ods escapechar='^' ;
ods rtf style=TStyleRTF file="&outpath.VS_L81.rtf" ;

/**----- TITLES/FOOTNOTES -----**/;
title1 j=left "&ptitle1" j=right 'Page ^{pageof}' ;
title2 j=left "&ptitle2" j=right "&sysdate9"  ;
title3 j=center "Listing 8.1" ;
title4 j=center "Vital Signs (Blood Pressure and Heart Rate) and Oxygen Saturation" ;

footnote1 h=10pt j=left "^R'\brdrt\brdrs\super a\nosupersub Cohort 1 Sequence: Bag in Infusion 1 / Bottle in Infusion 2, Cohort 2 Sequence: Bottle in Infusion 1 / Bag in Infusion 2.'" ;
footnote2 h=10pt j=left "^R'\super b\nosupersub Change from baseline.'" ;
footnote3 h=10pt j=left "^R'\super c\nosupersub Baseline is the last value prior to the start of PROD.'" ;
footnote4 h=10pt j=left "^R'\nosupersub  I or D = Increase or decrease from baseline of clinical importance based on the criteria specified below: \line 
\tab Systolic blood pressure above/below normal range(90 to 200mm Hg) and increase/decrease >=20 mm Hg \line 
\tab Diastolic blood pressure above/below normal range(60 to 120mm Hg) and increase/decrease >=20 mm Hg \line
\tab Heart Rate above/below normal range (45 to 120bpm) and increase/decrease >=10 bpm \line
\tab Oxygen Saturation <90% and decrease >=5%'" ;

footnote5 h=10pt j=left "^R'\nosupersub n/a = not applicable'";
footnote6 h=10pt j=left "^R'\nosupersub - = missing'" ;
footnote7 j=left "&llastfoot adsllib.advs" j=right "&rlastfoot lvs81.sas";

/**----- REPORT DEFINITION -----**/;

proc report data=lvs_fin missing center split='|' style=[outputwidth=9.0in];

   column usubjid trt01p tpt ("^S={borderbottomcolor=black borderbottomwidth=2} Systolic Blood|Pressure (mmHg)"(sysval syschgc)) blank
						     ("^S={borderbottomcolor=black borderbottomwidth=2} Diastolic Blood|Pressure (mmHg)"(diaval diachgc)) blank
							 ("^S={borderbottomcolor=black borderbottomwidth=2} Heart Rate|(beats/min)"(hrval hrchgc)) blank
							 ("^S={borderbottomcolor=black borderbottomwidth=2} Oxygen Saturation (%)" (oxval oxchgc));
   
   define blank /" " style(column)=[cellwidth=0.1in] ;
   define usubjid / order "Subject" center ;
   define trt01p / order "Cohort^{super a}" center ;
   define tpt / "Scheduled Timepoint";
   define sysval /display "Value" center;
   define syschgc /display "Change^{super b}" center;
   define diaval /display "Value" center;
   define diachgc /display "Change^{super b}" center;
   define hrval /display "Value" center;
   define hrchgc /display "Change^{super b}" center;
   define oxval /display "Value" center;
   define oxchgc /display "Change^{super b}" center;
 
   compute after usubjid;
   	line " ";
   endcomp;
run;

/**----- CLOSE RTF AND RESET TITLES/FOOTNOTES -----**/;
ods rtf close ;
ods listing ;

options date number ;
title ;
footnote ;

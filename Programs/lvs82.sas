/**-------------------------------------------------------------------------------------------**
** PROGRAM:    LVS82.SAS 
** CREATED:    December 2019
** PURPOSE:    Create Vital Sign Listing 8.2
** PROGRAMMER: Deepti Shah
** INPUT:      adsllib.advs
** OUTPUT:     Listing 8.1 (VS_L82.rtf)
** PROTOCOL:   PROD-124
**-------------------------------------------------------------------------------------------**/
/* ----------- SAS University Edition 9.4 ----------- */


/*	Fetch data from ADVS dataset	*/



data lvs82;
	set adsllib.advs;
run;

data resp(keep=usubjid trt01p trt01pn avisit avisitn aval chg rename=(aval=respval chg=respchg));
	set lvs82(where=(vstestcd="RESP" and ( vstpt="STUDY DAY 1" or vstpt = "STUDY DAY 2") ));
run;

data temp(keep=usubjid trt01p trt01pn avisit avisitn aval chg rename=(aval=tempval chg=tempchg));
	set lvs82(where=(vstestcd="TEMP" and ( vstpt="STUDY DAY 1" or vstpt = "STUDY DAY 2")));
run;

/**----------- merge for final listing ----------------**/;

proc sort data=resp;
	by usubjid avisitn avisit trt01pn trt01p;
run;

proc sort data=temp;
	by usubjid avisitn avisit trt01pn trt01p;
run;

data lvs82_f;
	merge 	resp 
			temp
    ;

	attrib tpt length = $80;

	by usubjid avisitn avisit trt01pn trt01p;

	if AVISIT = "STUDY DAY 1" then tpt = "Baseline";
	else if AVISIT = "STUDY DAY 2" then tpt = "Study Day 2";
run;

proc sort data=lvs82_f out=lvs82_s;
		by usubjid avisitn avisit trt01pn trt01p;
run;


**-------------------------------------------------------------------------------**;
**              Create Report Listing 8.2 for Vital Signs                            **;
**-------------------------------------------------------------------------------**;

/**----- RTF SETUP -----**/;
options nodate nonumber orientation=landscape;
ods listing close ;
ods escapechar='^' ;
ods rtf style=TStyleRTF file="&outpath.VS_L82.rtf" ;

/**----- TITLES/FOOTNOTES -----**/;
title1 j=left "&ptitle1" j=right 'Page ^{pageof}' ;
title2 j=left "&ptitle2" j=right "&sysdate9"  ;
title3 j=center "Listing 8.2" ;
title4 j=center "Vital Signs (Respiration Rate and Temperature)" ;

footnote1 h=10pt j=left "^R'\brdrt\brdrs\super a\nosupersub  Cohort 1 Sequence: Bag in Infusion 1 / Bottle in Infusion 2, Cohort 2 Sequence: Bottle in Infusion 1 / Bag in Infusion 2.'" ;
footnote2 h=10pt j=left "^R'\super b\nosupersub  Change from baseline.'" ;

footnote3 j=left "&llastfoot adsllib.advs" j=right "&rlastfoot lvs82.sas";

/**----- REPORT DEFINITION -----**/;
proc report data=lvs82_s missing center split='|' style(report)={cellpadding=.1in} style=[outputwidth=9.0in];

   column usubjid trt01p tpt ("^S={borderbottomcolor=black borderbottomwidth=2} Respiration Rate| (breaths/min)"(respval respchg)) 
						     ("^S={borderbottomcolor=black borderbottomwidth=2} Temperature | (C)"(tempval tempchg)) 
   ;
   
   define usubjid / order "Subject" center ;
   define trt01p / order "Cohort^{super a}" CENTER ;
   define tpt / "Scheduled Timepoint";
   define respval /display "Value" center;
   define respchg /display "Change^{super b}" center;
   define tempval /display "Value" center;
   define tempchg /display "Change^{super b}" center;
 
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

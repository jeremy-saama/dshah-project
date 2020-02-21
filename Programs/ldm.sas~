
/**-------------------------------------------------------------------------------------------**
** PROGRAM:    ldm.sas 
** CREATED:    November 2019
** PURPOSE:    CREATE DM Listing
** PROGRAMMER: Deepti Shah
** INPUT:      adsllib.adsl
** OUTPUT:     Listing 2 (DM_L2.rtf)
** PROTOCOL:   PROD-124
**-------------------------------------------------------------------------------------------*/
/* ----------- SAS University Edition 9.4 ----------- */


data dm_d1 (drop=studyid subjid siteid race ageu arm brthdtc rficdt);
   set adsllib.adsl (where=(saffl = "Y"));

	format rficdtc brthdt date9.;
	
	
	cohort = trt01pn;

	rficdtc_temp = put(rficdt,YYMMDD10.);
	rficdtc = input (rficdtc_temp, e8601da10.);
	
	
	brthdt = input(brthdtc,e8601da10.);
	if raceoth ne "" then frace = propcase(strip(race)) || ", " || propcase(strip(raceoth)) ;
	else frace = propcase(strip(race));

run;

options nodate nonumber orientation=landscape;
ods listing close ;
ods escapechar='^' ;
ods rtf style=TStyleRTF file="&outpath.DM_L2.rtf" ;

/**----- TITLES/FOOTNOTES -----**/;
title1 j=left "&ptitle1" j=right 'Page ^{pageof}' ;
title2 j=left "&ptitle2" j=right "&sysdate9"  ;
title3 j=center "Listing 2" ;
title4 j=center "Demographics and Baseline Characteristics" ;
footnote1 h=10pt j=left "^R'\brdrt\brdrs\super a\nosupersub Cohort 1 Sequence: Bag in Infusion 1 / Bottle in Infusion 2, Cohort 2 Sequence: Bottle in Infusion 1 / Bag in Infusion 2.'";
footnote2 j=left "&llastfoot adsllib.adsl" j=right "&rlastfoot ldm.sas";



/**----- REPORT DEFINITION -----**/;
proc report data=dm_d1 missing nowindows center split='|' style(report)={cellpadding=.1in} style=[outputwidth=9.0in];
   column usubjid cohort rficdtc brthdt age sex frace weight height;

   define usubjid /display "Subject" CENTER;
   define cohort /display "Cohort^{super a}" CENTER;
   define rficdtc /display "Informed|Consent|Date" CENTER;
   define brthdt /display "Date of|Birth" CENTER;
   define age /display "Age (yrs)" CENTER;
   define sex /display "Sex" CENTER;
   define frace /display "Race" CENTER;
   define weight /display "Weight (kg)" CENTER;
   define height /display "Height|(inch)" CENTER;

run ;

/**----- CLOSE RTF AND RESET TITLES/FOOTNOTES -----**/;
ods rtf close ;
ods listing ;

options date number ;
title ;
footnote ;

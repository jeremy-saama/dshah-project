
/**-------------------------------------------------------------------------------------------**
** PROGRAM:    LAE.SAS 
** CREATED:    December 2019
** PURPOSE:    Create Listing 6 - Adverse Events
** PROGRAMMER: Deepti Shah
** INPUT:      adsllib.adae
** OUTPUT:     Listing 6 - Adverse Events
** PROTOCOL:   PROD-124
**-------------------------------------------------------------------------------------------**/
/* ----------- SAS University Edition 9.4 ----------- */


/*	Fetch data from AE dataset	*/


data lst_ae (keep=usubjid trt01pn age sex race col2 aebodsys aedecod aeterm col3 asttm arelsettm adurn aesev aerel aeacn );
   	set adsllib.adae;

	attrib col2 length=$200
		   col3 length=$300
    ;

	col2 = catx('^n',put(trt01pn, 1.),put(age, 4.),sex,race);
	col3 = catx('^n',aebodsys,aedecod,aeterm);

run;


**-------------------------------------------------------------------------------**;
**              Create List Report Listing 2                            		 **;
**-------------------------------------------------------------------------------**;

/**----- RTF SETUP -----**/;
options nodate nonumber orientation=landscape ;
ods listing close ;
ods escapechar='^' ;
ods rtf style=TStyleRTF file="&outpath.AE_L6.rtf" ;

/**----- TITLES/FOOTNOTES -----**/;

title1 j=left "&ptitle1" j=right 'Page ^{pageof}' ;
title2 j=left "&ptitle2" j=right "&sysdate9"  ;
title3 j=center "Listing 6" ;
title4 j=center "Adverse Events" ;
footnote1 h=10pt j=left
   "^R'\brdrt\brdrs\super a\nosupersub Cohort 1 Sequence: Bag in Infusion 1 / Bottle in Infusion 2, Cohort 2 Sequence: Bottle in Infusion 1 / Bag in Infusion 2.'";
footnote2 h=10pt j=left "^R'\super b \nosupersub Relative to the start of PROD administration. Negative times indicate occurrence prior to the start of PROD'";
footnote3 h=10pt j=left "^R'\super c \nosupersub Duration (D:H:M): D=Days; H=Hours; M=Minutes.'";
footnote4;
footnote5 j=left "&llastfoot adsllib.adae" j=right "&rlastfoot lae.sas";

/**----- REPORT DEFINITION -----**/;
proc report data=lst_ae missing nowindows center split='|' style(report)={cellpadding=.1in} style=[outputwidth=9.0in] ;
   column usubjid trt01pn age sex race Col2 aebodsys aedecod aeterm col3 asttm arelsettm adurn aesev aerel aeacn;

   define usubjid /display "Subject" CENTER;
   define trt01pn /noprint;
   define age /noprint;
   define sex /noprint;
   define race /noprint;
   define Col2 /display "Cohort^{super a} |Age |Sex |Race" left;
   define aebodsys /noprint;
   define aedecod /noprint;
   define aeterm /noprint;
   define Col3 /display "MedDRA Body System |MedDRA Preferred Term |CRF Verbatim Term" left;
   define asttm /display "Onset|Time|(HH:MM)" center;
   define arelsettm /display "Onset|Time ^{super b}|Relative|to PROD|(D:H:M)";
   define adurn /display "Duration|(D:H:M)^{super c}" center;
   define aesev /display "Severity" center;
   define aerel /display "Relationship to PROD" center;
   define aeacn /display "Action Taken" center;
run ;

/**----- CLOSE RTF AND RESET TITLES/FOOTNOTES -----**/;
ods rtf close ;
ods listing ;

options date number ;
title ;
footnote ;


/**-------------------------------------------------------------------------------------------**
** PROGRAM:    LPA.SAS 
** CREATED:    December 2019
** PURPOSE:    Create Listing 5 - Prod Administration using Exposure Dataset
** PROGRAMMER: Deepti Shah
** INPUT:      adsllib.adex
** OUTPUT:     Listing 5 - Prod Administration (L5)
** PROTOCOL:   PROD-124
**-------------------------------------------------------------------------------------------**/
/* ----------- SAS University Edition 9.4 ----------- */

/*	Fetch data from EX dataset	*/

proc delete data=work._all_;
run;

data lst_ex;

   set adsllib.adex(where=(paramn=1));
   format adate date9.;

	**----------- Derive columns needed for Listing display	----------------**;

	col1 = catx("/",usubjid,trt01pn);
	wt = put(weight,6.1);

	infper = substr(epoch,18,1);
	col3 = catx("/",infper,excat);
	
	amt=put(aval,4.1);

	adt_n_c = put(adt,YYMMDD10.);
	adate = input (adt_n_c, e8601da10.);

	mgkg = put(amt/wt, 7.1);

run;

proc sort data=lst_ex;
	by usubjid;
run;

/*		Create Listing 5 - Prod Administration		*/

/**----- RTF SETUP -----**/;
options nodate nonumber orientation=landscape missing=' ';
ods listing close ;
ods escapechar='^' ;
ods rtf style=TStyleRTF file="&outpath.EX_L5.rtf" ;

/**----- TITLES/FOOTNOTES -----**/;
title1 j=left "&ptitle1" j=right 'Page ^{pageof}' ;
title2 j=left "&ptitle2" j=right "&sysdate9"  ;
title3 j=center "Listing 5" ;
title4 j=center "PROD Administration" ;
footnote1 h=10pt j=left   "^{super a}Cohort 1 Sequence: Bag in Infusion 1 / Bottle in Infusion 2, Cohort 2 Sequence: Bottle in Infusion 1 / Bag in Infusion 2.";
footnote2 j=left "&llastfoot adsllib.adex" j=right "&llastfoot lpa.sas";



/**----- REPORT DEFINITION -----**/;
proc report data=lst_ex missing nowindows center split='|' style(report)={cellpadding=.1in} style=[outputwidth=9.0in];

   column col1 wt col3 ("^S={borderbottomcolor=black borderbottomwidth=2} Amount Administered"(amt mgkg)) adate asttm aentm;
   
   define col1 /display order order=data "Subject/|Cohort^{super a}" center ;
   define wt /display order order=data "Weight|(kg)" CENTER ;
   define col3 /display "Infusion Period/|Consfiguration" center;
   define amt /display "(mg)" center;
   define mgkg /display "(mg/kg)" center;
   define adate /display "Date" center;
   define asttm /display "Start Time" center;
   define aentm /display "Stop Time" center;

   compute after col1;
   	line " ";
   endcomp;

run;

**----- CLOSE RTF AND RESET TITLES/FOOTNOTES -----**;
ods rtf close ;
ods listing ;

options date number ;
title ;
footnote ;
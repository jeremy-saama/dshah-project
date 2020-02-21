
/**-------------------------------------------------------------------------------------------**
** PROGRAM:    TAE.SAS
** CREATED:    December 2019
** PURPOSE:    Create AE Table 7.2.1
** PROGRAMMER: Deepti Shah
** INPUT:	   adsllib.adae
** OUTPUT:	   Table 7.2.1 (AE_T721.rtf)
** PROTOCOL:   PROD-124
**-------------------------------------------------------------------------------------------*/
/* ----------- SAS University Edition 9.4 ----------- */


**-------------------------------------------------------------------------------**;
**             BRING ADSL adae dataset                        **;
**-------------------------------------------------------------------------------**;

proc delete data=work._all_;
run;

data ae;
	set adsllib.adae;
run;

/*Include AE reported after start of PROD administration */

data sae(keep=usubjid aeseq trt01p trt01pn trtsdtm astdtm aeterm aebodsys aedecod );
	set ae(where=(saffl="Y" and astdtm>trtsdtm));
run;

proc sort data=sae nodupkey out=sae1;
	by usubjid;
run;

**-------------------------------------------------------------------------------**;
**          Derive Big N for Safety Population from adsllib.adsl                      **;
**-------------------------------------------------------------------------------**;

data dm;
	set adsllib.adsl;
run;

data tdm_1;
	set dm(where=(saffl="Y"));
	output;
	trt01pn=3;
	trt01p="Total";
	output;
run;
proc sort data=tdm_1 out=tdm_s;
	by trt01pn trt01p;
run;

proc freq data=tdm_s noprint;
	tables trt01pn/list nocum nopercent out=TotPats;
run;

/**----------- Assign Totals into Macro Varibles	----------------**/;

data _null_;
	set TotPats;
	call symput("cohortTot"||compress(put(trt01pn,1.)),put(count,2.));
run;


**-------------------------------------------------------------------------------**;
**   Derive Statistics for Cohort 1                                  **;
**-------------------------------------------------------------------------------**;

/**----------- Cohort 1 Stat ----------------**/;
data cohort1;
	set sae1(where=(trt01pn=1));
run;

proc sort data=cohort1 out=cohort1_s;
	by aebodsys aedecod;
run;
proc means data=cohort1_s n noprint;
	var trt01pn;
	by aebodsys aedecod;
	output out=cohort1_stat(drop=_type_ _freq_) n= /autoname;
run;

/**----------- rename for table output and derive display values ----------------**/;
data cohort1_stat1;
	set cohort1_stat(rename=(trt01pn_n=Cohort1));
	
	cohort1pct = Cohort1/&cohortTot1*100;
	n1pct = strip(put(Cohort1,best12.)) || " ("|| strip(put(cohort1pct,best4.1)) || ")";
	
run;


/**----------- Cohort 2 Stat ----------------**/;
data cohort2;
	set sae1(where=(trt01pn=2));
run;

proc sort data=cohort2 out=cohort2_s;
	by aebodsys aedecod;
run;
proc means data=cohort2_s n noprint;
	var trt01pn;
	by aebodsys aedecod;
	output out=cohort2_stat(drop=_type_ _freq_) n= /autoname;
run;

/**----------- rename for table output and derive display values ----------------**/;
data cohort2_stat1;
	set cohort2_stat(rename=(trt01pn_n=Cohort2));
	
	cohort2pct = Cohort2/&cohortTot2*100;
	n2pct = strip(put(Cohort2,best12.)) || " ("|| strip(put(cohort2pct,best4.1)) || ")";
run;

/**----------- All Subjects Stat ----------------**/;

proc sort data=sae1 out=sae1_s;
	by aebodsys aedecod;
run;

proc means data=sae1_s n noprint;
	var trt01pn;
	by aebodsys aedecod;
	output out=ch_stat(drop=_type_ _freq_) n= /autoname;
run;

/**----------- rename for table output and derive display values ----------------**/;
data ch_stat1;
	set ch_stat(rename=(trt01pn_n=TotSub));
	
	chpct = TotSub/&cohortTot2*100;
	npct = strip(put(TotSub,best12.)) || " ("|| strip(put(chpct,best4.1)) || ")";
run;

/**----------- Subjects with AE ----------------**/;

data sae1_s1;
	set sae1_s;
	output;
	trt01p = "Cohort 3";
	trt01pn = 3;
	output;
run;

proc freq data=sae1_s1 noprint;
	tables trt01pn/list nocum nopercent out= sub_ae;

run;

proc transpose data=sub_ae 
			   out=sub_aet(drop=_name_ _label_) 
			   prefix=cohort;
	var count;
	id trt01pn;
run;

data sub_ae1(drop=cohort1 cohort2 cohort3);
	set sub_aet;

	length npct	n1pct n2pct	$19. newname $130;

	npct  = put(cohort3,best12.);
	n1pct = put(cohort1,best12.);
	n2pct = put(cohort2,best12.);
	
	printord = 0;
	newname = "Subjects with Adverse Event(s)^{super d}";
run;

proc sort data=sub_ae1;
	by printord;
run;

**-------------------------------------------------------------------------------**;
**      Combine all the statistics and generate printable table values           **;
**-------------------------------------------------------------------------------**;

data tae_final_temp;
	set ch_stat1 cohort1_stat1 cohort2_stat1;
	select(AEBODSYS);
		when("GASTROINTESTINAL DISORDERS")								printord=1;
		when("GENERAL DISORDERS AND ADMINISTRATION SITE CONDITIONS")	printord=2;
		when("NERVOUS SYSTEM DISORDERS")								printord=3;
		when("VASCULAR DISORDERS")										printord=4;
	end;
run;

proc sort data = ch_stat1;
by aebodsys aedecod;
run;

proc sort data = cohort2_stat1;
by aebodsys aedecod;
run;

proc sort data = cohort1_stat1;
by aebodsys aedecod;
run;

proc sort data=tae_final_temp;
	by printord;
run;


/**----------- Derive Stat for Bodysys based on Treatment group ----------------**/;

data bs;
	set sae1;
run;

proc sort data=bs out=bs_s;
	by aebodsys ;
run;
proc means data=bs_s n noprint;
	var trt01pn;
	by aebodsys;
	output out=bs_stat(drop=_type_ _freq_) n= /autoname;
run;

/**----------- rename for table output and derive percent values for display ----------------**/;
data bs_stat1;
	set bs_stat(rename=(trt01pn_n=TotBS));
	
	bspct = TotBS/&cohortTot2*100;
	bsnpct = strip(put(TotBS,best12.)) || " ("|| strip(put(bspct,best4.1)) || ")";
run;

proc sort data=tae_final_temp;
	by printord;
run;

/**----------- Set Indents for SubCategory----------------**/;

data tae_final_1(drop=aebodsys aedecod totsub chpct cohort1 cohort1pct cohort2 cohort2pct);
	set tae_final_temp;

	by printord;
	length newname $130;
	
	if first.printord then do;
		newname= aebodsys;
		n1pct = "";
		n2pct = "";
		output;
	end;
	else do;
		newname =  "^R'\li220\ '" || aedecod;
		output;
	end;
run;

data tae_final;
	set tae_final_1 sub_ae1;
run;

proc sort data=tae_final;
	by printord;
run;

**-------------------------------------------------------------------------------**;
**         RTF SETUP                       								         **;
**-------------------------------------------------------------------------------**;

/**----- RTF SETUP -----**/;

options nodate nonumber orientation=landscape;
ods listing close ;
ods escapechar='^' ;
ods rtf style=TStyleRTF file="&outpath.AE_T721.rtf" ;

/**----- TITLES/FOOTNOTES -----**/;

title1 j=left "&ptitle1" j=right 'Page ^{pageof}' ;
title2 j=left "&ptitle2" j=right "&sysdate9"  ;
title3 j=center "Table 7.2.1" ;
title4 j=center "Adverse Events^{super a} by Body System" ;
title5 j=left "Study Population: Safety" ;



footnote1 h=10pt j=left "^R'\brdrt\brdrs\super a\nosupersub  Includes all adverse events reported after start of PROD administration.'" ;
footnote2 h=10pt j=left "^R'\super b\nosupersub  Subjects who had more than one event within a body system were counted once.'" ;
footnote3 h=10pt j=left "^R'\super c\nosupersub Subjects who had more than one event assigned to the same preferred term were counted once.'" ;
footnote4 h=10pt j=left "^R'\super d\nosupersub Subjects who had more than one event were counted once.'" ;

footnote5 j=left "&llastfoot adsllib.adae" j=right "&rlastfoot tae.sas";

**-------------------------------------------------------------------------------**;
**       BEGIN THE REPORT                                                        **;
**-------------------------------------------------------------------------------**;

/**----------- REPORT DEFINITION	----------------**/;
	
proc report data=tae_final  missing center center split='|' style(report)=[outputwidth=9.0in];
	
	column printord newname npct n1pct n2pct;

	define newname/display "MedDRA Body System^{super b}|^R'\li220\ 'Preferred Term^{super c}" style(header)=[just=left] style(column)=[width=2.0 in];
	define npct/display "All Subjects| (N=&cohorttot3)| n(%)" style(column)=[width=1.2 in just=center];
	define n1pct/display "Cohort 1 | (N=&cohorttot1)| n(%)" style(column)=[width=1.2 in just=center];
	define n2pct/display "Cohort 2 | (N=&cohorttot2)| n(%)" style(column)=[width=1.2 in just=center];
		
	define printord/order noprint;

	compute after printord;
	  line ' ';
	endcomp;
run ;

ods rtf close ;
ods listing ;

/**-------------------------------------------------------------------------------------------**
** PROGRAM:    ADAE.SAS 
** CREATED:    December 2019
** PURPOSE:    Create ADEX dataset from SDTM EX and ADSL dataset
** PROGRAMMER: Deepti Shah
** INPUT:      sdtmlib.ex, adsllib.adsl
** OUTPUT:     adsllib.adex
** PROTOCOL:   PROD-124
**-------------------------------------------------------------------------------------------**
/* ----------- SAS University Edition 9.4 ----------- */





/* Bring SDTM EX and ADSL Dataset */



/* ----------- Clear work library ----------- */

proc delete data=work._all_;
run;

/* Bring SDTM EX and ADSL Dataset */

data adsl(keep=usubjid saffl trt01pn trt01p weight);
	set adsllib.adsl;
run;
proc sort data=adsl out=adsl_s;
	by usubjid;
run;

data adex;
	set sdtmlib.ex;
run;

proc sort data=adex out=adex_s;
	by usubjid;
run;



data adex_1;
	merge adsl_s adex_s(in=inex);
	by usubjid;
	
	if inex;
run;

data adex_2;
	set adex_1;

	attrib dosep 	label="Planned Treatment Dose" 				format=best12.
		   doscump 	label="Cumulative Planned Treatment Dose" 	format=best12.
		   doseu 	label="Treatment Dose Units"
		   adt		label="Analysis Date"						format=yymmdd10.
		   atm		label="Analysis Time"						format=hhmm.
		   adtm		label="Analysis DateTime"					format=is8601dt.
		   ady		label="Analysis Relative Day"
		   ASTDT	label="Analysis Start Date"					format=yymmdd10.
		   ASTTM	label="Analysis Start Time	"				format=hhmm.
		   ASTDTM	label="Analysis Start DateTime"				format=is8601dt.
		   ASTDY	label="Analysis Start Relative Day"
		   AENDT	label="Analysis End Date"					format=yymmdd10.
		   AENTM	label="Analysis End Time"					format=hhmm.
		   AENDTM	label="Analysis End DateTime"				format=is8601dt.
		   AENDY	label="Analysis End Relative Day "
		   AVISIT	label="Analysis Visit"
		   PARAM	label="Parameter"	
		   PARAMCD  label="Parameter Code"
		   PARAMN	label="Parameter (N)"						format=1.				
		   AVAL		label="Analysis Value"
	;

	/**----------- Define Dose Variables  ----------------**/;
	dosep = exdose;
	doscump = exdose; 
	doseu = exdosu;

	/**----------- Define all the Timing Variables ----------------**/;
	adt = input(exstdtc,is8601da.);
	atm = input(substr(exstdtc,12),is8601tm.);
	adtm = input(exstdtc,is8601dt.);
	ady = input(exstdtc,is8601da.) - adt +1;
	ASTDT = input(exstdtc,is8601da.);
	ASTTM = input(substr(exstdtc,12),is8601tm.);
	ASTDTM = input(exstdtc,is8601dt.);
	ASTDY = input(exstdtc,is8601da.) - adt +1; 
	AENDT = input(exendtc,is8601da.);
	AENTM = input(substr(exendtc,12),is8601tm.);
	AENDTM = input(exendtc,is8601dt.);
	AENDY = input(exstdtc,is8601da.) - adt +1;	
	AVISIT = exstdy;
	AVISITN = 1; 

	/**----------- Analysis Parameter Variables for Dose (mg) ----------------**/;

	PARAM = "PROD Dosage(mg)         ";
	PARAMCD = "DOSE  ";
	PARAMN = 1;
	AVAL = EXDOSE;


run;

data adex_3;
	set adex_2;
	
	/**----------- Analysis Param Variables for mg/kg----------------**/;

	PARAM = "PROD Dosage for Weight";
	PARAMCD = "DOSEWT";
	PARAMN = 2;
	AVAL = EXDOSE/weight;

run;


/**----------- Merge(Concatenate) both parameters (adex_2 and adex_3) into a single dataset ----------------**/;
data adex_4;
	set adex_2 adex_3;
	
run;

proc sort data=adex_4 out=adex_5;
	by usubjid paramn;
run;

data adex_5;
	set adex_5;

	by usubjid;
	attrib aseq 	label="Analysis Sequence Number" 			format=best12.;

	/**----------- generate SEQ per subject **/
	
	aseq+1;
	if first.usubjid then aseq=1;
	
run;

**-------------------------------------------------------------------------------**;
**          Create ADEX dataset with attributes                                **;
**-------------------------------------------------------------------------------**;

proc sql;
	create table adsllib.adex (label='Exposure') as
	select  studyid, 
			usubjid,
			aseq,
			saffl,
			trt01p,
			trt01pn,
			weight,
			exseq,
			extrt,
			excat,
			exdose,
			exdosu,
			exdosfrm,
			exdosfrq,
			exroute,
			epoch,
			exstdtc,
			exendtc,
			exstdy,
			exendy,
			dosep,
			doscump,
			doseu,
			adt,
			atm,
			adtm,
			ady,
			astdt,
			asttm,
			astdtm,
			astdy,
			aendt,
			aentm,
			aendtm,
			aendy,
			avisit,
			avisitn,
			param,
			paramcd,
			paramn,
			aval	
	from adex_5
	;
quit;

proc print;
run;



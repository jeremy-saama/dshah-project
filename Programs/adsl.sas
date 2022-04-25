/**-------------------------------------------------------------------------------------------**
** PROGRAM:    ADSL.SAS 
** CREATED:    November 2019
** PURPOSE:    CREATE ADSL DATASET FROM SDTM DM DATA
** PROGRAMMER: Deepti Shah
** INPUT:      sdtmlib.dm
** OUTPUT:     adsllib.adsl
** PROTOCOL:   PROD-124
**-------------------------------------------------------------------------------------------**
/* ----------- SAS University Edition 9.4 ----------- */


/* Bring SDTM DM dataset */

data adsl_a1;

	set sdtmlib.dm;	
	
	/* Define and format the treatment date and time variables */
	format 	rficdt yymmdd10. 
	   	trtsdt trtedt tr01sdt tr01edt is8601da. 
		trtsdtm trtedtm  is8601dt. 
		trtstm trtetm tr01stm tr01etm is8601tm. ;
		
			
	/* Derive the safety flag based on reference start date and time. */
	
	if rfstdtc = "" then saffl = "N";
	else saffl = "Y";
	
	trt01p 	= armcd;
	trtseqp = arm;
	
	if trt01p = "Cohort 1" then trt01pn = 1;
	else if trt01p = "Cohort 2" then trt01pn = 2;
	
	rficdt = input(rficdtc,is8601da.);
	
	**----------- Derive Treatment Start dates and End dates	----------------**;
	if rfstdtc ne "" then
	do;
		
		trtsdtc  = ifc(lengthn(rfstdtc) eq 10, 
		               trim(rfstdtc) || ":00",
			       rfstdtc);
		trtsdt   = input(trtsdtc,is8601da.);
		trtstm   = input(substr(trtsdtc,12,8),is8601tm.);
		trtsdtm  = input(trtsdtc,is8601dt.);
		tr01sdt  = input(trtsdtc,is8601da.);
		tr01stm  = input(substr(trtsdtc,12,8),is8601tm.);
		
		trtsdtc  = ifc(lengthn(rfendtc) eq 10, 
		               trim(rfendtc) || ":00",
			       rfendtc);
		trtedt  = input(trtedtc,is8601da.);
		trtetm  = input(substr(trtedtc,12,8),is8601tm.);
		trtedtm = input(trtedtc,is8601dt.);
		tr01edt = input(trtedtc,is8601da.);
		tr01etm = input(substr(trtedtc,12,8),is8601tm.);
		
		
	end;

		
 	drop rfstdtc armcd rficdtc;
		
run;

**----------- Get Race Other from DM Supplemental dataset	----------------**;

data adsl_dm_sup(keep= usubjid raceoth);
	set sdtmlib.suppdm;	
	
	length raceoth $25;  
	raceoth = qval; 
 
run;

**----------- Get baseline weight from VS dataset	----------------**;

data vs_weight(keep= usubjid weight );
	set sdtmlib.vs (where = (vstestcd="WEIGHT" and VSBLFL="Y"));

 	attrib weight format=5.1;
	weight=input(vsorres,best.);
	
run;



proc sort; 
	by usubjid;
run;

**----------- Get baseline height from VS dataset	----------------**;

data vs_height(keep= usubjid height);
	set sdtmlib.vs (where =(vstestcd="HEIGHT" and VSBLFL="Y") );

	attrib height format=5.1;
	height=input(vsorres,best.);
run;

proc sort;
	by usubjid;
run;

**----------- Merge all the temp dataset and form the final ADSL dataset	----------------**;

data adsl_temp;
	merge adsl_a1 vs_weight vs_height adsl_dm_sup;
	by usubjid;
run;

proc print data=adsl_temp;
run;



**-------------------------------------------------------------------------------**;
**          Create Final ADSL dataset with all the key variable                    **;
**			Use Proc SQL - Create Table statement to create final ADSL dataset	 **;
**-------------------------------------------------------------------------------**;


proc sql;

	create table adsllib.adsl (label='Demographics and Baseline Characteristics') as
	select  studyid, 
			usubjid,
			subjid,
			siteid,
			brthdtc,
			age,
			ageu,
			sex,
			race,
			raceoth,
			saffl,
			arm,
			trt01p,
			trt01pn,
			trtseqp,
			trtsdt,
			trtstm,
			trtsdtm,
			trtedt,
			trtetm,
			trtedtm,
			rficdt,
			height,
			weight
	from adsl_temp
	;
quit;

proc print;
run;

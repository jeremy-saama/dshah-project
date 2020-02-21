/**-------------------------------------------------------------------------------------------**
** PROGRAM:    DM.SAS
** CREATED:    November 2019
** PURPOSE:    Create SDTM - DM dataset from Raw input data.
** PROGRAMMER: Deepti Shah
** INPUT:	   rawlib.Demo, rawlib.vital, rawlib.exposure
** OUTPUT:	   sdtm.dm
** PROTOCOL:   PROD-124
**-------------------------------------------------------------------------------------------*/
/* ----------- SAS University Edition 9.4 ----------- */



/* ----------- Change the path when running on different machine ----------- */
%let directory_start = /folders/myshortcuts/Deepti_Shah_Final_Project_2019/PROD124/Programs/;
%let directory_end= .sas;
%let fileName=msetup;

%include "&directory_start.&fileName.&directory_end.";
 
options validvarname = upcase;


**----------- Sort the raw input demo data	----------------**;
proc sort data=rawlib.demo;
	by inv_no patid;
run;


*************************************************************************************************
* STUDYID/DOMAIN/USUBJID/SUBJID/SITEID/birthdtC/SEX/RACE/COUNTRY/RFicdtC/AGE
*************************************************************************************************;

** ------------ Derive a temporary SDTM DM dataset ------------ **;

data demo_master;

	length	studyid $8
			domain $2
			usubjid $20
			subjid $6
			siteid $2
			brthdtc $19
			sex $8
			race $30
			country $3
			rficdtc $19
			ageu $10

			;
		
	set rawlib.demo;
	
	studyid = proto;
	domain = 'DM';
	usubjid = strip(proto) || '-' || put(inv_no,z2.) || '-' || put(patid,z3.);	
	subjid = put(inv_no,z2.) || '-' || put(patid,z3.);
	siteid =  put(inv_no,z2.);
	brthdtc = strip(put(year(birthdt),4.)) || '-' || strip(put(month(birthdt),Z2.)) || '-' || strip(put(DAY(birthdt),Z2.));

	
	if upcase(sex) = 'M' then sex = 'Male';
	else if upcase(sex) = 'F' then sex = 'Female';
	
	ageu = 'years';
	race = race;
	country = 'USA';
	rficdtc =   put(icdt,is8601da.); 
	
 	%mage(indate=icdt, dobvar=birthdt) 	/* Call the mage macro that return the age. */
	
run;



*************************************************************************************************
* RFSTDTC - DERIVE DATE OF FIRST DOSE - FROM THE VITALS DATA.
*************************************************************************************************;


proc sort data = rawlib.vital(keep = inv_no patid vsdt visit) out = exstdt; 
     by inv_no patid vsdt; 
run; 

data exstdt_1 (keep= inv_no patid vsdt visit where= (visit = 'STUDY DAY 1'));
	set exstdt;
	by inv_no patid;
	if first.patid then output exstdt_1;	
run;


proc sort data=exstdt_1;
	by inv_no patid;
run;

data vspt_sttm(keep=inv_no patid rfsttmc);
	set rawlib.vitaltpt(where=(VSTPTM="0 min"));
	
	inv_no = put(inv_no,2.);
	patid = put(patid,3.);

	** ------------ Start Time ------------ **;
	rfsttm = put(vstacttm,time5.);
	if length(strip(rfsttm)) < 5 then rfsttmc = "0"||strip(rfsttm);
	else rfsttmc = rfsttm;

run;



data demo_rfstdt;
    length rfstdt $20;
    
    merge demo_master(in=a) 
          exstdt_1(in=b);          
    by inv_no patid;

	rfstdt = put(vsdt,is8601da.);

    drop vsdt;

	if a;
	
run;

data demo_rfstdtc;
    length rfstdtc $20;
    
    merge demo_rfstdt(in=a) 
          vspt_sttm (in=b);
    by inv_no patid;
	
	if length(strip(rfstdt)) > 1 then rfstdtc = strip(rfstdt) || "T" || strip(rfsttmc);	
	else rfstdtc = '';
	
    drop rfstdt rfsttmc;

	if a;
	
run;



*************************************************************************************************
* RFENDTC - DERIVE DATE OF LAST DOSE - FROM THE VITALS DATA.
*************************************************************************************************;

proc sort data = rawlib.vital(keep = inv_no patid vsdt visit ) out = exendt;
    by inv_no patid descending vsdt;
run;

data exendt_1 (keep= inv_no patid vsdt visit where=(visit = 'STUDY DAY 2'));
    set exendt;
    by inv_no patid;
	if first.patid then output exendt_1;	    
run;

proc sort data = exendt_1;
    by inv_no patid descending vsdt;
run;



data vspt_endt(keep=inv_no patid rfentmc);
	set rawlib.vitaltpt(where=(VSTPTM="END OF INFUSION PERIOD #2"));
	inv_no = put(inv_no,2.);
	patid = put(patid,3.);

	** ------------ End Time ------------ **;

	rfentm = put(vstacttm,time5.);
	if length(strip(rfentm))<5 then rfentmc = "0"||strip(rfentm);
	else rfentmc = rfentm;

run;


data demo_rfendt ;
    length rfendt $20;
    merge demo_rfstdtc(in=a) 
          exendt_1(in=b);
    by inv_no patid;

	 
	if missing(vsdt) then rfendt = "";
	else rfendt = put(vsdt,is8601da.);
	
    drop vsdt;

	if a;
	
run;


data demo_rfendtc ;
    length rfendtc $20;
    merge demo_rfendt(in=a) 
          vspt_endt(in=b);
    by inv_no patid;

	 
	if length(strip(rfendt)) > 1 then rfendtc = strip(rfendt) || "T" || strip(rfentmc);	
	else rfendtc = '';
	
    drop rfendt rfentmc;

	if a;
	
run;




************************************************************************************************
* Derive ARM and ARMCD from Exposure Input data.   
************************************************************************************************;


proc sort data = rawlib.exposure(keep = inv_no patid cohort ) out = arm; 
     by inv_no patid cohort; 
run; 

data arm_1 (keep= inv_no patid cohort);
	set arm;
	by inv_no patid;
	if first.patid then output arm_1;	
run;


************************************************************************************************
* Per SAP - Cohort 1 followed the sequence of Bag and then Bottle
* Per SAP - Cohort 2 followed the sequence of Bottle and then Bag
************************************************************************************************;


data demo_arm ;
    length arm $40 armcd $20;
    
    merge demo_rfendtc(in=a) 
          arm_1(in=b);
    by inv_no patid;

   	if cohort = 1 then 
   		do;
   			arm = 'Bag/Bottle';
   			armcd = 'Cohort 1';
   			actarm = 'Bag/Bottle';
   			actarmcd = 'Cohort 1';
   		end;
   	   	
   	if cohort = 2 then 
   		do;
   			arm = 'Bottle/Bag';
   			armcd = 'Cohort 2';
   			actarm = 'Bottle/Bag';
   			actarmcd = 'Cohort 2';
   		end;
   	

    drop cohort;

    if a ;
    
    keep studyid domain usubjid subjid siteid brthdtc sex race country rficdtc rfstdtc rfendtc age ageu armcd arm actarm actarmcd;

    
run;


**-------------------------------------------------------------------------------**;
**          Create Final DM dataset with all the key variable                    **;
**			Use Proc SQL - Create Table statement to create final DM dataset	 **;
**-------------------------------------------------------------------------------**;

proc sql;
    create table sdtmlib.dm(label = "Demographic") as
        select         
	        studyid ,
	        domain ,
	        usubjid ,
	        subjid ,
	        rficdtc ,
	        rfstdtc,
	        rfendtc ,
	        siteid ,
	        brthdtc ,
	        age ,
	        ageu ,
	        sex ,
	        race ,
	        armcd ,
	        arm ,
	        actarmcd,
			actarm ,
	        country 
       	from demo_arm;
quit;

proc print;
run;


/*************************************************************/
/******************END OF DM Processing **********************/
/*************************************************************/





/*************************************************************/
/*****************SUPPDM Processing **************************/
/*************************************************************/


data demo_supp;
	set demo_master(keep = studyid domain usubjid raceoth);
run;

proc transpose data=demo_supp out=demo_tran;
   by studyid domain usubjid;
   var raceoth;
run;

data demo_supp1(drop = domain _name_ _label_ col1) ;
set demo_tran (where=(col1 ^= ''));

	rdomain = domain;
	idvar = "";
	idvarval = "";

	qnam = _name_;
	qlabel = _label_;
	qval = left(trim(col1));

	qorig = "CRF";
	qeval = "";

run;



**-------------------------------------------------------------------------------**;
**          Create Final SUPP DM dataset with all the key variable               **;
**			Use Proc SQL - Create Table statement to create final SUPP DM dataset**;
**-------------------------------------------------------------------------------**;

proc sql;
    create table sdtmlib.suppdm(label = "Suplemental Demographic") as
        select         
			studyid,
			rdomain,
			usubjid,
			idvar,
			idvarval,
			qnam,
			qlabel,
			qval,
			qorig, 
			qeval
       	from demo_supp1;
quit;

proc print;
run;



/*************************************************************/
/**************END OF SUPPDM Processing **********************/
/*************************************************************/



			
	


/* ----------- Change the path when running on different machine ----------- */

%let path=/folders/myshortcuts/Deepti_Shah_Final_Project_2019/PROD124;
%let outpath = &path/output/;

libname rawlib  "&path./Data/Original" ACCESS=READONLY ;
libname sdtmlib "&path./Data/SDTM"  ;
libname adsllib "&path./Data/Analysis" ;
libname tmpltlib "&path./programs" ;

%include "&path./Library/mage.sas" ;  

        
ods path tmpltlib.templat(UPDATE) sashelp.tmplmst(READ);   ** CONNECT TO STANDARD ODS TEMPLATES **;

**----- DEFINE GENERIC VARIABLES -----**;

%let study=PROD-124;
%let ptitle1=CM Pharmaceuticals, Inc.;
%let ptitle2=Protocol PROD-124;

%let rtitle1 = %str( j=left "&ptitle1" j=right 'Page ^{thispage}' ); ** FOR RTF TLFs, COMPLETE 1ST TITLE **;
%let rtitle2 = %str( j=left "&ptitle2" j=right "&sysdate9" );        ** FOR RTF TLFs, COMPLETE 2ND TITLE **;


**----- DEFINE GENERIC FOOTNOTES -----**;

%let topbrdr =^R'\brdrt\brdrs\brdrw30\ ';  ** RTF CODE FOR OVERLINE CELL BORDER **;
%let llastfoot=Data Source: ;
%let rlastfoot=Program: ;
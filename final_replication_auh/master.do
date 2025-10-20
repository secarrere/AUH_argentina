********************************************************************************
/*do-file: master.do
********************************************************************************
********************************************************************************
****project title: AUH_argentina			
****database used: INDEC - Encuesta permanente de hogares (EPH)
****authors: S. Carrère	
********************************************************************************
********************************************************************************
****description: set the working directory and run all do-files to create the final database

****date: 20/11/2024	created
****date: 20/10/2025	modified
*/
********************************************************************************

* /!\ SET WORKING DIRECTORY  

clear
global AUH_argentina "C:/Users/sebac/Work/AUH_argentina/final_replication_AUH" // /!\ Set your own working directory /!\ 
set more off

********************************************************************************

/*
**Replication of the full database:
***********************************

STEP 1: -From the INDEC website: https://www.indec.gob.ar/indec/web/Institucional-Indec-BasesDeDatos
        -Download microdata for each quarter from the 'Microdatos y documentos 
		 2003-2015' section, and select 'Formato Stata'

STEP 2: -Extract each file and put the 'Hogar_t***.dta' and 'Individual_t***.dta' files
        in the 'final_replication_AUH/data/default/EPH' directory

STEP 3: run the following code to replicate the full database
*/

cd "$AUH_argentina/dofiles/"

local i : dir "" files "*.do"
foreach file in `i' {
run  `file'
cd "$AUH_argentina/dofiles/"
}





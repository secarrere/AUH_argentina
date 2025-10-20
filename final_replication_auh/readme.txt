********************************************************************************
/*Readme
********************************************************************************
********************************************************************************
****project title: AUH_argentina			
****database used: INDEC - Encuesta permanente de hogares (EPH)
****authors: S. Carrère	
********************************************************************************
********************************************************************************
****date   : 20/11/2024	created
****date   : 20/10/2025	modified
****version: v1
*/
********************************************************************************

In this folder, you will find codes and datasets to replicate the results of the paper "How effective are cash transfer programs in mitigating income instability? Evidence from the AUH in Argentina" that you can find at the following link:

-Published version: Forthcoming in the Journal of Development Studies...

-Working paper version: https://hal.science/hal-04525248


Structure of the folder:
************************

- 'master.stpr'   : Stata project file
- 'master.do'     : Main do-file for setting up the working environment and creating the database.
- 'data' folder   : -> "AUH_ready_base" compressed file, corresponding to the ready-to-use database for the main analysis
		    -> ‘default/EPH/’ directory where quarterly EPH data should be stored.
                    -> ‘alt_sample’ folder where alternative samples will be saved for supplementary analysis.
                    -> 'cpi.dta' file which contains consumer price index data. 
- 'dofiles' folder: Three dofiles needed for the full database construction
- 'results' folder: -> 2 dofiles necessary to replicate the results of the main analysis and additional analyses.
		    -> 'tables' and 'graphs' folders where tables and figures can be stored.
- 'ado' folder    : The ‘c’ and ‘d’ folders contain the ado files for the Stata packages -csdid- and -drdid- version 1.71, which were used to obtain
		    the results presented in this paper. They must be copied to your Stata ado directory, which is usually located in ‘C:\ado\plus\’. 
	  	    A more recent version of these packages may produce slightly different results due to modified weight calculations.

Results replication:
********************

Few steps are needed for results replication:

1. In Stata, open the "master.stpr" project file
2. Open the "master.do" file that you can find on the left panel
3. Set your own working directory in line 20 : global AUH_argentina "C:/Users/sebac/Work/AUH_argentina/final_replication_AUH" 

4a. OPTION 1: Replication of the main results:

- Extract the 'AUH_ready_base' file that contains the 'AUH_ready_base.dta' database. This ready-to-use dataset is the short version of the complete dataset that you can compute in option 4b. This database only keeps the sample used in the main analysis.


4b. OPTION 2: Replication of the full database for supplementary analysis:

STEP 1: -From the INDEC website: https://www.indec.gob.ar/indec/web/Institucional-Indec-BasesDeDatos
        -Download microdata for each quarter from the 'Microdatos y documentos 
		 2003-2015' section, and select 'Formato Stata'
STEP 2: -Extract each file and put the 'Hogar_t***.dta' and 'Individual_t***.dta' files
        in the 'final_replication_AUH/data/default/EPH' directory
STEP 3: run the master do-file code to replicate the full database. It may takes a few minutes, depending on your computer. 


*Note: /!\ results from the csdid command were produced under the 1.71 package version. Since this package is continuously
*		   updated, more recent package version could change the results marginally. The 'ado' folder contains the 1.71 version of  
*                  the -drdid- and -csdid- package used in the paper. If you want to replicate correctly these results, you need to copy
*		   the 'c' and 'd' folder into you ado directory file, usually located in "C:\ado\plus\".



Don't hesitate to reach me at 
sebastien.carrere@univ-grenoble-alpes.fr / sebascarrere@gmail.com



Best,

S. Carrère

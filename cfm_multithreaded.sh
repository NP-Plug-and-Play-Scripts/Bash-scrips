#!/bin/bash

#################################################################
# Runs cfm id on multiple cores. Does this through 				#
# running it in multiple background processes					#
# adjust the amount of cores used by editing the 				#
# "cores" variable.												#
#																#
# In order to run its check all the path 						#
# variables and change them to you're file 						#
#	locations and preferences.									#
#																#
# cores = the amount of core you want to use (also the 			#
#	amount of files that will be created with split)			#
# totalLines = the number of smiles/lines in the selected file 	#
# linesPerFile = calculate by taking the number of smiles 		#
#	in the document divided by the number of cores				#
#								  								#
# cfmPath = the path to the cfm-id executables.					#
# cfmData = path to the directory in which the config, 			#
#  pretrained models and folder with smile files are located.	#
# smileDir = name of the folder in cfmData that contains 		#
#	the smile file.												#
# smileFile = name if the file that should be 					#
#	ran through cfm-id.											#
# newFileName = hwo the new files will be named. (00,01,02... 	#
#	numbering will be added at the end along with a .txt)		#
#																#
#																#
# Made by Rutger Ozinga           								#
# Last update : 4/sept/2018	  									#
#################################################################

#the amount of cores you wish to use.
cores=10
#path to the cfm-id instalation
cfmPath="/mnt/scratch/ozing003/CFM_workplace/cfm/bin"
#this path should contain the cfm config file, the folder with pretrained models and a folder containing the smile files
cfmData="/mnt/scratch/ozing003/CFM_workplace/cfmData/"
#path to directory containing the smile strings. (continues from cfmData path.) 
smileDir="smileFile/"
#name of the file that needs to be ran through cfm_id
smileFile="Rutger_10000_SMILES.txt"
totalLines=$(wc -l < $cfmData$smileDir$smileFile)
linesPerFile=$((totalLines/cores))
newFileName=smiles_${linesPerFile}_part_

read -p "Run cfm on $cores cores y/n)?" CONT
if [ "$CONT" = "y" ]; then
	cd $cfmData/$smileDir
	#creates the smaller files for each of the cores
	split --lines=$linesPerFile $smileFile $newFileName --numeric-suffixes --additional-suffix=.txt
	
	for ((i=0;i<$cores;i++));
	do 	
		#value is the number with a 0 placed infront of it so it matches the file counting of split (00, 01, 02 etc)
		value=$(printf "%02d" $i)
		#command to run cfm-predict.
		$cfmPath/cfm-predict ${cfmData}${smileDir}${newFileName}${value}.txt 0.001 $cfmData/params_metab_ce_cfm/param_output0.log $cfmData/param_config.txt 0 $cfmData/results/${newFileName}${value}_output.mgf&
		
	done
else
  exit;
fi

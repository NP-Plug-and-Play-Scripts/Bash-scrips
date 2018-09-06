#!/bin/bash

##########################################################################
#Bash script for the full instalation of CFM-id. Will create a new folder#
#at the current location that will contain CFM-id and the libraries	 #  
#lpsolve,rdkit,boost and cmake(if you decide to keep it).		 #
# 									 #
#These library versions can be found at:				 #
#cfm-id: https://sourceforge.net/projects/cfm-id/			 #
#lpsolve: https://sourceforge.net/projects/lpsolve/files/lpsolve/5.5.2.5/#
#rdkit:https://sourceforge.net/projects/rdkit/files/rdkit/Q1_2016/ 	 #
#boost:https://www.boost.org/users/history/version_1_67_0.html		 #
#Made by Rutger Ozinga 					    		 #
#last update:2018/9/3					                 #
##########################################################################

read -p "Continue with the instalation of CFM-id (y/n)? " CONT
if [ "$CONT" = "y" ]; then
	#create the directories
	mkdir CFM_workplace
	cd CFM_workplace
	#download the required tar files.

	#install cmake
	wget http://www.cmake.org/files/v3.12/cmake-3.12.1.tar.gz
	echo Unzipping cmake in $PWD !
	tar xzf cmake-3.12.1.tar.gz
	rm cmake-3.12.1.tar.gz
	cd cmake-3.12.1
	echo configuring cmake install path!
	./configure --prefix=$PWD
	echo installing cmake!
	make
	make install
	
	#install boost
	cd ..
	wget https://dl.bintray.com/boostorg/release/1.67.0/source/boost_1_67_0.tar.gz
	tar -zxf boost_1_67_0.tar.gz
	rm boost_1_67_0.tar.gz
	cd boost_1_67_0
	./bootstrap.sh --prefix=. --with-libraries=regex,serialization,filesystem,system
	./b2 address-model=64 cflags=-fPIC cxxflags=-fPIC install
	export BOOST_ROOT=$PWD
	
	#install rdKit 
	cd ..
	wget https://sourceforge.net/projects/rdkit/files/rdkit/Q1_2016/RDKit_2016_03_1.tgz
	tar -zxf RDKit_2016_03_1.tgz
	rm RDKit_2016_03_1.tgz
	cd rdkit-Release_2016_03_1/External/INCHI-API
	bash download-inchi.sh
	cd ../..
	mkdir build
	cd build
	../../cmake-3.12.1/bin/cmake .. -DRDK_BUILD_PYTHON_WRAPPERS=OFF -DRDK_BUILD_INCHI_SUPPORT=ON -DBOOST_ROOT=~/boost_1_67_0
	make install
	cd ..
	export RDBASE=$PWD
	echo Done!
	
	#install lpsolve
	cd ..
	wget https://github.com/RutgerOzinga/Wur_LPSolve/archive/master.zip
	unzip master.zip
	cd Wur_LPSolve-master
	mv lp_solve_5.5/  ../
	cd ..
	rm -r Wur_LPSolve-master
	rm master.zip
	cd lp_solve_5.5/lpsolve55
	sh ccc
	echo lpsolve compiled
	
	#install cfm-id
	cd ../..
	wget https://github.com/RutgerOzinga/Cfm-id/archive/master.zip
	unzip master.zip
	rm master.zip
	cd Cfm-id-master
	mv cfm/ ../
	mv cfmData/ ../
	cd ..
	rm -r Cfm-id-master
	cd cfm 
	mkdir build
	cd ..
	cmake-3.12.1/bin/cmake -Bcfm/build -Hcfm -DLPSOLVE_INCLUDE_DIR=$PWD/lp_solve_5.5 -DLPSOLVE_LIBRARY_DIR=$PWD/lp_solve_5.5/lpsolve55/bin/ux64
	cd cfm/build
	make install
	cd ../..
	export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$PWD/boost_1_67_0/lib:$PWD/rdkit-Release_2016_03_1/lib:$PWD/lp_solve_5.5/lpsolve55/bin/ux64
	#comment out the following two lines to disable the removal of cmake!!
	echo removing cmake-3.12.1 to save disk space!
	rm -r cmake-3.12.1/
	echo Instalation complete!
else
	exit;
fi

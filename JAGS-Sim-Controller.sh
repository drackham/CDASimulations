#!/bin/bash
# nohup sh simulationController.sh | tee Results/Sim4/log.txt &

# Read the simulationConditions.csv file
file="Simulation Code/Simulation Conditions.csv"
#read -p "What Simulation Condition do you want to run? `echo $'\n> '`" simNumber
simNumber=1
echo $simNumber

lineNumber=$(($simNumber+1))

simulationUUID=$(sed -n "${lineNumber}p" "$file" | awk -F ',' '{print $1}')
N=$(sed -n "${lineNumber}p" "$file" | awk -F ',' '{print $2}')
data=$(sed -n "${lineNumber}p" "$file" | awk -F ',' '{print $3}')
model=$(sed -n "${lineNumber}p" "$file" | awk -F ',' '{print $4}')
maxCores=$(sed -n "${lineNumber}p" "$file" | awk -F ',' '{print $5}')
iter=$(sed -n "${lineNumber}p" "$file" | awk -F ',' '{print $6}')


# Run script
Rscript R-DINA-JAGS-SIM.R $simulationUUID $N $data $model $maxCores $iter

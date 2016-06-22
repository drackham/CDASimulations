# nohup Rscript R-DINA-JAGS-SIM.R | tee R-DINA-JAGS/R-DINA-JAGS-log.txt

library('devtools')
install_github("drackham/dcms", ref="develop")
library('dcms')
library('coda')
library('ggmcmc')
library('parallel')
library('runjags')

# -------------------------------------------------------Command Line Setup---------------------------------------------------
options(echo=FALSE) # if you want see commands in output file
args <- commandArgs(trailingOnly = TRUE)

simulation_id <- as.numeric(args[1])
dataset <- as.character(args[2])
model <- as.character(args[3])
N <- as.numeric(args[4])
max_cores <- as.numeric(args[5])
iter <- as.numeric(args[6])
chains <- as.numeric(args[7])
results_path <- as.character(args[8])

cat("Simulation id is: ", simulation_id, "\n")
cat("data is: ", dataset, "\n")
cat("model is: ", model, "\n")
cat("Sample Size is: ", N, "\n")
cat("max_cores is: ", max_cores, "\n")
cat("iterations is: ", iter, "\n")
cat("chains is: ", chains, "\n")
cat("results_path: ", results_path, "\n")

# Set working directory
setwd(results_path)

# Load and save the simulated data 
# http://stackoverflow.com/questions/9083907/r-how-to-call-an-object-with-the-character-variable-of-the-same-name
data <- get(dataset)


# Specify which model to use
generateRDINAJagsNonHierachical()
# generateRDINAJags()
# generateHO_R_DINA_Jags()

# Start the timer!
ptm <- proc.time()

sim <- rDINAJagsSim(data, jagsModel = model,
                    maxCores = max_cores, adaptSteps = 1000, burnInSteps = 1000,
										numSavedSteps = iter, thinSteps = 4)

# Stop the timer...
duration <- proc.time() - ptm
totalTime <- as.numeric(duration[3])

save(sim, file = "Sim.RData")

#.......... Document the simulation ..............
simType = model
dataSet = paste("R_DINA_SimpleQ.", N, sep = "")
dateStarted <- Sys.time()

# Get the SHA1 that was used
dcms.SHA1 <- unlist(strsplit(system("git ls-remote https://github.com/drackham/dcms develop", intern = TRUE), "\t"))[[1]] # Execute system command, split on \t unlist and keep only the SHA1

simInfo <- data.frame(simulation_id, simType, dateStarted, dcms.SHA1, dataSet, max_cores, iter, chains, totalTime)

# Save the simInfo object
save(simInfo, file = "simInfo.RData" )

# Quit the R session and clean up
quit(save = "no", status = 0, runLast = TRUE)
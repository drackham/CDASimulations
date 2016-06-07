# nohup Rscript R-DINA-JAGS-SIM.R | tee R-DINA-JAGS/R-DINA-JAGS-log.txt

library('devtools')
install_github("drackham/dcms", ref="develop")
library('dcms')
library('uuid')
library('coda')
library('ggmcmc')
library('parallel')
library('runjags')

# -------------------------------------------------------Command Line Setup---------------------------------------------------
options(echo=TRUE) # if you want see commands in output file
# args <- commandArgs(trailingOnly = TRUE)

# simulationUUID <- UUIDgenerate()
N <- 500
data <- R_DINA_SimpleQ.500
model <- "R-DINA-Non-Hierarchical.jags"
maxCores <- min(2, parallel::detectCores()-1)
iter <- 20000
chains <- maxCores

# simulationUUID <- as.numeric(args[1])
# N <- as.numeric(args[2])
# data <- as.numeric(args[3])
# model <- as.numeric(args[4])
# maxCores <- as.numeric(args[5])
# iter <- as.numeric(args[6])
# chains <- cores


# simPath <- paste("Results/Sim", simulationCondition, "/", sep="")
# 
# cat("Simulation Condition is: ", simulationCondition, "\n")
# cat("Sample Size is: ", sampleSize, "\n")
# cat("savedSteps is: ", savedSteps, "\n")
# cat("thin is: ", thin, "\n")
# cat("betaA is: ", betaA, "\n")
# cat("betaB is: ", betaB, "\n")
# cat("Model name is: ", jagsModel, "\n")

# Set the simID
simID <- UUIDgenerate()

# Set working directories
wdLocal <- "~/Desktop/R-DINA-JAGS"
wdRemote <- "/home/drackham/R-DINA-JAGS"
wdSirThomas <- "/home/dave/dev/results"

setwd(wdSirThomas)

# Create simulation folder
dir.create(simID)

# Load and save the simulated data
# N <- 500
# data(R_DINA_SimpleQ_Flat.500)
data(data)

# Specify which model to use

generateRDINAJagsNonHierachical()
# generateRDINAJags()
# generateHO_R_DINA_Jags()

# Start the timer!
ptm <- proc.time()

sim <- rDINAJagsSim(data, jagsModel = model, 
                    maxCores = maxCores, adaptSteps = 1000, burnInSteps = 1000,
										numSavedSteps = iter, thinSteps = 4)

# Stop the timer...
duration <- proc.time() - ptm
totalTime <- as.numeric(duration[3])

save(sim, file = paste(simID, "/", simID, "-Sim.RData", sep=""))

#.......... Document the simulation ..............
simType = model
dataSet = paste("R_DINA_SimpleQ.", N, sep = "")
dateStarted <- Sys.time()

# Get the SHA1 that was used
dcms.SHA1 <- unlist(strsplit(system("git ls-remote https://github.com/drackham/dcms develop", intern = TRUE), "\t"))[[1]] # Execute system command, split on \t unlist and keep only the SHA1

simInfo <- data.frame(simID, simType, dateStarted, dcms.SHA1, dataSet, maxCores, iter, chains, totalTime)

# Save the simInfo object
write.table(simInfo, file = paste(simID, "/", simID, "-R-DINA Non-Hierarchical JAGS.txt", sep=""))

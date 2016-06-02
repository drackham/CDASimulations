# nohup Rscript R-DINA-JAGS-SIM.R | tee R-DINA-JAGS-log.txt

library('devtools')
install_github("drackham/dcms", ref="develop")
library('dcms')
library('uuid')
library('coda')
library('ggmcmc')
library('parallel')
library('runjags')

# Set the simID
simID <- UUIDgenerate()

# Set working directories
wdLocal <- "~/Desktop/R-DINA-JAGS"
wdRemote <- "/home/drackham/R-DINA-JAGS"

setwd(wdRemote)

# Create simulation folder
dir.create(simID)

# Load and save the simulated data
N <- 500
data(R_DINA_SimpleQ_Flat.500)

# Specify which model to use
model <- "R-DINA-Non-Hierarchical.jags"
generateRDINAJagsNonHierachical()
# generateRDINAJags()
# generateHO_R_DINA_Jags()

cores = min(4, parallel::detectCores()-1)
iter = 50
chains = cores

# Start the timer!
ptm <- proc.time()

sim <- rDINAJagsSim(R_DINA_SimpleQ_Flat.500, jagsModel = model, 
                    maxCores = cores, adaptSteps = 10, burnInSteps = 10,
										numSavedSteps = iter, thinSteps = 1)

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

simInfo <- data.frame(simID, simType, dateStarted, dcms.SHA1, dataSet, cores, iter, chains, totalTime)

# Save the simInfo object
write.table(simInfo, file = paste(simID, "/", simID, "-R-DINA Non-Hierarchical JAGS.txt", sep=""))

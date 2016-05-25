# nohup Rscript STAN-IRT-1PL-Sim.R | tee STAN-IRT-1PL-log.txt

library('devtools')
install_github("drackham/dcms", ref="develop")
library("dcms")
library("rstan")
library("uuid")

# Set the simID
simID <- UUIDgenerate()

# Configure RSTAN
rstan::rstan_options(auto_write = TRUE)
options(mc.cores = parallel::detectCores())

# Load the simulated data
N <- 100
data(paste("IRT_1PL.", N, sep = ""))

# Set working directories
wdLocal <- "~/Desktop/IRT-1PL"

# Start the timer!
ptm <- proc.time()

cores = min(3, parallel::detectCores()-1)
iter = 6000
chains = 3

print("Starting simulation...")

# Run the simulation
fit <- STAN_IRT_1PL (data = IRT_1PL.1000, wd = wdLocal, cores = cores, iter = iter, chains = chains)

# Stop the timer...
duration <- proc.time() - ptm
totalTime <- as.numeric(duration[3])

# Save the output
save(fit, file = paste(simID, "-stanFit.R", sep=""))

#.......... Document the simulation ..............
simType = "IRT 1-PL N = 1000"
dataSet = paste("IRT_1PL.", N, sep = "")
dateStarted <- Sys.time()

# Get the SHA1 that was used
dcms.SHA1 <- unlist(strsplit(system("git ls-remote https://github.com/drackham/dcms develop", intern = TRUE), "\t"))[[1]] # Execute system command, split on \t unlist and keep only the SHA1

simInfo <- data.frame(simID, simType, dateStarted, dcms.SHA1, dataSet, cores, iter, chains, totalTime)

# Save the simInfo object
write.table(simInfo, file = paste(simID, "-IRT-1PL-Info.csv", sep=","))

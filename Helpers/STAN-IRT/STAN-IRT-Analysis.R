library('devtools')
install_github("drackham/dcms", ref="develop")
library("dcms")
library('ggmcmc')
library('rstan')
library("shinystan")
source("/Users/Dave/dev/EffectiveThetaBIN/Helpers/rootMeanSquaredDifference.R")

# Load the files

# Load the data
data("IRT_1PL.1000")

print(fit)

# Load the simulated parameter values
thetaSim <- IRT_1PL.1000$theta
betaSim <- IRT_1PL.1000$beta

post <- rstan::extract(fit, permuted = TRUE) # return a list of arrays

thetaHat <- colMeans(post$theta)

plot(thetaSim, thetaHat, xlim=c(-5,5), ylim=c(-5,5))
abline(a=0,b=1)

rmsd <- rootMeanSquaredDifference(thetaSim,thetaHat)
mean(rmsd)
plot(density(rmsd)) 

betaHat <- colMeans(post$beta)

plot(betaSim, betaHat, xlim=c(-5,5), ylim=c(-5,5))
abline(a=0,b=1)

rmsd <- rootMeanSquaredDifference(betaSim,betaHat)
mean(rmsd)
plot(density(rmsd)) 

my_sso <- launch_shinystan(fit)


sim_monitor <- as.data.frame(monitor(fit, print = FALSE))

# Make vector of wanted parameter names
wanted_pars <- c(paste0("beta[", 1:IRT_1PL.500$J, "]"))

# Get estimated and generating values for wanted parameters
generating_values = c(betaSim)
estimated_values <- sim_monitor[wanted_pars, c("mean", "2.5%", "97.5%")]

# Assesmble a data frame to pass to ggplot()
sim_df <- data.frame(parameter = factor(wanted_pars, rev(wanted_pars)), row.names = NULL)
sim_df$middle <- estimated_values[, "mean"] - generating_values
sim_df$lower <- estimated_values[, "2.5%"] - generating_values
sim_df$upper <- estimated_values[, "97.5%"] - generating_values

# Plot the discrepancy
ggplot(sim_df) + aes(x = parameter, y = middle, ymin = lower, ymax = upper) +
	scale_x_discrete() + geom_abline(intercept = 0, slope = 0, color = "white") +
	geom_linerange() + geom_point(size = 2) + labs(y = "Discrepancy", x = NULL) +
	theme(panel.grid = element_blank()) + coord_flip()


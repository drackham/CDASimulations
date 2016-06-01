library('ggplot2')
library('ggmcmc')
library("shinystan")
library('rstan')
source("/Users/Dave/dev/EffectiveThetaBIN/Helpers/rootMeanSquaredDifference.R")

# setwd("")
data(R_DINA_SimpleQ.100)

post <- rstan::extract(fit, permuted = TRUE) # return a list of arrays

my_sso <- launch_shinystan(fit)

dHat <- colMeans(post$dHat)
simD <- R_DINA_SimpleQ.100$d

plot(simD, dHat, xlim=c(0,18), ylim=c(0,18))
abline(a=0,b=1)

rmsd <- rootMeanSquaredDifference(simD,dHat)
mean(rmsd)
plot(density(rmsd)) #.820549

fHat <- colMeans(post$fHat)
simF <- R_DINA_SimpleQ.100$f

plot(simF, fHat, xlim=c(-10,0), ylim=c(-10,0))
abline(a=0,b=1)

rmsd <- rootMeanSquaredDifference(simF,fHat)
mean(rmsd)
plot(density(rmsd)) #.369

# launch_shinystan(my_sso)
sim_monitor <- as.data.frame(monitor(fit, print = FALSE))

# Make vector of wanted parameter names
wanted_pars <- c(paste0("dHat[", 1:R_DINA_SimpleQ.100$J, "]"), paste0("fHat[", 1:R_DINA_SimpleQ.100$J, "]"))

# Get estimated and generating values for wanted parameters
generating_values = c(simD, simF)
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

# Prob response
probHat <- boot::inv.logit(fHat + dHat)
prob <- boot::inv.logit(simF + simD)

diff <- (probHat - prob)
mean(diff)

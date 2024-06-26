source("functions.R")
setwd("../Data")
local_exp_results <- readRDS('local_exp_results.rds')
df <- data.frame(phi = numeric(), n = numeric(), CI = character(), 
                 target = character(), cov = numeric(),
                 LB = numeric(), UB = numeric())
nrep <- 10000
for(i in names(local_exp_results)) {
  phi <- as.numeric(strsplit(i, '_')[[1]][1])
  n <- as.integer(strsplit(i, '_')[[1]][2])
  mymvd <- copula::mvdc(normalCopula(phi), margins = "exp", 
                        paramMargins = list(rate=1), marginsIdentical = TRUE)
  
  ## numerical integration to get 
  EXY <- pracma::dblquad(function(x, y) x * y * 
                           copula::dMvdc(cbind(x, y), mymvd), 0, 20, 0, 20)
  ## approximate true rho
  rho <- (EXY - 1) / 1
  cov <- mychk(local_exp_results[[i]], c(1, 1, rho))
  types <- c('stdCI', 'stuCI', 'pctCI', 'ctrCI', 'bcCI', 'bcaCI', 'propCI')
  CI <- rep(types, each = length(cov) / length(types))
  parameters <- c('mu', 'sigma', 'rho')
  target <- rep(parameters, length(cov) / length(parameters))
  LB <- sapply(cov, function(i) prop.test(i*nrep, nrep)$conf.int[1])
  UB <- sapply(cov, function(i) prop.test(i*nrep, nrep)$conf.int[2])
  new_rows <- data.frame(phi = rep(phi, length(cov)), n = rep(n, length(cov)), CI, target, cov, LB, UB)
  df <- rbind(df, new_rows)
}

t <- 'mu'
exp_mu <- df[(df$target == t),]
write.csv(exp_mu,"exp_mu.csv", row.names = FALSE)

t <- 'sigma'
exp_sigma <- df[(df$target == t),]
write.csv(exp_sigma,"exp_sigma.csv", row.names = FALSE)

t <- 'rho'
exp_rho <- df[(df$target == t),]
write.csv(exp_rho,"exp_rho.csv", row.names = FALSE)
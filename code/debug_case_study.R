resample = function(data, B) {
  N = length(data)
  result = numeric(B)
  
  # repeat this whole process B times
  for (b in 1:B) {
    
    # make an object to hold the resampled indices
    indx = integer(N)
    
    # resample one data point at a time
    for (i in 1:N) {
      indx[[i]] = sample(1:N, size=1)
    }
    
    # calculate the mean of this resampled data
    result[[b]] = mean(data[indx])
  }
  
  # return all of the mean resamples
  result
}


bootstrap = function(data, ..., B=1000) {
  # get the names of grouping factors
  grouping_factors = sapply(list(...), unlist)
  
  # identify all possible combinations of grouping factors
  grouping_levels =
    sapply(grouping_factors,
           function(grp) unique(data[[grp]]) |> as.character(),
           simplify = FALSE) |>
    setNames(grouping_factors)
  
  # cross the grouping levels to get all combinations
  groups = split(data, data[,grouping_factors])
  
  # create an empty data.frame to hold the results
  col_names = names(groups)
  result = replicate(length(groups), numeric(B), simplify=FALSE) |>
    as.data.frame(col.names = col_names)
  
  # bootstrap the mean of mass for each group
  for (i in 1:length(groups)) {
    # get the subset of data that is relevant to this group
    group = groups[[i]]
    
    # calculate the mean of a bunch of bootstrap resamples
    result[[i]] = resample(group$body_mass_g, B=B)
  }

  # return the result
  result
}


make_bootstrap_plots = function(data, ..., B=1000) {
  # get the resampled mean masses
  my_resamples = bootstrap(data, B=B, ...) |>
    stack()
  
  # get the names of the grouping factors
  my_groups = list(...)
  my_grouping_factors = lapply(my_groups, function(x) data[[x]])
  
  # combine the group names into a label
  my_label = paste("Penguins by", paste(my_groups, collapse="/"))
  
  # make a boxplot of the group means
  ggplot(my_resamples) +
    aes(x=ind, y=values) +
    geom_boxplot() +
    xlab(my_label) +
    ylab("Average penguin mass (grams)") +
    ggtitle("Value and uncertainty of average penguin mass",
            subtitle="Red dots are measured penguin masses") + 
    # theme(axis.text.x = element_text(angle = 70, vjust = 0.5, hjust = 0.4)) +
    geom_point(
      data=data,
      mapping=aes(x=interaction(my_grouping_factors), y=body_mass_g),
      alpha=0.2,
      color='red',
      shape=16)
}

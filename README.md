## Parietal Inactivation Analyses
# Eshed Margalit, Moore Lab

Listing of available analyses:

1. trial_stats_wrapper: for each dataset provided, compares selected statistics for each trial (e.g., fixation_length, pupil size)

2. m_seq_wrapper: for each dataset (or for all datasets combined if 'aggregate' is used as mode), plots the m_sequence (saccade duration vs. pixels spanned)

3. compare_centered_raw: for a given dataset and trial, compare the raw and cetnered fixation trajectories

4. temperature_histrogram: plots a 2d histogram of the two temperatures in a given dataset

====================

Useful utilities:

From File Exchange:

1. hist2d and Plot2dHist

2. shadedErrorBar

Custom:

1. make_saliency_maps: rough file to loop over all images and compute GBVS maps

2. load_experiments: for all (or a subset of) experiments, create a DataSet object from each. This should probably be your starting point for every analysis.

3. aggregate_trials: given some group of datasets, smush all trials of a given type together

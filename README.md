## Parietal Inactivation Analyses
# Eshed Margalit, Moore Lab

Listing of available analyses:

1. trial_stats_wrapper: for each dataset provided, compares selected statistics for each trial (e.g., fixation_length, pupil size)

2. trial_stats_wrapper_global_position: Same as (1), but 'left' and 'right' correspond to global left/right, where left corresponds to all pixels on the left half of the image.

3. m_seq_wrapper: for each dataset (or for all datasets combined if 'aggregate' is used as mode), plots the m_sequence (saccade duration vs. pixels spanned)

4. sal_vs_fix_wrapper: plots salience against fixation number, optionally does permutation testing for control/cooling differences

5. compare_centered_raw: for a given dataset and trial, compare the raw and cetnered fixation trajectories

6. temperature_histrogram: plots a 2d histogram of the two temperatures in a given dataset

7. compare_auc: compare area-under-ROC-curve for different salience map formulations

8. saccade_magnitude_distribution: does a histogram binning of saccade magnitudes for a subset of trials

====================

Useful utilities:

From File Exchange:

1. hist2d and Plot2dHist

2. shadedErrorBar

Custom:

1. make_saliency_maps: rough file to loop over all images and compute GBVS maps

2. load_experiments: for all (or a subset of) experiments, create a DataSet object from each. This should probably be your starting point for every analysis.

3. aggregate_trials: given some group of datasets, smush all trials of a given type together

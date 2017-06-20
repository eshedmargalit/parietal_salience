function center_of_mass_global_salience_comparison(control_trials, inactivation_trials, salmethod)
% CENTER_OF_MASS_GLOBAL_SALIENCE_COMPARISON compares global salience after 
%	splitting trials by center of mass along x axis
% Inputs
%	control_trials - cell vector of control Trial objects
%	inactivation_trials - cell vector of inactivation Trial objects
%	salmethod - 'gbvs' or 'ik' 
%
% Outputs
%	None
%
% Eshed Margalit
% June 20, 2017

	%% Pre-processing
	nc = numel(control_trials);
	ni = numel(inactivation_trials);

	% Control
	control_leftcom = {}; lidx = 1;
	control_rightcom = {}; ridx = 1;

	for i = 1:ni
		trial = control_trials{i}; 
		if trial.center_of_mass < (1920/2)
			control_leftcom{lidx} = trial;
			lidx = lidx + 1;
		else
			control_rightcom{ridx} = trial;
			ridx = ridx + 1;
		end
	end

	% Inactivation
	inactivation_leftcom = {}; lidx = 1;
	inactivation_rightcom = {}; ridx = 1;

	for i = 1:ni
		trial = inactivation_trials{i}; 
		if trial.center_of_mass < (1920/2)
			inactivation_leftcom{lidx} = trial;
			lidx = lidx + 1;
		else
			inactivation_rightcom{ridx} = trial;
			ridx = ridx + 1;
		end
	end


	n_ct_left = numel(control_leftcom);
	n_ct_right = numel(control_rightcom);
	n_it_left = numel(inactivation_leftcom);
	n_it_right = numel(inactivation_rightcom);

	ct_left_leftpref = zeros(n_ct_left,1);
	ct_right_leftpref = zeros(n_ct_right,1);
	it_left_leftpref = zeros(n_it_left,1);
	it_right_leftpref = zeros(n_it_right,1);

	for i = 1:n_ct_left
		t = control_leftcom{i};
		ct_left_leftpref(i) = t.average_salience.(salmethod).left_preference_percent_chance;
	end

	for i = 1:n_ct_right
		t = control_rightcom{i};
		ct_right_leftpref(i) = t.average_salience.(salmethod).left_preference_percent_chance;
	end

	for i = 1:n_it_left
		t = inactivation_leftcom{i};
		it_left_leftpref(i) = t.average_salience.(salmethod).left_preference_percent_chance;
	end

	for i = 1:n_it_right
		t = inactivation_rightcom{i};
		it_right_leftpref(i) = t.average_salience.(salmethod).left_preference_percent_chance;
	end

	raw = {ct_left_leftpref, ct_right_leftpref, it_left_leftpref, it_right_leftpref};
	[mns, sems] = quickstats(raw);
	strs = {'COM Left - Control','COM Right - Control', 'COM Left - Inactivation', 'COM Right - Inactivation'};
	plotit(mns,sems,strs,raw);

end

function plotit(means, sems, strs, raw)
	% Open figure
	figure;
	hold on;

	n = length(means);

	flag = 1;
	for i = 1:n 
		mn = means(i);
		sem = sems(i);

		[h,p,ci,stats] = ttest(raw{i});
		if (p < .05)
			fprintf('%s is significantly different from 0', strs{i});
			flag = 0;
		end


		% Plot bar with SEM
		bar(i, mn, 0.5,'LineWidth',1.5);
		errorbar(i, mn, sem, 'k.','LineWidth',1.5);

		ylabel('Left Salience Preference');
	end

	if flag
		disp('None of these are significantly different from 0. Sorry.');
	end

	% Set bar titles 
	set(gca,'XTick',1:n);
	set(gca,'XTickLabels',strs);

	% Set appropriate x/y limits
	lower_lim = min(means) * 2.55;
	upper_lim = max(means) * 3.15;

	ylim([lower_lim, upper_lim]);
	xlim([.52, n+.52]);

end

function [mns, sems] = quickstats(trialvec)

	n = numel(trialvec);
	mns = zeros(n,1);
	sems = zeros(n,1);

	for i = 1:n
		trials = trialvec{i};
		n_t = length(trials);

		mns(i) = mean(trials);
		sems(i) = std(trials) ./ sqrt(n_t);
	end
end

% Eshed Margalit
% April 24, 2017
classdef Trial < handle

	properties
		%% trivial props
		temp1
		temp2
		fixation_on
		fixation_in
		image_on
		image_end
		figure_number
		fname % the name of the 1920x1080 image
		condition % either 'control' or 'inactivation'
		im_dir % the folder in which images are kept
		exp_num

		%% derived props
		% fixations
		fixations
		n_fixations
		baseline_fixation % time after fixation onset and before image onset
		center_of_mass % mean of fixation x positions


		gbvs_chance_salience
		ik_chance_salience
		sam_chance_salience
		average_salience

		% saccades
		saccades
		n_saccades

	end

	methods
		%% Constructor
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		function obj = Trial(trial_info, fixation_table, blink_tbl,...
			im_dir, exp_num)

			% trivial initialization
			trivial_init(obj, trial_info);
			obj.im_dir = im_dir;
			obj.exp_num = exp_num;

			% classify trial type based on maximum of two temps
			assign_condition(obj);

			% store image filename
			obj.fname = sprintf('%s/A%d.jpg',obj.im_dir,...
				obj.figure_number);

			%% Parse fixation table
			parse_fixation_table(obj,fixation_table,blink_tbl);	
			compute_saccades(obj);

			obj.n_fixations = length(obj.fixations);
			obj.n_saccades = obj.n_fixations - 1;

			% assign saccades to fixations
			assign_fixations_saccades(obj);
		end

		%% For relevant fields, compute basic statistics 
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		function stats = get_stats(self, direction, order, salmethod, salscaling)
			% direction can be '', 'left', or 'right'
			% order can be 'next' or 'prev'

			fixations = self.get_fixations(direction, order);

			stats = struct();
			stats.n_fixations = length(fixations);

			durations = zeros(stats.n_fixations,1);
			pupil_sizes = zeros(stats.n_fixations,1);
			saliences = zeros(stats.n_fixations,1);
			xs = zeros(stats.n_fixations,1);

			for i = 1:stats.n_fixations
				durations(i) = fixations{i}.duration;
				pupil_sizes(i) = fixations{i}.pupil;
				saliences(i) = fixations{i}.get_salience(salmethod,salscaling);
				xs(i) = fixations{i}.cx;
			end

			% Fixation durations
			stats.fixation_durations = struct();
			stats.fixation_durations.mn = mean(durations);
			stats.fixation_durations.sd = std(durations);
			stats.fixation_durations.sem = stats.fixation_durations.sd...
				./ sqrt(stats.n_fixations);

			% Pupil sizes
			stats.pupil_sizes = struct();
			stats.pupil_sizes.mn = mean(pupil_sizes);
			stats.pupil_sizes.sd = std(pupil_sizes);
			stats.pupil_sizes.sem = stats.pupil_sizes.sd...
				./ sqrt(stats.n_fixations);

			% Saliences
			stats.saliences = struct();
			stats.saliences.mn = mean(saliences);
			stats.saliences.sd = std(saliences);
			stats.saliences.sem = stats.saliences.sd...
				./ sqrt(stats.n_fixations);

			% Mean Xs
			stats.xs = struct();
			stats.xs.mn = mean(xs);
			stats.xs.sd = std(xs);
			stats.xs.sem = stats.xs.sd...
				./ sqrt(stats.n_fixations);

			% For ease of access, store means separately
			stats.fixation_durations_mn = stats.fixation_durations.mn;
			stats.pupil_sizes_mn = stats.pupil_sizes.mn;
			stats.saliences_mn = stats.saliences.mn;
			stats.xs_mn = stats.xs.mn;

		end

		%% Retrieve fixations matching the direction provided. Filter
		%% by direction, which can be 'left', 'right', 'global_left'
		%% or 'global_right'. The 'order' argument specifies whether 
		%% fixations should be labeled by the direction of the preceding
		%% saccade ('prev') or the next saccade ('next')
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		function retval = get_fixations(obj, direction, order)

			switch order
			case 'prev'
				saccade_order = 'prev_saccade';
			case 'next'
				saccade_order = 'next_saccade';
			otherwise
				error('Please choose one of ''next'' or ''prev''');
			end

			if strcmp(direction,'') || strcmp(direction,'all')
				retval = obj.fixations;
			elseif startsWith(direction,'global')
				retval = {};
				for i = 1:obj.n_fixations
					f = obj.fixations{i};
					if isempty(f.(saccade_order))
						continue;
					end

					pos = split(direction,'_');
					pos = pos{2};
					if strcmp(pos, f.(saccade_order).global_position)
						retval = [retval; {f}];
					end
				end

			else
				retval = {};
				for i = 1:obj.n_fixations
					f = obj.fixations{i};
					if isempty(f.(saccade_order))
						continue;
					end

					if strcmp(direction, f.(saccade_order).direction)
						retval = [retval; {f}];
					end
				end
			end
		end

		%% Retrieve saccades matching the direction ('left' or 'right')
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		function retval = get_saccades(obj, varargin)
			if length(varargin) > 1
				error('Too many arguments. 1 argument expected');
			elseif length(varargin) == 0
				direction = '';
			else
				direction = varargin{1};
			end


			if strcmp(direction,'') 
				retval = obj.saccades;
			else
				retval = {};
				for i = 1:obj.n_saccades
					s = obj.saccades{i};
					if strcmp(direction, s.direction)
						retval = [retval; {s}];
					end
				end
			end
		end

		%% Creates a binary fixation map 
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		function fm = get_fixation_map(self, varargin)

			xpix = 1920;
			ypix = 1080;

			if length(varargin) > 0
				direction = varargin{1};
			else
				direction = 'all';
			end

			[xs, ys] = get_fixation_positions(...
				self.get_fixations(direction));
			xs = max(1,floor(xs));
			ys = max(1,floor(ys));

			fm = zeros(1920,1080);

			for i = 1:length(xs)
				fm(xs(i),ys(i)) = 1;
			end

		end

		%% Get the fixation density map 
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		function dm = get_density_map(self, scaled_dims, varargin)

			xpix = 1920;
			ypix = 1080;

			if length(varargin) > 0
				direction = varargin{1};
			else
				direction = 'all';
			end

			[xs, ys] = get_fixation_positions(...
				self.get_fixations(direction));

			rangey = linspace(0,ypix,scaled_dims(1));
			rangex = linspace(0,xpix,scaled_dims(2));
			downsampled = hist3([ys,xs],{rangey,rangex});
			dm = imresize(downsampled',[xpix,ypix],'lanczos2');
		end

		%% Plot the image with a salience map overlay 
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		function hm = get_heatmap(self)
			img = imread(self.fname);
			params = makeGBVSParams;
			params.levels = [2, 3, 5, 6, 7, 8, 9]; % from Xiaomo
			saliency_map = gbvs(img, params);
			hm = heatmap_overlay(img,saliency_map.master_map_resized);
		end

		%% Compute GBVS salience for each fixation -- very slow, I now
		%% load in from .jpg salmaps in parse_fixation_table
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		%function compute_fixation_salience(self)
			%img = imread(self.fname);
			%params = makeGBVSParams;
			%params.levels = [2, 3, 5, 6, 7, 8, 9]; % from Xiaomo
			%saliency_map = gbvs(img, params);

			%% assign salience to each fix
			%for f = 1:length(self.fixations)
				%x = floor(self.fixations{f}.x);
				%y = floor(self.fixations{f}.y);
				%self.fixations{f}.salience = saliency_map.master_map_resized(y,x);
			%end
		%end

		%% Given temperature at the two loops, assign the trial into 
		%% control/inactivation conditions 
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		function assign_condition(obj)
			max_temp = max(obj.temp1, obj.temp2);
			if max_temp < -30000 || max_temp > 30 
				obj.condition = 'control';
			else
				obj.condition = 'inactivation';
			end
		end

		%% Plot the image and fixations, coloring saccades by number
		%% in sequence
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		function plot_fixations(self, mode)
			
			% compute heatmap overlay
			hm = self.get_heatmap();
			figure();
			imshow(hm); hold on;
			
			fixations = self.fixations;

			colors = cool(self.n_fixations);
			for i = 1:self.n_fixations
				fix = fixations{i};
				switch mode
				case 'raw'
					fx = fix.x;
					fy = fix.y;
				case 'centered'
					fx = fix.cx;
					fy = fix.cy;
				otherwise
					error('Mode must be ''centered'' or ''raw''');
				end

				if i ==1
					plot([1920/2, fx], [1080/2, fy],...
						'Color',colors(i,:),...
						'LineWidth',3);
				else
					plot([prev.x, fx], [prev.y, fy],...
						'Color',colors(i,:),...
						'LineWidth',3);
				end
				prev.x = fx;
				prev.y = fy;
			end
		end

		%% Plot the image and fixations, coloring saccades by left/right 
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		function lr_test(obj)
			
			% compute heatmap overlay
			hm = obj.get_heatmap();
			figure();
			imshow(hm); hold on;
			
			saccades = obj.saccades;

			for i = 1:obj.n_saccades
				sac = saccades{i};

				color = 'r';
				if strcmp(sac.direction, 'left')
					color = 'b';
				end
				
				plot([sac.xs(1), sac.xs(2)],...
					[sac.ys(1), sac.ys(2)],...
					'Color',color,...
					'LineWidth',3);
			end
		end

		%% Shallow initialization: copy values from the provided
		%% trial information 
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		function trivial_init(obj, trial_info)
			obj.temp1 = trial_info.Temperature1;
			obj.temp2 = trial_info.Temperature2;
			obj.fixation_on = trial_info.FixationOn;
			obj.fixation_in = trial_info.FixationIn;
			obj.figure_number = trial_info.FigureNum;
			obj.image_on = trial_info.ImageOn;
			obj.image_end = trial_info.ImageEnd;
		end

		%% After Saccade and Fixation objects have been made, add 
		%% next/prev pointers 
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		function assign_fixations_saccades(obj)
			cum_dist = 0;
			for fix_idx = 1:obj.n_fixations

				if fix_idx == 1 % first
					obj.fixations{fix_idx}.next_saccade = ...
						obj.saccades{fix_idx};
					obj.fixations{fix_idx}.prev_saccade = ...
						[];
					obj.fixations{fix_idx}.cumulative_distance = 0;
					cum_dist = cum_dist + obj.fixations{fix_idx}.next_saccade.distance;
				elseif fix_idx == obj.n_fixations % last
					obj.fixations{fix_idx}.next_saccade = ...
						[];
					obj.fixations{fix_idx}.prev_saccade = ...
						obj.saccades{fix_idx-1};	
					obj.fixations{fix_idx}.cumulative_distance = cum_dist;
				else %middle
					obj.fixations{fix_idx}.next_saccade = ...
						obj.saccades{fix_idx};
					obj.fixations{fix_idx}.prev_saccade = ...
						obj.saccades{fix_idx-1};	
					obj.fixations{fix_idx}.cumulative_distance = cum_dist;
					cum_dist = cum_dist + obj.fixations{fix_idx}.next_saccade.distance;
				end
			end
		end

		%% set average_salience.(method).left, average_salience.right, and average_salience.left_preference
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		function set_global_salience(obj, gbvs_chance_sal, ik_chance_sal,...
			sam_chance_sal)
			base = '~/moorelab/parietal_inactivation/data/QuitoImagesExp';
			gbvs_str = sprintf('%s%d/saliency_maps/gbvs_A%d.jpg',...
				base, obj.exp_num, obj.figure_number);
			ik_str = sprintf('%s%d/saliency_maps/ik_A%d.jpg',...
				base, obj.exp_num, obj.figure_number);
			sam_str = sprintf('%s%d/saliency_maps/sam_A%d.jpg',...
				base, obj.exp_num, obj.figure_number);

			gbvs_salmap = imread(gbvs_str)'; % transpose for (x by y)
			ik_salmap = imread(ik_str)';
			sam_salmap = imread(sam_str)';

			average_salience = struct();
			average_salience.gbvs = struct();
			average_salience.ik = struct();
			average_salience.sam = struct();

			average_salience.gbvs.left = mean2(gbvs_salmap(1:(1920/2),:));
			average_salience.gbvs.right = mean2(gbvs_salmap((1920/2):end,:));
			average_salience.gbvs.left_preference = ...
				average_salience.gbvs.left - average_salience.gbvs.right; 

			average_salience.ik.left = mean2(ik_salmap(1:(1920/2),:));
			average_salience.ik.right = mean2(ik_salmap((1920/2):end,:));
			average_salience.ik.left_preference = ...
				average_salience.ik.left - average_salience.ik.right; 

			average_salience.sam.left = mean2(sam_salmap(1:(1920/2),:));
			average_salience.sam.right = mean2(sam_salmap((1920/2):end,:));
			average_salience.sam.left_preference = ...
				average_salience.sam.left - average_salience.sam.right; 

			method_strs = {'gbvs','ik','sam'};
			chance_sals = [gbvs_chance_sal, ik_chance_sal, sam_chance_sal];

			for i =1:numel(method_strs)
				method_str = method_strs{i};
				chance = chance_sals(i);

				average_salience.(method_str).left_percent_chance = ...
					average_salience.(method_str).left / ...
					chance * 100;

				average_salience.(method_str).right_percent_chance = ...
					average_salience.(method_str).right / ...
					chance * 100;

				average_salience.(method_str).left_preference_percent_chance = ...
					average_salience.(method_str).left_preference / ...
					chance * 100;
			end

			obj.average_salience = average_salience;
		end


		%% Given the fixation table, create all the Fixation objects 
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		function parse_fixation_table(obj,fix_tbl,blink_tbl)
			% scrub any fixation within 100ms of blink
			n_fixations = size(fix_tbl,1);
			blink_on = blink_tbl(:,3);
			blink_off = blink_tbl(:,3);
			cut_early = blink_on - 100;
			cut_late = blink_off + 100;

			blink_rows = [];
			for i = 1:n_fixations
				fix = fix_tbl(i,:);
				after_cut_early = cut_early < fix.FixationStart;
				before_cut_late = cut_late > fix.FixationEnd;
				both = after_cut_early .* before_cut_late;
				if sum(both) > 0
					blink_rows = [blink_rows i];
				end
			end
			n_blinks = length(blink_rows);
			for i=1:n_blinks
				fprintf('*');
			end
			fix_tbl(blink_rows,:) = [];
			n_fixations = size(fix_tbl,1);

			% determine x0,y0: monkey's fixation point before image appears
			starts_after_fixation = fix_tbl.FixationStart >= obj.fixation_on;
			ends_before_image_onset = fix_tbl.FixationEnd <= obj.image_on;
			intersection = (starts_after_fixation .* ends_before_image_onset);
			baseline_fixation_indices = find(intersection);
			fix0 = fix_tbl(baseline_fixation_indices,:);


			% if any fixations meet the criteria after blink
			% removal, use the mean. If not, use the
			% first entry in the table 
			if size(fix0,1) == 0
				x0 = fix_tbl.XPosition(1);
				y0 = fix_tbl.YPosition(1);
			else
				x0 = mean(fix0.XPosition);
				y0 = mean(fix0.YPosition);
			end


			% Load salience map
			base = '~/moorelab/parietal_inactivation/data/QuitoImagesExp';
			gbvs_str = sprintf('%s%d/saliency_maps/gbvs_A%d.jpg',...
				base, obj.exp_num, obj.figure_number);
			ik_str = sprintf('%s%d/saliency_maps/ik_A%d.jpg',...
				base, obj.exp_num, obj.figure_number);
			sam_str = sprintf('%s%d/saliency_maps/sam_A%d.jpg',...
				base, obj.exp_num, obj.figure_number);

			salmap = imread(gbvs_str);
			ik_salmap = imread(ik_str);
			sam_salmap = imread(sam_str);

			% Keep any fixations after image onset
			start_after_image_onset = fix_tbl.FixationStart >= obj.image_on;

			% if all fixations are before image onset (?) then grab first fixation
			if all(~start_after_image_onset)
				fix_tbl = fix_tbl(1:2,:);
			else
				fix_tbl(~start_after_image_onset, :) = [];
			end

			n_fixations = size(fix_tbl,1);

			% Initialize all fixations
			fixations = cell(n_fixations,1);

			for i = 1:n_fixations
				fixations{i} = Fixation(fix_tbl(i,:),...
					x0,y0,salmap',ik_salmap',sam_salmap');
			end
			obj.fixations = fixations;

			if size(fix0,1) == 0
				obj.baseline_fixation = fix_tbl(1,:);
			else
				obj.baseline_fixation = fix0;
			end

			% compute center of mass of fixations
			xs = zeros(n_fixations,1);
			for i = 1:n_fixations
				xs(i) = fixations{i}.cx;
			end
			obj.center_of_mass = mean(xs);

		end

		%% Initialize each saccade using its surrounding fixations
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		function saccades = compute_saccades(obj)
			
			saccades = cell(length(obj.fixations)-1,1);
			for f = 2:length(obj.fixations)
				fix1 = obj.fixations{f-1};
				fix2 = obj.fixations{f};
				saccades{f-1} = Saccade(fix1,fix2);
			end
			obj.saccades = saccades;
		end

		%% For each fixation, sets the salience relative to the 
		%% experiment's chance value
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		function set_percent_chance_salience(obj, gbvs, ik, sam)
			obj.gbvs_chance_salience = gbvs; 
			obj.ik_chance_salience = ik; 
			obj.sam_chance_salience = sam;

			for f = 1:obj.n_fixations
				obj.fixations{f}.gbvs_percent_chance_salience = ...
					obj.fixations{f}.gbvs_salience / ...
					gbvs * 100;

				obj.fixations{f}.ik_percent_chance_salience = ...
					obj.fixations{f}.ik_salience / ...
					ik * 100;

				obj.fixations{f}.sam_percent_chance_salience = ...
					obj.fixations{f}.sam_salience / ...
					sam * 100;
			end
		end
	end
end

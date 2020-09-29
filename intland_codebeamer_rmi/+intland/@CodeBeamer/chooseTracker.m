function tracker = chooseTracker(cb)
    persistent projects;
	projectURI = getpref('codebeamer', 'project',     []);
	trackerURI = getpref('codebeamer', 'projTracker', []);
    
    if isempty(projects)
        projects = webread([cb.server.url '/rest/projects'], cb.server.jsonOptions());
    end

	[projectNames, project, projectValue] = getProjectNames(projects);

	if projectValue > 0
        try
            [trackers, trackerNames, tracker, trackerValue] = getTrackers(project);
        catch exception
            errmsg = getReport(exception, 'basic');
            disp(errmsg);
            
            projectURI = [];
            trackerURI = [];
            
            try
                rmpref('codebeamer', {'project', 'projTracker'});
            catch
            end
           
            projects = webread([cb.server.url '/rest/projects'], cb.server.jsonOptions());
            [projectNames, project, projectValue] = getProjectNames(projects);

            if projectValue > 0
                [trackers, trackerNames, tracker, trackerValue] = getTrackers(project);
            else
                tracker = {};
                return
            end
        end
 
        popup = dialog('Position',[400 320 500 150], 'Name', 'Select a CodeBeamer Tracker');
    
        projectLabel    = uicontrol('Parent', popup, 'Style', 'text',  'Position', [20 100  50 20], 'String', 'Project: '); %#ok<NASGU>
        projectSelector = uicontrol('Parent', popup, 'Style', 'popup', 'Position', [80 100 400 25], 'String', projectNames, 'Value', projectValue, 'Callback', @projectSelected);
 
        trackerLabel    = uicontrol('Parent', popup, 'Style', 'text',  'Position', [20 70  50 20],  'String', 'Tracker: '); %#ok<NASGU>
        trackerSelector = uicontrol('Parent', popup, 'Style', 'popup', 'Position', [80 70 400 25],  'String', trackerNames, 'Value', trackerValue, 'Callback', @trackerSelected);
       
        uicontrol('Parent', popup, 'Position', [ 20 20 70 25], 'String', 'OK',          'Callback', @okClicked );
        uicontrol('Parent', popup, 'Position', [110 20 70 25], 'String', 'Cancel',      'Callback', @cancelClicked );
        uicontrol('Parent', popup, 'Position', [320 20 70 25], 'String', 'Reload',      'Callback', @reloadProjects );
        uicontrol('Parent', popup, 'Position', [410 20 70 25], 'String', 'Settings...', 'Callback', @editSettings );
      
        % Wait for popup to close before running to completion
        uiwait(popup);
    else
        errordlg(['The user "' cb.server.username '" does not have access to any projects on the CodeBeamer server at "' cb.server.url '"!'], 'No accessible projects');
        tracker = {};
	end

	function [projectNames, project, projectValue] = getProjectNames(projects)
        projectNames = {};
        project      = {};
        projectValue = 0;

        if ~isempty(projects)
            size = length(projects);
            projectNames = cell(1, size);
            projectValue = 1;
      
%           disp(['getProjects() found ' int2str(size) ' projects']);

            if iscell(projects)
                if isempty(projectURI)
                    projectURI = projects{1}.uri;
                end

                for index = 1:size
                    project = projects{index};
                    projectNames{index} = project.name;

                    if strcmp(project.uri, projectURI)
                        projectValue = index;
                    end
                end
      
                project = projects{projectValue};
            else
                if isempty(projectURI)
                    projectURI = projects(1).uri;
                end

                for index = 1:size
                    project = projects(index);
                    projectNames{index} = project.name;

                    if strcmp(project.uri, projectURI)
                        projectValue = index;
                    end
                end
     
                project = projects(projectValue);
            end

            projectURI = project.uri;

        end
    end

    function csv = getTrackerTypes()
        csv = [];
        
        trackerTypes = cb.itemTypes;
        if ~isempty(trackerTypes)
            csv = int2str(trackerTypes(1));
            
            for index = 2:length(trackerTypes)
                csv = [csv ',' int2str(trackerTypes(index))]; %#ok<AGROW>
            end
        end
    end
 
	function [trackers, trackerNames, tracker, trackerValue] = getTrackers(project)
        trackers     = webread([cb.server.url '/rest' project.uri '/trackers?kind=Category,Tracker&type=' getTrackerTypes()], cb.server.jsonOptions);
        trackerNames = {};
        tracker      = {};
        trackerValue = 1;

        if ~isempty(trackers)
            size = length(trackers);
            trackerNames = cell(1, size);
      
%           disp(['getTrackers(' project.uri ') found ' int2str(size) ' trackers']);

            if isempty(trackerURI)
                trackerURI = containers.Map;
            end

            if iscell(trackers)
                if ~isKey(trackerURI, project.uri)
                    trackerURI(project.uri) = trackers{1}.uri;
                end

                for index = 1:size
                    tracker = trackers{index};
                    trackerNames{index} = tracker.name;

                    if strcmp(tracker.uri, trackerURI(project.uri))
                        trackerValue = index;
                    end
                end

                tracker = trackers{trackerValue};
            else
                [~, order] = sort({trackers.name});
                trackers = trackers(order);
       
                if ~isKey(trackerURI, project.uri)
                    trackerURI(project.uri) = trackers(1).uri;
                end

                for index = 1:size
                    tracker = trackers(index);
                    trackerNames{index} = tracker.name;

                    if strcmp(tracker.uri, trackerURI(project.uri))
                        trackerValue = index;
                    end
                end

                tracker = trackers(trackerValue);
            end

            trackerURI(project.uri) = tracker.uri;
        else
            trackerNames{1} = '-- No suitable trackers --';
        end
    end
 
	function reloadProjects(~, ~)
        projects = webread([cb.server.url '/rest/projects'], cb.server.jsonOptions());
        
        [projectNames, project, projectValue] = getProjectNames(projects);

        if projectValue > 0
            [trackers, trackerNames, tracker, trackerValue] = getTrackers(project);
            
            set(projectSelector, 'String', projectNames);
            set(projectSelector, 'Value',  projectValue);

            set(trackerSelector, 'String', trackerNames);
            set(trackerSelector, 'Value',  trackerValue);
        else
            errordlg(['The user "' cb.server.username '" does not have access to any projects on the CodeBeamer server at "' cb.server.url '"!'], 'No accessible projects');
            tracker = {};
        end
    end

    function editSettings(~, ~)
        if cb.editSettings
            reloadProjects([], []);
        end
    end

	function projectSelected(selector, ~)
        projectValue = get(selector, 'Value');

        if iscell(projects)
            project = projects{projectValue};
        else
            project = projects(projectValue);
        end

        projectURI = project.uri;

        [trackers, trackerNames, tracker, trackerValue] = getTrackers(project);
 
        set(trackerSelector, 'String', trackerNames);
        set(trackerSelector, 'Value',  trackerValue);
    end

	function trackerSelected(selector, ~)
        trackerValue = get(selector, 'Value');
        if trackerValue <= length(trackers)
            if iscell(trackers)
                tracker = trackers{trackerValue};
            else
                tracker = trackers(trackerValue);
            end

            trackerURI(projectURI) = tracker.uri;
        else
            tracker = {};
        end
    end

	function okClicked(~, ~) 
        if ~isempty(tracker)
            tracker.project = project;
        end
        
        setpref('codebeamer', 'project',     projectURI);
        setpref('codebeamer', 'projTracker', trackerURI);
 
        delete(gcf);
    end

	function cancelClicked(~, ~) 
        tracker = {};
        delete(gcf);
	end

end

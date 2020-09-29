function item = chooseTrackerItem(cb)
	trackers    = getpref('codebeamer', 'trackers',    []);
	trackerURI  = getpref('codebeamer', 'tracker',     []);
	trackerItem = getpref('codebeamer', 'trackerItem', []);

    [trackerNames, tracker, trackerValue] = getTrackerNames(trackers);
    
    try
        [items, itemNames, item, itemValue] = getTrackerItems();
    catch exception
        errmsg = getReport(exception, 'basic');
        disp(errmsg);
        
        trackers = [];
        trackerURI = [];
        trackerItem = [];
        
        try
            rmpref('codebeamer', {'trackers', 'tracker', 'trackerItem'});
        catch
        end

        [trackerNames, tracker, trackerValue] = getTrackerNames(trackers);
        [items, itemNames, item, itemValue] = getTrackerItems();
    end
    
    matchingItems = [];
    itemFilter = [];

    popup = dialog('Position',[250 100 800 520], 'Name', 'Select a CodeBeamer Tracker Item');
    
    trackerLabel    = uicontrol('Parent', popup, 'Style', 'text',  'Position', [ 20 475  70 20],  'String', 'Tracker: '); %#ok<NASGU>
    trackerSelector = uicontrol('Parent', popup, 'Style', 'popup', 'Position', [100 472 560 25],  'String', trackerNames, 'Value', trackerValue, 'Callback', @trackerSelected);
    chooseButton    = uicontrol('Parent', popup, 'Position', [680 475 70 25], 'String', 'Choose...', 'Callback', @addTracker ); %#ok<NASGU>

    itemsLabel      = uicontrol('Parent', popup, 'Style', 'text',    'Position', [ 20 450  70 20], 'String', 'Items: '); %#ok<NASGU>
    itemsListBox    = uicontrol('Parent', popup, 'Style', 'listbox', 'Position', [100 70 560 400], 'String', itemNames, 'Value', itemValue, 'Callback', @itemSelected);
    filterLabel     = uicontrol('Parent', popup, 'Style', 'text',    'Position', [660 435 70 25],  'String', 'Filter: '); %#ok<NASGU>
    itemsFilter     = uicontrol('Parent', popup, 'Style', 'edit',    'Position', [680 420 100 25], 'HorizontalAlignment', 'Left', 'Callback', @setItemFilter ); %#ok<NASGU>
    noMatch         = uicontrol('Parent', popup, 'Style', 'text',    'Position', [680 390 70 25],  'String', 'No match!', 'ForegroundColor', 'red', 'Visible', 'off');
  
    uicontrol('Parent', popup, 'Position', [ 30 20 70 25], 'String', 'OK',     'Callback', @okClicked );
    uicontrol('Parent', popup, 'Position', [120 20 70 25], 'String', 'Cancel', 'Callback', @cancelClicked );

    % Wait for popup to close before running to completion
    uiwait(popup);

   	function [trackerNames, tracker, trackerValue] = getTrackerNames(trackers)
        trackerNames = {};
        tracker      = {};
        trackerValue = 1;

        if ~isempty(trackers)
            size = length(trackers);
            trackerNames = cell(1, size);
      
            if isempty(trackerURI)
                trackerURI = trackers{1}.uri;
            end

            for index = 1:size
                tracker = trackers{index};
                trackerNames{index} = [tracker.project.name ' / ' tracker.name ' (' tracker.keyName ')'];

                if strcmp(tracker.uri, trackerURI)
                    trackerValue = index;
                end
            end

            tracker = trackers{trackerValue};
        else
            trackerNames{1} = '-- Please choose --';
        end
    end

    function tracker = addTracker(~, ~)
        tracker = chooseTracker(cb);
        if ~isempty(tracker)
            trackerURI = tracker.uri;
            changed = false;
            
            if isempty(trackers)
                trackers = {tracker};
                trackerValue = 1;
                changed = true;
            else
                size = length(trackers);
                trackerValue = 0;
                
                for index = 1:size
                    if strcmp(trackers{index}.uri, trackerURI)
                        trackerValue = index;
                        break;
                    end
                end
                
                if trackerValue == 0
                    trackerValue = size + 1;
                    trackers{trackerValue} = tracker;
                    changed = true;
                end
            end
            
            if changed
                setpref('codebeamer', 'trackers', trackers);

                [trackerNames, tracker, trackerValue] = getTrackerNames(trackers);

                set(trackerSelector, 'String', trackerNames);
                set(trackerSelector, 'Value',  trackerValue);
                
                trackerSelected(trackerSelector, []);
            end
        end
    end

	function trackerSelected(selector, ~)
        trackerValue = get(selector, 'Value');
        if trackerValue <= length(trackers)
            tracker = trackers{trackerValue};
            trackerURI = tracker.uri;
            items = getTrackerItems();
            
            setpref('codebeamer', 'tracker', trackerURI);

            showFilteredItems();
        end
    end

    function [items, itemNames, item, itemValue] = getTrackerItems()
    	showParagraph = cb.showParagraph;
    
        if isempty(tracker)
            items = [];
        else
            if showParagraph
                paragraph = '&paragraph=true';
            else
                paragraph = '';
            end
            
            items = webread([cb.server.url '/rest' tracker.uri '/outline?flat=true' paragraph], cb.server.jsonOptions);
        end
        
        if nargout > 1
            [itemNames, item, itemValue] = getItemNames(items);
        end
    end
        
    function [itemNames, item, itemValue] = getItemNames(items)
        itemNames = {};
        item      = [];
        itemValue = 1;

        if isempty(items)
            itemNames{1} = '-- No items --';
        else
            size = length(items);
            itemNames = cell(1, size);
            
            if isempty(trackerItem)
                trackerItem = containers.Map;
            end
            
            showId = cb.showItemId;
            showParagraph = cb.showParagraph;

            if iscell(items)
                if ~isKey(trackerItem, trackerURI)
                    itemId = items{1}.id;
                    trackerItem(trackerURI) = itemId;
                else
                    itemId = trackerItem(trackerURI);
                end

                for index = 1:size
                    item = items{index};
                    itemNames{index} = intland.CodeBeamer.getItemLabel(item, showId, showParagraph);
                    
                    if item.id == itemId
                        itemValue = index;
                    end
                end
                
                item = items{itemValue};
            else
                if ~isKey(trackerItem, trackerURI)
                    itemId = items(1).id;
                    trackerItem(trackerURI) = itemId;
                else
                    itemId = trackerItem(trackerURI);
                end

                for index = 1:size
                    item = items(index);
                    itemNames{index} = intland.CodeBeamer.getItemLabel(item, showId, showParagraph);
                    
                    if item.id == itemId
                        itemValue = index;
                    end
                end
                
                item = items(itemValue);
            end
        end
    end

    function setItemFilter(filter, ~)
        itemFilter = get(filter, 'String');
        showFilteredItems();
    end

    function showFilteredItems()
        notFound = 'off';
        
        matchingItems = findItemsMatchingItemFilter();
        if ~isempty(matchingItems)
            [itemNames, item, itemValue] = getItemNames(matchingItems);
        else
            [itemNames, item, itemValue] = getItemNames(items);
            
            if ~isempty(itemFilter)
                notFound = 'on';
            end
        end

        set(itemsListBox, 'String', itemNames);
        set(itemsListBox, 'Value',  itemValue);
        set(noMatch, 'Visible', notFound);
    end

    function matchingItems = findItemsMatchingItemFilter()
        matchingItems = {};
        
        if ~isempty(itemFilter) && ~isempty(items)
            found = 0;
            size = length(items);

            if iscell(items)
                for index = 1:size
                    check = items{index};
                    if itemMatches(check)
                        found = found + 1;
                        matchingItems{found} = check; %#ok<AGROW>
                    end
                end
            else
                for index = 1:size
                    check = items(index);
                    if itemMatches(check)
                        found = found + 1;
                        matchingItems{found} = check; %#ok<AGROW>
                    end
                end
            end
        end
    end

    function matches = itemMatches(item)
        matches = ~isempty(strfind(item.name, itemFilter));
        if ~matches
            matches = ~isempty(strfind(int2str(item.id), itemFilter));
            if ~matches
                try
                    matches = ~isempty(strfind(item.chapter, itemFilter));
                catch
                end
            end
        end
    end

	function itemSelected(selector, ~)
        itemValue = get(selector, 'Value');
        
        if ~isempty(matchingItems)
            if itemValue <= length(matchingItems)
                item = matchingItems{itemValue};
            else
                item = [];
            end
        elseif itemValue <= length(items)
            if iscell(items)
                item = items{itemValue};
            else
                item = items(itemValue);
            end
        else
            item = [];
        end
    end

	function okClicked(~, ~) 
        if ~isempty(item)
            item.tracker = tracker;
            
            trackerItem(trackerURI) = item.id;
            setpref('codebeamer', 'trackerItem', trackerItem);
        end
        delete(gcf);
    end

	function cancelClicked(~, ~) 
        item = [];
        delete(gcf);
	end

end


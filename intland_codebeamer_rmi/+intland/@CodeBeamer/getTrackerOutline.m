function [itemName, itemDepth, itemURI] = getTrackerOutline(cb, trackerURI, depth)
	if nargin < 3
        depth = 99;
    end

    items     = webread([cb.server.url '/rest' trackerURI '/outline?flat=true&depth=' int2str(depth)], cb.server.jsonOptions);
	itemName  = {};
	itemDepth = [];
	itemURI   = {};

	if ~isempty(items)
        size = length(items);
        
        itemName  = cell(1, size);
        itemDepth = zeros(1, size);
        itemURI   = cell(1, size);
        
        if iscell(items)
            for index = 1:size
                item = items{index};
                itemName{index} = item.name;
                itemDepth(index) = item.depth;
                itemURI{index} = ['#' int2str(item.id)];
           end
        else
            for index = 1:size
                item = items(index);
                itemName{index} = item.name;
                itemDepth(index) = item.depth;
                itemURI{index} = ['#' int2str(item.id)];
            end
        end
	end
end
 

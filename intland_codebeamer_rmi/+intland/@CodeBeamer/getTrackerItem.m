function item = getTrackerItem(cb, itemIdOrURI)
    persistent lastItem;
    
    itemURI = [];
    if ischar(itemIdOrURI) && strncmp(itemIdOrURI, '/item/', 6)
        itemURI = itemIdOrURI;
    elseif isnumeric(itemIdOrURI)
        itemURI = ['/item/' int2str(itemIdOrURI)];
    end
    
    if isempty(itemURI)
        item = [];
    elseif ~isempty(lastItem) && strcmp(lastItem.uri, itemURI)
        item = lastItem;
    else 
        item = webread([cb.server.url '/rest' itemURI], cb.server.jsonOptions);
        if ~isempty(item)
            lastItem = item;
        end
    end;

end


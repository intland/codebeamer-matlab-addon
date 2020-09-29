function tracker = getTracker(cb, uri)
    persistent lastTracker;
    
    if ~isempty(lastTracker) && strcmp(lastTracker.uri, uri)
        tracker = lastTracker;
    elseif strncmp(uri, '/tracker/', 9) || strncmp(uri, '/category/', 10)
        tracker = webread([cb.server.url '/rest' uri], cb.server.jsonOptions);
        if ~isempty(tracker)
            lastTracker = tracker;
        end
    else
        tracker = [];
    end;
end


classdef CodeBeamer
	properties(Constant)
        server = intland.RemoteConnection.preferred('codebeamer');
    end
   
	properties(Dependent)
        itemTypes;
        showItemId;
        showParagraph;
	end
   
	methods
        function itemTypes = get.itemTypes(~)
            itemTypes = getpref('codebeamer', 'itemTypes', [5, 102, 104, 105]);
        end
        
        function showItemId = get.showItemId(~)
            showItemId = getpref('codebeamer', 'showItemId', false);
        end
        
        function showParagraph = get.showParagraph(~)
            showParagraph = getpref('codebeamer', 'showParagraph', false);
        end

        ok = editSettings(cb);
        tracker = chooseTracker(cb);
        tracker = getTracker(cb, uri);
        [itemLabel, itemDepth, itemURI] = getTrackerOutline(cb, trackerURI, depth);
        item = chooseTrackerItem(cb);
        item = getTrackerItem(cb, id);
        description = getDescription(cb, item, format);
        comment = createComment(cb, itemIdOrURI, description, format);
        association = createAssociation(cb, item, url, description);
    end
   
    methods (Static, Access = protected)
        label = getItemLabel(item, showId, showParagraph);
    end
    
	methods (Static)
        setup(cm);
	end

end

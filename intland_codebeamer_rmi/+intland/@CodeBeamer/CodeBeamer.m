% BSD 3-Clause License
% 
% Copyright 2020 Intland Software GmbH
% All rights reserved.
% 
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions are met:
% 
% 1. Redistributions of source code must retain the above copyright notice, this
%    list of conditions and the following disclaimer.
% 
% 2. Redistributions in binary form must reproduce the above copyright notice,
%    this list of conditions and the following disclaimer in the documentation
%    and/or other materials provided with the distribution.
% 
% 3. Neither the name of the copyright holder nor the names of its
%    contributors may be used to endorse or promote products derived from
%    this software without specific prior written permission.

% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
% DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
% FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
% DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
% SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
% CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
% OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
% OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

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

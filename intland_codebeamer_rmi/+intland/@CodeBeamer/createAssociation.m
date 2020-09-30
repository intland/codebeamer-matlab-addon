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

function association = createAssociation(cb, item, url, description)
    association = [];
    
    if ~(isempty(item) || isempty(url))
        existing = webread([cb.server.url '/rest/item/' int2str(item.id) '/associations'], cb.server.jsonOptions);
        if ~isempty(existing)
            size = length(existing);
            
            if iscell(existing)
                for index = 1:size
                    association = existing{index};
                    if strcmp(association.url, url)
                        return;
                    end
                end
            else
                for index = 1:size
                    association = existing(index);
                    if strcmp(association.url, url)
                        return;
                    end
               end
            end
        end

        data = struct('from', sprintf('/item/%d', item.id), ...
                      'type', '/association/type/4', ...  %related
                      'url', url, ...
                      'description', description, ...
                      'descFormat', 'Text');
                  

        association = webwrite([cb.server.url '/rest/association'], data, cb.server.jsonOptions);
    end
end


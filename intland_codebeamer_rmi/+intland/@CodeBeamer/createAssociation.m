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


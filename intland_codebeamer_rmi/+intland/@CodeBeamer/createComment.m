function comment = createComment(cb, itemIdOrURI, description, format)
    comment = [];
    
    if nargin < 4
        format = 'Wiki';
    end
   
    if ~isempty(description)
        item = cb.getTrackerItem(itemIdOrURI);
        if ~isempty(item)
            try
                if ~isempty(item.comments)
                    size = length(item.comments);
                    
                    if iscell(item.comments)
                        for index = 1:size
                            comment = item.comments{index};
                            if strmcp(comment.comment, description)
                                return;
                            end
                        end
                    else
                        for index = 1:size
                            comment = item.comments(index);
                            if strmcp(comment.comment, description)
                                return;
                            end
                        end
                    end
                end
            catch
            end
            
            data = struct('comment', description, 'commentFormat', format);

            comment = webwrite([cb.server.url '/rest' item.uri '/comment'], data, cb.server.jsonOptions);
        end
    end

end


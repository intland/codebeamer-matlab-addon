function description = getDescription(cb, item, format)
    description = '';
    
	if ~isempty(item)
        try 
            description = item.description;
        catch 
        end
            
        if ~isempty(description) && ~strcmp(description, '--')
            if nargin >= 3 && strcmpi(format, 'Html') && strcmpi(item.descFormat, 'Wiki')
                try        
                    description = webwrite([cb.server.url '/rest/' item.uri '/wiki2html'], description, cb.server.textOptions); 
                catch exception
                    errmsg = getReport(exception, 'basic');
                    msgbox(errmsg, 'Rendering item description to HTML failed', 'error');
                    disp(errmsg);
                end
            end
        end
    end
end


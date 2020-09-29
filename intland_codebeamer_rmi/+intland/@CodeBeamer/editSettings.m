function ok = editSettings(cb)
    ok = false;
    
    popup = dialog('Position',[360 200 560 400], 'Name', 'CodeBeamer Settings');
  
    serverPanel = uipanel('Parent', popup, 'Title', 'Server Connection', 'FontWeight', 'bold', 'Units', 'pixels', 'Position', [20 260 520 120]);

    urlLabel = uicontrol('Parent', serverPanel, 'Style', 'text', 'Position', [10 70  70 20], 'String', 'Server URL: '); %#ok<NASGU>
    urlField = uicontrol('Parent', serverPanel, 'Style', 'edit', 'Position', [90 70 400 25], 'HorizontalAlignment', 'Left', 'String', cb.server.url);

    usernameLabel = uicontrol('Parent', serverPanel, 'Style', 'text', 'Position', [10 40  70 20], 'String', 'Username: '); %#ok<NASGU>
    usernameField = uicontrol('Parent', serverPanel, 'Style', 'edit', 'Position', [90 40 150 25], 'HorizontalAlignment', 'Left', 'String', cb.server.username);
 
    passwordLabel = uicontrol('Parent', serverPanel, 'Style', 'text', 'Position', [10 10  70 20],  'String', 'Password: '); %#ok<NASGU>
    
    passwordField = javacomponent('javax.swing.JPasswordField', [90 10 150 25], serverPanel);
    set(passwordField, 'text', cb.server.password);
    
    itemTypesPanel = uipanel('Parent', popup, 'Title', 'Linkable Item Types', 'FontWeight', 'bold', 'Units', 'pixels', 'Position', [20 120 520 120]);
    
    itemTypes = cb.itemTypes;
    
    typeRequirement = uicontrol('Parent', itemTypesPanel, 'Style', 'checkbox', 'Position', [ 20, 70, 140, 25], 'String', 'Requirements',    'Value', isSelected(5));
    typeRisk        = uicontrol('Parent', itemTypesPanel, 'Style', 'checkbox', 'Position', [ 20, 40, 140, 25], 'String', 'Risks',           'Value', isSelected(11));
    typeTask        = uicontrol('Parent', itemTypesPanel, 'Style', 'checkbox', 'Position', [ 20, 10, 140, 25], 'String', 'Tasks',           'Value', isSelected(6));

    typeChangeReq   = uicontrol('Parent', itemTypesPanel, 'Style', 'checkbox', 'Position', [170, 70, 140, 25], 'String', 'Change Requests', 'Value', isSelected(3));
    typeUserStory   = uicontrol('Parent', itemTypesPanel, 'Style', 'checkbox', 'Position', [170, 40, 140, 25], 'String', 'User Stories',    'Value', isSelected(10));
    typeComponent   = uicontrol('Parent', itemTypesPanel, 'Style', 'checkbox', 'Position', [170, 10, 140, 25], 'String', 'Components',      'Value', isSelected(105));

    typeUseCase     = uicontrol('Parent', itemTypesPanel, 'Style', 'checkbox', 'Position', [350, 70, 140, 25], 'String', 'Use Cases',       'Value', isSelected(104));
    typeTestCase    = uicontrol('Parent', itemTypesPanel, 'Style', 'checkbox', 'Position', [350, 40, 140, 25], 'String', 'Test Cases',      'Value', isSelected(102));

    showItemIdCheck = uicontrol('Parent', popup, 'Style', 'checkbox', 'Position', [40, 70, 200, 25], 'String', 'Show Item Ids ?', 'Value', cb.showItemId);
    showParagraphCheck = uicontrol('Parent', popup, 'Style', 'checkbox', 'Position',[190, 70, 200, 25], 'String', 'Show Paragraphs ?', 'Value', cb.showParagraph);

    uicontrol('Parent', popup, 'Position', [ 30 20 70 25], 'String', 'OK',     'Callback', @okClicked );
    uicontrol('Parent', popup, 'Position', [120 20 70 25], 'String', 'Cancel', 'Callback', @cancelClicked );
      
    % Wait for popup to close before running to completion
    uiwait(popup);
    
	function okClicked(~, ~)
        try
            opts = weboptions('Username', get(usernameField, 'String'), 'Password', get(passwordField, 'text'), 'ContentType', 'json');
            user = webread([get(urlField, 'String') '/rest/user/self'], opts);
            
            if ~isempty(user)
                cb.server.url      = get(urlField, 'String');
                cb.server.username = get(usernameField, 'String');
                cb.server.password = get(passwordField, 'text');
                
                setpref('codebeamer', 'connection', cb.server);
                setpref('codebeamer', 'showItemId', get(showItemIdCheck, 'Value'));
                setpref('codebeamer', 'showParagraph', get(showParagraphCheck, 'Value'));
                
                selectedItemTypes = [];
                numSel = 0;
                
                if get(typeRequirement, 'Value')
                    numSel = numSel + 1;
                    selectedItemTypes(numSel) = 5; %#ok<NASGU>
                end
                
                if get(typeRisk, 'Value')
                    numSel = numSel + 1;
                    selectedItemTypes(numSel) = 11; %#ok<NASGU>
                end
                
                if get(typeTask, 'Value')
                    numSel = numSel + 1;
                    selectedItemTypes(numSel) = 5; %#ok<NASGU>
                end
                
                if get(typeChangeReq, 'Value')
                    numSel = numSel + 1;
                    selectedItemTypes(numSel) = 3; %#ok<NASGU>
                end

                if get(typeUserStory, 'Value')
                    numSel = numSel + 1;
                    selectedItemTypes(numSel) = 10; %#ok<NASGU>
                end

                if get(typeComponent, 'Value')
                    numSel = numSel + 1;
                    selectedItemTypes(numSel) = 105; %#ok<NASGU>
                end
                
                if get(typeUseCase, 'Value')
                    numSel = numSel + 1;
                    selectedItemTypes(numSel) = 104; %#ok<NASGU>
                end
                
                if get(typeTestCase, 'Value')
                    numSel = numSel + 1;
                    selectedItemTypes(numSel) = 102; %#ok<NASGU>
                end
                
               setpref('codebeamer', 'itemTypes', selectedItemTypes);
            end
            
            ok = true;
            delete(gcf);
            
        catch exception
            errmsg = getReport(exception, 'basic');
            msgbox(errmsg, 'Invalid CodeBeamer connection', 'error');
            disp(errmsg);
        end
    end

	function cancelClicked(~, ~) 
        delete(gcf);
    end

    function selected = isSelected(typeId)
        selected = false;
        if ~isempty(itemTypes)
            for index = 1:length(itemTypes)
                if itemTypes(index) == typeId
                    selected = true;
                    break;
                end
            end
        end
    end

end


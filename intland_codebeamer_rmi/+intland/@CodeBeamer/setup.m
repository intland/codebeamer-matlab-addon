function setup(cm)
%SETUPCUSTOMIZATION Add custom CodeBeamer menus to Simulink
    disp('intland.CodeBeamer.setup()');
    
    cm.addCustomMenuFcn('Simulink:ToolsMenu', @getToolMenus);
    
    function menus = getToolMenus(~)
        menus = {@getCodeBeamerMenu};
    end 

    function menu = getCodeBeamerMenu(~)
        menu = sl_container_schema;
        menu.label = 'CodeBeamer';     
        menu.childrenFcns = {@getEditConnection};
    end 

    function action = getEditConnection(~)
        action = sl_action_schema;
        action.label = 'Settings...';
        action.callback = @editSettings; 
    end

    function editSettings(~)
        cb = intland.CodeBeamer;
        cb.editSettings;
    end
end


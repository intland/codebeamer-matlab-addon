function sl_customization(cm)

  %% Register custom menu function.
    intland.CodeBeamer.setup(cm);
    
    try
        rmi('unregister', 'intland_codebeamer_rmi');
    catch
    end
    
    rmi('register', 'intland_codebeamer_rmi');
    
end


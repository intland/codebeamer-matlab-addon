function label = getItemLabel(item, showId, showParagraph)
    if showId
        if showParagraph
            label = sprintf('%-10d %s%s  %s', item.id, blanks(4 * item.depth), item.chapter, item.name);
        else
            label = sprintf('%-10d %s%s', item.id, blanks(4 * item.depth), item.name);
        end
    elseif showParagraph
        label = sprintf('%s%s  %s', blanks(4 * item.depth), item.chapter, item.name);
    elseif item.depth > 0
        label = [blanks(4 * item.depth) item.name];
    else
        label = item.name;
    end
end
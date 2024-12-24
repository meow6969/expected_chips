function eval_card_chips(card, context)
    context = context or {}
    local ret = {}

    if context.repetition_only then
        local seals = card:calculate_seal(context)
        if seals then
            ret.seals = seals
        end
        return ret
    end

    if context.cardarea == G.play then
        local chips = card:get_chip_bonus()
        if chips > 0 then
            ret.chips = chips
        end

        local mult = card:get_chip_mult()
        if mult > 0 then
            ret.mult = mult
        end

        local x_mult = card:get_chip_x_mult(context)
        if x_mult > 0 then
            ret.x_mult = x_mult
        end

        local p_dollars = card:get_p_dollars()
        if p_dollars > 0 then
            ret.p_dollars = p_dollars
        end

        local jokers = card:calculate_joker_chips(context)
        if jokers then
            ret.jokers = jokers
        end

        local edition = card:get_edition(context)
        if edition then
            ret.edition = edition
        end
    end

    if context.cardarea == G.hand then
        local h_mult = card:get_chip_h_mult()
        if h_mult > 0 then
            ret.h_mult = h_mult
        end

        local h_x_mult = card:get_chip_h_x_mult()
        if h_x_mult > 0 then
            ret.x_mult = h_x_mult
        end

        local jokers = card:calculate_joker_chips(context)
        if jokers then
            ret.jokers = jokers
        end
    end

    if context.cardarea == G.jokers or context.card == G.consumeables then
        local jokers = nil
        if context.edition then
            jokers = card:get_edition(context)
        elseif context.other_joker then
            jokers = context.other_joker:calculate_joker_chips(context)
        else
            jokers = card:calculate_joker_chips(context)
        end
        if jokers then
            ret.jokers = jokers
        end
    end

    return ret
end

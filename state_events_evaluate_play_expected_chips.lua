G.FUNCS.evaluate_play_expected_chips_once = function(e)
    if G.hand == nil then
        return -1
    end

    local text,disp_text,poker_hands,scoring_hand,non_loc_disp_text = G.FUNCS.get_poker_hand_info(G.hand.highlighted)

    if text == nil or text == '' or text == "NULL" then
        return -1
    end

    for j=1, #G.jokers.cards do
        if G.jokers.cards[j].facing == "back" then
            return -2
        end
    end
    for j=1, #G.hand.highlighted do
        if G.hand.highlighted[j].facing == "back" then
            return -2
        end
    end

--     love.filesystem.append("meow.txt", "\n")
--     love.filesystem.append("meow.txt", #G.hand.highlighted)
--     G.GAME.hands[text].played = G.GAME.hands[text].played + 1
--     G.GAME.hands[text].played_this_round = G.GAME.hands[text].played_this_round + 1
--     G.GAME.last_hand_played = text
--     set_hand_usage(text)
--     G.GAME.hands[text].visible = true

    --Add all the pure bonus cards to the scoring hand
    local pures = {}
    for i=1, #G.hand.highlighted do
        if next(find_joker('Splash')) then
            scoring_hand[i] = G.hand.highlighted[i]
        else
            if G.hand.highlighted[i].ability.effect == 'Stone Card' then
                local inside = false
                for j=1, #scoring_hand do
                    if scoring_hand[j] == G.hand.highlighted[i] then
                        inside = true
                    end
                end
                if not inside then table.insert(pures, G.hand.highlighted[i]) end
            end
        end
    end
    for i=1, #pures do
        table.insert(scoring_hand, pures[i])
    end
    table.sort(scoring_hand, function (a, b) return a.T.x < b.T.x end )
--     delay(0.2)
--     for i=1, #scoring_hand do
--         --Highlight all the cards used in scoring and play a sound indicating highlight
--         highlight_card(scoring_hand[i],(i-0.999)/5,'up')
--     end

--  bro wtf is this???????????????????????????????????????
    local percent = 0.3
    local percent_delta = 0.08

--     if G.GAME.current_round.current_hand.handname ~= disp_text then delay(0.3) end
--     update_hand_text({sound = G.GAME.current_round.current_hand.handname ~= disp_text and 'button' or nil, volume = 0.4, immediate = true, nopulse = nil,
--                 delay = G.GAME.current_round.current_hand.handname ~= disp_text and 0.4 or 0}, {handname=disp_text, level=G.GAME.hands[text].level, mult = G.GAME.hands[text].mult, chips = G.GAME.hands[text].chips})

    if not G.GAME.blind:debuff_hand(G.hand.highlighted, poker_hands, text, true) then
--         love.filesystem.append("meow.txt", text)
        mult = mod_mult(G.GAME.hands[text].mult)
        hand_chips = mod_chips(G.GAME.hands[text].chips)

--         check_for_unlock({type = 'hand', handname = text, disp_text = non_loc_disp_text, scoring_hand = scoring_hand, full_hand = G.play.cards})

--         delay(0.4)

        if G.GAME.first_used_hand_level and G.GAME.first_used_hand_level > 0 then
--             level_up_hand(G.deck.cards[1], text, nil, G.GAME.first_used_hand_level)
            G.GAME.first_used_hand_level = nil
        end

        local hand_text_set = false
        for i=1, #G.jokers.cards do
            --calculate the joker effects
            local effects = eval_card_chips(G.jokers.cards[i], {cardarea = G.jokers, full_hand = G.hand.highlighted, scoring_hand = scoring_hand, scoring_name = text, poker_hands = poker_hands, before = true, chip_calculation = true})
            if effects.jokers then
--                 card_eval_status_text(G.jokers.cards[i], 'jokers', nil, percent, nil, effects.jokers)
                percent = percent + percent_delta
                if effects.jokers.level_up then
--                     level_up_hand(G.jokers.cards[i], text)
                end
            end
        end

        mult = mod_mult(G.GAME.hands[text].mult)
        hand_chips = mod_chips(G.GAME.hands[text].chips)

        local modded = false

        mult, hand_chips, modded = G.GAME.blind:modify_hand(G.hand.highlighted, poker_hands, text, mult, hand_chips)
        mult, hand_chips = mod_mult(mult), mod_chips(hand_chips)
--         if modded then update_hand_text({sound = 'chips2', modded = modded}, {chips = hand_chips, mult = mult}) end
        for i=1, #scoring_hand do
            --add cards played to list
            if scoring_hand[i].ability.effect ~= 'Stone Card' then
--                 G.GAME.cards_played[scoring_hand[i].base.value].total = G.GAME.cards_played[scoring_hand[i].base.value].total + 1
--                 G.GAME.cards_played[scoring_hand[i].base.value].suits[scoring_hand[i].base.suit] = true
            end
            --if card is debuffed
            if scoring_hand[i].debuff then
                G.GAME.blind.triggered = true
--                 G.E_MANAGER:add_event(Event({
--                     trigger = 'immediate',
--                     func = (function() G.HUD_blind:get_UIE_by_ID('HUD_blind_debuff_1'):juice_up(0.3, 0)
--                         G.HUD_blind:get_UIE_by_ID('HUD_blind_debuff_2'):juice_up(0.3, 0)
--                         G.GAME.blind:juice_up();return true end)
--                 }))
--                 card_eval_status_text(scoring_hand[i], 'debuff')
            else
                --Check for play doubling
                local reps = {1}

                --From Red seal
                local eval = eval_card_chips(scoring_hand[i], {repetition_only = true,cardarea = G.play, full_hand = G.hand.highlighted, scoring_hand = scoring_hand, scoring_name = text, poker_hands = poker_hands, repetition = true, chip_calculation = true})
                if next(eval) then
                    for h = 1, eval.seals.repetitions do
                        reps[#reps+1] = eval
                    end
                end
                --From jokers
                for j=1, #G.jokers.cards do
                    --calculate the joker effects
                    local eval = eval_card_chips(G.jokers.cards[j], {cardarea = G.play, full_hand = G.hand.highlighted, scoring_hand = scoring_hand, scoring_name = text, poker_hands = poker_hands, other_card = scoring_hand[i], repetition = true, chip_calculation = true})
                    if next(eval) and eval.jokers then
                        for h = 1, eval.jokers.repetitions do
                            reps[#reps+1] = eval
                        end
                    end
                end
                for j=1,#reps do
                    percent = percent + percent_delta
--                     if reps[j] ~= 1 then
--                         card_eval_status_text((reps[j].jokers or reps[j].seals).card, 'jokers', nil, nil, nil, (reps[j].jokers or reps[j].seals))
--                     end

                    --calculate the hand effects
                    local effects = {eval_card_chips(scoring_hand[i], {cardarea = G.play, full_hand = G.hand.highlighted, scoring_hand = scoring_hand, poker_hand = text, chip_calculation = true})}
                    for k=1, #G.jokers.cards do
                        --calculate the joker individual card effects
                        local eval = G.jokers.cards[k]:calculate_joker_chips({cardarea = G.play, full_hand = G.hand.highlighted, scoring_hand = scoring_hand, scoring_name = text, poker_hands = poker_hands, other_card = scoring_hand[i], individual = true, chip_calculation = true})
                        if eval then
                            table.insert(effects, eval)
                        end
                    end
                    scoring_hand[i].lucky_trigger = nil

                    for ii = 1, #effects do
                        --If chips added, do chip add event and add the chips to the total
                        if effects[ii].chips then
--                             if effects[ii].card then juice_card(effects[ii].card) end
                            hand_chips = mod_chips(hand_chips + effects[ii].chips)
--                             update_hand_text({delay = 0}, {chips = hand_chips})
--                             card_eval_status_text(scoring_hand[i], 'chips', effects[ii].chips, percent)
                        end

                        --If mult added, do mult add event and add the mult to the total
                        if effects[ii].mult then
--                             if effects[ii].card then juice_card(effects[ii].card) end
                            mult = mod_mult(mult + effects[ii].mult)
--                             update_hand_text({delay = 0}, {mult = mult})
--                             card_eval_status_text(scoring_hand[i], 'mult', effects[ii].mult, percent)
                        end

                        --If play dollars added, add dollars to total
                        if effects[ii].p_dollars then
--                             if effects[ii].card then juice_card(effects[ii].card) end
--                             ease_dollars(effects[ii].p_dollars)
--                             card_eval_status_text(scoring_hand[i], 'dollars', effects[ii].p_dollars, percent)
                        end

                        --If dollars added, add dollars to total
                        if effects[ii].dollars then
--                             if effects[ii].card then juice_card(effects[ii].card) end
--                             ease_dollars(effects[ii].dollars)
--                             card_eval_status_text(scoring_hand[i], 'dollars', effects[ii].dollars, percent)
                        end

                        --Any extra effects
                        if effects[ii].extra then
--                             if effects[ii].card then juice_card(effects[ii].card) end
                            local extras = {mult = false, hand_chips = false}
                            if effects[ii].extra.mult_mod then mult =mod_mult( mult + effects[ii].extra.mult_mod);extras.mult = true end
                            if effects[ii].extra.chip_mod then hand_chips = mod_chips(hand_chips + effects[ii].extra.chip_mod);extras.hand_chips = true end
                            if effects[ii].extra.swap then
                                local old_mult = mult
                                mult = mod_mult(hand_chips)
                                hand_chips = mod_chips(old_mult)
                                extras.hand_chips = true; extras.mult = true
                            end
                            if effects[ii].extra.func then effects[ii].extra.func() end
--                             update_hand_text({delay = 0}, {chips = extras.hand_chips and hand_chips, mult = extras.mult and mult})
--                             card_eval_status_text(scoring_hand[i], 'extra', nil, percent, nil, effects[ii].extra)
                        end

                        --If x_mult added, do mult add event and mult the mult to the total
                        if effects[ii].x_mult then
--                             if effects[ii].card then juice_card(effects[ii].card) end
                            mult = mod_mult(mult*effects[ii].x_mult)
--                             update_hand_text({delay = 0}, {mult = mult})
--                             card_eval_status_text(scoring_hand[i], 'x_mult', effects[ii].x_mult, percent)
                        end

                        --calculate the card edition effects
                        if effects[ii].edition then
                            hand_chips = mod_chips(hand_chips + (effects[ii].edition.chip_mod or 0))
                            mult = mult + (effects[ii].edition.mult_mod or 0)
                            mult = mod_mult(mult*(effects[ii].edition.x_mult_mod or 1))
--                             update_hand_text({delay = 0}, {
--                                 chips = effects[ii].edition.chip_mod and hand_chips or nil,
--                                 mult = (effects[ii].edition.mult_mod or effects[ii].edition.x_mult_mod) and mult or nil,
--                             })
--                             card_eval_status_text(scoring_hand[i], 'extra', nil, percent, nil, {
--                                 message = (effects[ii].edition.chip_mod and localize{type='variable',key='a_chips',vars={effects[ii].edition.chip_mod}}) or
--                                         (effects[ii].edition.mult_mod and localize{type='variable',key='a_mult',vars={effects[ii].edition.mult_mod}}) or
--                                         (effects[ii].edition.x_mult_mod and localize{type='variable',key='a_xmult',vars={effects[ii].edition.x_mult_mod}}),
--                                 chip_mod =  effects[ii].edition.chip_mod,
--                                 mult_mod =  effects[ii].edition.mult_mod,
--                                 x_mult_mod =  effects[ii].edition.x_mult_mod,
--                                 colour = G.C.DARK_EDITION,
--                                 edition = true})
                        end
                    end
                end
            end
        end

--         delay(0.3)
        local mod_percent = false
            for i=1, #G.hand.cards do
                if mod_percent then percent = percent + percent_delta end
                mod_percent = false

                --Check for hand doubling
                local reps = {1}
                local j = 1
                while j <= #reps do
                    if reps[j] ~= 1 then
--                         card_eval_status_text((reps[j].jokers or reps[j].seals).card, 'jokers', nil, nil, nil, (reps[j].jokers or reps[j].seals))
                        percent = percent + percent_delta
                    end

                    --calculate the hand effects
                    local effects = {eval_card_chips(G.hand.cards[i], {cardarea = G.hand, full_hand = G.hand.highlighted, scoring_hand = scoring_hand, scoring_name = text, poker_hands = poker_hands, chip_calculation = true})}

                    for k=1, #G.jokers.cards do
                        --calculate the joker individual card effects
                        local eval = G.jokers.cards[k]:calculate_joker_chips({cardarea = G.hand, full_hand = G.hand.highlighted, scoring_hand = scoring_hand, scoring_name = text, poker_hands = poker_hands, other_card = G.hand.cards[i], individual = true, chip_calculation = true})
                        if eval then
                            mod_percent = true
                            table.insert(effects, eval)
                        end
                    end

                    if reps[j] == 1 then
                        --Check for hand doubling

                        --From Red seal
                        local eval = eval_card_chips(G.hand.cards[i], {repetition_only = true,cardarea = G.hand, full_hand = G.hand.highlighted, scoring_hand = scoring_hand, scoring_name = text, poker_hands = poker_hands, repetition = true, card_effects = effects, chip_calculation = true})
                        if next(eval) and (next(effects[1]) or #effects > 1) then
                            for h  = 1, eval.seals.repetitions do
                                reps[#reps+1] = eval
                            end
                        end

                        --From Joker
                        for j=1, #G.jokers.cards do
                            --calculate the joker effects
                            local eval = eval_card_chips(G.jokers.cards[j], {cardarea = G.hand, full_hand = G.hand.highlighted, scoring_hand = scoring_hand, scoring_name = text, poker_hands = poker_hands, other_card = G.hand.cards[i], repetition = true, card_effects = effects, chip_calculation = true})
                            if next(eval) then
                                for h  = 1, eval.jokers.repetitions do
                                    reps[#reps+1] = eval
                                end
                            end
                        end
                    end

                    for ii = 1, #effects do
                        --if this effect came from a joker
                        if effects[ii].card then
                            mod_percent = true
--                             G.E_MANAGER:add_event(Event({
--                                 trigger = 'immediate',
--                                 func = (function() effects[ii].card:juice_up(0.7);return true end)
--                             }))
                        end

                        --If hold mult added, do hold mult add event and add the mult to the total

                        --If dollars added, add dollars to total
--                         if effects[ii].dollars then
--                             ease_dollars(effects[ii].dollars)
--                             card_eval_status_text(G.hand.cards[i], 'dollars', effects[ii].dollars, percent)
--                         end

                        if effects[ii].h_mult then
                            mod_percent = true
                            mult = mod_mult(mult + effects[ii].h_mult)
--                             update_hand_text({delay = 0}, {mult = mult})
--                             card_eval_status_text(G.hand.cards[i], 'h_mult', effects[ii].h_mult, percent)
                        end

                        if effects[ii].x_mult then
                            mod_percent = true
                            mult = mod_mult(mult*effects[ii].x_mult)
--                             update_hand_text({delay = 0}, {mult = mult})
--                             card_eval_status_text(G.hand.cards[i], 'x_mult', effects[ii].x_mult, percent)
                        end

                        if effects[ii].message then
                            mod_percent = true
--                             update_hand_text({delay = 0}, {mult = mult})
--                             card_eval_status_text(G.hand.cards[i], 'extra', nil, percent, nil, effects[ii])
                        end
                    end
                    j = j +1
                end
            end
        --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
        --Joker Effects
        --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
        percent = percent + percent_delta
        for i=1, #G.jokers.cards + #G.consumeables.cards do
            local _card = G.jokers.cards[i] or G.consumeables.cards[i - #G.jokers.cards]
            --calculate the joker edition effects
            local edition_effects = eval_card_chips(_card, {cardarea = G.jokers, full_hand = G.hand.highlighted, scoring_hand = scoring_hand, scoring_name = text, poker_hands = poker_hands, edition = true, chip_calculation = true})
            if edition_effects.jokers then
                edition_effects.jokers.edition = true
                if edition_effects.jokers.chip_mod then
                    hand_chips = mod_chips(hand_chips + edition_effects.jokers.chip_mod)
--                     update_hand_text({delay = 0}, {chips = hand_chips})
--                     card_eval_status_text(_card, 'jokers', nil, percent, nil, {
--                         message = localize{type='variable',key='a_chips',vars={edition_effects.jokers.chip_mod}},
--                         chip_mod =  edition_effects.jokers.chip_mod,
--                         colour =  G.C.EDITION,
--                         edition = true})
                end
                if edition_effects.jokers.mult_mod then
                    mult = mod_mult(mult + edition_effects.jokers.mult_mod)
--                     update_hand_text({delay = 0}, {mult = mult})
--                     card_eval_status_text(_card, 'jokers', nil, percent, nil, {
--                         message = localize{type='variable',key='a_mult',vars={edition_effects.jokers.mult_mod}},
--                         mult_mod =  edition_effects.jokers.mult_mod,
--                         colour = G.C.DARK_EDITION,
--                         edition = true})
                end
                percent = percent+percent_delta
            end

            --calculate the joker effects
            local effects = eval_card_chips(_card, {cardarea = G.jokers, full_hand = G.hand.highlighted, scoring_hand = scoring_hand, scoring_name = text, poker_hands = poker_hands, joker_main = true, chip_calculation = true})

            --Any Joker effects
            if effects.jokers then
                local extras = {mult = false, hand_chips = false}
                if effects.jokers.mult_mod then mult = mod_mult(mult + effects.jokers.mult_mod);extras.mult = true end
                if effects.jokers.chip_mod then hand_chips = mod_chips(hand_chips + effects.jokers.chip_mod);extras.hand_chips = true end
                if effects.jokers.Xmult_mod then mult = mod_mult(mult*effects.jokers.Xmult_mod);extras.mult = true  end
--                 update_hand_text({delay = 0}, {chips = extras.hand_chips and hand_chips, mult = extras.mult and mult})
--                 card_eval_status_text(_card, 'jokers', nil, percent, nil, effects.jokers)
                percent = percent+percent_delta
            end

            --Joker on Joker effects
            for _, v in ipairs(G.jokers.cards) do
                local effect = v:calculate_joker_chips{full_hand = G.hand.highlighted, scoring_hand = scoring_hand, scoring_name = text, poker_hands = poker_hands, other_joker = _card, chip_calculation = true}
                if effect then
                    local extras = {mult = false, hand_chips = false}
                    if effect.mult_mod then mult = mod_mult(mult + effect.mult_mod);extras.mult = true end
                    if effect.chip_mod then hand_chips = mod_chips(hand_chips + effect.chip_mod);extras.hand_chips = true end
                    if effect.Xmult_mod then mult = mod_mult(mult*effect.Xmult_mod);extras.mult = true  end
--                     if extras.mult or extras.hand_chips then update_hand_text({delay = 0}, {chips = extras.hand_chips and hand_chips, mult = extras.mult and mult}) end
--                     if extras.mult or extras.hand_chips then card_eval_status_text(v, 'jokers', nil, percent, nil, effect) end
                    percent = percent+percent_delta
                end
            end

            if edition_effects.jokers then
                if edition_effects.jokers.x_mult_mod then
                    mult = mod_mult(mult*edition_effects.jokers.x_mult_mod)
--                     update_hand_text({delay = 0}, {mult = mult})
--                     card_eval_status_text(_card, 'jokers', nil, percent, nil, {
--                         message = localize{type='variable',key='a_xmult',vars={edition_effects.jokers.x_mult_mod}},
--                         x_mult_mod =  edition_effects.jokers.x_mult_mod,
--                         colour =  G.C.EDITION,
--                         edition = true})
                end
                percent = percent+percent_delta
            end
        end

        local nu_chip, nu_mult = G.GAME.selected_back:trigger_effect{context = 'final_scoring_step', chips = hand_chips, mult = mult}
        mult = mod_mult(nu_mult or mult)
        hand_chips = mod_chips(nu_chip or hand_chips)

--         local cards_destroyed = {}
--         for i=1, #scoring_hand do
--             local destroyed = nil
--             --un-highlight all cards
--             highlight_card(scoring_hand[i],(i-0.999)/(#scoring_hand-0.998),'down')
--
--             for j = 1, #G.jokers.cards do
--                 destroyed = G.jokers.cards[j]:calculate_joker({destroying_card = scoring_hand[i], full_hand = G.play.cards})
--                 if destroyed then break end
--             end
--
--             if scoring_hand[i].ability.name == 'Glass Card' and not scoring_hand[i].debuff and pseudorandom('glass') < G.GAME.probabilities.normal/scoring_hand[i].ability.extra then
--                 destroyed = true
--             end
--
--             if destroyed then
--                 if scoring_hand[i].ability.name == 'Glass Card' then
--                     scoring_hand[i].shattered = true
--                 else
--                     scoring_hand[i].destroyed = true
--                 end
--                 cards_destroyed[#cards_destroyed+1] = scoring_hand[i]
--             end
--         end
        for j=1, #G.jokers.cards do
            eval_card_chips(G.jokers.cards[j], {cardarea = G.jokers, remove_playing_cards = true, removed = cards_destroyed, chip_calculation = true})
        end

--         local glass_shattered = {}
--         for k, v in ipairs(cards_destroyed) do
--             if v.shattered then glass_shattered[#glass_shattered+1] = v end
--         end

--         check_for_unlock{type = 'shatter', shattered = glass_shattered}

--         for i=1, #cards_destroyed do
--             G.E_MANAGER:add_event(Event({
--                 func = function()
--                     if cards_destroyed[i].ability.name == 'Glass Card' then
--                         cards_destroyed[i]:shatter()
--                     else
--                         cards_destroyed[i]:start_dissolve()
--                     end
--                   return true
--                 end
--               }))
--         end
    else
        mult = mod_mult(0)
        hand_chips = mod_chips(0)
--         G.E_MANAGER:add_event(Event({
--             trigger = 'immediate',
--             func = (function()
--                 G.HUD_blind:get_UIE_by_ID('HUD_blind_debuff_1'):juice_up(0.3, 0)
--                 G.HUD_blind:get_UIE_by_ID('HUD_blind_debuff_2'):juice_up(0.3, 0)
--                 G.GAME.blind:juice_up()
--                 G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.06*G.SETTINGS.GAMESPEED, blockable = false, blocking = false, func = function()
--                     play_sound('tarot2', 0.76, 0.4);return true end}))
--                 play_sound('tarot2', 1, 0.4)
--                 return true
--             end)
--         }))

--         play_area_status_text("Not Allowed!")--localize('k_not_allowed_ex'), true)
        --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
        --Joker Debuff Effects
        --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
        for i=1, #G.jokers.cards do

            --calculate the joker effects
            local effects = eval_card_chips(G.jokers.cards[i], {cardarea = G.jokers, full_hand = G.hand.highlighted, scoring_hand = scoring_hand, scoring_name = text, poker_hands = poker_hands, debuffed_hand = true, chip_calculation = true})

            --Any Joker effects
            if effects.jokers then
--                 card_eval_status_text(G.jokers.cards[i], 'jokers', nil, percent, nil, effects.jokers)
                percent = percent+percent_delta
            end
        end
    end
--     G.E_MANAGER:add_event(Event({
--         trigger = 'after',delay = 0.4,
--         func = (function()  update_hand_text({delay = 0, immediate = true}, {mult = 0, chips = 0, chip_total = math.floor(hand_chips*mult), level = '', handname = ''});play_sound('button', 0.9, 0.6);return true end)
--       }))
--       check_and_set_high_score('hand', hand_chips*mult)
--
--       check_for_unlock({type = 'chip_score', chips = math.floor(hand_chips*mult)})

--     if hand_chips*mult > 0 then
--         delay(0.8)
--         G.E_MANAGER:add_event(Event({
--         trigger = 'immediate',
--         func = (function() play_sound('chips2');return true end)
--         }))
--     end
--     G.E_MANAGER:add_event(Event({
--       trigger = 'ease',
--       blocking = false,
--       ref_table = G.GAME,
--       ref_value = 'chips',
--       ease_to = G.GAME.chips + math.floor(hand_chips*mult),
--       delay =  0.5,
--       func = (function(t) return math.floor(t) end)
--     }))
--     G.E_MANAGER:add_event(Event({
--       trigger = 'ease',
--       blocking = true,
--       ref_table = G.GAME.current_round.current_hand,
--       ref_value = 'chip_total',
--       ease_to = 0,
--       delay =  0.5,
--       func = (function(t) return math.floor(t) end)
--     }))
--     G.E_MANAGER:add_event(Event({
--       trigger = 'immediate',
--       func = (function() G.GAME.current_round.current_hand.handname = '';return true end)
--     }))
--     delay(0.3)

    for i=1, #G.jokers.cards do
        --calculate the joker after hand played effects
        local effects = eval_card_chips(G.jokers.cards[i], {cardarea = G.jokers, full_hand = G.hand.highlighted, scoring_hand = scoring_hand, scoring_name = text, poker_hands = poker_hands, after = true, chip_calculation = true})
        if effects.jokers then
--             card_eval_status_text(G.jokers.cards[i], 'jokers', nil, percent, nil, effects.jokers)
            percent = percent + percent_delta
        end
    end
    local expected_chips = hand_chips * mult
--     love.filesystem.append("meow.txt", "\n")
--     love.filesystem.append("meow.txt", "hand_chips: ")
--     love.filesystem.append("meow.txt", hand_chips)
--     love.filesystem.append("meow.txt", ", percent: ")
--     love.filesystem.append("meow.txt", percent)
--     love.filesystem.append("meow.txt", ", mult: ")
--     love.filesystem.append("meow.txt", mult)
--     love.filesystem.append("meow.txt", ", expected_chips: ")
--     love.filesystem.append("meow.txt", expected_chips)
    return expected_chips

--     G.E_MANAGER:add_event(Event({
--         trigger = 'immediate',
--         func = (function()
--             if G.GAME.modifiers.debuff_played_cards then
--                 for k, v in ipairs(scoring_hand) do v.ability.perma_debuff = true end
--             end
--         return true end)
--       }))

--   end

--   G.FUNCS.draw_from_play_to_discard = function(e)
--     local play_count = #G.play.cards
--     local it = 1
--     for k, v in ipairs(G.play.cards) do
--         if (not v.shattered) and (not v.destroyed) then
--             draw_card(G.play,G.discard, it*100/play_count,'down', false, v)
--             it = it + 1
--         end
--     end
--   end

--   G.FUNCS.draw_from_play_to_hand = function(cards)
--     local gold_count = #cards
--     for i=1, gold_count do --draw cards from play
--         if not cards[i].shattered and not cards[i].destroyed then
--             draw_card(G.play,G.hand, i*100/gold_count,'up', true, cards[i])
--         end
--     end
--   end

--   G.FUNCS.draw_from_discard_to_deck = function(e)
--     G.E_MANAGER:add_event(Event({
--         trigger = 'immediate',
--         func = function()
--             local discard_count = #G.discard.cards
--             for i=1, discard_count do --draw cards from deck
--                 draw_card(G.discard, G.deck, i*100/discard_count,'up', nil ,nil, 0.005, i%2==0, nil, math.max((21-i)/20,0.7))
--             end
--             return true
--         end
--       }))
--   end

--   G.FUNCS.draw_from_hand_to_deck = function(e)
--     local hand_count = #G.hand.cards
--     for i=1, hand_count do --draw cards from deck
--         draw_card(G.hand, G.deck, i*100/hand_count,'down', nil, nil,  0.08)
--     end
--   end

--   G.FUNCS.draw_from_hand_to_discard = function(e)
--     local hand_count = #G.hand.cards
--     for i=1, hand_count do
--         draw_card(G.hand,G.discard, i*100/hand_count,'down', nil, nil, 0.07)
--     end
end

G.FUNCS.evaluate_play_expected_chips = function(e)
    expected_chips_values = 0

    -- save all current probabilities
    local old_probabilities = {}
    for k,v in pairs(G.GAME.pseudorandom) do
        old_probabilities[k] = v
    end
    local calculations = 10
    if SMODS ~= nil then  -- SMODS is running
        -- sendDebugMessage("Detected SMODS", "expected chips")
        calculations = exp_chips.num_calculations
    end

    -- love.filesystem.append("meow.txt", "nyaaa!!\n")
    for i=1,calculations do
        expected_chip_value = G.FUNCS.evaluate_play_expected_chips_once()
        if expected_chip_value == -1 or expected_chip_value == -2 then
            return expected_chip_value
        end
        expected_chips_values = expected_chips_values + expected_chip_value
    end

    -- put the probabilities back
    for k,v in pairs(old_probabilities) do
        G.GAME.pseudorandom[k] = v
    end

    return math.ceil(expected_chips_values / calculations)
end

function Card:calculate_joker_chips(context)
    -- i tried to get it compatible with other mods but i give up
    -- sendDebugMessage(self.mod, "ExpectedChips|self.mod")
--     sendDebugMessage(inspectDepth(self.config.center), "ExpectedChips")
--     if SMODS ~= nil and self.config.center.config.expected_chips_compatible == true then  -- SMODS is loaded, this is a modded joker, and this joker is compatible with the mod
--         sendDebugMessage(self.ability.name)
--         sendDebugMessage(inspectDepth(SMODS.find_card(self.config.center.key)))
--         -- return self.role.draw_major.config.center.calculate(self, context)
--     end
--

    if self.debuff then return nil end
    if self.ability.set == "Planet" and not self.debuff then
        if context.joker_main then
            if G.GAME.used_vouchers.v_observatory and self.ability.consumeable.hand_type == context.scoring_name then
                return {
                    message = localize{type = 'variable', key = 'a_xmult', vars = {G.P_CENTERS.v_observatory.config.extra}},
                    Xmult_mod = G.P_CENTERS.v_observatory.config.extra
                }
            end
        end
    end
    if self.ability.set == "Joker" and not self.debuff then
        if self.ability.name == "Blueprint" then
            local other_joker = nil
            for i = 1, #G.jokers.cards do
                if G.jokers.cards[i] == self then other_joker = G.jokers.cards[i+1] end
            end
            if other_joker and other_joker ~= self then
                context.blueprint = (context.blueprint and (context.blueprint + 1)) or 1
                context.blueprint_card = context.blueprint_card or self
                if context.blueprint > #G.jokers.cards + 1 then return end
                local other_joker_ret = other_joker:calculate_joker(context)
                if other_joker_ret then
                    other_joker_ret.card = context.blueprint_card or self
                    other_joker_ret.colour = G.C.BLUE
                    return other_joker_ret
                end
            end
        end
        if self.ability.name == "Brainstorm" then
            local other_joker = G.jokers.cards[1]
            if other_joker and other_joker ~= self then
                context.blueprint = (context.blueprint and (context.blueprint + 1)) or 1
                context.blueprint_card = context.blueprint_card or self
                if context.blueprint > #G.jokers.cards + 1 then return end
                local other_joker_ret = other_joker:calculate_joker(context)
                if other_joker_ret then
                    other_joker_ret.card = context.blueprint_card or self
                    other_joker_ret.colour = G.C.RED
                    return other_joker_ret
                end
            end
        end
        if context.remove_playing_cards then
            if self.ability.name == 'Caino' and not context.blueprint and context.chip_calculation ~= true then
                local face_cards = 0
                for k, val in ipairs(context.removed) do
                    if val:is_face() then face_cards = face_cards + 1 end
                end
                if face_cards > 0 then
                    self.ability.caino_xmult = self.ability.caino_xmult + face_cards*self.ability.extra
                    G.E_MANAGER:add_event(Event({
                    func = function() card_eval_status_text(self, 'extra', nil, nil, nil, {message = localize{type = 'variable', key = 'a_xmult', vars = {self.ability.caino_xmult}}}); return true
                    end}))
                end
                return
            end

            if self.ability.name == 'Glass Joker' and not context.blueprint then
                local glass_cards = 0
                for k, val in ipairs(context.removed) do
                    if val.shattered then glass_cards = glass_cards + 1 end
                end
                if glass_cards > 0 then
                    G.E_MANAGER:add_event(Event({
                        func = function()
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            self.ability.x_mult = self.ability.x_mult + self.ability.extra*glass_cards
                        return true
                        end
                    }))
                    card_eval_status_text(self, 'extra', nil, nil, nil, {message = localize{type = 'variable', key = 'a_xmult', vars = {self.ability.x_mult + self.ability.extra*glass_cards}}})
                    return true
                        end
                    }))
                end
                return
            end
        elseif context.debuffed_hand then
            if self.ability.name == 'Matador' then
                if G.GAME.blind.triggered then
                    ease_dollars(self.ability.extra)
                    G.GAME.dollar_buffer = (G.GAME.dollar_buffer or 0) + self.ability.extra
                    G.E_MANAGER:add_event(Event({func = (function() G.GAME.dollar_buffer = 0; return true end)}))
                    return {
                        message = localize('$')..self.ability.extra,
                        dollars = self.ability.extra,
                        colour = G.C.MONEY
                    }
                end
            end
        elseif context.individual then
            if context.cardarea == G.play then
                if self.ability.name == 'Hiker' and context.chip_calculation ~= true then
                        context.other_card.ability.perma_bonus = context.other_card.ability.perma_bonus or 0
                        context.other_card.ability.perma_bonus = context.other_card.ability.perma_bonus + self.ability.extra
                        return {
                            extra = {message = localize('k_upgrade_ex'), colour = G.C.CHIPS},
                            colour = G.C.CHIPS,
                            card = self
                        }
                end
--                 if self.ability.name == 'Lucky Cat' and context.other_card.lucky_trigger and not context.blueprint then
--                     self.ability.x_mult = self.ability.x_mult + self.ability.extra
--                     if context.chip_calculation ~= true then
--                         return {
--                             extra = {focus = self, message = localize('k_upgrade_ex'), colour = G.C.MULT},
--                             card = self
--                         }
--                     end
--                 end
                if self.ability.name == 'Wee Joker' and context.chip_calculation ~= true and
                    context.other_card:get_id() == 2 and not context.blueprint then
                        self.ability.extra.chips = self.ability.extra.chips + self.ability.extra.chip_mod

                        return {
                            extra = {focus = self, message = localize('k_upgrade_ex')},
                            card = self,
                            colour = G.C.CHIPS
                        }
                end
                if self.ability.name == 'Photograph' then
                    local first_face = nil
                    for i = 1, #context.scoring_hand do
                        if context.scoring_hand[i]:is_face() then first_face = context.scoring_hand[i]; break end
                    end
                    if context.other_card == first_face then
                        return {
                            x_mult = self.ability.extra,
                            colour = G.C.RED,
                            card = self
                        }
                    end
                end
                if self.ability.name == '8 Ball' and #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
                    if (context.other_card:get_id() == 8) and (pseudorandom('8ball') < G.GAME.probabilities.normal/self.ability.extra) and context.chip_calculation ~= true then
                        G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
                        return {
                            extra = {focus = self, message = localize('k_plus_tarot'), func = function()
                                G.E_MANAGER:add_event(Event({
                                    trigger = 'before',
                                    delay = 0.0,
                                    func = (function()
                                            local card = create_card('Tarot',G.consumeables, nil, nil, nil, nil, nil, '8ba')
                                            card:add_to_deck()
                                            G.consumeables:emplace(card)
                                            G.GAME.consumeable_buffer = 0
                                        return true
                                    end)}))
                            end},
                            colour = G.C.SECONDARY_SET.Tarot,
                            card = self
                        }
                    end
                end
                if self.ability.name == 'The Idol' and
                    context.other_card:get_id() == G.GAME.current_round.idol_card.id and
                    context.other_card:is_suit(G.GAME.current_round.idol_card.suit) then
                        return {
                            x_mult = self.ability.extra,
                            colour = G.C.RED,
                            card = self
                        }
                    end
                if self.ability.name == 'Scary Face' and (
                    context.other_card:is_face()) then
                        return {
                            chips = self.ability.extra,
                            card = self
                        }
                    end
                if self.ability.name == 'Smiley Face' and (
                    context.other_card:is_face()) then
                        return {
                            mult = self.ability.extra,
                            card = self
                        }
                    end
                if self.ability.name == 'Golden Ticket' and
                    context.other_card.ability.name == 'Gold Card' and context.chip_calculation ~= true then
                        G.GAME.dollar_buffer = (G.GAME.dollar_buffer or 0) + self.ability.extra
                        G.E_MANAGER:add_event(Event({func = (function() G.GAME.dollar_buffer = 0; return true end)}))
                        return {
                            dollars = self.ability.extra,
                            card = self
                        }
                    end
                if self.ability.name == 'Scholar' and
                    context.other_card:get_id() == 14 then
                        return {
                            chips = self.ability.extra.chips,
                            mult = self.ability.extra.mult,
                            card = self
                        }
                    end
                if self.ability.name == 'Walkie Talkie' and
                (context.other_card:get_id() == 10 or context.other_card:get_id() == 4) then
                    return {
                        chips = self.ability.extra.chips,
                        mult = self.ability.extra.mult,
                        card = self
                    }
                end
                if self.ability.name == 'Business Card' and
                    context.other_card:is_face() and
                    pseudorandom('business') < G.GAME.probabilities.normal/self.ability.extra and context.chip_calculation ~= true then
                        G.GAME.dollar_buffer = (G.GAME.dollar_buffer or 0) + 2
                        G.E_MANAGER:add_event(Event({func = (function() G.GAME.dollar_buffer = 0; return true end)}))
                        return {
                            dollars = 2,
                            card = self
                        }
                    end
                if self.ability.name == 'Fibonacci' and (
                context.other_card:get_id() == 2 or
                context.other_card:get_id() == 3 or
                context.other_card:get_id() == 5 or
                context.other_card:get_id() == 8 or
                context.other_card:get_id() == 14) then
                    return {
                        mult = self.ability.extra,
                        card = self
                    }
                end
                if self.ability.name == 'Even Steven' and
                context.other_card:get_id() <= 10 and
                context.other_card:get_id() >= 0 and
                context.other_card:get_id()%2 == 0
                then
                    return {
                        mult = self.ability.extra,
                        card = self
                    }
                end
                if self.ability.name == 'Odd Todd' and
                ((context.other_card:get_id() <= 10 and
                context.other_card:get_id() >= 0 and
                context.other_card:get_id()%2 == 1) or
                (context.other_card:get_id() == 14))
                then
                    return {
                        chips = self.ability.extra,
                        card = self
                    }
                end
                if self.ability.effect == 'Suit Mult' and
                    context.other_card:is_suit(self.ability.extra.suit) then
                    return {
                        mult = self.ability.extra.s_mult,
                        card = self
                    }
                end
                if self.ability.name == 'Rough Gem' and
                context.other_card:is_suit("Diamonds") and context.chip_calculation ~= true then
                    G.GAME.dollar_buffer = (G.GAME.dollar_buffer or 0) + self.ability.extra
                    G.E_MANAGER:add_event(Event({func = (function() G.GAME.dollar_buffer = 0; return true end)}))
                    return {
                        dollars = self.ability.extra,
                        card = self
                    }
                end
                if self.ability.name == 'Onyx Agate' and
                context.other_card:is_suit("Clubs") then
                    return {
                        mult = self.ability.extra,
                        card = self
                    }
                end
                if self.ability.name == 'Arrowhead' and
                context.other_card:is_suit("Spades") then
                    return {
                        chips = self.ability.extra,
                        card = self
                    }
                end
                if self.ability.name ==  'Bloodstone' and
                context.other_card:is_suit("Hearts") and
                pseudorandom('bloodstone') < G.GAME.probabilities.normal/self.ability.extra.odds then
                    return {
                        x_mult = self.ability.extra.Xmult,
                        card = self
                    }
                end
                if self.ability.name == 'Ancient Joker' and
                context.other_card:is_suit(G.GAME.current_round.ancient_card.suit) then
                    return {
                        x_mult = self.ability.extra,
                        card = self
                    }
                end
                if self.ability.name == 'Triboulet' and
                    (context.other_card:get_id() == 12 or context.other_card:get_id() == 13) then
                        return {
                            x_mult = self.ability.extra,
                            colour = G.C.RED,
                            card = self
                        }
                    end
            end
            if context.cardarea == G.hand then
                    if self.ability.name == 'Shoot the Moon' and
                        context.other_card:get_id() == 12 then
                        if context.other_card.debuff then
                            return {
                                message = localize('k_debuffed'),
                                colour = G.C.RED,
                                card = self,
                            }
                        else
                            return {
                                h_mult = 13,
                                card = self
                            }
                        end
                    end
                    if self.ability.name == 'Baron' and
                        context.other_card:get_id() == 13 then
                        if context.other_card.debuff then
                            return {
                                message = localize('k_debuffed'),
                                colour = G.C.RED,
                                card = self,
                            }
                        else
                            return {
                                x_mult = self.ability.extra,
                                card = self
                            }
                        end
                    end
                    if self.ability.name == 'Reserved Parking' and
                    context.other_card:is_face() and
                    pseudorandom('parking') < G.GAME.probabilities.normal/self.ability.extra.odds and context.chip_calculation ~= true then
                        if context.other_card.debuff then
                            return {
                                message = localize('k_debuffed'),
                                colour = G.C.RED,
                                card = self,
                            }
                        else
                            G.GAME.dollar_buffer = (G.GAME.dollar_buffer or 0) + self.ability.extra.dollars
                            G.E_MANAGER:add_event(Event({func = (function() G.GAME.dollar_buffer = 0; return true end)}))
                            return {
                                dollars = self.ability.extra.dollars,
                                card = self
                            }
                        end
                    end
                    if self.ability.name == 'Raised Fist' then
                        local temp_Mult, temp_ID = 15, 15
                        local raised_card = nil
                        for i=1, #G.hand.cards do
                            if temp_ID >= G.hand.cards[i].base.id and G.hand.cards[i].ability.effect ~= 'Stone Card' then temp_Mult = G.hand.cards[i].base.nominal; temp_ID = G.hand.cards[i].base.id; raised_card = G.hand.cards[i] end
                        end
                        if raised_card == context.other_card then
                            if context.other_card.debuff then
                                return {
                                    message = localize('k_debuffed'),
                                    colour = G.C.RED,
                                    card = self,
                                }
                            else
                                return {
                                    h_mult = 2*temp_Mult,
                                    card = self,
                                }
                            end
                        end
                    end
            end
        elseif context.repetition then
            if context.cardarea == G.play then
                if self.ability.name == 'Sock and Buskin' and (
                context.other_card:is_face()) then
                    return {
                        message = localize('k_again_ex'),
                        repetitions = self.ability.extra,
                        card = self
                    }
                end
                if self.ability.name == 'Hanging Chad' and (
                context.other_card == context.scoring_hand[1]) then
                    return {
                        message = localize('k_again_ex'),
                        repetitions = self.ability.extra,
                        card = self
                    }
                end
                if self.ability.name == 'Dusk' and (G.GAME.current_round.hands_left == 0 or (G.GAME.current_round.hands_left == 1 and context.chip_calculation == true)) then
                    return {
                        message = localize('k_again_ex'),
                        repetitions = self.ability.extra,
                        card = self
                    }
                end
                if self.ability.name == 'Seltzer' then
                    return {
                        message = localize('k_again_ex'),
                        repetitions = 1,
                        card = self
                    }
                end
                if self.ability.name == 'Hack' and (
                context.other_card:get_id() == 2 or
                context.other_card:get_id() == 3 or
                context.other_card:get_id() == 4 or
                context.other_card:get_id() == 5) then
                    return {
                        message = localize('k_again_ex'),
                        repetitions = self.ability.extra,
                        card = self
                    }
                end
            end
            if context.cardarea == G.hand then
                if self.ability.name == 'Mime' and
                (next(context.card_effects[1]) or #context.card_effects > 1) then
                    return {
                        message = localize('k_again_ex'),
                        repetitions = self.ability.extra,
                        card = self
                    }
                end
            end
        elseif context.other_joker then
            if self.ability.name == 'Baseball Card' and context.other_joker.config.center.rarity == 2 and self ~= context.other_joker then
                if context.chip_calculation ~= true then
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            context.other_joker:juice_up(0.5, 0.5)
                            return true
                        end
                    }))
                end
                return {
                    message = localize{type='variable',key='a_xmult',vars={self.ability.extra}},
                    Xmult_mod = self.ability.extra
                }
            end
        else
            if context.cardarea == G.jokers then
                if context.before then
                    if self.ability.name == 'Spare Trousers' and (next(context.poker_hands['Two Pair']) or next(context.poker_hands['Full House'])) and not context.blueprint and context.chip_calculation ~= true then
                        self.ability.mult = self.ability.mult + self.ability.extra
                        return {
                            message = localize('k_upgrade_ex'),
                            colour = G.C.RED,
                            card = self
                        }
                    end
                    if self.ability.name == 'Space Joker' and pseudorandom('space') < G.GAME.probabilities.normal/self.ability.extra and context.chip_calculation ~= true then
                        return {
                            card = self,
                            level_up = true,
                            message = localize('k_level_up_ex')
                        }
                    end
                    if self.ability.name == 'Square Joker' and #context.full_hand == 4 and not context.blueprint and context.chip_calculation ~= true then
                        self.ability.extra.chips = self.ability.extra.chips + self.ability.extra.chip_mod
                        return {
                            message = localize('k_upgrade_ex'),
                            colour = G.C.CHIPS,
                            card = self
                        }
                    end
                    if self.ability.name == 'Runner' and next(context.poker_hands['Straight']) and not context.blueprint and context.chip_calculation ~= true then
                        self.ability.extra.chips = self.ability.extra.chips + self.ability.extra.chip_mod
                        return {
                            message = localize('k_upgrade_ex'),
                            colour = G.C.CHIPS,
                            card = self
                        }
                    end
                    if self.ability.name == 'Midas Mask' and not context.blueprint and context.chip_calculation ~= true then
                        local faces = {}
                        for k, v in ipairs(context.scoring_hand) do
                            if v:is_face() then
                                faces[#faces+1] = v
                                v:set_ability(G.P_CENTERS.m_gold, nil, true)
                                G.E_MANAGER:add_event(Event({
                                    func = function()
                                        v:juice_up()
                                        return true
                                    end
                                }))
                            end
                        end
                        if #faces > 0 then
                            return {
                                message = localize('k_gold'),
                                colour = G.C.MONEY,
                                card = self
                            }
                        end
                    end
                    if self.ability.name == 'Vampire' and not context.blueprint and context.chip_calculation ~= true then
                        local enhanced = {}
                        for k, v in ipairs(context.scoring_hand) do
                            if v.config.center ~= G.P_CENTERS.c_base and not v.debuff and not v.vampired then
                                enhanced[#enhanced+1] = v
                                v.vampired = true
                                v:set_ability(G.P_CENTERS.c_base, nil, true)
                                G.E_MANAGER:add_event(Event({
                                    func = function()
                                        v:juice_up()
                                        v.vampired = nil
                                        return true
                                    end
                                }))
                            end
                        end

                        if #enhanced > 0 then
                            self.ability.x_mult = self.ability.x_mult + self.ability.extra*#enhanced
                            return {
                                message = localize{type='variable',key='a_xmult',vars={self.ability.x_mult}},
                                colour = G.C.MULT,
                                card = self
                            }
                        end
                    end
                    if self.ability.name == 'To Do List' and context.scoring_name == self.ability.to_do_poker_hand and context.chip_calculation ~= true then
                        ease_dollars(self.ability.extra.dollars)
                        G.GAME.dollar_buffer = (G.GAME.dollar_buffer or 0) + self.ability.extra.dollars
                        G.E_MANAGER:add_event(Event({func = (function() G.GAME.dollar_buffer = 0; return true end)}))
                        return {
                            message = localize('$')..self.ability.extra.dollars,
                            dollars = self.ability.extra.dollars,
                            colour = G.C.MONEY
                        }
                    end
                    if self.ability.name == 'DNA' and G.GAME.current_round.hands_played == 0 and context.chip_calculation ~= true then
                        if #context.full_hand == 1 then
                            G.playing_card = (G.playing_card and G.playing_card + 1) or 1
                            local _card = copy_card(context.full_hand[1], nil, nil, G.playing_card)
                            _card:add_to_deck()
                            G.deck.config.card_limit = G.deck.config.card_limit + 1
                            table.insert(G.playing_cards, _card)
                            G.hand:emplace(_card)
                            _card.states.visible = nil

                            G.E_MANAGER:add_event(Event({
                                func = function()
                                    _card:start_materialize()
                                    return true
                                end
                            }))
                            return {
                                message = localize('k_copied_ex'),
                                colour = G.C.CHIPS,
                                card = self,
                                playing_cards_created = {true}
                            }
                        end
                    end
                    if self.ability.name == 'Ride the Bus' and not context.blueprint and context.chip_calculation ~= true then
                        local faces = false
                        for i = 1, #context.scoring_hand do
                            if context.scoring_hand[i]:is_face() then faces = true end
                        end
                        if faces then
                            local last_mult = self.ability.mult
                            self.ability.mult = 0
                            if last_mult > 0 then
                                return {
                                    card = self,
                                    message = localize('k_reset')
                                }
                            end
                        else
                            self.ability.mult = self.ability.mult + self.ability.extra
                        end
                    end
                    if self.ability.name == 'Obelisk' and not context.blueprint and context.chip_calculation ~= true then
                        local reset = true
                        local play_more_than = (G.GAME.hands[context.scoring_name].played or 0)
                        for k, v in pairs(G.GAME.hands) do
                            if k ~= context.scoring_name and v.played >= play_more_than and v.visible then
                                reset = false
                            end
                        end
                        if reset then
                            if self.ability.x_mult > 1 then
                                self.ability.x_mult = 1
                                return {
                                    card = self,
                                    message = localize('k_reset')
                                }
                            end
                        else
                            self.ability.x_mult = self.ability.x_mult + self.ability.extra
                        end
                    end
                    if self.ability.name == 'Green Joker' and not context.blueprint and context.chip_calculation ~= true then
                        return
                    end
                elseif context.after then
                    if self.ability.name == 'Ice Cream' and not context.blueprint and context.chip_calculation ~= true then
                        if self.ability.extra.chips - self.ability.extra.chip_mod <= 0 then
                            G.E_MANAGER:add_event(Event({
                                func = function()
                                    play_sound('tarot1')
                                    self.T.r = -0.2
                                    self:juice_up(0.3, 0.4)
                                    self.states.drag.is = true
                                    self.children.center.pinch.x = true
                                    G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.3, blockable = false,
                                        func = function()
                                                G.jokers:remove_card(self)
                                                self:remove()
                                                self = nil
                                            return true; end}))
                                    return true
                                end
                            }))
                            return {
                                message = localize('k_melted_ex'),
                                colour = G.C.CHIPS
                            }
                        else
                            self.ability.extra.chips = self.ability.extra.chips - self.ability.extra.chip_mod
                            return {
                                message = localize{type='variable',key='a_chips_minus',vars={self.ability.extra.chip_mod}},
                                colour = G.C.CHIPS
                            }
                        end
                    end
                    if self.ability.name == 'Seltzer' and not context.blueprint and context.chip_calculation ~= true then
                        if self.ability.extra - 1 <= 0 then
                            G.E_MANAGER:add_event(Event({
                                func = function()
                                    play_sound('tarot1')
                                    self.T.r = -0.2
                                    self:juice_up(0.3, 0.4)
                                    self.states.drag.is = true
                                    self.children.center.pinch.x = true
                                    G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.3, blockable = false,
                                        func = function()
                                                G.jokers:remove_card(self)
                                                self:remove()
                                                self = nil
                                            return true; end}))
                                    return true
                                end
                            }))
                            return {
                                message = localize('k_drank_ex'),
                                colour = G.C.FILTER
                            }
                        else
                            self.ability.extra = self.ability.extra - 1
                            return {
                                message = self.ability.extra..'',
                                colour = G.C.FILTER
                            }
                        end
                    end
                else
                        if self.ability.name == 'Loyalty Card' and context.chip_calculation ~= true then
                            self.ability.loyalty_remaining = (self.ability.extra.every-1-(G.GAME.hands_played - self.ability.hands_played_at_create))%(self.ability.extra.every+1)
                            if context.blueprint then
                                if self.ability.loyalty_remaining == self.ability.extra.every then
                                    return {
                                        message = localize{type='variable',key='a_xmult',vars={self.ability.extra.Xmult}},
                                        Xmult_mod = self.ability.extra.Xmult
                                    }
                                end
                            else
                                if self.ability.loyalty_remaining == 0 then
                                    local eval = function(card) return (card.ability.loyalty_remaining == 0) end
                                    juice_card_until(self, eval, true)
                                elseif self.ability.loyalty_remaining == self.ability.extra.every then
                                    return {
                                        message = localize{type='variable',key='a_xmult',vars={self.ability.extra.Xmult}},
                                        Xmult_mod = self.ability.extra.Xmult
                                    }
                                end
                            end
                        end
                        if self.ability.name ~= 'Seeing Double' and self.ability.x_mult > 1 and (self.ability.type == '' or next(context.poker_hands[self.ability.type])) then
                            return {
                                message = localize{type='variable',key='a_xmult',vars={self.ability.x_mult}},
                                colour = G.C.RED,
                                Xmult_mod = self.ability.x_mult
                            }
                        end
                        if self.ability.t_mult > 0 and next(context.poker_hands[self.ability.type]) then
                            return {
                                message = localize{type='variable',key='a_mult',vars={self.ability.t_mult}},
                                mult_mod = self.ability.t_mult
                            }
                        end
                        if self.ability.t_chips > 0 and next(context.poker_hands[self.ability.type]) then
                            return {
                                message = localize{type='variable',key='a_chips',vars={self.ability.t_chips}},
                                chip_mod = self.ability.t_chips
                            }
                        end
                        if self.ability.name == 'Half Joker' and #context.full_hand <= self.ability.extra.size then
                            return {
                                message = localize{type='variable',key='a_mult',vars={self.ability.extra.mult}},
                                mult_mod = self.ability.extra.mult
                            }
                        end
                        if self.ability.name == 'Abstract Joker' then
                            local x = 0
                            for i = 1, #G.jokers.cards do
                                if G.jokers.cards[i].ability.set == 'Joker' then x = x + 1 end
                            end
                            return {
                                message = localize{type='variable',key='a_mult',vars={x*self.ability.extra}},
                                mult_mod = x*self.ability.extra
                            }
                        end
                        if self.ability.name == 'Acrobat' and (G.GAME.current_round.hands_left == 0 or (G.GAME.current_round.hands_left == 1 and context.chip_calculation == true)) then
                            return {
                                message = localize{type='variable',key='a_xmult',vars={self.ability.extra}},
                                Xmult_mod = self.ability.extra
                            }
                        end
                        if self.ability.name == 'Mystic Summit' and G.GAME.current_round.discards_left == self.ability.extra.d_remaining then
                            return {
                                message = localize{type='variable',key='a_mult',vars={self.ability.extra.mult}},
                                mult_mod = self.ability.extra.mult
                            }
                        end
                        if self.ability.name == 'Misprint' then
                            local temp_Mult = pseudorandom('misprint', self.ability.extra.min, self.ability.extra.max)
                            return {
                                message = localize{type='variable',key='a_mult',vars={temp_Mult}},
                                mult_mod = temp_Mult
                            }
                        end
                        if self.ability.name == 'Banner' and G.GAME.current_round.discards_left > 0 then
                            return {
                                message = localize{type='variable',key='a_chips',vars={G.GAME.current_round.discards_left*self.ability.extra}},
                                chip_mod = G.GAME.current_round.discards_left*self.ability.extra
                            }
                        end
                        if self.ability.name == 'Stuntman' then
                            return {
                                message = localize{type='variable',key='a_chips',vars={self.ability.extra.chip_mod}},
                                chip_mod = self.ability.extra.chip_mod,
                            }
                        end
                        if self.ability.name == 'Matador' then
                            if G.GAME.blind.triggered and context.chip_calculation ~= true then
                                ease_dollars(self.ability.extra)
                                G.GAME.dollar_buffer = (G.GAME.dollar_buffer or 0) + self.ability.extra
                                G.E_MANAGER:add_event(Event({func = (function() G.GAME.dollar_buffer = 0; return true end)}))
                                return {
                                    message = localize('$')..self.ability.extra,
                                    dollars = self.ability.extra,
                                    colour = G.C.MONEY
                                }
                            end
                        end
                        if self.ability.name == 'Supernova' then
                            return {
                                message = localize{type='variable',key='a_mult',vars={G.GAME.hands[context.scoring_name].played}},
                                mult_mod = G.GAME.hands[context.scoring_name].played
                            }
                        end
                        if self.ability.name == 'Ceremonial Dagger' and self.ability.mult > 0 then
                            return {
                                message = localize{type='variable',key='a_mult',vars={self.ability.mult}},
                                mult_mod = self.ability.mult
                            }
                        end
                        if self.ability.name == 'Vagabond' and #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit and context.chip_calculation ~= true then
                            if G.GAME.dollars <= self.ability.extra then
                                G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
                                G.E_MANAGER:add_event(Event({
                                    trigger = 'before',
                                    delay = 0.0,
                                    func = (function()
                                            local card = create_card('Tarot',G.consumeables, nil, nil, nil, nil, nil, 'vag')
                                            card:add_to_deck()
                                            G.consumeables:emplace(card)
                                            G.GAME.consumeable_buffer = 0
                                        return true
                                    end)}))
                                return {
                                    message = localize('k_plus_tarot'),
                                    card = self
                                }
                            end
                        end
                        if self.ability.name == 'Superposition' and #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit and context.chip_calculation ~= true then
                            local aces = 0
                            for i = 1, #context.scoring_hand do
                                if context.scoring_hand[i]:get_id() == 14 then aces = aces + 1 end
                            end
                            if aces >= 1 and next(context.poker_hands["Straight"]) then
                                local card_type = 'Tarot'
                                G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
                                G.E_MANAGER:add_event(Event({
                                    trigger = 'before',
                                    delay = 0.0,
                                    func = (function()
                                            local card = create_card(card_type,G.consumeables, nil, nil, nil, nil, nil, 'sup')
                                            card:add_to_deck()
                                            G.consumeables:emplace(card)
                                            G.GAME.consumeable_buffer = 0
                                        return true
                                    end)}))
                                return {
                                    message = localize('k_plus_tarot'),
                                    colour = G.C.SECONDARY_SET.Tarot,
                                    card = self
                                }
                            end
                        end
                        if self.ability.name == 'Seance' and #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit and context.chip_calculation ~= true then
                            if next(context.poker_hands[self.ability.extra.poker_hand]) then
                                G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
                                G.E_MANAGER:add_event(Event({
                                    trigger = 'before',
                                    delay = 0.0,
                                    func = (function()
                                            local card = create_card('Spectral',G.consumeables, nil, nil, nil, nil, nil, 'sea')
                                            card:add_to_deck()
                                            G.consumeables:emplace(card)
                                            G.GAME.consumeable_buffer = 0
                                        return true
                                    end)}))
                                return {
                                    message = localize('k_plus_spectral'),
                                    colour = G.C.SECONDARY_SET.Spectral,
                                    card = self
                                }
                            end
                        end
                        if self.ability.name == 'Flower Pot' then
                            local suits = {
                                ['Hearts'] = 0,
                                ['Diamonds'] = 0,
                                ['Spades'] = 0,
                                ['Clubs'] = 0
                            }
                            for i = 1, #context.scoring_hand do
                                if context.scoring_hand[i].ability.name ~= 'Wild Card' then
                                    if context.scoring_hand[i]:is_suit('Hearts', true) and suits["Hearts"] == 0 then suits["Hearts"] = suits["Hearts"] + 1
                                    elseif context.scoring_hand[i]:is_suit('Diamonds', true) and suits["Diamonds"] == 0  then suits["Diamonds"] = suits["Diamonds"] + 1
                                    elseif context.scoring_hand[i]:is_suit('Spades', true) and suits["Spades"] == 0  then suits["Spades"] = suits["Spades"] + 1
                                    elseif context.scoring_hand[i]:is_suit('Clubs', true) and suits["Clubs"] == 0  then suits["Clubs"] = suits["Clubs"] + 1 end
                                end
                            end
                            for i = 1, #context.scoring_hand do
                                if context.scoring_hand[i].ability.name == 'Wild Card' then
                                    if context.scoring_hand[i]:is_suit('Hearts') and suits["Hearts"] == 0 then suits["Hearts"] = suits["Hearts"] + 1
                                    elseif context.scoring_hand[i]:is_suit('Diamonds') and suits["Diamonds"] == 0  then suits["Diamonds"] = suits["Diamonds"] + 1
                                    elseif context.scoring_hand[i]:is_suit('Spades') and suits["Spades"] == 0  then suits["Spades"] = suits["Spades"] + 1
                                    elseif context.scoring_hand[i]:is_suit('Clubs') and suits["Clubs"] == 0  then suits["Clubs"] = suits["Clubs"] + 1 end
                                end
                            end
                            if suits["Hearts"] > 0 and
                            suits["Diamonds"] > 0 and
                            suits["Spades"] > 0 and
                            suits["Clubs"] > 0 then
                                return {
                                    message = localize{type='variable',key='a_xmult',vars={self.ability.extra}},
                                    Xmult_mod = self.ability.extra
                                }
                            end
                        end
                        if self.ability.name == 'Seeing Double' then
                            local suits = {
                                ['Hearts'] = 0,
                                ['Diamonds'] = 0,
                                ['Spades'] = 0,
                                ['Clubs'] = 0
                            }
                            for i = 1, #context.scoring_hand do
                                if context.scoring_hand[i].ability.name ~= 'Wild Card' then
                                    if context.scoring_hand[i]:is_suit('Hearts') then suits["Hearts"] = suits["Hearts"] + 1 end
                                    if context.scoring_hand[i]:is_suit('Diamonds') then suits["Diamonds"] = suits["Diamonds"] + 1 end
                                    if context.scoring_hand[i]:is_suit('Spades') then suits["Spades"] = suits["Spades"] + 1 end
                                    if context.scoring_hand[i]:is_suit('Clubs') then suits["Clubs"] = suits["Clubs"] + 1 end
                                end
                            end
                            for i = 1, #context.scoring_hand do
                                if context.scoring_hand[i].ability.name == 'Wild Card' then
                                    if context.scoring_hand[i]:is_suit('Clubs') and suits["Clubs"] == 0 then suits["Clubs"] = suits["Clubs"] + 1
                                    elseif context.scoring_hand[i]:is_suit('Diamonds') and suits["Diamonds"] == 0  then suits["Diamonds"] = suits["Diamonds"] + 1
                                    elseif context.scoring_hand[i]:is_suit('Spades') and suits["Spades"] == 0  then suits["Spades"] = suits["Spades"] + 1
                                    elseif context.scoring_hand[i]:is_suit('Hearts') and suits["Hearts"] == 0  then suits["Hearts"] = suits["Hearts"] + 1 end
                                end
                            end
                            if (suits["Hearts"] > 0 or
                            suits["Diamonds"] > 0 or
                            suits["Spades"] > 0) and
                            suits["Clubs"] > 0 then
                                return {
                                    message = localize{type='variable',key='a_xmult',vars={self.ability.extra}},
                                    Xmult_mod = self.ability.extra
                                }
                            end
                        end
                        if self.ability.name == 'Wee Joker' then
                            return {
                                message = localize{type='variable',key='a_chips',vars={self.ability.extra.chips}},
                                chip_mod = self.ability.extra.chips,
                                colour = G.C.CHIPS
                            }
                        end
                        if self.ability.name == 'Castle' and (self.ability.extra.chips > 0) then
                            return {
                                message = localize{type='variable',key='a_chips',vars={self.ability.extra.chips}},
                                chip_mod = self.ability.extra.chips,
                                colour = G.C.CHIPS
                            }
                        end
                        if self.ability.name == 'Blue Joker' and #G.deck.cards > 0 then
                            return {
                                message = localize{type='variable',key='a_chips',vars={self.ability.extra*#G.deck.cards}},
                                chip_mod = self.ability.extra*#G.deck.cards,
                                colour = G.C.CHIPS
                            }
                        end
                        if self.ability.name == 'Erosion' and (G.GAME.starting_deck_size - #G.playing_cards) > 0 then
                            return {
                                message = localize{type='variable',key='a_mult',vars={self.ability.extra*(G.GAME.starting_deck_size - #G.playing_cards)}},
                                mult_mod = self.ability.extra*(G.GAME.starting_deck_size - #G.playing_cards),
                                colour = G.C.MULT
                            }
                        end
                        if self.ability.name == 'Square Joker' then
                            return {
                                message = localize{type='variable',key='a_chips',vars={self.ability.extra.chips}},
                                chip_mod = self.ability.extra.chips,
                                colour = G.C.CHIPS
                            }
                        end
                        if self.ability.name == 'Runner' then
                            return {
                                message = localize{type='variable',key='a_chips',vars={self.ability.extra.chips}},
                                chip_mod = self.ability.extra.chips,
                                colour = G.C.CHIPS
                            }
                        end
                        if self.ability.name == 'Ice Cream' then
                            return {
                                message = localize{type='variable',key='a_chips',vars={self.ability.extra.chips}},
                                chip_mod = self.ability.extra.chips,
                                colour = G.C.CHIPS
                            }
                        end
                        if self.ability.name == 'Stone Joker' and self.ability.stone_tally > 0 then
                            return {
                                message = localize{type='variable',key='a_chips',vars={self.ability.extra*self.ability.stone_tally}},
                                chip_mod = self.ability.extra*self.ability.stone_tally,
                                colour = G.C.CHIPS
                            }
                        end
                        if self.ability.name == 'Steel Joker' and self.ability.steel_tally > 0 then
                            return {
                                message = localize{type='variable',key='a_xmult',vars={1 + self.ability.extra*self.ability.steel_tally}},
                                Xmult_mod = 1 + self.ability.extra*self.ability.steel_tally,
                                colour = G.C.MULT
                            }
                        end
                        if self.ability.name == 'Bull' and (G.GAME.dollars + (G.GAME.dollar_buffer or 0)) > 0 then
                            return {
                                message = localize{type='variable',key='a_chips',vars={self.ability.extra*math.max(0,(G.GAME.dollars + (G.GAME.dollar_buffer or 0))) }},
                                chip_mod = self.ability.extra*math.max(0,(G.GAME.dollars + (G.GAME.dollar_buffer or 0))),
                                colour = G.C.CHIPS
                            }
                        end
                        if self.ability.name == "Driver's License" then
                            if (self.ability.driver_tally or 0) >= 16 then
                                return {
                                    message = localize{type='variable',key='a_xmult',vars={self.ability.extra}},
                                    Xmult_mod = self.ability.extra
                                }
                            end
                        end
                        if self.ability.name == "Blackboard" then
                            local black_suits, all_cards = 0, 0
                            for k, v in ipairs(G.hand.cards) do
                                all_cards = all_cards + 1
                                if v:is_suit('Clubs', nil, true) or v:is_suit('Spades', nil, true) then
                                    black_suits = black_suits + 1
                                end
                            end
                            if black_suits == all_cards then
                                return {
                                    message = localize{type='variable',key='a_xmult',vars={self.ability.extra}},
                                    Xmult_mod = self.ability.extra
                                }
                            end
                        end
                        if self.ability.name == "Joker Stencil" then
                            if (G.jokers.config.card_limit - #G.jokers.cards) > 0 then
                                return {
                                    message = localize{type='variable',key='a_xmult',vars={self.ability.x_mult}},
                                    Xmult_mod = self.ability.x_mult
                                }
                            end
                        end
                        if self.ability.name == 'Swashbuckler' and self.ability.mult > 0 then
                            return {
                                message = localize{type='variable',key='a_mult',vars={self.ability.mult}},
                                mult_mod = self.ability.mult
                            }
                        end
                        if self.ability.name == 'Joker' then
                            return {
                                message = localize{type='variable',key='a_mult',vars={self.ability.mult}},
                                mult_mod = self.ability.mult
                            }
                        end
                        if self.ability.name == 'Spare Trousers' and self.ability.mult > 0 then
                            return {
                                message = localize{type='variable',key='a_mult',vars={self.ability.mult}},
                                mult_mod = self.ability.mult
                            }
                        end
                        if self.ability.name == 'Ride the Bus' and self.ability.mult > 0 then
                            return {
                                message = localize{type='variable',key='a_mult',vars={self.ability.mult}},
                                mult_mod = self.ability.mult
                            }
                        end
                        if self.ability.name == 'Flash Card' and self.ability.mult > 0 then
                            return {
                                message = localize{type='variable',key='a_mult',vars={self.ability.mult}},
                                mult_mod = self.ability.mult
                            }
                        end
                        if self.ability.name == 'Popcorn' and self.ability.mult > 0 then
                            return {
                                message = localize{type='variable',key='a_mult',vars={self.ability.mult}},
                                mult_mod = self.ability.mult
                            }
                        end
                        if self.ability.name == 'Green Joker' and self.ability.mult > 0 then
                            return {
                                message = localize{type='variable',key='a_mult',vars={self.ability.mult}},
                                mult_mod = self.ability.mult + 1
                            }
                        end
                        if self.ability.name == 'Fortune Teller' and G.GAME.consumeable_usage_total and G.GAME.consumeable_usage_total.tarot > 0 then
                            return {
                                message = localize{type='variable',key='a_mult',vars={G.GAME.consumeable_usage_total.tarot}},
                                mult_mod = G.GAME.consumeable_usage_total.tarot
                            }
                        end
                        if self.ability.name == 'Gros Michel' then
                            return {
                                message = localize{type='variable',key='a_mult',vars={self.ability.extra.mult}},
                                mult_mod = self.ability.extra.mult,
                            }
                        end
                        if self.ability.name == 'Cavendish' then
                            return {
                                message = localize{type='variable',key='a_xmult',vars={self.ability.extra.Xmult}},
                                Xmult_mod = self.ability.extra.Xmult,
                            }
                        end
                        if self.ability.name == 'Red Card' and self.ability.mult > 0 then
                            return {
                                message = localize{type='variable',key='a_mult',vars={self.ability.mult}},
                                mult_mod = self.ability.mult
                            }
                        end
                        if self.ability.name == 'Card Sharp' and G.GAME.hands[context.scoring_name] and (G.GAME.hands[context.scoring_name].played_this_round > 1 or (G.GAME.hands[context.scoring_name].played_this_round == 1 and context.chip_calculation == true)) then
                            return {
                                message = localize{type='variable',key='a_xmult',vars={self.ability.extra.Xmult}},
                                Xmult_mod = self.ability.extra.Xmult,
                            }
                        end
                        if self.ability.name == 'Bootstraps' and math.floor((G.GAME.dollars + (G.GAME.dollar_buffer or 0))/self.ability.extra.dollars) >= 1 then
                            return {
                                message = localize{type='variable',key='a_mult',vars={self.ability.extra.mult*math.floor((G.GAME.dollars + (G.GAME.dollar_buffer or 0))/self.ability.extra.dollars)}},
                                mult_mod = self.ability.extra.mult*math.floor((G.GAME.dollars + (G.GAME.dollar_buffer or 0))/self.ability.extra.dollars)
                            }
                        end
                        if self.ability.name == 'Caino' and self.ability.caino_xmult > 1 then
                            return {
                                message = localize{type='variable',key='a_xmult',vars={self.ability.caino_xmult}},
                                Xmult_mod = self.ability.caino_xmult
                            }
                        end
                    end
                end
            end
        end
    end

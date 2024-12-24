exp_chips = SMODS.current_mod

exp_chips.save_config = function(self)
    SMODS.save_mod_config(self)
    exp_chips.num_calculations = self.config.number_of_chip_calculations
--     sendDebugMessage(exp_chips.num_calculations, "ExpectedChips")
--     sendDebugMessage("exp_chips.num_calculations: "..exp_chips.num_calculations, "ExpectedChips")
end

SMODS.Atlas({
    key = "modicon",
    path = "modicon.png",
    px = 128,
    py = 128
})

exp_chips:save_config()

exp_chips.config_tab = function()
    local option_cycle_list = {}
    for i=1,40 do
        table.insert(option_cycle_list, i)
    end

    return {n = G.UIT.ROOT,
        config = {
            r = 0.1,
            minw = 5,
            align = "cm",
            padding = 0.2,
            colour = G.C.BLACK
        },
        nodes = {
            create_option_cycle({
                    label = localize('num_calculations_text'),
                    scale = 0.8,
                    w = 8,
                    options = option_cycle_list,
                    opt_callback = 'expected_chips_select_num_calculations',
                    current_option = exp_chips.num_calculations
            }),
        }}
end


function G.FUNCS.expected_chips_select_num_calculations(num)
    exp_chips.config.number_of_chip_calculations = num.to_val
    exp_chips:save_config()
end

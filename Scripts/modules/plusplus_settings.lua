plusplus_pages = {
    {
        tab_name = "@{PLUSPLUS_SETTINGS_SENSING}",
        settings = {
        }
    }
}

function sensor:client_onTinker(character, state)
    if state then
        fprint({type = "interaction", func = "client_onTinker"}, "Interacted with sensor")
        gui.refresh(self, {is_open = true, is_refresh = true, page = "plusplus_settings"})
    end
end

function Key(msg, code)
	if client.console then return end
	if msg == LBUTTON_UP then
		if IsKeyDown(16) then
			client:Ping(Client.PING_DANGER,client.mousePosition)
		end
	elseif msg == KEY_UP and code == 16 then
		client:Ping(Client.PING_NORMAL,client.mousePosition)
	end
end	

script:RegisterEvent(EVENT_KEY,Key)

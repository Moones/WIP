function Key(msg, code)
	if msg and code then
		print(msg, code)
	elseif msg then
		print(msg)
	elseif code then
		print(code)
	end
end
script:RegisterEvent(EVENT_KEY, Key)

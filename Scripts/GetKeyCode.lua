require("libs.Utils")

function Key(msg, code)
	print(msg, code)
end

script:RegisterEvent(EVENT_KEY, Key)

Control:

IF:
(body is above top limit AND pitch is within controlled range)
OR
(body is below bottom limit AND pitch is within controlled range)
	THEN:
	IF: this is the first time
		THEN:
		-take raw angle as held value
		-prescribe restoring movement based on held value
		-'limit' switch ON
	ELSE:
		THEN:
		-continue movement based on the held angle
ELSE:
	THEN:
	-react() to flow
	-adhere to pitch limits
	-'limit' switch OFF

		

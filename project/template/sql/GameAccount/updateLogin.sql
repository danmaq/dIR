UPDATE		DIR_GAME_ACCOUNT
	SET		LOGIN_TIME	= NOW(),
			LOGIN_COUNT	= LOGIN_COUNT + 1
	WHERE	ID			= ?	AND
			USER_ID		= ?	AND
			GAME_ID		= ?;
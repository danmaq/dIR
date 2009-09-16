UPDATE		DIR_GAME_ACCOUNT
	SET		PASSWD			= ?,
			NICKNAME		= ?,
			INTRODUCTION	= ?,
			RENEW_TIME		= NOW(),
			NOTES			= ?
	WHERE	ID				= ?	AND
			USER_ID			= ?	AND
			GAME_ID			= ?;

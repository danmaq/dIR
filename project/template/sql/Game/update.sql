UPDATE		DIR_GAME
	SET		DEVCODE		= ?,
			TITLE		= ?,
			VALIDATOR	= ?,
			REG_BROWSER	= ?,
			NOTES		= ?
	WHERE	ID			= ? AND
			PUB_ID		= ?;

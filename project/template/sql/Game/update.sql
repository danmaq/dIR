UPDATE		DIR_GAME
	SET		DEVCODE		= ?,
			TITLE		= ?,
			VALIDATOR	= ?,
			REG_BROWSER	= ?,
			SCORENAME0	= ?,
			SCORENAME1	= ?,
			SCORENAME2	= ?,
			SCORENAME3	= ?,
			SCORENAME4	= ?,
			SCORENAME5	= ?,
			SCORENAME6	= ?,
			SCORENAME7	= ?,
			NOTES		= ?
	WHERE	ID			= ? AND
			PUB_ID		= ?;

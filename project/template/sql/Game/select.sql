SELECT			ID,
				PUB_ID,
				DEVCODE,
				TITLE,
				VALIDATOR,
				REG_BROWSER,
				SCORENAME0,
				SCORENAME1,
				SCORENAME2,
				SCORENAME3,
				SCORENAME4,
				SCORENAME5,
				SCORENAME6,
				SCORENAME7,
				UNIX_TIMESTAMP(REGIST_TIME)	AS REGIST_TIME,
				NOTES
	FROM		DIR_GAME
	ORDER BY	ID;

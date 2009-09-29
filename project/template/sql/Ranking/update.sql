UPDATE		DIR_RANKING
	SET		CAPTION		= ?,
			VIEW0		= ?,
			VIEW1		= ?,
			VIEW2		= ?,
			VIEW3		= ?,
			VIEW4		= ?,
			VIEW5		= ?,
			VIEW6		= ?,
			VIEW7		= ?,
			TOP_LIST	= ?
	WHERE	ID			= ? AND
			GAME_ID		= ?;

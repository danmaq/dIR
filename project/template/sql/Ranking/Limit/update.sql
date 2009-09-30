UPDATE		DIR_RANKING_LIMIT
	SET		TARGET_COL	= ?,
			THRESHOLD	= ?,
			LO_PASS		= ?,
			HI_PASS		= ?
	WHERE	ID			= ? AND
			RANK_ID		= ?;

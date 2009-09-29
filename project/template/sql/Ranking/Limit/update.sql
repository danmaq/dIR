UPDATE		DIR_RANKING_LIMIT
	SET		SCORE_COL	= ?,
			BORDER		= ?,
			LESS_GAP	= ?,
			MORE_GAP	= ?
	WHERE	ID			= ? AND
			RANK_ID		= ?;

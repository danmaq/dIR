INSERT INTO DIR_SCORE (
	GACCOUNT_ID,	PASSWD,	SCORE0,	SCORE1,			SCORE2,			SCORE3,			SCORE4,
	SCORE5,			SCORE6,	SCORE7,	REGIST_TIME,	REMOTE_ADDR,	REMOTE_HOST,	USER_AGENT
)
VALUES(
	?,				?,		?,		?,				?,				?,				?,
	?,				?,		?,		NOW(),			?,				?,				?
);

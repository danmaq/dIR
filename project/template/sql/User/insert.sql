INSERT INTO DIR_USER_ACCOUNT(
	ID,				PASSWD,		NICKNAME,	INTRODUCTION,
	REGIST_TIME,	RENEW_TIME,	LOGIN_TIME
)
VALUES (
	?,				?,			?,			?,
	NOW(),			NOW(),		NOW()
);

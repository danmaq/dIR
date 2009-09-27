SELECT			EMAIL,
				EMAIL_VALID,
				NOTIFY_SERVICE,
				NOTIFY_ADS,
				UNDELIVERABLE,
				UNIX_TIMESTAMP(REGIST_TIME)	AS REGIST_TIME
	FROM		DIR_USER_EMAIL
	WHERE		USER_ID = ?
	ORDER BY	EMAIL

CREATE TABLE DIR_M_GAME(
	ID			SMALLINT UNSIGNED	PRIMARY KEY AUTO_INCREMENT		COMMENT 'ゲームID',
	REG_BROWSER	BOOLEAN				NOT NULL DEFAULT TRUE			COMMENT 'Webブラウザから登録可能かどうか',
	DEVCODE		VARCHAR(255)		NOT NULL UNIQUE					COMMENT '固有コード',
	TITLE		VARCHAR(255)		NOT NULL						COMMENT 'タイトル',
	VALIDATOR	VARCHAR(255)		CHARACTER SET ascii NOT NULL	COMMENT '検証URL',
	NOTES		TEXT												COMMENT '備考'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT = '対象ゲームマスタ';

INSERT INTO DIR_M_GAME (REG_BROWSER, DEVCODE, TITLE, VALIDATOR) VALUES (TRUE,	'MK_B1',	'MAKIWARI-2K beta1',		'http://ir.danmaq.com/validator/nph-mk_b1.cgi');
INSERT INTO DIR_M_GAME (REG_BROWSER, DEVCODE, TITLE, VALIDATOR) VALUES (TRUE,	'MK_B2',	'Mk-IIK beta2',				'http://ir.danmaq.com/validator/nph-mk_b2.cgi');
INSERT INTO DIR_M_GAME (REG_BROWSER, DEVCODE, TITLE, VALIDATOR) VALUES (TRUE,	'CHOPPIN',	'牛チョップ',				'http://ir.danmaq.com/validator/nph-choppin.cgi');
INSERT INTO DIR_M_GAME (REG_BROWSER, DEVCODE, TITLE, VALIDATOR) VALUES (FALSE,	'BALL',		'赤い玉 青い玉 競走ゲーム',	'http://ir.danmaq.com/validator/nph-ball.cgi');

CREATE TABLE DIR_T_USER_ACCOUNT(
	ID				INTEGER UNSIGNED					PRIMARY KEY 				COMMENT 'ユーザID',
	PASSWD			VARCHAR(255) CHARACTER SET ascii	NOT NULL					COMMENT 'マスターパスワード',
	REGIST_TIME		TIMESTAMP							NOT NULL					COMMENT '登録日時',
	LOGIN_TIME		TIMESTAMP							NOT NULL					COMMENT '最終ログイン日時',
	LOGIN_COUNT		INTEGER	UNSIGNED					NOT NULL DEFAULT 0			COMMENT 'ログイン回数',
	NOTES			TEXT															COMMENT '備考'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT = 'ユーザマスターアカウント';

CREATE TABLE DIR_T_USER_EMAIL(
	USER_ID			INTEGER UNSIGNED					NOT NULL				COMMENT 'ユーザID',
	EMAIL			VARCHAR(255) CHARACTER SET ascii	NOT NULL UNIQUE			COMMENT 'メールアドレス',
	EMAIL_VALID		VARCHAR(255) CHARACTER SET ascii							COMMENT 'Eメール認証コード',
	NOTIFY_SERVICE	BOOLEAN								NOT NULL DEFAULT FALSE	COMMENT 'サービス内キャンペーンのメール通知有無',
	NOTIFY_ADS		BOOLEAN								NOT NULL DEFAULT FALSE	COMMENT 'その他danmaqの広告宣伝のメール通知有無',
	UNDELIVERABLE	TINYINT UNSIGNED					NOT NULL DEFAULT 0		COMMENT '不達カウント',
	PRIMARY KEY(USER_ID, EMAIL),
	FOREIGN KEY (USER_ID) REFERENCES DIR_T_USER_ACCOUNT(ID) ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT = 'ユーザマスターアカウントのメール情報';

CREATE TABLE IF NOT EXISTS DIR_T_USER_ADDITIONAL(
	USER_ID			INTEGER UNSIGNED	PRIMARY KEY				COMMENT 'ユーザID',
	NICKNAME		VARCHAR(255)		NOT NULL				COMMENT 'ニックネーム',
	INTRODUCTION	VARCHAR(255)		NOT NULL DEFAULT ''		COMMENT '自己紹介',
	RENEW_TIME		TIMESTAMP			NOT NULL				COMMENT '最終更新日時',
	NOTES			TEXT										COMMENT '備考',
	FOREIGN KEY (USER_ID) REFERENCES DIR_T_USER_ACCOUNT(ID) ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB CHARSET=utf8 COMMENT = 'ユーザマスターアカウントの付加情報';

CREATE TABLE DIR_T_GAME_ACCOUNT(
	ID				INTEGER UNSIGNED					NOT NULL UNIQUE AUTO_INCREMENT	COMMENT 'ゲームアカウントID',
	USER_ID			INTEGER UNSIGNED					NOT NULL						COMMENT 'ユーザID',
	GAME_ID			SMALLINT UNSIGNED					NOT NULL						COMMENT 'ゲームID',
	PASSWD			VARCHAR(255) CHARACTER SET ascii	NOT NULL						COMMENT 'ゲームパスワード',
	NICKNAME		VARCHAR(255)						NOT NULL						COMMENT 'ゲーム用ニックネーム',
	INTRODUCTION	VARCHAR(255)						NOT NULL						COMMENT '自己紹介',
	REGIST_TIME		TIMESTAMP							NOT NULL						COMMENT '登録日時',
	RENEW_TIME		TIMESTAMP							NOT NULL						COMMENT '最終更新日時',
	NOTES			TEXT																COMMENT '備考',
	PRIMARY KEY(USER_ID, GAME_ID),
	FOREIGN KEY (USER_ID) REFERENCES DIR_T_USER_ACCOUNT(ID) ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY (GAME_ID) REFERENCES DIR_M_GAME(ID) ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT = 'ゲーム用アカウント';

CREATE TABLE DIR_T_RIVAL(
	GACCOUNT_ID		INTEGER UNSIGNED	NOT NULL	COMMENT 'ゲームアカウントID',
	RIVAL_ID		INTEGER UNSIGNED	NOT NULL	COMMENT 'ライバルID',
	INTRODUCTION	VARCHAR(255)		NOT NULL	COMMENT '紹介文',
	PRIMARY KEY(GACCOUNT_ID, RIVAL_ID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT = 'ライバル一覧';

CREATE TABLE DIR_T_SCORE(
	ID			INTEGER UNSIGNED	PRIMARY KEY AUTO_INCREMENT							COMMENT 'スコアID',
	GACCOUNT_ID	INTEGER UNSIGNED	NOT NULL											COMMENT 'ゲームアカウントID',
	PASSWD		VARCHAR(255)		NOT NULL											COMMENT 'スコア登録パスワード',
	SCORE0		BIGINT UNSIGNED		NOT NULL DEFAULT 0									COMMENT 'スコア',
	SCORE1		BIGINT UNSIGNED		NOT NULL DEFAULT 0									COMMENT 'スコア',
	SCORE2		BIGINT UNSIGNED		NOT NULL DEFAULT 0									COMMENT 'スコア',
	SCORE3		INTEGER UNSIGNED	NOT NULL DEFAULT 0									COMMENT 'スコア',
	SCORE4		INTEGER UNSIGNED	NOT NULL DEFAULT 0									COMMENT 'スコア',
	SCORE5		INTEGER UNSIGNED	NOT NULL DEFAULT 0									COMMENT 'スコア',
	SCORE6		INTEGER UNSIGNED	NOT NULL DEFAULT 0									COMMENT 'スコア',
	SCORE7		INTEGER UNSIGNED	NOT NULL DEFAULT 0									COMMENT 'スコア',
	INJUSTICE	BOOLEAN				NOT NULL DEFAULT FALSE								COMMENT '不正フラグ',
	WITHDRAW	BOOLEAN				NOT NULL DEFAULT FALSE								COMMENT '非公開フラグ',
	REGIST_TIME	TIMESTAMP			NOT NULL											COMMENT '登録日時',
	REMOTE_ADDR	VARCHAR(15)			CHARACTER SET ascii NOT NULL DEFAULT '127.0.0.1'	COMMENT 'リモートIPアドレス',
	REMOTE_HOST	VARCHAR(255)		CHARACTER SET ascii									COMMENT 'リモートホスト',
	USER_AGENT	TEXT				CHARACTER SET ascii									COMMENT 'ユーザエージェント',
	NOTES		TEXT																	COMMENT '備考',
	FOREIGN KEY (GACCOUNT_ID) REFERENCES DIR_T_GAME_ACCOUNT(ID) ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT = 'スコア一覧';

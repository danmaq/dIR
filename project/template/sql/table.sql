CREATE TABLE DIR_SESSIONS(
	id			CHAR(32)	CHARACTER SET ascii PRIMARY KEY	COMMENT 'ID',
	a_session	TEXT		NOT NULL						COMMENT '内容'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='セッション保持用';

CREATE TABLE DIR_BATCH_REPORT(
	ID		SMALLINT UNSIGNED	PRIMARY KEY AUTO_INCREMENT	COMMENT 'レポートID',
	NAME	VARCHAR(255)		NOT NULL					COMMENT 'バッチ名',
	STATUS	TINYINT UNSIGNED	NOT NULL DEFAULT 0			COMMENT 'ステータスコード',
	STARTED	TIMESTAMP			NOT NULL					COMMENT '実行開始日時',
	ENDED	TIMESTAMP			NOT NULL					COMMENT '実行終了日時',
	NOTES	TEXT											COMMENT '詳細な報告'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='バッチ処理レポート';

CREATE TABLE DIR_USER_ACCOUNT(
	ID				INTEGER UNSIGNED				PRIMARY KEY 		COMMENT 'ユーザ マスター アカウントID',
	PASSWD			VARCHAR(40) CHARACTER SET ascii	NOT NULL			COMMENT 'マスターパスワード',
	NICKNAME		VARCHAR(255)					NOT NULL			COMMENT 'ニックネーム',
	INTRODUCTION	VARCHAR(255)					NOT NULL DEFAULT ''	COMMENT '自己紹介',
	REGIST_TIME		TIMESTAMP						NOT NULL			COMMENT '登録日時',
	RENEW_TIME		TIMESTAMP						NOT NULL			COMMENT '情報更新日時',
	LOGIN_TIME		TIMESTAMP						NOT NULL			COMMENT '最終ログイン日時',
	LOGIN_COUNT		INTEGER	UNSIGNED				NOT NULL DEFAULT 1	COMMENT 'ログイン回数',
	NOTES			TEXT												COMMENT '備考'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='ユーザ マスター アカウント';

INSERT INTO DIR_USER_ACCOUNT (ID, PASSWD, NICKNAME, INTRODUCTION, REGIST_TIME, RENEW_TIME, LOGIN_TIME) VALUES (
	1, 'raXrEvi4ffDyNnsVwVnWivkmzuY', 'Mc/まく', 'danmaq', '1999-05-01 00:00:00', '1999-05-01 00:00:00', NOW());

CREATE TABLE DIR_USER_EMAIL(
	USER_ID			INTEGER UNSIGNED					NOT NULL				COMMENT 'ユーザ マスター アカウントID',
	EMAIL			VARCHAR(255) CHARACTER SET ascii	NOT NULL UNIQUE			COMMENT 'メールアドレス',
	EMAIL_VALID		VARCHAR(255) CHARACTER SET ascii							COMMENT 'Eメール認証コード',
	NOTIFY_SERVICE	BOOLEAN								NOT NULL DEFAULT FALSE	COMMENT 'サービス内キャンペーンのメール通知有無',
	NOTIFY_ADS		BOOLEAN								NOT NULL DEFAULT FALSE	COMMENT 'その他danmaqの広告宣伝のメール通知有無',
	UNDELIVERABLE	TINYINT UNSIGNED					NOT NULL DEFAULT 0		COMMENT '不達カウント',
	REGIST_TIME		TIMESTAMP							NOT NULL				COMMENT '登録日時',
	PRIMARY KEY(USER_ID, EMAIL),
	FOREIGN KEY (USER_ID) REFERENCES DIR_USER_ACCOUNT(ID) ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='ユーザ マスター アカウントのメール情報';

INSERT INTO DIR_USER_EMAIL (USER_ID, EMAIL, NOTIFY_SERVICE, NOTIFY_ADS) VALUES (1, 'info@danmaq.com', TRUE, TRUE);

CREATE TABLE DIR_PUBLISHER(
	USER_ID		INTEGER UNSIGNED					PRIMARY KEY			COMMENT 'ユーザ マスター アカウントID',
	CO_NAME		VARCHAR(255)						NOT NULL			COMMENT '会社名・団体名',
	HEAD_NAME	VARCHAR(255)						NOT NULL			COMMENT '代表者名',
	URL			VARCHAR(255) CHARACTER SET ascii	NOT NULL			COMMENT 'WebページURL',
	COMMISSION	TINYINT	UNSIGNED					NOT NULL DEFAULT 0	COMMENT '権限レベル',
	REGIST_TIME	TIMESTAMP							NOT NULL			COMMENT '登録日時',
	NOTES		TEXT													COMMENT '備考',
	FOREIGN KEY (USER_ID) REFERENCES DIR_USER_ACCOUNT(ID) ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='ゲームパブリッシャー';

INSERT INTO DIR_PUBLISHER (USER_ID, CO_NAME, HEAD_NAME, URL, COMMISSION, REGIST_TIME) VALUES (
	1, 'danmaq', '野村 周平', 'http://danmaq.com/', 255, '1999-05-01 00:00:00');

CREATE TABLE DIR_GAME(
	ID			SMALLINT UNSIGNED					PRIMARY KEY AUTO_INCREMENT	COMMENT 'ゲームID',
	PUB_ID		INTEGER UNSIGNED					NOT NULL					COMMENT 'パブリッシャー ユーザ マスター アカウントID',
	DEVCODE		VARCHAR(255)						NOT NULL UNIQUE				COMMENT '固有コード',
	TITLE		VARCHAR(255)						NOT NULL					COMMENT 'タイトル',
	VALIDATOR	VARCHAR(255) CHARACTER SET ascii	NOT NULL					COMMENT '検証URL',
	REG_BROWSER	BOOLEAN								NOT NULL DEFAULT TRUE		COMMENT 'Webブラウザから登録可能かどうか',
	REGIST_TIME	TIMESTAMP							NOT NULL					COMMENT '登録日時',
	NOTES		TEXT															COMMENT '備考',
	FOREIGN KEY (PUB_ID) REFERENCES DIR_PUBLISHER(USER_ID) ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='対象ゲーム';

INSERT INTO DIR_GAME (PUB_ID, DEVCODE, TITLE, VALIDATOR, REG_BROWSER, REGIST_TIME) VALUES (1, 'MK_B1',		'MAKIWARI-2K beta1',		'http://ir.danmaq.com/validator/nph-mk_b1.cgi',		TRUE,	'1999-08-12 03:58:00');
INSERT INTO DIR_GAME (PUB_ID, DEVCODE, TITLE, VALIDATOR, REG_BROWSER, REGIST_TIME) VALUES (1, 'MK_B2',		'Mk-IIK beta2',				'http://ir.danmaq.com/validator/nph-mk_b2.cgi',		TRUE,	'1999-12-06 02:12:18');
INSERT INTO DIR_GAME (PUB_ID, DEVCODE, TITLE, VALIDATOR, REG_BROWSER, REGIST_TIME) VALUES (1, 'CHOPPIN',	'牛チョップ',				'http://ir.danmaq.com/validator/nph-choppin.cgi',	TRUE,	'2000-03-09 22:54:28');
INSERT INTO DIR_GAME (PUB_ID, DEVCODE, TITLE, VALIDATOR, REG_BROWSER, REGIST_TIME) VALUES (1, 'BALL',		'赤い玉 青い玉 競走ゲーム',	'http://ir.danmaq.com/validator/nph-ball.cgi',		FALSE,	NOW());

CREATE TABLE DIR_GAME_ACCOUNT(
	ID				INTEGER UNSIGNED				NOT NULL UNIQUE		COMMENT 'ゲームアカウントID',
	USER_ID			INTEGER UNSIGNED				NOT NULL			COMMENT 'ユーザ マスター アカウントID',
	GAME_ID			SMALLINT UNSIGNED				NOT NULL			COMMENT 'ゲームID',
	PASSWD			VARCHAR(40) CHARACTER SET ascii	NOT NULL			COMMENT 'ゲームパスワード',
	NICKNAME		VARCHAR(255)					NOT NULL			COMMENT 'ゲーム用ニックネーム',
	INTRODUCTION	VARCHAR(255)					NOT NULL			COMMENT '自己紹介',
	REGIST_TIME		TIMESTAMP						NOT NULL			COMMENT '登録日時',
	RENEW_TIME		TIMESTAMP						NOT NULL			COMMENT '最終更新日時',
	LOGIN_TIME		TIMESTAMP						NOT NULL			COMMENT '最終ログイン日時',
	LOGIN_COUNT		INTEGER	UNSIGNED				NOT NULL DEFAULT 1	COMMENT 'ログイン回数',
	NOTES			TEXT												COMMENT '備考',
	PRIMARY KEY(USER_ID, GAME_ID),
	FOREIGN KEY (USER_ID) REFERENCES DIR_USER_ACCOUNT(ID) ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY (GAME_ID) REFERENCES DIR_GAME(ID) ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='ゲーム用アカウント';

CREATE TABLE DIR_RIVAL(
	GACCOUNT_ID		INTEGER UNSIGNED	NOT NULL	COMMENT 'ゲームアカウントID',
	RIVAL_ID		INTEGER UNSIGNED	NOT NULL	COMMENT 'ライバルID',
	INTRODUCTION	VARCHAR(255)		NOT NULL	COMMENT '紹介文',
	REGIST_TIME		TIMESTAMP			NOT NULL	COMMENT '登録日時',
	PRIMARY KEY(GACCOUNT_ID, RIVAL_ID),
	FOREIGN KEY (GACCOUNT_ID) REFERENCES DIR_GAME_ACCOUNT(ID) ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY (RIVAL_ID) REFERENCES DIR_GAME_ACCOUNT(ID) ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='ライバル一覧';

CREATE TABLE DIR_SCORE(
	ID			INTEGER UNSIGNED					PRIMARY KEY AUTO_INCREMENT		COMMENT 'スコアID',
	GACCOUNT_ID	INTEGER UNSIGNED					NOT NULL						COMMENT 'ゲームアカウントID',
	PASSWD		VARCHAR(255) CHARACTER SET ascii	NOT NULL						COMMENT 'スコア登録パスワード',
	SCORE0		BIGINT UNSIGNED						NOT NULL DEFAULT 0				COMMENT 'スコア',
	SCORE1		BIGINT UNSIGNED						NOT NULL DEFAULT 0				COMMENT 'スコア',
	SCORE2		BIGINT UNSIGNED						NOT NULL DEFAULT 0				COMMENT 'スコア',
	SCORE3		BIGINT 								NOT NULL DEFAULT 0				COMMENT 'スコア',
	SCORE4		BIGINT 								NOT NULL DEFAULT 0				COMMENT 'スコア',
	SCORE5		INTEGER 							NOT NULL DEFAULT 0				COMMENT 'スコア',
	SCORE6		INTEGER 							NOT NULL DEFAULT 0				COMMENT 'スコア',
	SCORE7		INTEGER 							NOT NULL DEFAULT 0				COMMENT 'スコア',
	INJUSTICE	BOOLEAN								NOT NULL DEFAULT FALSE			COMMENT '不正フラグ',
	WITHDRAW	BOOLEAN								NOT NULL DEFAULT FALSE			COMMENT '非公開フラグ',
	REGIST_TIME	TIMESTAMP							NOT NULL						COMMENT '登録日時',
	REMOTE_ADDR	VARCHAR(15) CHARACTER SET ascii		NOT NULL DEFAULT '127.0.0.1'	COMMENT 'リモートIPアドレス',
	REMOTE_HOST	VARCHAR(255) CHARACTER SET ascii									COMMENT 'リモートホスト',
	USER_AGENT	TEXT CHARACTER SET ascii											COMMENT 'ユーザエージェント',
	NOTES		TEXT																COMMENT '備考',
	FOREIGN KEY (GACCOUNT_ID) REFERENCES DIR_GAME_ACCOUNT(ID) ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='スコア一覧';

CREATE TABLE DIR_ACCESS(
	ID				INTEGER UNSIGNED					PRIMARY KEY AUTO_INCREMENT		COMMENT '履歴ID',
	USER_ID			INTEGER UNSIGNED					NOT NULL						COMMENT 'ユーザ マスター アカウントID',
	PAGE_NAME		VARCHAR(255) CHARACTER SET ascii	NOT NULL						COMMENT 'ページ名',
	PAGE_NUMBER		INTEGER																COMMENT 'ページ番号',
	REFERER			TEXT																COMMENT '前回表示したURL',
	CREATE_TIME		TIMESTAMP							NOT NULL						COMMENT '作成日時',
	REMOTE_ADDR		VARCHAR(15) CHARACTER SET ascii		NOT NULL DEFAULT '127.0.0.1'	COMMENT 'リモートIPアドレス',
	REMOTE_HOST		VARCHAR(255) CHARACTER SET ascii									COMMENT 'リモートホスト',
	USER_AGENT		TEXT CHARACTER SET ascii											COMMENT 'ユーザエージェント',
	NOTES			TEXT																COMMENT '備考'
	-- USER_IDはゲストの場合0になるので外部キー設定はしない
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='アクセス履歴';

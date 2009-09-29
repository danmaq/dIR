#===============================================================================
#	dIR - danmaq Internet Ranking CGI
#		(c)2009 danmaq All rights reserved.
#===============================================================================
#	定数の静的クラス。
package DIR::Const;
use 5.006;
use strict;
use warnings;
use utf8;

use constant MODE_RANK_TOP	=> 1;

use constant FILE_HTT_FRAME			=> 'html/frame.htt';
use constant FILE_HTT_MAINTENANCE	=> 'html/maintenance.htt';
use constant FILE_HTT_TOP			=> 'html/top.htt';

use constant FILE_SQL_DDL									=> 'sql/table.sql';
use constant FILE_SQL_NOWTIME								=> 'sql/nowTime.sql';
use constant FILE_SQL_ACCESS_INSERT							=> 'sql/Access/insert.sql';
use constant FILE_SQL_ACCESS_SELECT_FROM_ID					=> 'sql/Access/selectFromID.sql';
use constant FILE_SQL_ACCESS_SELECT_LAST_ID					=> 'sql/Access/selectLastID.sql';
use constant FILE_SQL_ACCESS_UPDATE							=> 'sql/Access/update.sql';
use constant FILE_SQL_ACCESS_UPDATE_CLEAR_UID				=> 'sql/Access/updateClearUID.sql';
use constant FILE_SQL_BATCHREPORT_INSERT					=> 'sql/BatchReport/insert.sql';
use constant FILE_SQL_BATCHREPORT_SELECT_FROMID				=> 'sql/BatchReport/selectFromID.sql';
use constant FILE_SQL_BATCHREPORT_SELECT_LASTID				=> 'sql/BatchReport/selectLastID.sql';
use constant FILE_SQL_BATCHREPORT_UPDATE_WITH_NOTES			=> 'sql/BatchReport/updateWithNotes.sql';
use constant FILE_SQL_BATCHREPORT_UPDATE_WITHOUT_NOTES		=> 'sql/BatchReport/updateWithoutNotes.sql';
use constant FILE_SQL_GAME_DELETE							=> 'sql/Game/delete.sql';
use constant FILE_SQL_GAME_DELETE_FROM_PID					=> 'sql/Game/deleteFromPID.sql';
use constant FILE_SQL_GAME_INSERT							=> 'sql/Game/insert.sql';
use constant FILE_SQL_GAME_SELECT							=> 'sql/Game/select.sql';
use constant FILE_SQL_GAME_SELECT_FROM_ID					=> 'sql/Game/selectFromID.sql';
use constant FILE_SQL_GAME_SELECT_FROM_UID					=> 'sql/Game/selectFromUID.sql';
use constant FILE_SQL_GAME_SELECT_LAST_ID					=> 'sql/Game/selectLastID.sql';
use constant FILE_SQL_GAME_UPDATE							=> 'sql/Game/update.sql';
use constant FILE_SQL_GAMEACCOUNT_DELETE					=> 'sql/GameAccount/delete.sql';
use constant FILE_SQL_GAMEACCOUNT_DELETE_FROM_GID			=> 'sql/GameAccount/deleteFromGID.sql';
use constant FILE_SQL_GAMEACCOUNT_DELETE_FROM_UID			=> 'sql/GameAccount/deleteFromUID.sql';
use constant FILE_SQL_GAMEACCOUNT_INSERT					=> 'sql/GameAccount/insert.sql';
use constant FILE_SQL_GAMEACCOUNT_SELECT_FROM_ID			=> 'sql/GameAccount/selectFromID.sql';
use constant FILE_SQL_GAMEACCOUNT_SELECT_GAME_AND_USER		=> 'sql/GameAccount/selectFromGameAndUser.sql';
use constant FILE_SQL_GAMEACCOUNT_UPDATE					=> 'sql/GameAccount/update.sql';
use constant FILE_SQL_GAMEACCOUNT_UPDATE_LOGIN				=> 'sql/GameAccount/updateLogin.sql';
use constant FILE_SQL_GAMEACCOUNT_RIVAL_DELETE				=> 'sql/GameAccount/Rival/delete.sql';
use constant FILE_SQL_GAMEACCOUNT_RIVAL_DELETE_FROM_GAID	=> 'sql/GameAccount/Rival/deleteFromGAID.sql';
use constant FILE_SQL_GAMEACCOUNT_RIVAL_INSERT				=> 'sql/GameAccount/Rival/insert.sql';
use constant FILE_SQL_GAMEACCOUNT_RIVAL_SELECT_FROM_ID		=> 'sql/GameAccount/Rival/select.sql';
use constant FILE_SQL_GAMEACCOUNT_RIVAL_SELECT_FROM_ID_BOTH	=> 'sql/GameAccount/Rival/selectFromBothID.sql';
use constant FILE_SQL_GAMEACCOUNT_RIVAL_UPDATE				=> 'sql/GameAccount/Rival/update.sql';
use constant FILE_SQL_RANKING_DELETE						=> 'sql/Ranking/delete.sql';
use constant FILE_SQL_RANKING_DELETE_FROM_GID				=> 'sql/Ranking/deleteFromGID.sql';
use constant FILE_SQL_RANKING_INSERT						=> 'sql/Ranking/insert.sql';
use constant FILE_SQL_RANKING_SELECT						=> 'sql/Ranking/select.sql';
use constant FILE_SQL_RANKING_SELECT_FROM_GID				=> 'sql/Ranking/selectFromGID.sql';
use constant FILE_SQL_RANKING_SELECT_LAST_ID				=> 'sql/Ranking/selectLastID.sql';
use constant FILE_SQL_RANKING_UPDATE						=> 'sql/Ranking/update.sql';
use constant FILE_SQL_RANKING_LIMIT_DELETE					=> 'sql/Ranking/Limit/delete.sql';
use constant FILE_SQL_RANKING_LIMIT_DELETE_FROM_RID			=> 'sql/Ranking/Limit/deleteFromRID.sql';
use constant FILE_SQL_RANKING_LIMIT_INSERT					=> 'sql/Ranking/Limit/insert.sql';
use constant FILE_SQL_RANKING_LIMIT_SELECT					=> 'sql/Ranking/Limit/select.sql';
use constant FILE_SQL_RANKING_LIMIT_SELECT_FROM_RID			=> 'sql/Ranking/Limit/selectFromRID.sql';
use constant FILE_SQL_RANKING_LIMIT_SELECT_LAST_ID			=> 'sql/Ranking/Limit/selectLastID.sql';
use constant FILE_SQL_RANKING_LIMIT_UPDATE					=> 'sql/Ranking/Limit/update.sql';
use constant FILE_SQL_RANKING_ORDER_DELETE					=> 'sql/Ranking/Order/delete.sql';
use constant FILE_SQL_RANKING_ORDER_DELETE_FROM_RID			=> 'sql/Ranking/Order/deleteFromRID.sql';
use constant FILE_SQL_RANKING_ORDER_INSERT					=> 'sql/Ranking/Order/insert.sql';
use constant FILE_SQL_RANKING_ORDER_SELECT					=> 'sql/Ranking/Order/select.sql';
use constant FILE_SQL_RANKING_ORDER_SELECT_FROM_RID			=> 'sql/Ranking/Order/selectFromRID.sql';
use constant FILE_SQL_RANKING_ORDER_SELECT_LAST_ID			=> 'sql/Ranking/Order/selectLastID.sql';
use constant FILE_SQL_RANKING_ORDER_UPDATE					=> 'sql/Ranking/Order/update.sql';
use constant FILE_SQL_SCORE_DELETE							=> 'sql/Score/delete.sql';
use constant FILE_SQL_SCORE_INSERT							=> 'sql/Score/insert.sql';
use constant FILE_SQL_SCORE_SELECT_FROM_ID					=> 'sql/Score/selectFromID.sql';
use constant FILE_SQL_SCORE_SELECT_LAST_ID					=> 'sql/Score/selectLastID.sql';
use constant FILE_SQL_SCORE_UPDATE							=> 'sql/Score/update.sql';
use constant FILE_SQL_USER_DELETE							=> 'sql/User/delete.sql';
use constant FILE_SQL_USER_INSERT							=> 'sql/User/insert.sql';
use constant FILE_SQL_USER_SELECT_FROMID					=> 'sql/User/selectFromID.sql';
use constant FILE_SQL_USER_UPDATE							=> 'sql/User/update.sql';
use constant FILE_SQL_USER_UPDATE_LOGIN						=> 'sql/User/updateLogin.sql';
use constant FILE_SQL_USER_EMAIL_DELETE						=> 'sql/User/EMail/delete.sql';
use constant FILE_SQL_USER_EMAIL_DELETE_FROM_UID			=> 'sql/User/EMail/deleteFromUID.sql';
use constant FILE_SQL_USER_EMAIL_INSERT						=> 'sql/User/EMail/insert.sql';
use constant FILE_SQL_USER_EMAIL_SELECT_FROM_URI			=> 'sql/User/EMail/selectFromEMail.sql';
use constant FILE_SQL_USER_EMAIL_SELECT_FROM_UID			=> 'sql/User/EMail/selectFromUID.sql';
use constant FILE_SQL_USER_EMAIL_UPDATE						=> 'sql/User/EMail/update.sql';
use constant FILE_SQL_USER_PUBLISHER_DELETE					=> 'sql/User/Publisher/delete.sql';
use constant FILE_SQL_USER_PUBLISHER_INSERT					=> 'sql/User/Publisher/insert.sql';
use constant FILE_SQL_USER_PUBLISHER_SELECT_FROM_UID		=> 'sql/User/Publisher/selectFromUID.sql';
use constant FILE_SQL_USER_PUBLISHER_UPDATE					=> 'sql/User/Publisher/update.sql';

$DIR::Const::VERSION = 0.01;	# バージョン情報

1;

__END__

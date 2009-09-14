#===============================================================================
#	dIR - danmaq Internet Ranking CGI
#		(c)2009 danmaq All rights reserved.
#===============================================================================
#	ゲーム情報のデータベース入出力クラス。
# ! NOTE : このクラスは、実質DIR::DBの一部として機能します。
package DIR::DB::Game;
use 5.006;
use strict;
use warnings;
use utf8;
use DBI qw(:sql_types);
use Exporter;
use Jcode;
use DIR::Template;
use DIR::Validate;

$DIR::DB::Game::VERSION = 0.01;	# バージョン情報

@DIR::DB::Game::ISA = qw(Exporter);
@DIR::DB::Game::EXPORT = qw(
	readGameFromID
	readGameFromUID
	writeGameInsert
	writeGameUpdate
);

#==========================================================
#==========================================================

#----------------------------------------------------------
# PUBLIC INSTANCE
#	ゲームIDからデータベース内のゲーム情報を検索します。
# PARAM NUM ゲームID
# RETURN \%(PUB_ID DEVCODE TITLE VALIDATOR REG_BROWSER REGIST_TIME NOTES)
#	団体名、代表者名、URL、権限レベル、登録日時、備考
sub readGameFromID{
	my $self = shift;
	my $id = shift;
	my $result = undef;
	if(defined($id) and $id){
		my $sql = $self->_execute(DIR::Template::FILE_SQL_GAME_SELECT_FROM_ID,
			{type => SQL_INTEGER, value => $id});
		if(ref($sql)){
			my $row = $sql->fetchrow_hashref();
			if(defined($row)){
				my $notes = $row->{NOTES};
				$result = {
					PUB_ID		=> $row->{PUB_ID},
					DEVCODE		=> $row->{DEVCODE},
					TITLE		=> Jcode->new($row->{TITLE}, 'utf8')->ucs2(),
					VALIDATOR	=> $row->{VALIDATOR},
					REG_BROWSER	=> $row->{REG_BROWSER},
					REGIST_TIME	=> $row->{REGIST_TIME},
					NOTES		=> defined($notes) ? Jcode->new($notes, 'utf8')->ucs2() : undef,
				};
			}
			$sql->finish();
		}
	}
	return $result;
}

#----------------------------------------------------------
# PUBLIC INSTANCE
#	ユーザ マスター アカウントIDからゲームIDを検索します。
# PARAM NUM ユーザ マスター アカウントID
# RETURN @NUM ゲームID
sub readGameFromUID{
	my $self = shift;
	my $uid = shift;
	my @result = ();
	if(defined($uid) and $uid){
		@result = $self->selectAllSingleColumn(DIR::Template::FILE_SQL_GAME_SELECT_FROM_UID,
			'ID', $uid);
	}
	return @result;
}

###########################################################

#----------------------------------------------------------
# PUBLIC INSTANCE
#	ゲーム情報をデータベースへ格納します。
# PARAM %(user_id dev_code title validator_uri registable_on_browser)
#	ユーザ マスター アカウントID、開発コード、タイトル、検証URL、Webブラウザから登録可能かどうか
# RETURN NUM ゲームID。失敗した場合、未定義値。
sub writeGameInsert{
	my $self = shift;
	my %args = @_;
	my $result = undef;
	if(
		DIR::Validate::isExistParameter(\%args,
			[qw(user_id dev_code title validator_uri registable_on_browser)], 1) and
		$self->dbi()->do(DIR::Template::get(DIR::Template::FILE_SQL_GAME_INSERT), undef, 
			$args{user_id}, $args{dev_code},
			Jcode->new($args{title}, 'ucs2')->utf8(),
			$args{validator_uri}, $args{registable_on_browser})
	){ $result = selectTableLastID(DIR::Template::FILE_SQL_GAME_SELECT_LAST_ID); }
	return $result;
}

#----------------------------------------------------------
# PUBLIC INSTANCE
#	ゲーム情報をデータベースへ格納します。
# PARAM %(id user_id dev_code title validator_uri registable_on_browser notes)
#	ゲームID、ユーザ マスター アカウントID、開発コード、タイトル、検証URL、Webブラウザから登録可能かどうか、備考
# RETURN BOOLEAN 成功した場合、真値。
sub writeGameUpdate{
	my $self = shift;
	my %args = @_;
	my $result = undef;
	if(
		DIR::Validate::isExistParameter(\%args, [qw(id user_id dev_code title validator_uri registable_on_browser)], 1) and
		DIR::Validate::isExistParameter(\%args, [qw(notes)])
	){
		my $notes = $args{notes};
		$result = $self->dbi()->do(DIR::Template::get(DIR::Template::FILE_SQL_GAME_UPDATE), undef,
			$args{dev_code},
			Jcode->new($args{title},				'ucs2')->utf8(),
			$args{validator_uri},
			$args{registable_on_browser},
			defined($notes) ? Jcode->new($notes,	'ucs2')->utf8() : undef,
			$args{id}, $args{user_id});
	}
	return $result;
}

1;

__END__

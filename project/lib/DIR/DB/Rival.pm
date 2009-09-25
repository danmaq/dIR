#===============================================================================
#	dIR - danmaq Internet Ranking CGI
#		(c)2009 danmaq All rights reserved.
#===============================================================================
#	ライバル情報のデータベース入出力クラス。
# ! NOTE : このクラスは、実質DIR::DBの一部として機能します。
package DIR::DB::Rival;
use 5.006;
use strict;
use warnings;
use utf8;
use DBI qw(:sql_types);
use Exporter;
use Jcode;
use DIR::Template;
use DIR::Validate;

$DIR::DB::Rival::VERSION = 0.01;	# バージョン情報

@DIR::DB::Rival::ISA = qw(Exporter);
@DIR::DB::Rival::EXPORT = qw(
	readRivalFromID
	readRivalFromBothID
	writeRivalInsert
	writeRivalUpdate
	eraseRival
	eraseRivalFromGameAccountID
);

#==========================================================
#==========================================================

#----------------------------------------------------------
# PUBLIC INSTANCE
#	ゲーム アカウントIDからデータベース内のライバル情報を検索します。
# PARAM NUM ゲーム アカウントID
# RETURN @\%(RIVAL_ID INTRODUCTION REGIST_TIME) ライバルのゲーム アカウントID、紹介文、登録日時
sub readRivalFromID{
	my $self = shift;
	my $id = shift;
	my @result = ();
	if(defined($id) and $id){
		my $sql = $self->_execute(DIR::Template::FILE_SQL_GAMEACCOUNT_RIVAL_SELECT_FROM_ID,
			{type => SQL_INTEGER, value => $id});
		if(ref($sql)){
			while(my $row = $sql->fetchrow_hashref()){
				push(@result, {
					RIVAL_ID		=> $row->{RIVAL_ID},
					INTRODUCTION	=> Jcode->new($row->{INTRODUCTION},	'utf8')->ucs2(),
					REGIST_TIME		=> $row->{REGIST_TIME}});
			}
			$sql->finish();
		}
	}
	return @result;
}

#----------------------------------------------------------
# PUBLIC INSTANCE
#	ゲーム アカウントIDからデータベース内のライバル情報を検索します。
# PARAM %(GACCOUNT_ID RIVAL_ID) ゲーム アカウントID、ライバルのゲーム アカウントID
# RETURN \%(INTRODUCTION REGIST_TIME) 紹介文、登録日時
sub readRivalFromBothID{
	my $self = shift;
	my %args = @_;
	my $result = undef;
	if(DIR::Validate::isExistParameter(\%args, [qw(GACCOUNT_ID RIVAL_ID)], 1, 1)){
		my $sql = $self->_execute(DIR::Template::FILE_SQL_GAMEACCOUNT_RIVAL_SELECT_FROM_ID_BOTH,
			{type => SQL_INTEGER, value => $args{GACCOUNT_ID}},
			{type => SQL_INTEGER, value => $args{RIVAL_ID}});
		if(ref($sql)){
			my $row = $sql->fetchrow_hashref();
			if(defined($row)){
				$result = {
					INTRODUCTION	=> Jcode->new($row->{INTRODUCTION},	'utf8')->ucs2(),
					REGIST_TIME		=> $row->{REGIST_TIME}};
			}
			$sql->finish();
		}
	}
	return $result;
}

###########################################################

#----------------------------------------------------------
# PUBLIC INSTANCE
#	データベースのライバル情報を更新します。
# PARAM %(GACCOUNT_ID RIVAL_ID INTRODUCTION)
#	紹介文、ゲーム アカウントID、ライバルのゲーム アカウントID
# RETURN BOOLEAN 成功した場合、真値。
sub writeRivalInsert{
	my $self = shift;
	my %args = @_;
	return (
		DIR::Validate::isExistParameter(\%args, [qw(INTRODUCTION GACCOUNT_ID RIVAL_ID)], 1) and
		$self->dbi()->do(DIR::Template::get(DIR::Template::FILE_SQL_GAMEACCOUNT_RIVAL_INSERT), undef,
			$args{GACCOUNT_ID}, $args{RIVAL_ID}, Jcode->new($args{INTRODUCTION}, 'ucs2')->utf8())
	);
}

###########################################################

#----------------------------------------------------------
# PUBLIC INSTANCE
#	データベースのライバル情報を更新します。
# PARAM %(INTRODUCTION GACCOUNT_ID RIVAL_ID)
#	紹介文、ゲーム アカウントID、ライバルのゲーム アカウントID
# RETURN BOOLEAN 成功した場合、真値。
sub writeRivalUpdate{
	my $self = shift;
	my %args = @_;
	return (
		DIR::Validate::isExistParameter(\%args, [qw(INTRODUCTION GACCOUNT_ID RIVAL_ID)], 1) and
		$self->dbi()->do(DIR::Template::get(DIR::Template::FILE_SQL_GAMEACCOUNT_RIVAL_UPDATE), undef,
			Jcode->new($args{INTRODUCTION}, 'ucs2')->utf8(), $args{GACCOUNT_ID}, $args{RIVAL_ID})
	);
}

###########################################################

#----------------------------------------------------------
# PUBLIC INSTANCE
#	ライバル情報をデータベースから抹消します。
# PARAM %(GACCOUNT_ID RIVAL_ID) ゲーム アカウントID、ライバルのゲーム アカウントID
# RETURN BOOLEAN 成功した場合、真値。
sub eraseRival{
	my $self = shift;
	my %args = @_;
	return (
		DIR::Validate::isExistParameter(\%args, [qw(GACCOUNT_ID RIVAL_ID)], 1, 1) and
		$self->dbi()->do(DIR::Template::get(DIR::Template::FILE_SQL_GAMEACCOUNT_RIVAL_DELETE), undef,
			$args{GACCOUNT_ID}, $args{RIVAL_ID})
	);
}

#----------------------------------------------------------
# PUBLIC INSTANCE
#	指定ゲーム アカウントIDを含むライバル情報をデータベースから抹消します。
# PARAM NUM ゲーム アカウントID
# RETURN BOOLEAN 成功した場合、真値。
sub eraseRivalFromGameAccountID{
	my $self = shift;
	my $id = shift;
	return (
		defined($id) and $id and
		$self->dbi()->do(DIR::Template::get(DIR::Template::FILE_SQL_GAMEACCOUNT_RIVAL_DELETE_FROM_GAID), undef,
			$id, $id)
	);
}

1;

__END__

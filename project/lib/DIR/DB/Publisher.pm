#===============================================================================
#	dIR - danmaq Internet Ranking CGI
#		(c)2009 danmaq All rights reserved.
#===============================================================================
#	パブリッシャー情報のデータベース入出力クラス。
# ! NOTE : このクラスは、実質DIR::DBの一部として機能します。
package DIR::DB::Publisher;
use 5.006;
use strict;
use warnings;
use utf8;
use DBI qw(:sql_types);
use Exporter;
use Jcode;
use DIR::Template;
use DIR::Validate;

$DIR::DB::Publisher::VERSION = 0.01;	# バージョン情報

@DIR::DB::Publisher::ISA = qw(Exporter);
@DIR::DB::Publisher::EXPORT = qw(
	readPublisherFromID
	readPublisherFromUID
	writePublisherInsert
	writePublisherUpdate
	erasePublisher
);

#==========================================================
#==========================================================

#----------------------------------------------------------
# PUBLIC INSTANCE
#	ユーザ マスター アカウントIDからデータベース内のパブリッシャー情報を検索します。
# PARAM NUM ユーザ マスター アカウントID
# RETURN \%(CO_NAME HEAD_NAME URL COMMISSION REGIST_TIME NOTES)
#	団体名、代表者名、URL、権限レベル、登録日時、備考
sub readPublisherFromUID{
	my $self = shift;
	my $uid = shift;
	my $result = undef;
	if(defined($uid) and $uid){
		my $sql = $self->_execute(DIR::Template::FILE_SQL_USER_PUBLISHER_SELECT_FROM_UID,
			{ type => SQL_INTEGER, value => $uid });
		if(ref($sql)){
			my $row = $sql->fetchrow_hashref();
			if(defined($row)){
				my $notes = $row->{NOTES};
				$result = {
					CO_NAME		=> Jcode->new($row->{CO_NAME},		'utf8')->ucs2(),
					HEAD_NAME	=> Jcode->new($row->{HEAD_NAME},	'utf8')->ucs2(),
					URL			=> $row->{URL},
					COMMISSION	=> $row->{COMMISSION},
					REGIST_TIME	=> $row->{REGIST_TIME},
					NOTES		=> defined($notes) ? Jcode->new($notes, 'utf8')->ucs2() : undef,
				};
			}
			$sql->finish();
		}
	}
	return $result;
}

###########################################################

#----------------------------------------------------------
# PUBLIC INSTANCE
#	パブリッシャー情報をデータベースへ格納します。
# PARAM %(uid co_name head_name uri)
#	ユーザ マスタ アカウントID、団体名、代表者名、URL
# RETURN BOOLEAN 成功した場合、真値。
sub writePublisherInsert{
	my $self = shift;
	my %args = @_;
	my $result = undef;
	if(DIR::Validate::isExistParameter(\%args, [qw(uid co_name head_name uri)], 1)){
		$result =
			$self->dbi()->do(DIR::Template::get(DIR::Template::FILE_SQL_USER_PUBLISHER_INSERT), undef,
				$args{uid},
				Jcode->new($args{co_name},		'ucs2')->utf8(),
				Jcode->new($args{head_name},	'ucs2')->utf8(),
				$args{uri});
	}
	return $result;
}

###########################################################

#----------------------------------------------------------
# PUBLIC INSTANCE
#	パブリッシャー情報をデータベースへ格納します。
# PARAM %(uid co_name head_name uri commision)
#	ユーザ マスタ アカウントID、団体名、代表者名、URL、権限レベル
# RETURN BOOLEAN 成功した場合、真値。
sub writePublisherUpdate{
	my $self = shift;
	my %args = @_;
	my $result = undef;
	if(DIR::Validate::isExistParameter(\%args, [qw(uid co_name head_name uri commision)], 1)){
		$result = 
			$self->dbi()->do(DIR::Template::get(DIR::Template::FILE_SQL_USER_PUBLISHER_UPDATE), undef,
				Jcode->new($args{co_name},		'ucs2')->utf8(),
				Jcode->new($args{head_name},	'ucs2')->utf8(),
				$args{uri}, $args{commision}, $args{uid});
	}
	return $result;
}

###########################################################

#----------------------------------------------------------
# PUBLIC INSTANCE
#	パブリッシャー アカウントをデータベースから抹消します。
# PARAM NUM ユーザ マスター アカウントID
# RETURN BOOLEAN 成功した場合、真値。
sub erasePublisher{
	my $self = shift;
	my $uid = shift;
	my $result = undef;
	if(defined($uid) and $uid){
		$result = $self->dbi()->do(
			DIR::Template::get(DIR::Template::FILE_SQL_USER_PUBLISHER_DELETE), undef, $uid);
	}
	return $result;
}

1;

__END__

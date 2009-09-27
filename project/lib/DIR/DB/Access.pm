#===============================================================================
#	dIR - danmaq Internet Ranking CGI
#		(c)2009 danmaq All rights reserved.
#===============================================================================
#	アクセスログ情報のデータベース入出力クラス。
# ! NOTE : このクラスは、実質DIR::DBの一部として機能します。
package DIR::DB::Access;
use 5.006;
use strict;
use warnings;
use utf8;
use DBI qw(:sql_types);
use Exporter;
use Jcode;
use DIR::Template;
use DIR::Validate;

$DIR::DB::Access::VERSION = 0.01;	# バージョン情報

@DIR::DB::Access::ISA = qw(Exporter);
@DIR::DB::Access::EXPORT = qw(
	readAccessFromID
	writeAccessInsert
	writeAccessUpdate
	writeAccessClearUID
);

#==========================================================
#==========================================================

#----------------------------------------------------------
# PUBLIC INSTANCE
#	アクセスログIDからデータベース内のアクセスログ情報を検索します。
# PARAM NUM アクセスログID
# RETURN \%(USER_ID PAGE_NAME PAGE_NUMBER REFERER CREATE_TIME REMOTE_ADDR REMOTE_HOST USER_AGENT NOTES)
#	ユーザID、ページ名、ページ番号、リファラ、作成日時、IPアドレス、リモートホスト、エージェント名、備考
sub readAccessFromID{
	my $self = shift;
	my $id = shift;
	my $result = undef;
	if(defined($id) and $id){
		my $sql = $self->_execute(DIR::Template::FILE_SQL_ACCESS_SELECT_FROM_ID,
		{ type => SQL_INTEGER, value => $id });
		if(ref($sql)){
			my $row = $sql->fetchrow_hashref();
			if(defined($row)){
				my $notes = $row->{NOTES};
				$result = {
					USER_ID		=> $row->{USER_ID},
					PAGE_NAME	=> $row->{PAGE_NAME},
					PAGE_NUMBER	=> $row->{PAGE_NUMBER},
					REFERER		=> $row->{REFERER},
					CREATE_TIME	=> $row->{CREATE_TIME},
					REMOTE_ADDR	=> $row->{REMOTE_ADDR},
					REMOTE_HOST	=> $row->{REMOTE_HOST},
					USER_AGENT	=> $row->{USER_AGENT},
					NOTES	=> defined($notes) ? Jcode->new($notes, 'utf8')->ucs2() : undef,
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
#	アクセスログをデータベースへ格納します。
# PARAM %(user_id page_name page_number referer remote_addr remote_host user_agent)
#	ユーザ マスター アカウントID、ページ名、ページ番号、
#	リファラ、IPアドレス、リモートホスト、エージェント名
# RETURN NUM アクセスログID。失敗した場合、未定義値。
sub writeAccessInsert{
	my $self = shift;
	my %args = @_;
	my $result = undef;
	if(
		DIR::Validate::isExistParameter(\%args, [qw(user_id page_name remote_addr)], 1) and
		DIR::Validate::isExistParameter(\%args, [qw(page_number referer remote_host user_agent)]) and
		$self->dbi()->do(DIR::Template::get(DIR::Template::FILE_SQL_ACCESS_INSERT), undef, 
			$args{user_id}, $args{page_name}, $args{page_number}, $args{referer},
			$args{remote_addr},$args{remote_host}, $args{user_agent})
	){ $result = $self->selectTableLastID(DIR::Template::FILE_SQL_ACCESS_SELECT_LAST_ID); }
	return $result;
}

###########################################################

#----------------------------------------------------------
# PUBLIC INSTANCE
#	データベースのアクセスログを更新します。
# PARAM %(id notes) アクセスログID、備考
# RETURN BOOLEAN 成功した場合、真値。
sub writeAccessUpdate{
	my $self = shift;
	my %args = @_;
	my $result = undef;
	if(
		DIR::Validate::isExistParameter(\%args, [qw(id)], 1) and
		DIR::Validate::isExistParameter(\%args, [qw(notes)])
	){
		$result = $self->dbi()->do(DIR::Template::get(DIR::Template::FILE_SQL_ACCESS_UPDATE), undef,
			Jcode->new($args{notes}, 'ucs2')->utf8(), $args{id});
	}
	return $result;
}

#----------------------------------------------------------
# PUBLIC INSTANCE
#	データベースのアクセスログからユーザ マスター アカウントIDを抹消します。
# PARAM NUM ユーザ マスター アカウントID
# RETURN BOOLEAN 成功した場合、真値。
sub writeAccessClearUID{
	my $self = shift;
	my $uid = shift;
	my $result = undef;
	if(defined($uid) and $uid){
		$result = $self->dbi()->do(
			DIR::Template::get(DIR::Template::FILE_SQL_ACCESS_UPDATE_CLEAR_UID), undef, $uid);
	}
	return $result;
}

1;

__END__
